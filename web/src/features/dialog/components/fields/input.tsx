import { createStyles, PasswordInput, TextInput } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React, { useEffect } from 'react';
import { IInput } from '../../../../interfaces/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';

interface Props {
  register: UseFormRegisterReturn;
  row: IInput;
  index: number;
}

const useStyles = createStyles((theme) => ({
  eyeIcon: {
    color: theme.colors.dark[2],
  },
}));

const InputField: React.FC<Props> = (props) => {
  const { classes } = useStyles();

  return (
    <>
      {!props.row.password ? (
        <TextInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          description={props.row.description}
          icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          disabled={props.row.disabled}
        />
      ) : (
        <PasswordInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          description={props.row.description}
          icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          disabled={props.row.disabled}
          visibilityToggleIcon={({ reveal, size }) => (
            <FontAwesomeIcon
              icon={reveal ? 'eye-slash' : 'eye'}
              fontSize={size}
              cursor="pointer"
              className={classes.eyeIcon}
              fixedWidth
            />
          )}
        />
      )}
    </>
  );
};

export default InputField;
