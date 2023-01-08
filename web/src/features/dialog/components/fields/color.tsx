import { IColorInput } from '../../../../interfaces/dialog';
import { Control, useController } from 'react-hook-form';
import { FormValues } from '../../InputDialog';
import { ColorInput } from '@mantine/core';

interface Props {
  row: IColorInput;
  index: number;
  control: Control<FormValues>;
}

const ColorField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default,
  });

  return (
    <ColorInput
      withEyeDropper={false}
      value={controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={controller.field.onChange}
      label={props.row.label}
      description={props.row.description}
      disabled={props.row.disabled}
      defaultValue={props.row.default}
      format={props.row.format}
    />
  );
};

export default ColorField;
