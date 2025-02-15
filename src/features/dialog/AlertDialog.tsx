import { Button, createStyles, Group, Modal, Stack } from '@mantine/core';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import MarkdownComponents from '../../config/MarkdownComponents';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import type { AlertProps } from '../../typings';
import { fetchNui } from '../../utils/fetchNui';

const useStyles = createStyles(() => ({
  contentStack: {
    color: 'rgba(255, 255, 255, 0.75)',
  },
}));

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
  const { classes } = useStyles();
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

  return (
    <>
      <Modal
        styles={{
          root: {
            fontFamily: 'Albert Sans',
          },
          modal: {
            backgroundColor: 'rgba(0, 0, 0, 0.80)',
            color: 'white',
            borderRadius: 16,
          },
          header: {
            fontSize: 20,
            fontWeight: 500,
          },
        }}
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
              <Button
                variant="default"
                onClick={() => closeAlert('cancel')}
                mr={3}
                styles={{
                  root: {
                    transition: 'all 200ms ease-in-out',
                    backgroundColor: 'transparent',
                    ':hover': { backgroundColor: 'transparent' },
                    fontWeight: 400,
                    fontSize: 14,
                  },
                  label: {
                    transition: 'all 200ms ease-in-out',
                    color: 'rgba(255, 255, 255, 0.75)',
                    ':hover': { color: 'rgba(255, 255, 255, 1)' },
                  },
                }}
              >
                {dialogData.labels?.cancel || locale.ui.cancel}
              </Button>
            )}
            <Button
              styles={{
                root: {
                  transition: 'all 200ms ease-in-out',
                  backgroundColor: 'rgb(194, 5, 5)',
                  ':hover': { backgroundColor: 'rgb(194, 5, 5)' },
                  borderRadius: 8,
                },
                label: { color: 'white' },
              }}
              variant={dialogData.cancel ? 'light' : 'default'}
              onClick={() => closeAlert('confirm')}
            >
              {dialogData.labels?.confirm || locale.ui.confirm}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </>
  );
};

export default AlertDialog;
