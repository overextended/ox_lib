import {
  Box,
  InputGroup,
  InputLeftElement,
  InputRightElement,
  Text,
  Input,
} from "@chakra-ui/react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { Row } from "../../../interfaces/dialog";

interface Props {
  row: Row;
  index: number;
  handleChange: (value: string | number | boolean, index: number) => void;
  passwordStates: boolean[];
  handlePasswordStates: (index: number) => void;
}

const InputField: React.FC<Props> = (props) => {
  return (
    <>
      <Box mb={3} textAlign="left">
        <Text>{props.row.label}</Text>
        <InputGroup>
          {props.row.icon && (
            <InputLeftElement
              pointerEvents="none"
              children={<FontAwesomeIcon icon={props.row.icon} />}
            />
          )}
          <Input
            onChange={(e) => props.handleChange(e.target.value, props.index)}
            type={
              !props.row.password || props.passwordStates[props.index]
                ? "text"
                : "password"
            }
          />
          {props.row.password && (
            <InputRightElement
              cursor="pointer"
              onClick={() => props.handlePasswordStates(props.index)}
              children={
                <FontAwesomeIcon
                  fixedWidth
                  icon={props.passwordStates[props.index] ? "eye" : "eye-slash"}
                  fontSize="1em"
                  style={{ paddingRight: 8 }}
                />
              }
            />
          )}
        </InputGroup>
      </Box>
    </>
  );
};

export default InputField;
