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
  HStack,
  Progress
} from '@chakra-ui/react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { Option, ContextMenuProps } from '../../../interfaces/context';
import { fetchNui } from '../../../utils/fetchNui';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: false });
};

const clickContext = (id: string) => {
  fetchNui('clickContext', id);
};

const Item: React.FC<{
  option: [string, Option];
}> = ({ option }) => {
  const button = option[1];
  const buttonKey = option[0];

  return (
    <>
      <Popover placement="right-start" trigger="hover" eventListeners={{ scroll: true }} isLazy>
        <PopoverTrigger>
          <Box
            bg={button.disabled ? 'gray.600' : 'gray.800'}
            borderRadius="md"
            h="fit-content"
            w="100%"
            p={2}
            mb={1}
            fontFamily="Poppins"
            fontSize="md"
            transition="300ms"
            _hover={{ bg: !button.disabled && 'gray.700' }}
            cursor={(button.disabled && 'not-allowed') || undefined}
          >
            <Flex
              w="100%"
              alignItems="center"
              color={button.disabled ? '#718096' : undefined}
              onClick={() =>
                !button.disabled ? (button.menu ? openMenu(button.menu) : clickContext(buttonKey)) : null
              }
            >
              {button?.icon && (
                <FontAwesomeIcon
                  fixedWidth
                  icon={button.icon}
                  fontSize={20}
                  style={{
                    marginRight: 10,
                    justifySelf: 'center',
                    color: button.iconColor,
                  }}
                />
              )}
              <Box w="100%">
                <Box>
                  <Text w="100%" fontWeight="medium" color={button.disabled ? '#718096' : undefined}>
                    {button.title ? button.title : buttonKey}
                  </Text>
                </Box>
                { button.description && (
                  <Box paddingBottom={1} color={button.disabled ? '#718096' : undefined} fontWeight="light">
                    <Text>{button.description}</Text>
                  </Box>
                )}
                { button?.progress && (
                    <Progress value={button.progress} size="sm" colorScheme={button.colorScheme || "gray"} borderRadius="md" marginRight="5px"/>
                )}
              </Box>
              {(button.menu || button.arrow) && button.arrow !== false && (
                <>
                  <Spacer />
                  <Box alignSelf="center" justifySelf="center" mr={4} fontSize="xl">
                    <FontAwesomeIcon icon="chevron-right" />
                  </Box>
                </>
              )}
            </Flex>
            <Portal>
              {!button.disabled && (button.metadata || button.image) && (
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
                      {button.image && <Image src={button.image} />}
                      {Array.isArray(button.metadata) ? (
                        button.metadata.map((metadata: string | { label: string; value: any }, index: number) => (
                          <Text key={`context-metadata-${index}`}>
                            {typeof metadata === 'string' ? `${metadata}` : `${metadata.label}: ${metadata.value}`}
                          </Text>
                        ))
                      ) : (
                        <>
                          {typeof button.metadata === 'object' &&
                            Object.entries(button.metadata).map((metadata: { [key: string]: any }, index) => (
                              <Text key={`context-metadata-${index}`}>
                                {metadata[0]}: {metadata[1]}
                              </Text>
                            ))}
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
