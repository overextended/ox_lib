import Notifications from "./features/notifications/NotificationWrapper";
import CircleProgressbar from "./features/progress/CircleProgressbar";
import Progressbar from "./features/progress/Progressbar";
import TextUI from "./features/textui/TextUI";
import InputDialog from "./features/dialog/InputDialog";
import ContextMenu from "./features/menu/ContextMenu";
import Settings from "./features/settings";
import { useNuiEvent } from "./hooks/useNuiEvent";
import { setClipboard } from "./utils/setClipboard";
import { fetchNui } from "./utils/fetchNui";
import AlertDialog from "./features/dialog/AlertDialog";

const App: React.FC = () => {
  useNuiEvent("setClipboard", (data: string) => {
    setClipboard(data);
  });

  fetchNui("init");

  return (
    <>
      <Settings />
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
      <InputDialog />
      <AlertDialog />
      <ContextMenu />
    </>
  );
};

export default App;
