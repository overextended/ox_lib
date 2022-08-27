import {
  Box,
  Text,
  NumberInput,
  NumberInputField,
  NumberInputStepper,
  NumberIncrementStepper,
  NumberDecrementStepper,
} from "@chakra-ui/react";
import { useEffect } from "react";
import { INumber } from "../../../interfaces/dialog";

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
      <Text>{props.row.label}</Text>
      <NumberInput
        onChange={(val: string) => props.handleChange(+val, props.index)}
        defaultValue={props.row.default}
        min={props.row.min}
        max={props.row.max}
      >
        <NumberInputField placeholder={props.row.placeholder} />
        <NumberInputStepper>
          <NumberIncrementStepper />
          <NumberDecrementStepper />
        </NumberInputStepper>
      </NumberInput>
    </Box>
  );
};

export default NumberField;
