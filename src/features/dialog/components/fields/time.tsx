import { TimeInput } from '@mantine/dates';
import { Control, useController } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { ITimeInput } from '../../../../typings/dialog';
import { FormValues } from '../../InputDialog';

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
      styles={{
        input: {
          color: 'rgba(255, 255, 255, 0.75)',
          backgroundColor: 'rgba(0, 0, 0, 0.75)',
          borderRadius: 8,
          borderColor: 'rgba(255, 255, 255, 0.15)',
          ':focus-within': {
            borderColor: 'rgb(194, 5, 5)',
          },
        },
        icon: {
          color: 'rgba(255, 255, 255, 0.75)',
        },
      }}
    />
  );
};

export default TimeField;
