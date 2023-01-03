import { Select } from '@mantine/core';
import { ISelect } from '../../../../interfaces/dialog';
import { Control, FieldValues, useController, UseFormRegisterReturn, UseFormSetValue } from 'react-hook-form';
import { FormValues } from '../../InputDialog';

interface Props {
  row: ISelect;
  index: number;
  control: Control<FormValues>;
}

// TODO: set label to value of value when there is no label provided
const SelectField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default,
  });

  return (
    <Select
      data={props.row.options}
      value={controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={controller.field.onChange}
      disabled={props.row.disabled}
      label={props.row.label}
      description={props.row.description}
    />
  );
};

export default SelectField;
