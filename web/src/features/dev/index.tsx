import { ActionIcon, Button, Divider, Drawer, Stack, Tooltip } from '@mantine/core';
import { debugAlert } from './debug/alert';
import { debugContext } from './debug/context';
import { debugInput } from './debug/input';
import { debugMenu } from './debug/menu';
import { debugCustomNotification } from './debug/notification';
import { debugCircleProgressbar, debugProgressbar } from './debug/progress';
import { debugTextUI } from './debug/textui';
import { debugSkillCheck } from './debug/skillcheck';
import { useState } from 'react';
import { debugRadial } from './debug/radial';
import LibIcon from '../../components/LibIcon';

const Dev: React.FC = () => {
  const [opened, setOpened] = useState(false);

  return (
    <>
      <Tooltip label="Developer drawer" position="bottom">
        <ActionIcon
          onClick={() => setOpened(true)}
          radius="xl"
          variant="filled"
          color="orange"
          sx={{ position: 'absolute', bottom: 0, right: 0, width: 50, height: 50 }}
          size="xl"
          mr={50}
          mb={50}
        >
          <LibIcon icon="wrench" fontSize={24} />
        </ActionIcon>
      </Tooltip>

      <Drawer position="left" onClose={() => setOpened(false)} opened={opened} title="Developer drawer" padding="xl">
        <Stack>
          <Divider />
          <Button fullWidth onClick={() => debugInput()}>
            Open input dialog
          </Button>
          <Button fullWidth onClick={() => debugAlert()}>
            Open alert dialog
          </Button>
          <Divider />
          <Button fullWidth onClick={() => debugContext()}>
            Open context menu
          </Button>
          <Button fullWidth onClick={() => debugMenu()}>
            Open list menu
          </Button>
          <Button fullWidth onClick={() => debugRadial()}>
            Open radial menu
          </Button>
          <Divider />
          <Button fullWidth onClick={() => debugCustomNotification()}>
            Send notification
          </Button>
          <Divider />
          <Button fullWidth onClick={() => debugProgressbar()}>
            Activate progress bar
          </Button>
          <Button fullWidth onClick={() => debugCircleProgressbar()}>
            Activate progress circle
          </Button>
          <Divider />
          <Button fullWidth onClick={() => debugTextUI()}>
            Show TextUI
          </Button>
          <Divider />
          <Button fullWidth onClick={() => debugSkillCheck()}>
            Run skill check
          </Button>
        </Stack>
      </Drawer>
    </>
  );
};

export default Dev;
