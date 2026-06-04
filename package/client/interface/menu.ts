import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type MenuPosition = 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right';
type ChangeFunction = (selected: number, scrollIndex?: number, args?: any, checked?: boolean) => void;
type IconAnimation = 'spin' | 'spinPulse' | 'spinReverse' | 'pulse' | 'beat' | 'fade' | 'beatFade' | 'bounce' | 'shake';

interface MenuOptions {
  label: string;
  icon?: IconName | [IconPrefix, IconName] | string;
  iconColor?: string;
  iconAnimation?: IconAnimation;
  checked?: boolean;
  values?: Array<string | { label: string; description: string }>;
  description?: string;
  defaultIndex?: number;
  args?: Record<any, any>;
  close?: boolean;
}

interface MenuProps {
  id: string;
  title: string;
  options: MenuOptions[];
  position?: MenuPosition;
  disableInput?: boolean;
  canClose?: boolean;
  onClose?: (keyPressed?: 'Escape' | 'Backspace') => void;
  onSelected?: ChangeFunction;
  onSideScroll?: ChangeFunction;
  onCheck?: ChangeFunction;
  cb?: ChangeFunction;
}

type registerMenu = (data: MenuProps, cb: ChangeFunction) => void;
export const registerMenu: registerMenu = (data, cb) => exports.ox_lib.registerMenu(data, cb);

export const showMenu = (id: string): string => exports.ox_lib.showMenu(id);

export const hideMenu = (onExit: boolean): void => exports.ox_lib.hideMenu(onExit);

export const getOpenMenu = (): string | null => exports.ox_lib.getOpenMenu();

type setMenuOptions = (id: string, options: MenuOptions | MenuOptions[], index?: number) => void;
export const setMenuOptions: setMenuOptions = (id, options, index) => exports.ox_lib.setMenuOptions(id, options, index);
