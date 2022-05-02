import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalBody,
  Box,
  Input,
  Text,
  Button,
  Checkbox,
} from "@chakra-ui/react";
import React from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";

interface Props {
  heading: string;
  rows: {
    type: "input" | "checkbox";
    label: string;
  }[];
}

debugData<Props>([
  {
    action: "openDialog",
    data: {
      heading: "Police locker",
      rows: [
        { type: "input", label: "Locker number" },
        { type: "checkbox", label: "Some checkbox" },
        { type: "input", label: "Locker PIN" },
        { type: "checkbox", label: "Some other checkbox" },
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
  const [visible, setVisible] = React.useState(false);

  useNuiEvent<Props>("openDialog", (data) => {
    setFields(data);
    setInputData([]);
    setVisible(true);
  });

  const handleClose = () => {
    setVisible(false);
    fetchNui("inputData");
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement>,
    index: number,
    type: "input" | "checkbox"
  ) => {
    setInputData((previousData) => {
      previousData[index] =
        type === "input" ? e.target.value : e.target.checked;
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
                  <Box mb={3} key={`input-${index}`} textAlign="left">
                    <Text>{row.label}</Text>
                    <Input onChange={(e) => handleChange(e, index, "input")} />
                  </Box>
                )}
                {row.type === "checkbox" && (
                  <Box mb={3} key={`checkbox-${index}`}>
                    <Checkbox
                      onChange={(e) => handleChange(e, index, "checkbox")}
                    >
                      {row.label}
                    </Checkbox>
                  </Box>
                )}
              </React.Fragment>
            ))}
          </ModalBody>
          <ModalFooter>
            <Button mr={3} onClick={handleClose}>
              Close
            </Button>
            <Button colorScheme="blue" onClick={handleConfirm}>
              Confirm
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default InputDialog;
