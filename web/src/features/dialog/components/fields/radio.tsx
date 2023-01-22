import { Radio } from "@mantine/core";
import { UseFormRegisterReturn } from "react-hook-form";
import { IRadio } from "../../../../interfaces/dialog";

interface Props {
    register: UseFormRegisterReturn;
    row: IRadio;
    index: number;
  }

const RadioField: React.FC<Props> = (props) => {
      return (
        <>
        <Radio.Group label={props.row.label} description={props.row.description || ''} withAsterisk={props.row.required}>
            {props.row.options.map((option, index) => (
                <Radio key={index} value={option.value} label={option.label || option.value} disabled={option.disabled} {...props.register} />
            ))}
        </Radio.Group>
        </>
    );
}

export default RadioField;