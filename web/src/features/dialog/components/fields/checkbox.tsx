import { Checkbox } from '@mantine/core';
import { useEffect } from 'react';
import { ICheckbox } from '../../../../interfaces/dialog';

interface Props {
  row: ICheckbox;
  index: number;
  handleChange: (value: boolean, index: number) => void;
}

const CheckboxField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.checked) props.handleChange(props.row.checked, props.index);
  }, []);

  return (
    <Checkbox
      sx={{ display: 'flex' }}
      label={props.row.label}
      onChange={(e: React.ChangeEvent<HTMLInputElement>) => props.handleChange(e.target.checked, props.index)}
      defaultChecked={props.row.checked}
    />
  );
};

export default CheckboxField;
