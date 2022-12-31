import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { Box, createStyles, Group } from '@mantine/core';
import ReactMarkdown from 'react-markdown';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import ScaleFade from '../../transitions/ScaleFade';

type Position = 'right-center' | 'left-center' | 'top-center';

export interface TextUiProps {
  text: string;
  position?: Position;
  icon?: IconProp;
  iconColor?: string;
  style?: React.CSSProperties;
}

const useStyles = createStyles((theme, params: { position?: Position }) => ({
  wrapper: {
    height: '100%',
    width: '100%',
    position: 'absolute',
    display: 'flex',
    alignItems: params.position === 'top-center' ? 'baseline' : 'center',
    justifyContent:
      params.position === 'right-center' ? 'flex-end' : params.position === 'left-center' ? 'flex-start' : 'center',
  },
  container: {
    fontSize: 16,
    padding: 12,
    margin: 8,
    backgroundColor: theme.colors.dark[6],
    color: theme.colors.dark[0],
    fontFamily: 'Roboto',
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
              {data.icon && <FontAwesomeIcon icon={data.icon} fixedWidth size="lg" style={{ color: data.iconColor }} />}
              <ReactMarkdown>{data.text}</ReactMarkdown>
            </Group>
          </Box>
        </ScaleFade>
      </Box>
    </>
  );
};

export default TextUI;
