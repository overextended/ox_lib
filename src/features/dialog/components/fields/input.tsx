import { createStyles, PasswordInput, TextInput } from '@mantine/core';
import React from 'react';
import { UseFormRegisterReturn } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { IInput } from '../../../../typings/dialog';

interface Props {
  register: UseFormRegisterReturn;
  row: IInput;
  index: number;
}

const useStyles = createStyles((theme) => ({
  eyeIcon: {
    color: 'rgba(255, 255, 255, 0.75)',
  },
  InputField: {
    color: 'rgba(255, 255, 255, 0.75)',
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
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
          icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          minLength={props.row.min}
          maxLength={props.row.max}
          disabled={props.row.disabled}
          withAsterisk={props.row.required}
          styles={{
            input: {
              color: 'rgba(255, 255, 255, 0.75)',
              backgroundColor: 'rgba(0, 0, 0, 0.75)',
              borderRadius: 8,
              borderColor: 'rgba(255, 255, 255, 0.15)',
              ':focus': {
                borderColor: 'rgb(194, 5, 5)',
              },
            },
          }}
        />
      ) : (
        <PasswordInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          description={props.row.description}
          icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          minLength={props.row.min}
          maxLength={props.row.max}
          disabled={props.row.disabled}
          withAsterisk={props.row.required}
          styles={{
            input: {
              color: 'rgba(255, 255, 255, 0.75)',
              backgroundColor: 'rgba(0, 0, 0, 0.75)',
              borderRadius: 8,
              borderColor: 'rgba(255, 255, 255, 0.15)',
              ':focus-within': {
                borderColor: 'rgb(194, 5, 5)',
              },
            },
            icon: {
              color: 'rgba(255, 255, 255, 0.75)',
            },
          }}
          visibilityToggleIcon={({ reveal, size }) => (
            <LibIcon
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
