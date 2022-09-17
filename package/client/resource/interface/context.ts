import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

interface ContextMenuItem {
  title?: string;
  menu?: string;
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  onSelect?: (args: any) => void;
  arrow?: boolean;
  description?: string;
  metadata?: string | { [key: string]: any } | string[];
  event?: string;
  serverEvent?: string;
  args?: any;
}

interface ContextMenuArrayItem extends ContextMenuItem {
  title: string;
}

interface ContextMenuProps {
  id: string;
  title: string;
  menu?: string;
  onExit?: () => void;
  canClose?: boolean;
  options: { [key: string]: ContextMenuItem } | ContextMenuArrayItem[];
}

type registerContext = (context: ContextMenuProps | ContextMenuProps[]) => void;
export const registerContext: registerContext = (context) => exports.ox_lib.registerContext(context);

export const showContext = (id: string): void => exports.ox_lib.showContext(id);

export const hideContext = (onExit: boolean): void => exports.ox_lib.hideContext(onExit);

export const getOpenContextMenu = (): string | null => exports.ox_lib.getOpenContextMenu();
