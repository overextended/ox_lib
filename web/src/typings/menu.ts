import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { IconAnimation } from '../components/LibIcon';

export type MenuPosition = 'top-left' | 'top-center' | 'top-right' | 'center-left' | 'center' | 'center-right' | 'bottom-left' | 'bottom-center' | 'bottom-right';

export interface MenuItem {
  image?: string;
  label: string;
  progress?: number;
  colorScheme?: string;
  checked?: boolean;
  values?: Array<string | { label: string; description: string }>;
  description?: string;
  icon?: IconProp | string;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  defaultIndex?: number;
  close?: boolean;
}

export interface MenuSettings {
  position?: MenuPosition;
  title: string;
  canClose?: boolean;
  items: Array<MenuItem>;
  startItemIndex?: number;
}
