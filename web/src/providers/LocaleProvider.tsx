import { Context, createContext, useContext, useState } from 'react';
import { useNuiEvent } from '../hooks/useNuiEvent';
import { debugData } from '../utils/debugData';

debugData([
  {
    action: 'loadLocales',
    data: ['en', 'fr', 'de', 'it', 'es', 'pt-BR', 'pl', 'ru', 'ko', 'zh-TW', 'ja', 'es-MX', 'zh-CN'],
  },
]);

debugData([
  {
    action: 'setLocale',
    data: {
      language: 'English',
      ui: {
        cancel: 'Cancel',
        close: 'Close',
        confirm: 'Confirm',
        more: 'More...',
      },
    },
  },
]);

interface Locale {
  language: string;
  ui: {
    cancel: string;
    close: string;
    confirm: string;
    more: string;
  };
}

interface LocaleContextValue {
  locale: Locale;
  setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [locale, setLocale] = useState<Locale>({
    language: '',
    ui: {
      cancel: '',
      close: '',
      confirm: '',
      more: '',
    },
  });

  useNuiEvent('setLocale', async (data: Locale) => setLocale(data));

  return <LocaleCtx.Provider value={{ locale, setLocale }}>{children}</LocaleCtx.Provider>;
};

export default LocaleProvider;

export const useLocales = () => useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
