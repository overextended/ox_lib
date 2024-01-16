import { TimeInput } from '@mantine/dates';
import { Control, useController } from 'react-hook-form';
import { ITimeInput } from '../../../../typings/dialog';
import { FormValues } from '../../InputDialog';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  row: ITimeInput;
  index: number;
  control: Control<FormValues>;
}

const TimeField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: { required: props.row.required },
  });

  return (
    <TimeInput
      value={controller.field.value ? new Date(controller.field.value) : controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={(date) => controller.field.onChange(date ? date.getTime() : null)}
      label={props.row.label}
      description={props.row.description}
      disabled={props.row.disabled}
      format={props.row.format || '12'}
      withAsterisk={props.row.required}
      clearable={props.row.clearable}
      icon={props.row.icon && <LibIcon fixedWidth icon={props.row.icon} />}
    />
  );
};

export default TimeField;
