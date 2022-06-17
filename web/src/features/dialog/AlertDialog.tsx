import {
  AlertDialog as Dialog,
  AlertDialogBody,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogContent,
  AlertDialogOverlay,
  useDisclosure,
  Button,
} from "@chakra-ui/react";
import { useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";
import { useLocales } from "../../providers/LocaleProvider";

interface DialogProps {
  header: string;
  content: string;
  centered?: boolean;
  cancel?: boolean;
}

debugData<DialogProps>([
  {
    action: "sendAlert",
    data: {
      header: "Hello there",
      content: "General kenobi  \n Markdown works",
      centered: true,
      cancel: true,
    },
  },
]);

const AlertDialog: React.FC = () => {
  const { locale } = useLocales();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const cancelRef = useRef(null);
  const [dialogData, setDialogData] = useState<DialogProps>({
    header: "",
    content: "",
  });

  const closeAlert = (button: string) => {
    onClose();
    fetchNui("closeAlert", button);
  };

  useNuiEvent("sendAlert", (data: DialogProps) => {
    setDialogData(data);
    onOpen();
  });

  return (
    <>
      <Dialog
        leastDestructiveRef={cancelRef}
        onClose={onClose}
        isOpen={isOpen}
        isCentered={dialogData.centered}
        closeOnOverlayClick={false}
        onEsc={() => closeAlert("cancel")}
      >
        <AlertDialogOverlay />
        <AlertDialogContent fontFamily="Inter">
          <AlertDialogHeader fontSize="lg" fontWeight="bold">
            {dialogData.header}
          </AlertDialogHeader>
          <AlertDialogBody>
            <ReactMarkdown>{dialogData.content}</ReactMarkdown>
          </AlertDialogBody>
          <AlertDialogFooter>
            {dialogData.cancel && (
              <Button onClick={() => closeAlert("cancel")} mr={3}>
                {locale.ui.cancel}
              </Button>
            )}
            <Button
              colorScheme={dialogData.cancel ? "blue" : undefined}
              onClick={() => closeAlert("confirm")}
            >
              {locale.ui.confirm}
            </Button>
          </AlertDialogFooter>
        </AlertDialogContent>
      </Dialog>
    </>
  );
};

export default AlertDialog;
