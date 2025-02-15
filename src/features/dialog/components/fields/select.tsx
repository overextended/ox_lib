import { MultiSelect, Select } from '@mantine/core';
import { Control, useController } from 'react-hook-form';
import LibIcon from '../../../../components/LibIcon';
import { ISelect } from '../../../../typings';
import { FormValues } from '../../InputDialog';

interface Props {
  row: ISelect;
  index: number;
  control: Control<FormValues>;
}

const SelectField: React.FC<Props> = (props) => {
  const controller = useController({
    name: `test.${props.index}.value`,
    control: props.control,
    rules: { required: props.row.required },
  });

  return (
    <>
      {props.row.type === 'select' ? (
        <Select
          data={props.row.options}
          value={controller.field.value}
          name={controller.field.name}
          ref={controller.field.ref}
          onBlur={controller.field.onBlur}
          onChange={controller.field.onChange}
          disabled={props.row.disabled}
          label={props.row.label}
          description={props.row.description}
          withAsterisk={props.row.required}
          clearable={props.row.clearable}
          searchable={props.row.searchable}
          icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
          styles={{
            input: {
              color: 'rgba(255, 255, 255, 0.75)',
              backgroundColor: 'rgba(0, 0, 0, 0.75)',
              borderRadius: 8,
              borderColor: 'rgba(255, 255, 255, 0.15)',
              ':focus-within': {
                borderColor: 'rgb(194, 5, 5)',
              },
            },
            icon: {
              color: 'rgba(255, 255, 255, 0.75)',
            },
          }}
        />
      ) : (
        <>
          {props.row.type === 'multi-select' && (
            <MultiSelect
              data={props.row.options}
              value={controller.field.value}
              name={controller.field.name}
              ref={controller.field.ref}
              onBlur={controller.field.onBlur}
              onChange={controller.field.onChange}
              disabled={props.row.disabled}
              label={props.row.label}
              description={props.row.description}
              withAsterisk={props.row.required}
              clearable={props.row.clearable}
              searchable={props.row.searchable}
              maxSelectedValues={props.row.maxSelectedValues}
              icon={props.row.icon && <LibIcon icon={props.row.icon} fixedWidth />}
              styles={{
                root: {
                  color: 'rgba(255, 255, 255, 0.75)',
                  backgroundColor: 'rgba(0, 0, 0, 0.75)',
                  borderRadius: 8,
                  borderColor: 'rgba(255, 255, 255, 0.15)',
                  ':focus-within': {
                    borderColor: 'rgb(194, 5, 5)',
                  },
                },
                icon: {
                  color: 'rgba(255, 255, 255, 0.75)',
                },
              }}
            />
          )}
        </>
      )}
    </>
  );
};

export default SelectField;
