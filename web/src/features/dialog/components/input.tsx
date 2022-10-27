import { Box, InputGroup, InputLeftElement, InputRightElement, Input } from '@chakra-ui/react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useEffect } from 'react';
import { IInput } from '../../../interfaces/dialog';
import Label from './Label';

interface Props {
  row: IInput;
  index: number;
  handleChange: (value: string, index: number) => void;
  passwordStates: boolean[];
  handlePasswordStates: (index: number) => void;
}

const InputField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) props.handleChange(props.row.default, props.index);
  }, []);

  return (
    <>
      <Box mb={3} textAlign="left">
        <Label label={props.row.label} description={props.row.description} />
        <InputGroup>
          {props.row.icon && (
            <InputLeftElement pointerEvents="none" children={<FontAwesomeIcon icon={props.row.icon} fixedWidth />} />
          )}
          <Input
            onChange={(e: React.ChangeEvent<HTMLInputElement>) => props.handleChange(e.target.value, props.index)}
            placeholder={props.row.placeholder}
            defaultValue={props.row.default}
            type={!props.row.password || props.passwordStates[props.index] ? 'text' : 'password'}
            isDisabled={props.row.disabled}
          />
          {props.row.password && (
            <InputRightElement
              cursor="pointer"
              onClick={() => props.handlePasswordStates(props.index)}
              children={
                <FontAwesomeIcon
                  fixedWidth
                  icon={props.passwordStates[props.index] ? 'eye' : 'eye-slash'}
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
