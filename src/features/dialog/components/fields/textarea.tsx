import { Textarea } from '@mantine/core';
import React from 'react';
import { UseFormRegisterReturn } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { ITextarea } from '../../../../typings/dialog';

interface Props {
  register: UseFormRegisterReturn;
  row: ITextarea;
  index: number;
}

const TextareaField: React.FC<Props> = (props) => {
  return (
    <Textarea
      {...props.register}
      defaultValue={props.row.default}
      label={props.row.label}
      description={props.row.description}
      icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
      placeholder={props.row.placeholder}
      disabled={props.row.disabled}
      withAsterisk={props.row.required}
      autosize={props.row.autosize}
      minRows={props.row.min}
      maxRows={props.row.max}
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
    />
  );
};

export default TextareaField;
