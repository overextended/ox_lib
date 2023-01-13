import { IDateInput } from '../../../../interfaces/dialog';
import { Control, useController } from 'react-hook-form';
import { FormValues } from '../../InputDialog';
import { DatePicker } from '@mantine/dates';

interface Props {
  row: IDateInput;
  index: number;
  control: Control<FormValues>;
}

const DateField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default && new Date(props.row.default),
    rules: { required: props.row.required },
  });

  return (
    <DatePicker
      value={controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={controller.field.onChange}
      label={props.row.label}
      description={props.row.description}
      placeholder={props.row.placeholder}
      disabled={props.row.disabled}
      inputFormat="DD/MM/YYYY"
      withAsterisk={props.row.required}
      clearable={props.row.clearable}
    />
  );
};

export default DateField;
