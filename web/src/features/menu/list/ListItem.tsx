import { Box, Flex, Stack, Text, Progress } from '@chakra-ui/react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import React, { forwardRef } from 'react';
import CustomCheckbox from './CustomCheckbox';
import type { MenuItem } from './index';

interface Props {
  item: MenuItem;
  index: number;
  scrollIndex: number;
  checked: boolean;
}

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex, checked }, ref) => {
  return (
    <Box
      bg="#25262B"
      borderRadius="md"
      tabIndex={index}
      scrollMargin={2}
      p={2}
      height="60px"
      key={`item-${index}`}
      _focus={{ bg: '#373A40', outline: 'none' }}
      ref={(element) => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element]);
      }}
    >
      <Flex alignItems="center" height="100%" gap="15px">
        {item.icon && (
          <Box display="flex" alignItems="center">
            <FontAwesomeIcon icon={item.icon} fontSize={24} color="#909296" fixedWidth />
          </Box>
        )}
        {Array.isArray(item.values) ? (
          <Flex alignItems="center" justifyContent="space-between" w="100%">
            <Stack spacing={1} justifyContent="space-between">
              <Text color="#909296" textTransform="uppercase" fontSize={12} verticalAlign="middle">
                {item.label}
              </Text>
              <Text>
                {typeof item.values[scrollIndex] === 'object'
                  ? // @ts-ignore for some reason even checking the type TS still thinks it's a string
                    item.values[scrollIndex].label
                  : item.values[scrollIndex]}
              </Text>
            </Stack>
            <Stack direction="row" spacing="sm" pr={3} justifyContent="center" alignItems="center">
              <FontAwesomeIcon icon="chevron-left" fontSize={16} color="#909296" />
              <Text color="#909296" textTransform="uppercase" fontSize={14}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <FontAwesomeIcon icon="chevron-right" fontSize={16} color="#909296" />
            </Stack>
          </Flex>
        ) : item.checked !== undefined ? (
          <Flex alignItems="center" justifyContent="space-between" w="100%">
            <Text>{item.label}</Text>
            <CustomCheckbox checked={checked}></CustomCheckbox>
          </Flex>
        ) : item.progress !== undefined ? (
          <Flex flexDirection="column" w="100%" marginRight="5px">
            <Text verticalAlign="middle" marginBottom="3px"> {item.label} </Text>
            <Progress value={item.progress} size="sm" colorScheme={item.colorScheme} borderRadius="md"/>
          </Flex>
        ) : (
          <Text>{item.label}</Text>
        )}
      </Flex>
    </Box>
  );
});

export default React.memo(ListItem);
