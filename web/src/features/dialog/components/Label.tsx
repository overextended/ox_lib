import { HStack, Text } from '@chakra-ui/react';
import InfoTooltip from './InfoTooltip';

const Label: React.FC<{ label: string; description?: string }> = ({ label, description }) => {
  return (
    <HStack spacing={1}>
      <Text>{label}</Text>
      {description && <InfoTooltip description={description} />}
    </HStack>
  );
};

export default Label;
