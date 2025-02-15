import { Box, createStyles, Group } from '@mantine/core';
import React from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import MarkdownComponents from '../../config/MarkdownComponents';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import ScaleFade from '../../transitions/ScaleFade';
import type { TextUiPosition, TextUiProps } from '../../typings';

const useStyles = createStyles((theme, params: { position?: TextUiPosition }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems: 'flex-start',
    justifyContent: 'flex-start',
  },
  container: {
    fontSize: 16,
    padding: 8,
    margin: 16,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    color: 'white',
    fontFamily: 'Albert Sans',
    borderRadius: 4,
    fontWeight: 500,
  },
  buttonIndicator: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 4,
    padding: '2px 8px',
    border: `1px solid rgba(255, 255, 255, 0.30)`,
    backgroundColor: 'rgba(0, 0, 0, 0.75)',
    color: 'white',
    boxShadow: '1px 1px 0px 0px rgba(255, 255, 255, 0.20)',
    fontWeight: 800,
    fontSize: 16,
  },
}));

const TextUI: React.FC = () => {
  const [data, setData] = React.useState<TextUiProps>({
    text: '',
    key: '',
    position: 'left-center',
  });
  const [visible, setVisible] = React.useState(false);
  const { classes } = useStyles({ position: data.position });

  useNuiEvent<TextUiProps>('textUi', (data) => {
    if (!data.position) data.position = 'left-center'; // Default right position
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
              {/* {data.icon && (
                <LibIcon
                  icon={data.icon}
                  fixedWidth
                  size="lg"
                  animation={data.iconAnimation}
                  style={{
                    color: data.iconColor,
                    alignSelf: !data.alignIcon || data.alignIcon === 'center' ? 'center' : 'start',
                  }}
                />
              )} */}
              <div className={classes.buttonIndicator}>{data.key}</div>
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
