import { DatePicker, DateRangePicker } from '@mantine/dates';
import { Control, useController } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { IDateInput } from '../../../../typings/dialog';
import { FormValues } from '../../InputDialog';

interface Props {
  row: IDateInput;
  index: number;
  control: Control<FormValues>;
}

const DateField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: { required: props.row.required, min: props.row.min, max: props.row.max },
  });

  return (
    <>
      {props.row.type === 'date' && (
        <DatePicker
          value={controller.field.value ? new Date(controller.field.value) : controller.field.value}
          name={controller.field.name}
          ref={controller.field.ref}
          onBlur={controller.field.onBlur}
          // Workaround to use timestamp instead of Date object in values
          onChange={(date) => controller.field.onChange(date ? date.getTime() : null)}
          label={props.row.label}
          description={props.row.description}
          placeholder={props.row.format}
          disabled={props.row.disabled}
          inputFormat={props.row.format}
          withAsterisk={props.row.required}
          clearable={props.row.clearable}
          icon={props.row.icon && <LibIcon fixedWidth icon={props.row.icon} />}
          minDate={props.row.min ? new Date(props.row.min) : undefined}
          maxDate={props.row.max ? new Date(props.row.max) : undefined}
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
      )}
      {props.row.type === 'date-range' && (
        <DateRangePicker
          value={
            controller.field.value
              ? controller.field.value[0]
                ? controller.field.value.map((date: Date) => new Date(date))
                : controller.field.value
              : controller.field.value
          }
          name={controller.field.name}
          ref={controller.field.ref}
          onBlur={controller.field.onBlur}
          onChange={(dates) =>
            controller.field.onChange(dates.map((date: Date | null) => (date ? date.getTime() : null)))
          }
          label={props.row.label}
          description={props.row.description}
          placeholder={props.row.format}
          disabled={props.row.disabled}
          inputFormat={props.row.format}
          withAsterisk={props.row.required}
          clearable={props.row.clearable}
          icon={props.row.icon && <LibIcon fixedWidth icon={props.row.icon} />}
          minDate={props.row.min ? new Date(props.row.min) : undefined}
          maxDate={props.row.max ? new Date(props.row.max) : undefined}
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
      )}
    </>
  );
};

export default DateField;
