import { Group, Modal, Button, Stack } from '@mantine/core';
import React from 'react';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import { fetchNui } from '../../utils/fetchNui';
import { IInput, ICheckbox, ISelect, INumber, ISlider } from '../../interfaces/dialog';
import InputField from './components/fields/input';
import CheckboxField from './components/fields/checkbox';
import SelectField from './components/fields/select';
import NumberField from './components/fields/number';
import SliderField from './components/fields/slider';

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

  useNuiEvent('closeInputDialog', () => {
    setVisible(false);
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
      <Modal
        opened={visible}
        onClose={handleClose}
        centered
        closeOnClickOutside={false}
        size="xs"
        onKeyDown={(e) => {
          if (e.key === 'Enter' && visible) return handleConfirm();
        }}
        styles={{ title: { textAlign: 'center', width: '100%', fontSize: 18 } }}
        title={fields.heading}
        withCloseButton={false}
        overlayOpacity={0.5}
        transition="fade"
        exitTransitionDuration={150}
      >
        <Stack>
          {fields.rows.map((row: IInput | ICheckbox | ISelect | INumber | ISlider, index) => (
            <React.Fragment key={`row-${index}-${row.type}-${row.label}`}>
              {row.type === 'input' && (
                <InputField
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
          <Group position="right" spacing={10}>
            <Button uppercase variant="default" onClick={handleClose} mr={3}>
              {locale.ui.cancel}
            </Button>
            <Button uppercase variant="light" onClick={handleClose}>
              {locale.ui.confirm}
            </Button>
          </Group>
        </Stack>
      </Modal>
    </>
  );
};

export default InputDialog;
