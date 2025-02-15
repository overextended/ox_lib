import { Checkbox } from '@mantine/core';
import { UseFormRegisterReturn } from 'react-hook-form';
import { ICheckbox } from '../../../../typings/dialog';

interface Props {
  row: ICheckbox;
  index: number;
  register: UseFormRegisterReturn;
}

const CheckboxField: React.FC<Props> = (props) => {
  return (
    <Checkbox
      {...props.register}
      sx={{ display: 'flex' }}
      required={props.row.required}
      label={props.row.label}
      defaultChecked={props.row.checked}
      disabled={props.row.disabled}
      styles={{
        label: { color: 'rgba(255, 255, 255, 0.75)' },
        input: {
          borderColor: 'rgba(255, 255, 255, 0.15)',
          backgroundColor: 'rgba(0, 0, 0, 0.75)',
          borderRadius: 4,
          ':focus': {
            borderColor: 'rgba(255, 113, 0, 0.75)',
            backgroundColor: 'rgba(0, 0, 0, 0.75)',
            outlineOffset: '2px',
            outline: '2px solid rgba(255, 113, 0, 0.75)',
          },
          ':checked': {
            backgroundColor: 'rgba(255, 113, 0, 0.75)',
            borderBlockColor: 'rgba(255, 113, 0, 0.75)',
            borderColor: 'rgba(255, 113, 0, 0.75)',
            color: 'rgba(255, 113, 0, 0.75)',
          },
        },
      }}
    />
  );
};

export default CheckboxField;
