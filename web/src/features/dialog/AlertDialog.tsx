import { Modal, Button, Stack, Group, useMantineTheme } from '@mantine/core';
import { useState } from 'react';
import ReactMarkdown from 'react-markdown';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { fetchNui } from '../../utils/fetchNui';
import { useLocales } from '../../providers/LocaleProvider';

export interface AlertProps {
  header: string;
  content: string;
  centered?: boolean;
  cancel?: boolean;
  labels?: {
    cancel?: string;
    confirm?: string;
  };
}

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
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

  return (
    <>
      <Modal
        opened={opened}
        centered={dialogData.centered}
        closeOnClickOutside={false}
        onClose={() => {
          setOpened(false);
          closeAlert('cancel');
        }}
        withCloseButton={false}
        overlayOpacity={0.5}
        exitTransitionDuration={150}
        title={<ReactMarkdown>{dialogData.header}</ReactMarkdown>}
      >
        <Stack>
          <ReactMarkdown>{dialogData.content}</ReactMarkdown>
          <Group position="right" spacing={10}>
            {dialogData.cancel && (
              <Button uppercase variant="default" onClick={() => closeAlert('cancel')} mr={3}>
                {dialogData.labels?.cancel || locale.ui.cancel}
              </Button>
            )}
            <Button
              uppercase
              variant={dialogData.cancel ? 'light' : 'default'}
              color={dialogData.cancel ? theme.primaryColor : undefined}
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
