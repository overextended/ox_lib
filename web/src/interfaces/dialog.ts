import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface IInput {
  type: 'input';
  label: string;
  placeholder?: string;
  default?: string;
  password?: boolean;
  icon?: IconProp;
  disabled?: boolean;
  description?: string;
  required?: boolean;
}

export interface ICheckbox {
  type: 'checkbox';
  label: string;
  checked?: boolean;
  disabled?: boolean;
  description?: string;
  required?: boolean;
}

export type OptionValue = { value: string; label?: string };
export interface ISelect {
  type: 'select' | 'multi-select';
  label: string;
  default?: string | string[];
  options: Array<OptionValue>;
  disabled?: boolean;
  description?: string;
  required?: boolean;
  clearable?: boolean;
  icon?: IconProp;
}

export interface INumber {
  type: 'number';
  label: string;
  placeholder?: string;
  default?: number;
  icon?: IconProp;
  min?: number;
  max?: number;
  disabled?: boolean;
  description?: string;
  required?: boolean;
}

export interface ISlider {
  type: 'slider';
  label: string;
  default?: number;
  min?: number;
  max?: number;
  step?: number;
  disabled?: boolean;
  description?: string;
}

export interface IColorInput {
  type: 'color';
  label: string;
  default?: string;
  disabled?: boolean;
  description?: string;
  format?: 'hex' | 'hexa' | 'rgb' | 'rgba' | 'hsl' | 'hsla';
  required?: boolean;
  icon?: IconProp;
}

export interface IDateInput {
  type: 'date' | 'date-range';
  label: string;
  default?: string | [string, string] | true;
  disabled?: boolean;
  description?: string;
  format?: '12' | '24' | undefined;
  required?: boolean;
  placeholder?: string;
  clearable?: boolean;
  min?: string;
  max?: string;
  icon?: IconProp;
}

export interface ITimeInput {
  type: 'time';
  label: string;
  default?: string;
  disabled?: boolean;
  description?: string;
  format?: '12' | '24';
  required?: boolean;
  clearable?: boolean;
  placeholder?: string;
  icon?: IconProp;
}

export interface ITextarea {
  type: 'textarea';
  label: string;
  default?: string;
  disabled?: boolean;
  description?: string;
  required?: boolean;
  placeholder?: string;
  icon?: IconProp;
  autosize?: boolean;
  min?: number;
  max?: number;
}
