import { UserInterface } from 'interfaces/user';
import { MenuItemInterface } from 'interfaces/menu-item';
import { GetQueryInterface } from 'interfaces';

export interface OrderInterface {
  id?: string;
  wait_staff_id: string;
  menu_item_id: string;
  quantity: number;
  created_at?: any;
  updated_at?: any;

  user?: UserInterface;
  menu_item?: MenuItemInterface;
  _count?: {};
}

export interface OrderGetQueryInterface extends GetQueryInterface {
  id?: string;
  wait_staff_id?: string;
  menu_item_id?: string;
}
