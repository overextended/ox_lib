import { Box, Text, Slider, SliderTrack, SliderFilledTrack, SliderThumb, HStack, Tooltip } from '@chakra-ui/react';
import { useEffect, useState } from 'react';
import { ISlider } from '../../../interfaces/dialog';

interface Props {
  row: ISlider;
  index: number;
  handleChange: (value: number, index: number) => void;
}

const SliderField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) props.handleChange(props.row.default, props.index);
  }, []);

  const [sliderValue, setSliderValue] = useState(props.row.default || props.row.min || 0);

  return (
    <>
      <Box mb={3} key={`slider-${props.index}`}>
        <Text>{props.row.label}</Text>
        <Slider
          onChangeEnd={(val: number) => props.handleChange(val, props.index)}
          onChange={(val: number) => setSliderValue(val)}
          defaultValue={props.row.default || props.row.min || 0}
          min={props.row.min}
          max={props.row.max}
          step={props.row.step}
        >
          <SliderTrack>
            <SliderFilledTrack />
          </SliderTrack>
          <Tooltip hasArrow label={sliderValue} placement="bottom" gutter={10}>
            <SliderThumb />
          </Tooltip>
        </Slider>
        <HStack justifyContent="space-between">
          <Text fontSize="sm">{props.row.min || 0}</Text>
          <Text fontSize="sm">{props.row.max || 100}</Text>
        </HStack>
      </Box>
    </>
  );
};

export default SliderField;
