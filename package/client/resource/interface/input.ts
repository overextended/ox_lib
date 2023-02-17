import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

// Should really be improved at some point to only display properties depending on the input type
interface InputDialogRowProps {
  type:
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
    | 'text-area';
  label: string;
  options?: { value: string; label: string; default?: string }[];
  password?: boolean;
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  placeholder?: string;
  default?: string | number;
  disabled?: boolean;
  checked?: boolean;
  min?: number;
  max?: number;
  autosize?: boolean;
  step?: number;
  required?: boolean;
  format?: string;
  description?: string;
}

type inputDialog = (
  heading: string,
  rows: string[] | InputDialogRowProps[],
  options: {
    allowCancel?: boolean;
  }
) => Promise<Array<string | number | boolean> | undefined>;
export const inputDialog: inputDialog = async (heading, rows) => await exports.ox_lib.inputDialog(heading, rows);

export const closeInputDialog = () => exports.ox_lib.inputDialog();
