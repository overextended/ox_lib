import { cache } from '../cache/index';
import { printf } from 'fast-printf';

const dict: Record<string, string> = {};

function flattenDict(source: Record<string, any>, target: Record<string, string>, prefix?: string) {
  for (const key in source) {
    const fullKey = prefix ? `${prefix}.${key}` : key;
    const value = source[key];

    if (typeof value === 'object') flattenDict(value, target, fullKey);
    else target[fullKey] = String(value);
  }

  return target;
}

export const locale = (str: string, ...args: any[]) => {
  const lstr = dict[str];

  if (!lstr) return str;

  if (lstr) {
    if (typeof lstr !== 'string') return lstr;

    if (args.length > 0) {
      return printf(lstr, ...args);
    }

    return lstr;
  }

  return str;
};

export const getLocales = () => dict;

export function getLocale(resource: string, key: string) {
  let locale = dict[key];

  if (locale) console.warn(`overwritin existing locale '${key} (${locale})`);

  locale = exports[resource].getLocale(key);
  dict[key] = locale;

  if (!locale) console.warn(`no locale exists with key '${key} in resource '${resource}`);

  return locale;
}

function loadLocale(key: string): typeof dict {
  const data = LoadResourceFile(cache.resource, `locales/${key}.json`);

  if (!data) console.warn(`could not load 'locales/${key}.json'`);

  return JSON.parse(data) || {};
}

export const initLocale = (key?: string) => {
  const lang = key || exports.ox_lib.getLocaleKey();
  let locales = loadLocale('en');

  if (lang !== 'en') Object.assign(locales, loadLocale(lang));

  const flattened = flattenDict(locales, {});

  for (let [k, v] of Object.entries(flattened)) {
    if (typeof v === 'string') {
      const regExp = new RegExp(/\$\{([^}]+)\}/g);

      const matches = v.match(regExp);

      if (matches) {
        for (const match of matches) {
          if (!match) break;
          const variable = match.substring(2, match.length - 1) as keyof typeof locales;
          let locale: string = flattened[variable];

          if (locale) {
            v = v.replace(match, locale);
          }
        }
      }
    }

    dict[k] = v;
  }
};

initLocale();
