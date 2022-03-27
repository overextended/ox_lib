import Notifications from "./Notifications";
import CircleProgressbar from "./CircleProgressbar";
import Progressbar from "./Progressbar";
import TextUI from "./TextUI";
import InputDialog from "./InputDialog";
import ContextMenu from "./features/menu/ContextMenu";

const App: React.FC = () => {
  return (
    <>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
      <InputDialog />
      <ContextMenu />
    </>
  );
};

export default App;
