FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat python3 alpine-sdk
WORKDIR /app

# Install dependencies based on the preferred package manager
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile


# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Next.js collects completely anonymous telemetry data about general usage.
# Learn more here: https://nextjs.org/telemetry
# Uncomment the following line in case you want to disable telemetry during the build.
# ENV NEXT_TELEMETRY_DISABLED 1
ARG DATABASE_URL
ARG NEXT_PUBLIC_ROQ_CLIENT_ID
ARG NEXT_PUBLIC_ROQ_PLATFORM_URL
ARG NEXT_PUBLIC_SHOW_BRIEFING
ARG NEXT_PUBLIC_BASE_URL
ARG ROQ_BASE_URL
ARG ROQ_PLATFORM_URL
ARG ROQ_ENVIRONMENT_ID
ARG ROQ_API_KEY
ARG ROQ_SECRET
ARG ROQ_CLIENT_ID
ARG ROQ_CLIENT_SECRET
ARG ROQ_AUTH_CALLBACK_URL
ARG ROQ_AUTH_LOGIN_URL
ARG ROQ_AUTH_LOGOUT_URL
ARG ROQ_AUTH_URL
ARG SKIP_AUTHORIZATION
RUN yarn prisma generate && yarn build

# If using npm comment out above and use below instead
# RUN npm run build

# Production image, copy all the files and run next
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
# Uncomment the following line in case you want to disable telemetry during runtime.
# ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]