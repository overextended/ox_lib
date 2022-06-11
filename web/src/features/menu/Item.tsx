import {
  Portal,
  Popover,
  PopoverTrigger,
  PopoverBody,
  PopoverContent,
  Box,
  Text,
  Flex,
  Spacer,
  Image,
} from "@chakra-ui/react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { Option, ContextMenuProps } from "../../interfaces/context";
import { fetchNui } from "../../utils/fetchNui";

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>("openContext", id);
};

const clickContext = (id: string) => {
  fetchNui("clickContext", id);
};

const Item: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  return (
    <>
      <Popover
        placement="right-start"
        trigger="hover"
        eventListeners={{ scroll: true }}
        isLazy
      >
        <PopoverTrigger>
          <Box
            bg="gray.800"
            borderRadius="md"
            h="fit-content"
            w="100%"
            p={2}
            mb={1}
            fontFamily="Poppins"
            fontSize="md"
            transition="300ms"
            _hover={{ bg: "gray.700" }}
          >
            <Flex
              w="100%"
              alignItems="center"
              onClick={() =>
                option[1].menu
                  ? openMenu(option[1].menu)
                  : clickContext(option[0])
              }
            >
              <Box>
                <Box paddingBottom={option[1].description ? 1 : 0}>
                  <Text w="100%" fontWeight="medium">
                    {option[1].title ? option[1].title : option[0]}
                  </Text>
                </Box>
                {option[1].description && (
                  <Box paddingBottom={1}>
                    <Text>{option[1].description}</Text>
                  </Box>
                )}
              </Box>
              {(option[1].menu || option[1].arrow) && (
                <>
                  <Spacer />
                  <Box
                    alignSelf="center"
                    justifySelf="center"
                    mr={4}
                    fontSize="xl"
                  >
                    <FontAwesomeIcon icon="chevron-right" />
                  </Box>
                </>
              )}
            </Flex>
            <Portal>
              {option[1].metadata && (
                <PopoverContent
                  fontFamily="Poppins"
                  bg="gray.800"
                  outline="none"
                  border="none"
                  w="fit-content"
                  maxW="2xs"
                >
                  <PopoverBody>
                    <>
                      {option[1].image && <Image src={option[1].image} />}
                      {Array.isArray(option[1].metadata) ? (
                        option[1].metadata.map(
                          (
                            metadata: string | { label: string; value: any },
                            index: number
                          ) => (
                            <Text key={`context-metadata-${index}`}>
                              {typeof metadata === "string"
                                ? `${metadata}`
                                : `${metadata.label}: ${metadata.value}`}
                            </Text>
                          )
                        )
                      ) : (
                        <>
                          {typeof option[1].metadata === "object" &&
                            Object.entries(option[1].metadata).map(
                              (metadata: { [key: string]: any }, index) => (
                                <Text key={`context-metadata-${index}`}>
                                  {metadata[0]}: {metadata[1]}
                                </Text>
                              )
                            )}
                        </>
                      )}
                    </>
                  </PopoverBody>
                </PopoverContent>
              )}
            </Portal>
          </Box>
        </PopoverTrigger>
      </Popover>
    </>
  );
};

export default Item;
