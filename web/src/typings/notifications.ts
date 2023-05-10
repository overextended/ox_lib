import { ToastPosition } from 'react-hot-toast';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { Sx } from '@mantine/core';

export interface NotificationProps {
  style?: Sx;
  description?: string;
  title?: string;
  duration?: number;
  icon?: IconProp;
  iconColor?: string;
  position?: ToastPosition | 'top' | 'bottom';
  id?: number | string;
  type?: string;
}
