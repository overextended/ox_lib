import type { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

type Icon = IconName | [IconName, IconPrefix];

interface BaseInput {
  type?:
    | 'input'
    | 'number'
    | 'checkbox'
    | 'select'
    | 'multi-select'
    | 'slider'
    | 'color'
    | 'date'
    | 'date-range'
    | 'time'
    | 'textarea';
  label: string;
}

// Should really be improved at some point to only display properties depending on the input type
interface InputProps extends BaseInput {
  type?: 'input';
  description?: string;
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: string;
  password?: boolean;
  min?: number;
  max?: number;
}

interface NumberProps extends BaseInput {
  type: 'number';
  description?: string;
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: number;
  min?: number;
  max?: number;
  precision?: number;
  step?: number;
}

interface CheckboxProps extends BaseInput {
  type: 'checkbox';
  checked?: boolean;
  disabled?: boolean;
  required?: boolean;
}

interface SelectProps extends BaseInput {
  type: 'select' | 'multi-select';
  options: { value: string; label?: string }[];
  description?: string;
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: string | string[];
  clearable?: boolean;
  searchable?: boolean;
  maxSelectedValues?: number;
}

interface SliderProps extends BaseInput {
  type: 'slider';
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: number;
  min?: number;
  max?: number;
  step?: number;
}

interface ColorProps extends BaseInput {
  type: 'color';
  description?: string;
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: string;
  format?: 'hex' | 'hexa' | 'rgb' | 'rgba' | 'hsl' | 'hsla';
}

interface DateProps extends BaseInput {
  type: 'date';
  description?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: string | true;
  format?: string;
  returnString?: boolean;
  clearable?: boolean;
  min?: string;
  max?: string;
}

interface DateRangeProps extends BaseInput {
  type: 'date-range';
  description?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: [string, string];
  format?: string;
  returnString?: boolean;
  clearable?: boolean;
}

interface TimeProps extends BaseInput {
  type: 'time';
  description?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: string;
  format?: '12' | '24';
  clearable?: boolean;
}

interface TextAreaProps extends BaseInput {
  type: 'textarea';
  description?: string;
  placeholder?: string;
  icon?: Icon;
  required?: boolean;
  disabled?: boolean;
  default?: number;
  min?: number;
  max?: number;
  autosize?: boolean;
}

type RowInput =
  | InputProps
  | NumberProps
  | CheckboxProps
  | SelectProps
  | SliderProps
  | ColorProps
  | DateProps
  | DateRangeProps
  | TimeProps;

type inputDialog = (
  heading: string,
  rows: string[] | RowInput[],
  options: {
    allowCancel?: boolean;
  }
) => Promise<Array<string | number | boolean> | undefined>;
export const inputDialog: inputDialog = async (heading, rows, options) => await exports.ox_lib.inputDialog(heading, rows, options);

export const closeInputDialog = () => exports.ox_lib.closeInputDialog();
