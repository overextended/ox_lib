import {
  Button,
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalOverlay,
  useDisclosure,
} from "@chakra-ui/react";
import LocaleSetting from "./components/locale";
import { useState } from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
// import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";
import { useLocales } from "../../providers/LocaleProvider";

// debugData([
//   {
//     action: "openSettings",
//     data: true,
//   },
// ]);

const Settings: React.FC = () => {
  const { isOpen, onOpen, onClose } = useDisclosure();
  const { locale } = useLocales();
  const [languages, setLanguages] = useState([""]);
  const [selectValue, setSelectValue] = useState("");

  const closeSettings = () => {
    onClose();
    fetchNui("closeSettings");
  };

  useNuiEvent("loadLocales", (data) => setLanguages(data));
  useNuiEvent("openSettings", (data: string) => {
    onOpen();
    setSelectValue(data);
  });

  return (
    <>
      <Modal
        isOpen={isOpen}
        onClose={onClose}
        isCentered
        closeOnEsc
        onEsc={closeSettings}
        closeOnOverlayClick={false}
        size="xs"
      >
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>{locale.ui.settings.title}</ModalHeader>
          <ModalBody>
            <LocaleSetting
              languages={languages}
              selectValue={selectValue}
              setSelectValue={setSelectValue}
            />
          </ModalBody>
          <ModalFooter>
            <Button colorScheme="blue" onClick={closeSettings}>
              {locale.ui.close}
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default Settings;
