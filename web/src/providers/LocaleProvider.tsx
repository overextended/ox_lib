import { Context, createContext, useContext, useState } from "react";
import { useNuiEvent } from "../hooks/useNuiEvent";
import { debugData } from "../utils/debugData";

debugData([
  {
    action: "loadLocales",
    data: [
      "en",
      "fr",
      "de",
      "it",
      "es",
      "pt-BR",
      "pl",
      "ru",
      "ko",
      "zh-TW",
      "ja",
      "es-MX",
      "zh-CN",
    ],
  },
]);

debugData([
  {
    action: "setLocale",
    data: {
      language: "English",
      ui: {
        settings: {
          title: "Settings",
          language: "Language",
        },
        close: "Close",
        confirm: "Confirm",
      },
    },
  },
]);

interface Locale {
  language: string;
  ui: {
    settings: {
      title: string;
      language: string;
    };
    cancel: string;
    close: string;
    confirm: string;
  };
}

interface LocaleContextValue {
  locale: Locale;
  setLocale: (locales: Locale) => void;
}

const LocaleCtx = createContext<LocaleContextValue | null>(null);

const LocaleProvider: React.FC = ({ children }) => {
  const [locale, setLocale] = useState<Locale>({
    language: "",
    ui: {
      settings: {
        title: "",
        language: "",
      },
      cancel: "",
      close: "",
      confirm: "",
    },
  });

  useNuiEvent("setLocale", async (data: Locale) => setLocale(data));

  return (
    <LocaleCtx.Provider value={{ locale, setLocale }}>
      {children}
    </LocaleCtx.Provider>
  );
};

export default LocaleProvider;

export const useLocales = () =>
  useContext<LocaleContextValue>(LocaleCtx as Context<LocaleContextValue>);
