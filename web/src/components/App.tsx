import Notifications from "./Notifications";
import CircleProgressbar from "./CircleProgressbar";
import Progressbar from "./Progressbar";
import TextUI from "./TextUI";
import InputDialog from "./InputDialog";

const App: React.FC = () => {
  return (
    <>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
      <InputDialog />
    </>
  );
};

export default App;
