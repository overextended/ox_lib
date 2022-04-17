import Notifications from "./features/notifications/NotificationWrapper";
import CircleProgressbar from "./features/progress/CircleProgressbar";
import Progressbar from "./features/progress/Progressbar";
import TextUI from "./features/textui/TextUI";
import InputDialog from "./features/dialog/InputDialog";
import ContextMenu from "./features/menu/ContextMenu";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { setClipboard } from "./utils/setClipboard";

const App: React.FC = () => {
  useNuiEvent("setClipboard", (data: string) => {
    setClipboard(data);
  });

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
