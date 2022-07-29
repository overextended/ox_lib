import { Box, Flex, Stack, Spacer, Text } from "@chakra-ui/react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { forwardRef } from "react";

interface Item {
  label: string;
  value: string | string[];
}

interface Props {
  item: Item;
  index: number;
  scrollIndex: number;
}

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex }, ref) => {
  return (
    <Box
      bg="#25262B"
      borderRadius="md"
      tabIndex={index}
      pointerEvents="none"
      p={2}
      height="60px"
      key={`item-${index}`}
      _focus={{ bg: "#373A40", outline: "none" }}
      ref={(element) => {
        if (ref)
          // @ts-ignore i cba
          return (ref.current = [...ref.current, element]);
      }}
    >
      {Array.isArray(item.value) ? (
        <Flex justifyContent="center" alignItems="center">
          <Stack spacing={1}>
            <Text color="#909296" textTransform="uppercase" fontSize={12} verticalAlign="middle">
              {item.label}
            </Text>
            <Text>{item.value[scrollIndex]}</Text>
          </Stack>
          <Spacer />
          <Stack direction="row" spacing="sm" mr={3}>
            <FontAwesomeIcon icon="chevron-left" fontSize={16} color="#909296" />
            <FontAwesomeIcon icon="chevron-right" fontSize={16} color="#909296" />
          </Stack>
        </Flex>
      ) : (
        <Flex alignItems="center" height="100%">
          <Text>{item.label}</Text>
        </Flex>
      )}
    </Box>
  );
});

export default ListItem;
