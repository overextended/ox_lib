import { Checkbox } from '@mantine/core';
import { useEffect } from 'react';
import { ICheckbox } from '../../../../interfaces/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';

interface Props {
  row: ICheckbox;
  index: number;
  register: UseFormRegisterReturn;
}

const CheckboxField: React.FC<Props> = (props) => {
  return (
    <Checkbox {...props.register} sx={{ display: 'flex' }} label={props.row.label} defaultChecked={props.row.checked} />
  );
};

export default CheckboxField;
