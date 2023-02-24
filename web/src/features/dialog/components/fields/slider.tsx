import { Box, Slider, Text } from '@mantine/core';
import { ISlider } from '../../../../typings/dialog';
import { Control, useController } from 'react-hook-form';
import { fetchNui } from '../../../../utils/fetchNui';
import { FormValues } from '../../InputDialog';

interface Props {
  row: ISlider;
  index: number;
  control: Control<FormValues>;
}

const SliderField: React.FC<Props> = (props) => {
  const HandleChange = (change?: any, data?: any) => {
    fetchNui('inputCallback', data);
    return change
  }; 
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default || props.row.min || 0,
  });
  
  return (
    <Box>
      <Text sx={{ fontSize: 14, fontWeight: 500 }}>{props.row.label}</Text>
      <Slider
        mb={10}
        value={controller.field.value}
        name={controller.field.name}
        ref={controller.field.ref}
        onBlur={controller.field.onBlur}
        onChange={HandleChange(controller.field.onChange,{index: props.index, value: controller.field.value})}
        defaultValue={props.row.default || props.row.min || 0}
        min={props.row.min}
        max={props.row.max}
        step={props.row.step}
        disabled={props.row.disabled}
        marks={[
          { value: props.row.min || 0, label: props.row.min || 0 },
          { value: props.row.max || 100, label: props.row.max || 100 },
        ]}
      />
    </Box>
  );
};

export default SliderField;
