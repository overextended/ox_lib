import { Button, createStyles, Group, Modal, Stack, useMantineTheme } from '@mantine/core';
import { useEffect, useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { useLocales } from '../../providers/LocaleProvider';
import remarkGfm from 'remark-gfm';
import type { AlertProps } from '../../typings';
import MarkdownComponents from '../../config/MarkdownComponents';
import ShowDurationBar from '../utils/ShowDurationBar';

const useStyles = createStyles((theme) => ({
  contentStack: {
    color: theme.colors.dark[2],
  },
}));

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
  const { classes } = useStyles();
  const theme = useMantineTheme();
  const [opened, setOpened] = useState(false);
  const [dialogData, setDialogData] = useState<AlertProps>({
    header: '',
    content: '',
  });

  const closeAlert = (button: string) => {
    setOpened(false);
    fetchNui('closeAlert', button);
  };

  useNuiEvent('sendAlert', (data: AlertProps) => {
    setDialogData(data);
    setOpened(true);
  });

  useNuiEvent('closeAlertDialog', () => {
    setOpened(false);
  });

  useEffect(() => {
    if (dialogData.timeout) {
      const timer = setTimeout(() => {
        closeAlert('cancel');
      }, dialogData.timeout);

      return () => clearTimeout(timer);
    }
  });

  return (
    <>
      <Modal
        opened={opened}
        centered={dialogData.centered}
        size={dialogData.size || 'md'}
        overflow={dialogData.overflow ? 'inside' : 'outside'}
        closeOnClickOutside={false}
        onClose={() => {
          setOpened(false);
          closeAlert('cancel');
        }}
        withCloseButton={false}
        overlayOpacity={0.5}
        exitTransitionDuration={150}
        transition="fade"
        title={<ReactMarkdown components={MarkdownComponents}>{dialogData.header}</ReactMarkdown>}
      >
        <Stack className={classes.contentStack}>
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            components={{
              ...MarkdownComponents,
              img: ({ ...props }) => <img style={{ maxWidth: '100%', maxHeight: '100%' }} {...props} />,
            }}
          >
            {dialogData.content}
          </ReactMarkdown>
          <Group position="right" spacing={10}>
            {dialogData.cancel && (
              <Button uppercase variant="default" onClick={() => closeAlert('cancel')} mr={3}>
                {dialogData.labels?.cancel || locale.ui.cancel}
              </Button>
            )}
            {dialogData.confirm && (
              <Button
                uppercase
                variant={dialogData.cancel ? 'light' : 'default'}
                color={dialogData.cancel ? theme.primaryColor : undefined}
                onClick={() => closeAlert('confirm')}
              >
                {dialogData.labels?.confirm || locale.ui.confirm}
              </Button>
            )}
          </Group>
        </Stack>
        {dialogData.timeout && (<ShowDurationBar duration={dialogData.timeout} marginTop={15} />)}
      </Modal>
    </>
  );
};

export default AlertDialog;
