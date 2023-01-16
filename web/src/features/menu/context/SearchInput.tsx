import { Input } from '@chakra-ui/react';
import { Option } from '../../../interfaces/context';

const SearchInput: React.FC<{
  option: [string, Option];
  handleChange: (e: React.ChangeEvent<HTMLInputElement>) => void;
  search: string;
}> = ({ option, handleChange, search }) => {
  const placeholder = option[1].placeholder || 'Search';
  return <Input size="md" onChange={handleChange} value={search} placeholder={placeholder} />;
};

export default SearchInput;
