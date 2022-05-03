import { Box, Checkbox } from "@chakra-ui/react";
import { Row } from "../../../interfaces/dialog";

interface Props {
  row: Row;
  index: number;
  handleChange: (value: string | boolean, index: number) => void;
}

const CheckboxField: React.FC<Props> = (props) => {
  return (
    <>
      <Box mb={3} key={`checkbox-${props.index}`}>
        <Checkbox
          onChange={(e) => props.handleChange(e.target.checked, props.index)}
        >
          {props.row.label}
        </Checkbox>
      </Box>
    </>
  );
};

export default CheckboxField;
