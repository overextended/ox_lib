import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group, useMantineTheme } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import ScaleFade from '../../transitions/ScaleFade';
import remarkGfm from 'remark-gfm';
import type { TextUiPosition, TextUiProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import LibIcon from '../../components/LibIcon';

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems: 
      params.position === 'top-center' ? 'baseline' :
      params.position === 'bottom-center' ? 'flex-end' : 'center',
    justifyContent: 
      params.position === 'right-center' ? 'flex-end' :
      params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 16,
    padding: 12,
    margin: 8,
    backgroundColor: 'rgba(0, 0, 0, 0.7)',
    color: theme.colors.gray[0],
    fontFamily: 'Saira',
    borderRadius: theme.radius.sm,
    boxShadow: theme.shadows.sm,
  },
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    position: 'right-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });
  const theme = useMantineTheme();

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'right-center'; // Default right position
    setData(data);
    setVisible(true);
  });

  useNuiEvent('textUiHide', () => setVisible(false));

  return (
    <>
      <Box className={classes.wrapper}>
        <ScaleFade visible={visible}>
          <Box style={data.style} className={classes.container}>
            <Group spacing={12}>
              {data.icon && (

                <LibIcon
                  icon={data.icon}
                  fixedWidth
                  size="lg"
                  animation={data.iconAnimation}
                  style={{
                    color: data.iconColor? data.iconColor : theme.colors[theme.primaryColor][theme.fn.primaryShade()],
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                    filter: `drop-shadow(0 0 5px ${data.iconColor? data.iconColor : theme.colors[theme.primaryColor][theme.fn.primaryShade()]})`,
                  }}
                />
              )}
              <ReactMarkdown components={MarkdownComponents} remarkPlugins={[remarkGfm]}>
                {data.text}
              </ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;
