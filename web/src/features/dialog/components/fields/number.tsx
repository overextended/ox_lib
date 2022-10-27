import {
  Box,
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
  InputLeftElement,
} from '@chakra-ui/react';
import { useEffect } from 'react';
import { INumber } from '../../../../interfaces/dialog';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import Label from '../Label';

interface Props {
  row: INumber;
  index: number;
  handleChange: (value: number, index: number) => void;
}

const NumberField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) props.handleChange(props.row.default, props.index);
  }, []);

  return (
    <Box mb={3}>
      <Label label={props.row.label} description={props.row.description} />
      <NumberInput
        onChange={(val: string) => props.handleChange(+val, props.index)}
        defaultValue={props.row.default}
        min={props.row.min}
        max={props.row.max}
        isDisabled={props.row.disabled}
      >
        {props.row.icon && (
          <InputLeftElement pointerEvents="none" children={<FontAwesomeIcon icon={props.row.icon} fixedWidth />} />
        )}
        <NumberInputField placeholder={props.row.placeholder} pl={props.row.icon ? '40px' : undefined} />
        <NumberInputStepper>
          <NumberIncrementStepper />
          <NumberDecrementStepper />
        </NumberInputStepper>
      </NumberInput>
    </Box>
  );
};

export default NumberField;
