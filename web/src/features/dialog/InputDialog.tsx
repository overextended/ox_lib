import { Modal, ModalOverlay, ModalContent, ModalFooter, ModalHeader, ModalBody, Button } from '@chakra-ui/react';
import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import { fetchNui } from '../../utils/fetchNui';
import { IInput, ICheckbox, ISelect, INumber, ISlider } from '../../interfaces/dialog';
import InputField from './components/input';
import CheckboxField from './components/checkbox';
import SelectField from './components/select';
import NumberField from './components/number';
import SliderField from './components/slider';

export interface InputProps {
  heading: string;
  rows: Array<IInput | ICheckbox | ISelect | INumber | ISlider>;
}

const InputDialog: React.FC = () => {
  const [fields, setFields] = React.useState<InputProps>({
    heading: '',
    rows: [{ type: 'input', label: '' }],
  });
  const [inputData, setInputData] = React.useState<Array<string | number | boolean>>([]);
  const [passwordStates, setPasswordStates] = React.useState<boolean[]>([]);
  const [visible, setVisible] = React.useState(false);
  const { locale } = useLocales();

  const handlePasswordStates = (index: number) => {
    setPasswordStates({
      ...passwordStates,
      [index]: !passwordStates[index],
    });
  };

  useNuiEvent<InputProps>('openDialog', (data) => {
    setPasswordStates([]);
    setFields(data);
    setInputData([]);
    setVisible(true);
  });

  const handleClose = () => {
    setVisible(false);
    fetchNui('inputData');
  };

  const handleChange = (value: string | number | boolean, index: number) => {
    setInputData((previousData) => {
      previousData[index] = value;
      return previousData;
    });
  };

  const handleConfirm = () => {
    setVisible(false);
    fetchNui('inputData', inputData);
  };

  return (
    <>
      <Modal isOpen={visible} onClose={handleClose} isCentered closeOnEsc closeOnOverlayClick={false} size="xs">
        <ModalOverlay />
        <ModalContent
          onKeyDown={(e) => {
            if (e.key === 'Enter' && visible) return handleConfirm();
          }}
        >
          <ModalHeader textAlign="center">{fields.heading}</ModalHeader>
          <ModalBody fontFamily="Poppins" textAlign="left">
            {fields.rows.map((row: IInput | ICheckbox | ISelect | INumber | ISlider, index) => (
              <React.Fragment key={`row-${index}`}>
                {row.type === 'input' && (
                  <InputField
                    key={`input-${index}`}
                    row={row}
                    index={index}
                    handleChange={handleChange}
                    passwordStates={passwordStates}
                    handlePasswordStates={handlePasswordStates}
                  />
                )}
                {row.type === 'checkbox' && <CheckboxField row={row} index={index} handleChange={handleChange} />}
                {row.type === 'select' && <SelectField row={row} index={index} handleChange={handleChange} />}
                {row.type === 'number' && <NumberField row={row} index={index} handleChange={handleChange} />}
                {row.type === 'slider' && <SliderField row={row} index={index} handleChange={handleChange} />}
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
