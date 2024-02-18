import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface RadialMenuItem {
  icon: string | IconProp;
  label: string;
  isMore?: boolean;
  menu?: string;
  iconWidth?: number;
  iconHeight?: number;
}
