import { debugData } from "../../../utils/debugData";
import {InputProps} from "../../dialog/InputDialog";

export const debugInput = () => {
  debugData<InputProps>([
  {
    action: "openDialog",
    data: {
      heading: "Police locker",
      rows: [
        { type: "input", label: "Locker number", placeholder: "420" },
        { type: "checkbox", label: "Some checkbox" },
        { type: "input", label: "Locker PIN", password: true, icon: "lock" },
        { type: "checkbox", label: "Some other checkbox", checked: true },
        {
          type: "select",
          label: "Locker type",
          options: [
            { value: "option1" },
            { value: "option2", label: "Option 2" },
            { value: "option3", label: "Option 3" },
          ],
        },
        { type: "number", label: "Number counter", default: 12 },
        { type: "slider", label: "Slide bar", min: 10, max: 50, step: 2 },
      ],
    },
  },
]);
}