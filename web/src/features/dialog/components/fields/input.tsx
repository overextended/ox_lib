import { createStyles, PasswordInput, TextInput } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React from 'react';
import { IInput } from '../../../../typings/dialog';
import { UseFormRegisterReturn } from 'react-hook-form';
import { fetchNui } from '../../../../utils/fetchNui';
import { Control, useController } from 'react-hook-form';
import { FormValues } from '../../InputDialog';

interface Props {
  register: UseFormRegisterReturn;
  row: IInput;
  index: number;
  control: Control<FormValues>;
}

const useStyles = createStyles((theme) => ({
  eyeIcon: {
    color: theme.colors.dark[2],
  },
}));

const InputField: React.FC<Props> = (props) => {
  const { classes } = useStyles();
  const HandleChange = (change?: any, data?: any) => {
    fetchNui('inputCallback', data);
    return change
  }; 
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    defaultValue: props.row.default,
    rules: { required: props.row.required },
  });
  return (
    <>
      {!props.row.password ? (
        <TextInput
          {...props.register}
          defaultValue={props.row.default}
          label={props.row.label}
          onChange={HandleChange(controller.field.onChange,{index: props.index, value: controller.field.value})}
          description={props.row.description}
          icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
          placeholder={props.row.placeholder}
          disabled={props.row.disabled}
          withAsterisk={props.row.required}
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
          withAsterisk={props.row.required}
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
