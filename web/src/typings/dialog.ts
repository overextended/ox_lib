import { IconProp } from '@fortawesome/fontawesome-svg-core';

export interface InputProps {
  heading: string;
  rows: Array<IInput | ICheckbox | ISelect | INumber | ISlider | IColorInput | IDateInput | ITextarea | ITimeInput>;
  options?: {
    allowCancel?: boolean;
    size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  };
}

type BaseField<T, U> = {
  type: T;
  label: string;
  description?: string;
  placeholder?: string;
  default?: U;
  icon?: IconProp;
  disabled?: boolean;
  required?: boolean;
};

export interface IInput extends BaseField<'input', string> {
  password?: boolean;
  min?: number;
  max?: number;
}

export interface ICheckbox {
  type: 'checkbox';
  label: string;
  checked?: boolean;
  disabled?: boolean;
  required?: boolean;
}

export type OptionValue = { value: string; label?: string };
export interface ISelect extends BaseField<'select' | 'multi-select', string | string[]> {
  options: Array<OptionValue>;
  clearable?: boolean;
  searchable?: boolean;
  maxSelectedValues?: number;
}

export interface INumber extends BaseField<'number', number> {
  precision?: number;
  min?: number;
  max?: number;
  step?: number;
}

export interface ISlider extends Omit<BaseField<'slider', number>, 'description' | 'placeholder'> {
  min?: number;
  max?: number;
  step?: number;
}

export interface IColorInput extends BaseField<'color', string> {
  format?: 'hex' | 'hexa' | 'rgb' | 'rgba' | 'hsl' | 'hsla';
}

export interface IDateInput
  extends Omit<BaseField<'date' | 'date-range', string | [string, string] | true>, 'placeholder'> {
  format?: string;
  returnString?: boolean;
  clearable?: boolean;
  min?: string;
  max?: string;
}

export interface ITimeInput extends Omit<BaseField<'time', string>, 'placeholder'> {
  format?: '12' | '24';
  clearable?: boolean;
}

export interface ITextarea extends BaseField<'textarea', string> {
  autosize?: boolean;
  min?: number;
  max?: number;
  minLength?: number;
  maxLength?: number;
}
