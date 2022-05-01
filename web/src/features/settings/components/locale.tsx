import { HStack, Text, Select, Spacer } from "@chakra-ui/react";
import { useLocales } from "../../../providers/LocaleProvider";
import { fetchNui } from "../../../utils/fetchNui";

const LocaleSetting: React.FC<{
  languages: string[];
  selectValue: string;
  setSelectValue: React.Dispatch<React.SetStateAction<string>>;
}> = (props) => {
  const { locale } = useLocales();

  const handleChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    props.setSelectValue(e.target.value);
    fetchNui("getLocale", e.target.value);
  };

  return (
    <HStack spacing={5}>
      <Text>{locale.ui.settings.language}</Text>
      <Spacer />
      <Select
        onChange={(e) => handleChange(e)}
        value={props.selectValue}
        w={150}
      >
        {props.languages.map((language) => (
          <option key={language} value={language}>
            {language}
          </option>
        ))}
      </Select>
    </HStack>
  );
};

export default LocaleSetting;
