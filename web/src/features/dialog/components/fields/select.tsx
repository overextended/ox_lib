import { Box, Select } from '@chakra-ui/react';
import { useEffect } from 'react';
import { ISelect } from '../../../../interfaces/dialog';

interface Props {
  row: ISelect;
  index: number;
  handleChange: (value: string, index: number) => void;
}

const SelectField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.default) {
      props.row.options?.map((option) => {
        if (props.row.default === option.value) {
          props.handleChange(option.value, props.index);
        }
      });
    }
  }, []);

  return (
    <>
      <Box mb={3} key={`select-${props.row.label}-${props.index}`}>
        <Select
          onChange={(e: React.ChangeEvent<HTMLSelectElement>) => props.handleChange(e.target.value, props.index)}
          defaultValue={props.row.default || ''}
          isDisabled={props.row.disabled}
        >
          {/* Hacky workaround for selectable placeholder issue */}
          {!props.row.default && (
            <option value="" hidden disabled>
              {props.row.label}
            </option>
          )}
          {props.row.options?.map((option, index) => (
            <option key={`option-${index}`} value={option.value}>
              {option.label || option.value}
            </option>
          ))}
        </Select>
      </Box>
    </>
  );
};

export default SelectField;
