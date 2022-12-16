import { Select } from '@mantine/core';
import { useEffect } from 'react';
import { ISelect } from '../../../../interfaces/dialog';

interface Props {
  row: ISelect;
  index: number;
  handleChange: (value: string, index: number) => void;
}

// TODO: set label to value of value when there is no label provided
const SelectField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) {
      props.row.options?.map((option) => {
        if (props.row.default === option.value) {
          props.handleChange(option.value, props.index);
        }
      });
    }
  }, []);

  return (
    <Select
      onChange={(value) => props.handleChange(value as string, props.index)}
      defaultValue={props.row.default || ''}
      disabled={props.row.disabled}
      data={props.row.options}
      label={props.row.label}
      description={props.row.description}
    />
  );
};

export default SelectField;
