import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalFooter,
  ModalHeader,
  ModalBody,
  Box,
  Input,
  InputGroup,
  InputRightElement,
  Text,
  Button,
  Checkbox,
  Select,
} from "@chakra-ui/react";
import React from "react";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { useNuiEvent } from "../../hooks/useNuiEvent";
import { useLocales } from "../../providers/LocaleProvider";
import { debugData } from "../../utils/debugData";
import { fetchNui } from "../../utils/fetchNui";

type RowType = "input" | "checkbox" | "select";

interface Props {
  heading: string;
  rows: {
    type: RowType;
    label: string;
    options?: { value: string; label: string }[];
    password?: boolean;
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
        { type: "input", label: "Locker PIN", password: true },
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
  const [visible, setVisible] = React.useState(false);
  const { locale } = useLocales();

  const [showPassword, setShowPassword] = React.useState(false);
  const handleShowPassword = () => setShowPassword(!showPassword);

  useNuiEvent<Props>("openDialog", (data) => {
    setShowPassword(false);
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
                  <Box mb={3} key={`input-${index}`} textAlign="left">
                    <Text>{row.label}</Text>
                    <InputGroup>
                      <Input
                        onChange={(e) => handleChange(e.target.value, index)}
                        type={!row.password || showPassword ? 'text' : 'password'}
                      />
                      {row.password && (
                        <InputRightElement
                          cursor="pointer"
                          onClick={handleShowPassword}
                          children={
                            <FontAwesomeIcon
                              fixedWidth
                              icon={showPassword ? "eye" : "eye-slash"}
                              fontSize="1em"
                              style={{ paddingRight: 8 }}
                            />
                          }
                        />
                      )}
                    </InputGroup>
                  </Box>
                )}
                {row.type === "checkbox" && (
                  <Box mb={3} key={`checkbox-${index}`}>
                    <Checkbox
                      onChange={(e) => handleChange(e.target.checked, index)}
                    >
                      {row.label}
                    </Checkbox>
                  </Box>
                )}
                {row.type === "select" && (
                  <Box mb={3} key={`select-${index}`}>
                    <Select
                      onChange={(e) => handleChange(e.target.value, index)}
                    >
                      {/* Hacky workaround for selectable placeholder issue */}
                      <option value="" selected hidden disabled>
                        {row.label}
                      </option>
                      {row.options?.map((option, index) => (
                        <option key={`option-${index}`} value={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </Select>
                  </Box>
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
