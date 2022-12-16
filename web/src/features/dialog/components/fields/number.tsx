import { NumberInput } from '@mantine/core';
import { useEffect } from 'react';
import { INumber } from '../../../../interfaces/dialog';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

interface Props {
  row: INumber;
  index: number;
  handleChange: (value: number, index: number) => void;
}

const NumberField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) props.handleChange(props.row.default, props.index);
  }, []);

  return (
    <NumberInput
      label={props.row.label}
      description={props.row.description}
      defaultValue={props.row.default}
      min={props.row.min}
      max={props.row.max}
      disabled={props.row.disabled}
      onChange={(value) => props.handleChange(value as number, props.index)}
      icon={props.row.icon && <FontAwesomeIcon icon={props.row.icon} fixedWidth />}
    />
  );
};

export default NumberField;
