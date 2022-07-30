import { Box, Text } from "@chakra-ui/react";

const Header: React.FC<{ title: string }> = ({ title }) => {
  return (
    <Box
      p={3}
      textAlign="center"
      borderTopLeftRadius="md"
      borderTopRightRadius="md"
      bg="#25262B"
      height="60px"
      width="sm"
    >
      <Text fontSize={24} textTransform="uppercase" fontWeight={600} fontFamily="Nunito">
        {title}
      </Text>
    </Box>
  );
};

export default Header;
