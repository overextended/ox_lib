import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, Text, Flex, ScaleFade } from '@chakra-ui/react';
import { useEffect, useState } from 'react';
import { ContextMenuProps } from '../../../interfaces/context';
import Item from './Item';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const ContextMenu: React.FC = () => {
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });
  const [search, setSearch] = useState('');

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearch(e.target.value);
  };

  const filteredOptions = Object.entries(contextMenu.options).filter(
    ([key, option]) => {
      if (option.type === 'search' || search === '') {
        return true;
      } else {
        let match = false;
        if (option.title) {
          match = option.title.toLowerCase().includes(search.toLowerCase());
        }
        if (option.description) {
          match = match || option.description.toLowerCase().includes(search.toLowerCase());
        }
        return match;
      }
    }
  );
  
  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
    setSearch('');
  };

  // Hides the context menu on ESC
  useEffect(() => {
    if (!visible) return;

    const keyHandler = (e: KeyboardEvent) => {
      if (['Escape'].includes(e.code)) closeContext();
    };

    window.addEventListener('keydown', keyHandler);

    return () => window.removeEventListener('keydown', keyHandler);
  }, [visible]);

  useNuiEvent('hideContext', () => setVisible(false));

  useNuiEvent<ContextMenuProps>('showContext', async (data) => {
    if (visible) {
      setVisible(false);
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
    setContextMenu(data);
    setVisible(true);
  });

  return (
    <Flex position="absolute" w="75%" h="80%" justifyContent="flex-end" alignItems="center">
      <ScaleFade in={visible} unmountOnExit>
        <Box w="xs" h={580}>
          <Flex justifyContent="center" alignItems="center" mb={3}>
            {contextMenu.menu && (
              <Flex
                borderRadius="md"
                bg="gray.800"
                flex="1 15%"
                alignSelf="stretch"
                textAlign="center"
                justifyContent="center"
                alignItems="center"
                marginRight={2}
                p={2}
                _hover={{ bg: 'gray.700' }}
                transition="300ms"
                onClick={() => openMenu(contextMenu.menu)}
              >
                <FontAwesomeIcon icon="chevron-left" />
              </Flex>
            )}
            <Box borderRadius="md" bg="gray.800" flex="1 85%">
              <Text fontFamily="Poppins" fontSize="md" p={2} textAlign="center" fontWeight="light">
                <ReactMarkdown>{contextMenu.title}</ReactMarkdown>
              </Text>
            </Box>
            <Flex
              borderRadius="md"
              as="button"
              bg={contextMenu.canClose === false ? 'gray.600' : 'gray.800'}
              flex="1 15%"
              alignSelf="stretch"
              textAlign="center"
              justifyContent="center"
              alignItems="center"
              marginLeft={2}
              p={2}
              cursor={contextMenu.canClose === false ? 'not-allowed' : undefined}
              _hover={{ bg: contextMenu.canClose === false ? undefined : 'gray.700' }}
              transition="300ms"
              onClick={() => closeContext()}
            >
              <FontAwesomeIcon
                icon="xmark"
                fontSize={20}
                color={contextMenu.canClose === false ? '#718096' : undefined}
              />
            </Flex>
          </Flex>
          <Box maxH={560} overflowY="scroll">
            {filteredOptions.map((option, index) => {
              const isSearch = option[1].type === 'search';
              return isSearch ? 
                <Item option={option} key={`context-item-${index}`} handleChange={handleChange} search={search}/> : 
                <Item option={option} key={`context-item-${index}`} />
            })}
          </Box>
        </Box>
      </ScaleFade>
    </Flex>
  );
};

export default ContextMenu;
