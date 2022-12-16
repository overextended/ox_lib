import { TextInput } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { useEffect } from 'react';
import { IInput } from '../../../../interfaces/dialog';

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
    <TextInput
      label={props.row.label}
      description={props.row.description}
      icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
      placeholder={props.row.placeholder}
      defaultValue={props.row.default}
      disabled={props.row.disabled}
      type={!props.row.password || props.passwordStates[props.index] ? 'text' : 'password'}
      rightSection={
        props.row.password && (
          <FontAwesomeIcon
            onClick={() => props.handlePasswordStates(props.index)}
            cursor="pointer"
            icon={props.passwordStates[props.index] ? 'eye' : 'eye-slash'}
            fixedWidth
          />
        )
      }
    />
  );
};

export default InputField;
