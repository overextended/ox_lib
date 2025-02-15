import { Box, createStyles, Flex, Stack, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import MarkdownComponents from '../../../config/MarkdownComponents';
import { useNuiEvent } from '../../../hooks/useNuiEvent';
import ScaleFade from '../../../transitions/ScaleFade';
import { ContextMenuProps } from '../../../typings';
import { fetchNui } from '../../../utils/fetchNui';
import ContextButton from './components/ContextButton';
import HeaderButton from './components/HeaderButton';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const useStyles = createStyles(() => ({
  container: {
    position: 'absolute',
    top: '50%',
    right: '64px',
    width: 384,
    height: 'fit-content',
    transform: 'translateY(-50%)',
  },
  header: {
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 16,
  },
  titleContainer: {
    borderRadius: 4,
    flex: '1 85%',
    backgroundColor: 'transparent',
  },
  titleText: {
    color: '#FFFFFF',
    padding: 0,
    textAlign: 'left',
    fontSize: 24,
    fontWeight: 700,
  },
  buttonsContainer: {
    height: 'fit-content',
    overflowY: 'scroll',
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    borderRadius: 16,
  },
  buttonsFlexWrapper: {
    gap: 0,
  },
  customGradient: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: '50%',
    height: '100%',
    background: 'linear-gradient(90deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.75) 100%)',
  },
  divider: {
    width: '100%',
    height: 1,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
}));

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    options: { '': { description: '', metadata: [] } },
  });

  const closeContext = () => {
    if (contextMenu.canClose === false) return;
    setVisible(false);
    fetchNui('closeContext');
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
    <>
      {visible && <div className={classes.customGradient}></div>}
      <Box className={classes.container}>
        <ScaleFade visible={visible}>
          <Flex className={classes.header}>
            {contextMenu.menu && (
              <HeaderButton icon="chevron-left" iconSize={16} handleClick={() => openMenu(contextMenu.menu)} />
            )}
            <Box className={classes.titleContainer}>
              <Text className={classes.titleText}>
                <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
              </Text>
            </Box>
            <HeaderButton icon="xmark" canClose={contextMenu.canClose} iconSize={18} handleClick={closeContext} />
          </Flex>
          <Box className={classes.buttonsContainer}>
            <Stack className={classes.buttonsFlexWrapper}>
              {Object.entries(contextMenu.options).map((option, index) => (
                <>
                  <ContextButton option={option} key={`context-item-${index}`} />
                  <div className={classes.divider}></div>
                </>
              ))}
            </Stack>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default ContextMenu;
