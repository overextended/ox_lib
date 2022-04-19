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
} from "@chakra-ui/react";
import React from "react";
import { useNuiEvent } from "../../hooks/useNuiEvent";
// import { debugData } from "../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";

interface Props {
  heading: string;
  inputs: string[];
}

// debugData([
//   {
//     action: "openDialog",
//     data: {
//       heading: "Police locker",
//       inputs: ["Locker number", "Locker PIN"],
//     },
//   },
// ]);

const InputDialog: React.FC = () => {
  const [inputOptions, setInputOptions] = React.useState<Props>({
    heading: "",
    inputs: [""],
  });
  const [inputData, setInputData] = React.useState<string[]>([]);
  const [visible, setVisible] = React.useState(false);

  useNuiEvent<Props>("openDialog", (data) => {
    setInputOptions(data);
    setInputData([]);
    setVisible(true);
  });

  const handleClose = () => {
    setVisible(false);
    fetchNui("inputData");
  };

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement>,
    index: number
  ) => {
    setInputData((previousData) => {
      previousData[index] = e.target.value;
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
          <ModalHeader textAlign="center">{inputOptions.heading}</ModalHeader>
          <ModalBody fontFamily="Poppins">
            {inputOptions.inputs.map((input: string, index: number) => (
              <Box mb={3} key={`input-${index}`}>
                <Text>{input}</Text>
                <Input onChange={(e) => handleChange(e, index)} />
              </Box>
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
