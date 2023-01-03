import { TextInput } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React, { useEffect } from 'react';
import { IInput } from '../../../../interfaces/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';

interface Props {
  register: UseFormRegisterReturn;
  row: IInput;
  index: number;
  passwordStates: boolean[];
  handlePasswordStates: (index: number) => void;
}

const InputField: React.FC<Props> = (props) => {
  return (
    <TextInput
      {...props.register}
      defaultValue={props.row.default}
      label={props.row.label}
      description={props.row.description}
      icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
      placeholder={props.row.placeholder}
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
