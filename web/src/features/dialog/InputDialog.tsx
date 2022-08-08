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
import { useKeyPress } from "../../hooks/useKeyPress";
import { useLocales } from "../../providers/LocaleProvider";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";
import { IInput, ICheckbox, ISelect, INumber } from "../../interfaces/dialog";
import InputField from "./components/input";
import CheckboxField from "./components/checkbox";
import SelectField from "./components/select";
import NumberField from "./components/number";

interface Props {
  heading: string;
  rows: Array<IInput | ICheckbox | ISelect | INumber>;
}

// debugData<Props>([
//   {
//     action: "openDialog",
//     data: {
//       heading: "Police locker",
//       rows: [
//         { type: "input", label: "Locker number", placeholder: "420" },
//         { type: "checkbox", label: "Some checkbox" },
//         { type: "input", label: "Locker PIN", password: true, icon: "lock" },
//         { type: "checkbox", label: "Some other checkbox", checked: true },
//         {
//           type: "select",
//           label: "Locker type",
//           options: [
//             { value: "option1" },
//             { value: "option2", label: "Option 2" },
//             { value: "option3", label: "Option 3" },
//           ],
//         },
//         { type: "number", label: "Number counter", default: 12 },
//       ],
//     },
//   },
// ]);

const InputDialog: React.FC = () => {
  const [fields, setFields] = React.useState<Props>({
    heading: "",
    rows: [{ type: "input", label: "" }],
  });
  const [inputData, setInputData] = React.useState<
    Array<string | number | boolean>
  >([]);
  const [passwordStates, setPasswordStates] = React.useState<boolean[]>([]);
  const [visible, setVisible] = React.useState(false);
  const enterPressed = useKeyPress("Enter");
  const { locale } = useLocales();

  React.useEffect(() => {
    if (visible && enterPressed === false) handleConfirm();
  }, [enterPressed]);

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

  const handleChange = (value: string | number | boolean, index: number) => {
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
            {fields.rows.map((row: IInput | ICheckbox | ISelect | INumber, index) => (
              <React.Fragment key={`row-${index}`}>
                {row.type === "input" && (
                  <InputField
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
                {row.type === "number" && (
                  <NumberField
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
