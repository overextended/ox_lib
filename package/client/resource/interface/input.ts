import { IconName, IconPrefix } from '@fortawesome/fontawesome-common-types';

interface InputDialogRowProps {
  type: 'input' | 'number' | 'checkbox' | 'select' | 'slider';
  label: string;
  options?: { value: string; label: string; default?: string }[];
  password?: boolean;
  icon?: IconName | [IconPrefix, IconName];
  iconColor?: string;
  placeholder?: string;
  default?: string | number;
  disabled?: boolean;
  readonly?: boolean;
  checked?: boolean;
  min?: number;
  max?: number;
  step?: number;
}

type inputDialog = (
  heading: string,
  rows: string[] | InputDialogRowProps[]
) => Promise<Array<string | number | boolean> | undefined>;
export const inputDialog: inputDialog = async (heading, rows) => await exports.ox_lib.inputDialog(heading, rows);

export const closeInputDialog = () => exports.ox_lib.inputDialog();
