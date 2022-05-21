import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalBody,
  Button,
} from "@chakra-ui/react";
import React from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { useLocales } from "../../providers/LocaleProvider";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";
import { Row } from "../../interfaces/dialog";

import Input from "./components/input";
import CheckboxField from "./components/checkbox";
import SelectField from "./components/select";

interface Props {
  heading: string;
  rows: Row[];
}

debugData<Props>([
  {
    action: "openDialog",
    data: {
      heading: "Police locker",
      rows: [
        { type: "input", label: "Locker number" },
        { type: "checkbox", label: "Some checkbox" },
        { type: "input", label: "Locker PIN", password: true, icon: "lock" },
        { type: "checkbox", label: "Some other checkbox" },
        {
          type: "select",
          label: "Locker type",
          options: [
            { value: "option1", label: "Option 1" },
            { value: "option2", label: "Option 2" },
            { value: "option3", label: "Option 3" },
          ],
        },
      ],
    },
  },
]);

const InputDialog: React.FC = () => {
  const [fields, setFields] = React.useState<Props>({
    heading: "",
    rows: [{ type: "input", label: "" }],
  });
  const [inputData, setInputData] = React.useState<Array<string | boolean>>([]);
  const [passwordStates, setPasswordStates] = React.useState<boolean[]>([]);
  const [visible, setVisible] = React.useState(false);

  const { locale } = useLocales();

  const handlePasswordStates = (index: number) => {
    setPasswordStates({
      ...passwordStates,
      [index]: !passwordStates[index],
    });
  };

  useNuiEvent<Props>("openDialog", (data) => {
    setPasswordStates([]);
    setFields(data);
    setInputData([]);
    setVisible(true);
  });

  const handleClose = () => {
    setVisible(false);
    fetchNui("inputData");
  };

  const handleChange = (value: string | boolean, index: number) => {
    setInputData((previousData) => {
      previousData[index] = value;
      return previousData;
    });
  };

  const handleConfirm = () => {
    setVisible(false);
    fetchNui("inputData", inputData);
  };

  return (
    <>
      <Modal
        isOpen={visible}
        onClose={handleClose}
        isCentered
        closeOnEsc
        closeOnOverlayClick={false}
        size="xs"
      >
        <ModalOverlay />
        <ModalContent>
          <ModalHeader textAlign="center">{fields.heading}</ModalHeader>
          <ModalBody fontFamily="Poppins" textAlign="left">
            {fields.rows.map((row, index) => (
              <React.Fragment key={`row-${index}`}>
                {row.type === "input" && (
                  <Input
                    key={`input-${index}`}
                    row={row}
                    index={index}
                    handleChange={handleChange}
                    passwordStates={passwordStates}
                    handlePasswordStates={handlePasswordStates}
                  />
                )}
                {row.type === "checkbox" && (
                  <CheckboxField
                    row={row}
                    index={index}
                    handleChange={handleChange}
                  />
                )}
                {row.type === "select" && (
                  <SelectField
                    row={row}
                    index={index}
                    handleChange={handleChange}
                  />
                )}
              </React.Fragment>
            ))}
          </ModalBody>
          <ModalFooter>
            <Button mr={3} onClick={handleClose}>
              {locale.ui.close}
            </Button>
            <Button colorScheme="blue" onClick={handleConfirm}>
              {locale.ui.confirm}
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default InputDialog;
