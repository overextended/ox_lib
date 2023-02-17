import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface Option {
  menu?: string;
  title?: string;
  description?: string;
  arrow?: boolean;
  image?: string;
  icon?: IconProp;
  iconColor?: string;
  progress?: number;
  colorScheme?: string;
  metadata?: string[] | { [key: string]: any } | { label: string; value: any; progress?: number }[];
  disabled?: boolean;
  event?: string;
  serverEvent?: string;
  args?: any;
}

export interface Options {
  [key: string]: Option;
}

export interface ContextMenuProps {
  title: string;
  menu?: string;
  canClose?: boolean;
  options: Options | Option[];
}
