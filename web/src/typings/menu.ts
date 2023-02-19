import { IconProp } from '@fortawesome/fontawesome-svg-core';

export type MenuPosition = 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';

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
