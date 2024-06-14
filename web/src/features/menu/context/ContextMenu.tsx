import { useNuiEvent } from '../../../hooks/useNuiEvent';
import { Box, createStyles, Flex, Stack, Text } from '@mantine/core';
import { useEffect, useState } from 'react';
import { ContextMenuProps } from '../../../typings';
import ContextButton from './components/ContextButton';
import { fetchNui } from '../../../utils/fetchNui';
import ReactMarkdown from 'react-markdown';
import HeaderButton from './components/HeaderButton';
import ScaleFade from '../../../transitions/ScaleFade';
import SlideTransition from '../../../transitions/SlideTransition';
import MarkdownComponents from '../../../config/MarkdownComponents';
import { faCircleXmark } from '@fortawesome/free-solid-svg-icons';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

const openMenu = (id: string | undefined) => {
  fetchNui<ContextMenuProps>('openContext', { id: id, back: true });
};

const useStyles = createStyles((theme) => ({
  background: {
    backgroundImage: `linear-gradient(to right, rgba(255, 255, 255, 0) 50%, ${
      theme.colors[theme.primaryColor][theme.fn.primaryShade()]
    } 100%)`,
    width: '100%',
    height: '100vh',
    opacity: 0.6,
  },
  container: {
    position: 'absolute',
    top: '15%',
    right: '20%',
    width: 320,
    height: 580,
    fontSize: 20,
    fontWeight: 400,
  },
  header: {
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 5,
    gap: 6,
  },
  titleContainer: {
    borderRadius: 6,
    flex: '1 70%',
  },
  titleText: {
    color: '#fff',
    textShadow: '2px 1px 1px rgba(0, 0, 0, 0.3)',
    padding: 6,
    textAlign: 'right',
    fontSize: 25,
  },
  titleDesc: {
    color: '#fff',
    textShadow: '2px 1px 1px rgba(0, 0, 0, 0.3)',
    padding: 9,
    textAlign: 'right',
    fontSize: 16,
    fontWeight: 300,
    marginTop: -20,
  },
  buttonsContainer: {
    height: 560,
    overflowY: 'scroll',
  },
  buttonsFlexWrapper: {
    gap: 6,
  },
}));

const DelayedRender = ({ children, delay }: any) => {
  const [render, setRender] = useState(false);

  useEffect(() => {
    const timeout = setTimeout(() => {
      setRender(true);
    }, delay);

    return () => clearTimeout(timeout);
  }, [delay]);

  return render ? children : null;
};

const ContextMenu: React.FC = () => {
  const { classes } = useStyles();
  const [visible, setVisible] = useState(false);
  const [contextMenu, setContextMenu] = useState<ContextMenuProps>({
    title: '',
    description: '',
    backgroundColor: '',
    background: false,
    menu:'',
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
    <SlideTransition visible={visible} position="right">
      <Box
        className={classes.background}
        opacity={contextMenu.background == true ? 0.6 : 0}
        style={{
          backgroundImage: `linear-gradient(to right, rgba(255, 255, 255, 0) 50%, ${contextMenu.backgroundColor} 100%)`,
        }}
      />
    </SlideTransition>
      <Box className={classes.container}>
      <ScaleFade visible={visible}>
        <Flex className={classes.header} >
          {contextMenu.menu && (
            <HeaderButton icon="chevron-left" iconSize={16} handleClick={() => openMenu(contextMenu.menu)} />
          )}
          <Box className={classes.titleContainer}>
            <Text className={classes.titleText}>
              <ReactMarkdown components={MarkdownComponents}>{contextMenu.title}</ReactMarkdown>
            </Text>
            <Text className={classes.titleDesc}>
              <ReactMarkdown components={MarkdownComponents}>{contextMenu.description}</ReactMarkdown>
            </Text>
          </Box>
          <HeaderButton
            icon= "xmark"
            canClose={contextMenu.canClose}
            iconSize={20}
            handleClick={closeContext}
          />
        </Flex>
        <Box className={classes.buttonsContainer}>
          <Stack className={classes.buttonsFlexWrapper}>
            {Object.entries(contextMenu.options).map((option, index) => (
              <>
                <ContextButton option={option} />
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
