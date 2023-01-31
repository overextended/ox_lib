import Notifications from './features/notifications/NotificationWrapper';
import CircleProgressbar from './features/progress/CircleProgressbar';
import Progressbar from './features/progress/Progressbar';
import TextUI from './features/textui/TextUI';
import InputDialog from './features/dialog/InputDialog';
import ContextMenu from './features/menu/context/ContextMenu';
import { useNuiEvent } from './hooks/useNuiEvent';
import { copyClipboard } from './utils/copyClipboard';
import { fetchNui } from './utils/fetchNui';
import AlertDialog from './features/dialog/AlertDialog';
import ListMenu from './features/menu/list';
import Dev from './features/dev';
import { isEnvBrowser } from './utils/misc';
import SkillCheck from './features/skillcheck';
import { useState, useEffect } from 'react';

const App: React.FC = () => {

  let [pauseFocus, setPauseFocus] = useState(false);
  let [clipboard, setClipboard] = useState('');

  useNuiEvent('setClipboard', (data: string) => {
    setClipboard(data);
    setPauseFocus(true);
  });

  useEffect(() => {
    if (clipboard !== '') {
      copyClipboard(clipboard);
      setClipboard('');
      setPauseFocus(false);
    }
  }, [pauseFocus]);


  fetchNui('init');

  return (
    <>
      <Progressbar />
      <CircleProgressbar />
      <Notifications />
      <TextUI />
      <InputDialog />
      <AlertDialog />
      <ContextMenu />
      <ListMenu pauseFocus={pauseFocus} />
      <SkillCheck />
      {isEnvBrowser() && <Dev />}
    </>
  );
};

export default App;
