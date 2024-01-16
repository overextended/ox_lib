import { ToastPosition } from 'react-hot-toast';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { Sx } from '@mantine/core';
import { IconAnimation } from '../components/LibIcon';

export interface NotificationProps {
  style?: Sx;
  description?: string;
  title?: string;
  duration?: number;
  icon?: IconProp;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  position?: ToastPosition | 'top' | 'bottom';
  id?: number | string;
  type?: string;
  alignIcon?: 'top' | 'center';
}
