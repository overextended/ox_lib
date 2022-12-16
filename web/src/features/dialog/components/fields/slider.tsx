import { Box, Slider, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { ISlider } from '../../../../interfaces/dialog';

interface Props {
  row: ISlider;
  index: number;
  handleChange: (value: number, index: number) => void;
}

const SliderField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default || props.row.min) props.handleChange(props.row.default || props.row.min!, props.index);
  }, []);

  const [sliderValue, setSliderValue] = useState(props.row.default || props.row.min || 0);

  return (
    <Box>
      <Text sx={{ fontSize: 14, fontWeight: 500 }}>{props.row.label}</Text>
      <Slider
        mb={10}
        onChangeEnd={(val: number) => props.handleChange(val, props.index)}
        onChange={(val: number) => setSliderValue(val)}
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
