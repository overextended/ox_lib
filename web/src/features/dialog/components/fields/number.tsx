import { NumberInput } from '@mantine/core';
import { INumber } from '../../../../typings/dialog';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Control, useController } from 'react-hook-form';
import { FormValues } from '../../InputDialog';
import { fetchNui } from '../../../../utils/fetchNui';

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
    rules: { required: props.row.required },
  });
  const HandleChange = (change?: any, data?: any) => {
    fetchNui('inputCallback', data);
    return change
  }; 
  return (
    <NumberInput
      value={controller.field.value}
      name={controller.field.name}
      ref={controller.field.ref}
      onBlur={controller.field.onBlur}
      onChange={HandleChange(controller.field.onChange,{index: props.index, value: controller.field.value})}
      label={props.row.label}
      description={props.row.description}
      defaultValue={props.row.default}
      min={props.row.min}
      max={props.row.max}
      disabled={props.row.disabled}
      icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
      withAsterisk={props.row.required}
    />
  );
};

export default NumberField;
