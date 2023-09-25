import { TextInput, createStyles } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import { ChangeEvent } from 'react';

interface Props {
  icon: IconProp;
  handleChange: (data: ChangeEvent<HTMLInputElement>) => void;
  value: string;
}

const useStyles = createStyles((theme, params: { canClose?: boolean }) => ({
  button: {
    borderRadius: 4,
    flex: '1 15%',
    alignSelf: 'stretch',
    height: 'auto',
    textAlign: 'center',
    justifyContent: 'center',
    padding: 2,
  },
  root: {
    border: 'none',
  },
  label: {
    color: params.canClose === false ? theme.colors.dark[2] : theme.colors.dark[0],
  },
}));

const SearchInput: React.FC<Props> = ({ icon, handleChange, value }) => {
  return (
    <TextInput
      value={value}
      icon={<FontAwesomeIcon icon={icon} fontSize={16} fixedWidth />}
      onChange={handleChange}
      placeholder="Filter"
    />
  );
};

export default SearchInput;
