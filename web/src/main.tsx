import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { far } from '@fortawesome/free-regular-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';
import { library } from '@fortawesome/fontawesome-svg-core';
import { isEnvBrowser } from './utils/misc';
import LocaleProvider from './providers/LocaleProvider';
import ConfigProvider from './providers/ConfigProvider';
import ErrorBoundary from './providers/errorBoundary';

library.add(fas, far, fab);

if (isEnvBrowser()) {
  const root = document.getElementById('root');

  // https://i.imgur.com/iPTAdYV.png - Night time img
  root!.style.backgroundImage = 'url("https://i.imgur.com/3pzRj9n.png")';
  root!.style.backgroundSize = 'cover';
  root!.style.backgroundRepeat = 'no-repeat';
  root!.style.backgroundPosition = 'center';
}

const root = document.getElementById('root');

createRoot(root!).render(
  <StrictMode>
    <LocaleProvider>
      <ConfigProvider>
        <ErrorBoundary>
          <App />
        </ErrorBoundary>
      </ConfigProvider>
    </LocaleProvider>
  </StrictMode>
);
