import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

interface ContextMenuItem {
  menu?: string;
  title?: string;
  description?: string;
  arrow?: boolean;
  image?: string;
  icon?: IconName | [IconPrefix, IconName] | string;
  iconColor?: string;
  progress?: number;
  colorScheme?: string;
  onSelect?: (args: any) => void;
  metadata?: string[] | { [key: string]: any } | { label: string; value: any; progress?: number }[];
  disabled?: boolean;
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
  onBack?: () => void;
  canClose?: boolean;
  options: { [key: string]: ContextMenuItem } | ContextMenuArrayItem[];
}

type registerContext = (context: ContextMenuProps | ContextMenuProps[]) => void;
export const registerContext: registerContext = (context) => exports.ox_lib.registerContext(context);

export const showContext = (id: string): void => exports.ox_lib.showContext(id);

export const hideContext = (onExit: boolean): void => exports.ox_lib.hideContext(onExit);

export const getOpenContextMenu = (): string | null => exports.ox_lib.getOpenContextMenu();
