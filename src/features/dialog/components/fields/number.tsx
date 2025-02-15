import { NumberInput } from '@mantine/core';
import { Control, useController } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { INumber } from '../../../../typings/dialog';
import { FormValues } from '../../InputDialog';

interface Props {
  row: INumber;
  index: number;
  control: Control<FormValues>;
}

const NumberField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default,
    rules: { required: props.row.required, min: props.row.min, max: props.row.max },
  });

  return (
    <NumberInput
      value={controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={controller.field.onChange}
      label={props.row.label}
      description={props.row.description}
      defaultValue={props.row.default}
      min={props.row.min}
      max={props.row.max}
      step={props.row.step}
      precision={props.row.precision}
      disabled={props.row.disabled}
      icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
      withAsterisk={props.row.required}
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

export default NumberField;
