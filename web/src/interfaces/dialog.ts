import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface IInput {
  type: 'input';
  label: string;
  placeholder?: string;
  default?: string;
  password?: boolean;
  icon?: IconProp;
}

export interface ICheckbox {
  type: 'checkbox';
  label: string;
  checked?: boolean;
}

export interface ISelect {
  type: 'select';
  label: string;
  default?: string;
  options?: { value: string; label?: string }[];
}

export interface INumber {
  type: 'number';
  label: string;
  placeholder?: string;
  default?: number;
  min?: number;
  max?: number;
}

export interface ISlider {
  type: 'slider';
  label: string;
  default?: number;
  min?: number;
  max?: number;
  step?: number;
}
