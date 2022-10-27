import {
  Button,
  Drawer,
  DrawerBody,
  DrawerContent,
  DrawerHeader,
  DrawerOverlay,
  IconButton,
  Tooltip,
  VStack,
  Divider,
  useDisclosure,
} from '@chakra-ui/react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { debugAlert } from './debug/alert';
import { debugContext } from './debug/context';
import { debugInput } from './debug/input';
import { debugMenu } from './debug/menu';
import { debugCustomNotification, debugNotification } from './debug/notification';
import { debugCircleProgressbar, debugProgressbar } from './debug/progress';
import { debugTextUI } from './debug/textui';
import { debugSettings } from './debug/settings';
import { debugSkillCheck } from './debug/skillcheck';

const Dev: React.FC = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();

  return (
    <>
      <Tooltip label="Developer drawer">
        <IconButton
          position="absolute"
          bottom={0}
          right={0}
          mr={20}
          mb={20}
          borderRadius="50%"
          icon={<FontAwesomeIcon icon="wrench" fixedWidth size="lg" />}
          colorScheme="orange"
          size="lg"
          aria-label="Dev tools"
          onClick={() => onOpen()}
        />
      </Tooltip>
      <Drawer placement="left" onClose={onClose} isOpen={isOpen}>
        <DrawerOverlay />
        <DrawerContent>
          <DrawerHeader>Developer drawer</DrawerHeader>
          <DrawerBody>
            <VStack>
              <Divider />
              <Button isFullWidth onClick={() => debugInput()}>
                Open input dialog
              </Button>
              <Button isFullWidth onClick={() => debugAlert()}>
                Open alert dialog
              </Button>
              <Divider />
              <Button isFullWidth onClick={() => debugContext()}>
                Open context menu
              </Button>
              <Button isFullWidth onClick={() => debugMenu()}>
                Open list menu
              </Button>
              <Divider />
              <Button isFullWidth onClick={() => debugCustomNotification()}>
                Send custom notification
              </Button>
              <Button isFullWidth onClick={() => debugNotification()}>
                Send default notification
              </Button>
              <Divider />
              <Button isFullWidth onClick={() => debugProgressbar()}>
                Activate progress bar
              </Button>
              <Button isFullWidth onClick={() => debugCircleProgressbar()}>
                Activate progress circle
              </Button>
              <Divider />
              <Button isFullWidth onClick={() => debugSettings()}>
                Open settings page
              </Button>
              <Button isFullWidth onClick={() => debugTextUI()}>
                Show TextUI
              </Button>
              <Divider />
              <Button isFullWidth onClick={() => debugSkillCheck()}>
                Run skill check
              </Button>
            </VStack>
          </DrawerBody>
        </DrawerContent>
      </Drawer>
    </>
  );
};

export default Dev;
