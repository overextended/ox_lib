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
              <Button width="full" onClick={() => debugInput()}>
                Open input dialog
              </Button>
              <Button width="full" onClick={() => debugAlert()}>
                Open alert dialog
              </Button>
              <Divider />
              <Button width="full" onClick={() => debugContext()}>
                Open context menu
              </Button>
              <Button width="full" onClick={() => debugMenu()}>
                Open list menu
              </Button>
              <Divider />
              <Button width="full" onClick={() => debugCustomNotification()}>
                Send custom notification
              </Button>
              <Button width="full" onClick={() => debugNotification()}>
                Send default notification
              </Button>
              <Divider />
              <Button width="full" onClick={() => debugProgressbar()}>
                Activate progress bar
              </Button>
              <Button width="full" onClick={() => debugCircleProgressbar()}>
                Activate progress circle
              </Button>
              <Divider />
              <Button width="full" onClick={() => debugTextUI()}>
                Show TextUI
              </Button>
              <Divider />
              <Button width="full" onClick={() => debugSkillCheck()}>
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
