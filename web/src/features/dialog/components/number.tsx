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
import { Row } from "../../../interfaces/dialog";

interface Props {
  row: Row;
  index: number;
  handleChange: (value: string | number | boolean, index: number) => void;
}

const InputNumber: React.FC<Props> = (props) => {
  useEffect(() => {
    if(props.row.default) props.handleChange(props.row.default, props.index);
  }, []);

  return (
    <Box mb={3}>
      <Text>{props.row.label}</Text>
      <NumberInput onChange={(e) => props.handleChange(+e, props.index)} defaultValue={props.row.default}>
        <NumberInputField placeholder={props.row.placeholder} />
        <NumberInputStepper>
          <NumberIncrementStepper />
          <NumberDecrementStepper />
        </NumberInputStepper>
      </NumberInput>
    </Box>
  );
};

export default InputNumber;
