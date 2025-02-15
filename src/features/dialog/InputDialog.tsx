import { Button, createStyles, Group, Modal, Stack } from '@mantine/core';
import dayjs from 'dayjs';
import React from 'react';
import { useFieldArray, useForm } from 'react-hook-form';
import { useNuiEvent } from '../../hooks/useNuiEvent';
import { useLocales } from '../../providers/LocaleProvider';
import type { InputProps } from '../../typings';
import { OptionValue } from '../../typings';
import { fetchNui } from '../../utils/fetchNui';
import CheckboxField from './components/fields/checkbox';
import ColorField from './components/fields/color';
import DateField from './components/fields/date';
import InputField from './components/fields/input';
import NumberField from './components/fields/number';
import SelectField from './components/fields/select';
import SliderField from './components/fields/slider';
import TextareaField from './components/fields/textarea';
import TimeField from './components/fields/time';

export type FormValues = {
  test: {
    value: any;
  }[];
};

const useStyles = createStyles(() => ({
  modal: {},
  form: {},
  stack: {},
  customGradient: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: '50%',
    height: '100%',
    background: 'linear-gradient(90deg, rgba(0,0,0,0) 0%, rgba(0,0,0,0.75) 100%)',
  },
}));

const InputDialog: React.FC = () => {
  const [fields, setFields] = React.useState<InputProps>({
    heading: '',
    rows: [{ type: 'input', label: '' }],
  });
  const [visible, setVisible] = React.useState(false);
  const { locale } = useLocales();

  const form = useForm<{ test: { value: any }[] }>({});
  const fieldForm = useFieldArray({
    control: form.control,
    name: 'test',
  });

  useNuiEvent<InputProps>('openDialog', (data) => {
    setFields(data);
    setVisible(true);
    data.rows.forEach((row, index) => {
      fieldForm.insert(
        index,
        {
          value:
            row.type !== 'checkbox'
              ? row.type === 'date' || row.type === 'date-range' || row.type === 'time'
                ? // Set date to current one if default is set to true
                  row.default === true
                  ? new Date().getTime()
                  : Array.isArray(row.default)
                  ? row.default.map((date) => new Date(date).getTime())
                  : row.default && new Date(row.default).getTime()
                : row.default
              : row.checked,
        } || { value: null }
      );
      // Backwards compat with new Select data type
      if (row.type === 'select' || row.type === 'multi-select') {
        row.options = row.options.map((option) =>
          !option.label ? { ...option, label: option.value } : option
        ) as Array<OptionValue>;
      }
    });
  });

  useNuiEvent('closeInputDialog', async () => await handleClose(true));

  const handleClose = async (dontPost?: boolean) => {
    setVisible(false);
    await new Promise((resolve) => setTimeout(resolve, 200));
    form.reset();
    fieldForm.remove();
    if (dontPost) return;
    fetchNui('inputData');
  };

  const onSubmit = form.handleSubmit(async (data) => {
    setVisible(false);
    const values: any[] = [];
    for (let i = 0; i < fields.rows.length; i++) {
      const row = fields.rows[i];

      if ((row.type === 'date' || row.type === 'date-range') && row.returnString) {
        if (!data.test[i]) continue;
        data.test[i].value = dayjs(data.test[i].value).format(row.format || 'DD/MM/YYYY');
      }
    }
    Object.values(data.test).forEach((obj: { value: any }) => values.push(obj.value));
    await new Promise((resolve) => setTimeout(resolve, 200));
    form.reset();
    fieldForm.remove();
    fetchNui('inputData', values);
  });

  const { classes } = useStyles();

  return (
    <>
      {visible && <div className={classes.customGradient}></div>}
      <Modal
        className={classes.modal}
        styles={{
          inner: {
            position: 'absolute',
            top: '50%',
            right: '64px',
            transform: 'translateY(-50%)',
            width: 'fit-content',
            height: '100%',
            left: 'unset',
          },
          modal: {
            backgroundColor: 'rgba(0, 0, 0, 0.80)',
            color: 'white',
            borderRadius: 16,
          },
          header: {
            fontSize: 20,
            fontWeight: 500,
          },
        }}
        opened={visible}
        onClose={handleClose}
        centered
        closeOnEscape={fields.options?.allowCancel !== false}
        closeOnClickOutside={false}
        size="sm"
        withCloseButton={false}
        overlayOpacity={0}
        transition="fade"
        radius={16}
        exitTransitionDuration={150}
      >
        <form onSubmit={onSubmit} className={classes.form}>
          <Stack className={classes.stack}>
            {fieldForm.fields.map((item, index) => {
              const row = fields.rows[index];
              return (
                <React.Fragment key={item.id}>
                  {row.type === 'input' && (
                    <InputField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                  {row.type === 'checkbox' && (
                    <CheckboxField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                  {(row.type === 'select' || row.type === 'multi-select') && (
                    <SelectField row={row} index={index} control={form.control} />
                  )}
                  {row.type === 'number' && <NumberField control={form.control} row={row} index={index} />}
                  {row.type === 'slider' && <SliderField control={form.control} row={row} index={index} />}
                  {row.type === 'color' && <ColorField control={form.control} row={row} index={index} />}
                  {row.type === 'time' && <TimeField control={form.control} row={row} index={index} />}
                  {row.type === 'date' || row.type === 'date-range' ? (
                    <DateField control={form.control} row={row} index={index} />
                  ) : null}
                  {row.type === 'textarea' && (
                    <TextareaField
                      register={form.register(`test.${index}.value`, { required: row.required })}
                      row={row}
                      index={index}
                    />
                  )}
                </React.Fragment>
              );
            })}
            <Group position="right" spacing={8}>
              <Button
                styles={{
                  root: {
                    transition: 'all 200ms ease-in-out',
                    backgroundColor: 'transparent',
                    ':hover': { backgroundColor: 'transparent' },
                    fontWeight: 400,
                    fontSize: 14,
                  },
                  label: {
                    transition: 'all 200ms ease-in-out',
                    color: 'rgba(255, 255, 255, 0.75)',
                    ':hover': { color: 'rgba(255, 255, 255, 1)' },
                  },
                }}
                variant="default"
                onClick={() => handleClose()}
                mr={3}
                disabled={fields.options?.allowCancel === false}
              >
                {locale.ui.cancel}
              </Button>
              <Button
                styles={{
                  root: {
                    transition: 'all 200ms ease-in-out',
                    backgroundColor: 'rgb(194, 5, 5)',
                    ':hover': { backgroundColor: 'rgb(194, 5, 5)' },
                    borderRadius: 8,
                  },
                  label: { color: 'white' },
                }}
                variant="light"
                type="submit"
              >
                {locale.ui.confirm}
              </Button>
            </Group>
          </Stack>
        </form>
      </Modal>
    </>
  );
};

export default InputDialog;
