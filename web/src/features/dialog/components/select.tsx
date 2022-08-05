import { Box, Select } from "@chakra-ui/react";
import { useEffect } from "react";
import { Row } from "../../../interfaces/dialog";

interface Props {
  row: Row;
  index: number;
  handleChange: (value: string | boolean, index: number) => void;
}

const SelectField: React.FC<Props> = (props) => {
  useEffect(() => {
    if(props.row.default) {
      props.row.options?.map((option) => {
        if(props.row.default === option.value) {
          props.handleChange(option.value, props.index);
        }
      });
    }
  }, []);

  return (
    <>
      <Box mb={3} key={`select-${props.index}`}>
        <Select
          onChange={(e) => props.handleChange(e.target.value, props.index)}
          defaultValue={props.row.default}
        >
          {/* Hacky workaround for selectable placeholder issue */}
          <option value="" selected hidden disabled>
            {props.row.label}
          </option>
          {props.row.options?.map((option, index) => (
            <option key={`option-${index}`} value={option.value}>
              {option.label ? option.label : option.value}
            </option>
          ))}
        </Select>
      </Box>
    </>
  );
};

export default SelectField;
