import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface RadialMenuItem {
  icon: IconProp;
  label: string;
  isMore?: boolean;
  menu?: string;
}
