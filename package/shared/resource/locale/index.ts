import { cache } from '../cache/index';
import { printf } from 'fast-printf';

const dict: { [key: string]: string | number } = {};

export const locale = (str: keyof typeof dict, ...args: any[]) => {
  const lstr = dict[str];

  if (!lstr) return str;

  if (lstr) {
    if (typeof lstr !== 'string') return lstr;

    if (args.length > 0) {
      return printf(lstr, ...args);
    }

    return lstr;
  }
};

export const getLocales = () => dict;

export const initLocale = () => {
  const lang = GetConvar('ox:locale', 'en');
  let locales: unknown = JSON.parse(LoadResourceFile(cache.resource, `locales/${lang}.json`));

  if (!locales) {
    console.warn(`could not load 'locales/${lang}.json'`);

    if (lang !== 'en') {
      locales = LoadResourceFile(cache.resource, 'locales/en.json');

      if (!locales) {
        console.warn(`could not load 'locales/en.json'`);
      }
    }

    if (!locales) return;
  }

  for (let [k, v] of Object.entries(locales)) {
    if (typeof v === 'string') {
      const regExp = new RegExp(/\$\{([^}]+)\}/g);

      const matches = v.match(regExp);

      if (matches) {
        for (const match of matches) {
          if (!match) break;
          const variable = match.substring(2, match.length - 1) as keyof typeof locales;
          let locale: string = locales[variable];

          if (locale) {
            v = v.replace(match, locale);
          }
        }
      }
    }

    dict[k] = v;
  }
};
