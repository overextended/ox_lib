import React from 'react';
import { ToastPosition } from 'react-hot-toast';
import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface NotificationProps {
  style?: React.CSSProperties;
  description?: string;
  title?: string;
  duration?: number;
  icon?: IconProp;
  iconColor?: string;
  position?: ToastPosition | 'top' | 'bottom';
  id?: number | string;
  type?: string;
}
