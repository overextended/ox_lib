import { Box, Text } from '@chakra-ui/react';
import React from 'react';

const Header: React.FC<{ title: string }> = ({ title }) => {
  return (
    <Box
      p={3}
      textAlign="center"
      borderTopLeftRadius="md"
      borderTopRightRadius="md"
      bg="#25262B"
      height="50px"
      width="sm"
    >
      <Text fontSize={20} fontWeight={600} fontFamily="Nunito">
        {title}
      </Text>
    </Box>
  );
};

export default React.memo(Header);
