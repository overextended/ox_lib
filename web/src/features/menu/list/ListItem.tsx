import { Box, Flex, Stack, Spacer, Text, IconProps } from "@chakra-ui/react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { forwardRef } from "react";
import type { MenuItem } from "./index";

interface Props {
  item: MenuItem;
  index: number;
  scrollIndex: number;
}

const ListItem = forwardRef<Array<HTMLDivElement | null>, Props>(({ item, index, scrollIndex }, ref) => {
  return (
    <Box
      bg="#25262B"
      borderRadius="md"
      tabIndex={index}
      scrollMargin={2}
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
      <Flex alignItems="center" height="100%">
        {item.icon && (
          <FontAwesomeIcon
            icon={item.icon}
            fontSize={24}
            color="#909296"
            fixedWidth
            style={{ marginRight: 20, marginLeft: 5 }}
          />
        )}
        {Array.isArray(item.values) ? (
          <Flex justifyContent="center" alignItems="center" width="100%">
            <Stack spacing={1}>
              <Text color="#909296" textTransform="uppercase" fontSize={12} verticalAlign="middle">
                {item.label}
              </Text>
              <Text>{item.values[scrollIndex]}</Text>
            </Stack>
            <Spacer />
            <Stack direction="row" spacing="sm" mr={3} justifyContent="center" alignItems="center">
              <FontAwesomeIcon icon="chevron-left" fontSize={16} color="#909296" />
              <Text color="#909296" textTransform="uppercase" fontSize={14}>
                {scrollIndex + 1}/{item.values.length}
              </Text>
              <FontAwesomeIcon icon="chevron-right" fontSize={16} color="#909296" />
            </Stack>
          </Flex>
        ) : (
          <Text>{item.label}</Text>
        )}
      </Flex>
    </Box>
  );
});

export default ListItem;
