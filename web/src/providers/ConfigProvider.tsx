import { Context, createContext, useContext, useEffect, useState } from 'react';
import { MantineColor } from '@mantine/core';
import { fetchNui } from '../utils/fetchNui';

interface Config {
  primaryColor: MantineColor;
  primaryShade: 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9;
}

interface ConfigCtxValue {
  config: Config;
  setConfig: (config: Config) => void;
}

const ConfigCtx = createContext<{ config: Config; setConfig: (config: Config) => void } | null>(null);

const ConfigProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [config, setConfig] = useState<Config>({
    primaryColor: 'blue',
    primaryShade: 6,
  });

  useEffect(() => {
    // Initial fetch
    fetchNui<Config>('getConfig').then((data) => setConfig(data));

    // Event listener for real-time updates
    const handleConfigUpdate = (event: MessageEvent) => {
      if (event.data.action === 'updateColorSettings') {
        const { primaryColor, primaryShade } = event.data;
        setConfig((prevConfig) => ({
          ...prevConfig,
          primaryColor,
          primaryShade,
        }));
      }
    };

    window.addEventListener('message', handleConfigUpdate);

    return () => {
      window.removeEventListener('message', handleConfigUpdate);
    };
  }, []);

  return <ConfigCtx.Provider value={{ config, setConfig }}>{children}</ConfigCtx.Provider>;
};

export default ConfigProvider;

export const useConfig = () => useContext<ConfigCtxValue>(ConfigCtx as Context<ConfigCtxValue>);
