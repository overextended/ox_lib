import { Box, Checkbox, HStack, Text } from '@chakra-ui/react';
import { useEffect } from 'react';
import { ICheckbox } from '../../../interfaces/dialog';
import InfoTooltip from './InfoTooltip';
import Label from './Label';

interface Props {
  row: ICheckbox;
  index: number;
  handleChange: (value: boolean, index: number) => void;
}

const CheckboxField: React.FC<Props> = (props) => {
  useEffect(() => {
    if (props.row.checked) props.handleChange(props.row.checked, props.index);
  }, []);

  return (
    <>
      <Box mb={3} key={`checkbox-${props.index}`}>
        <Checkbox
          onChange={(e: React.ChangeEvent<HTMLInputElement>) => props.handleChange(e.target.checked, props.index)}
          defaultChecked={props.row.checked}
        >
          <Label label={props.row.label} description={props.row.description} />
        </Checkbox>
      </Box>
    </>
  );
};

export default CheckboxField;
