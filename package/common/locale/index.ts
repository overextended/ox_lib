import { cache } from '../cache';
import { printf } from 'fast-printf';
import type { FlattenObjectKeys } from "../utils";

const dict: Record<string, string> = {};
const path = GetResourceMetadata(cache.resource, 'locales_path', 0) || 'locales'

/** Flattens nested locale keys into dot-separated paths in the target dictionary. */
function flattenDict(source: Record<string, any>, target: Record<string, string>, prefix?: string) {
  for (const key in source) {
    const fullKey = prefix ? `${prefix}.${key}` : key;
    const value = source[key];

    if (typeof value === 'object') flattenDict(value, target, fullKey);
    else target[fullKey] = String(value);
  }

  return target;
}

/** Formats a translation with printf arguments, or returns the key when unavailable. */
export function locale<T extends string>(str: T, ...args: any[]): string {
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
}

/** Returns the shared translation dictionary. */
export const getLocales = () => dict;

/** Imports a translation from another resource into the local dictionary. */
export function getLocale(resource: string, key: string) {
  let locale = dict[key];

  if (locale) console.warn(`overwritin existing locale '${key} (${locale})`);

  locale = exports[resource].getLocale(key);
  dict[key] = locale;

  if (!locale) console.warn(`no locale exists with key '${key} in resource '${resource}`);

  return locale;
}

/** Reads and parses a locale JSON file from this resource. */
function loadLocale(key: string): typeof dict {
  const data = LoadResourceFile(cache.resource, `${path}/${key}.json`);

  if (!data) console.warn(`could not load '${path}/${key}.json'`);

  return JSON.parse(data) || {};
}

/**
 * Loads English translations, overlays the selected language, and expands locale references.
 * @deprecated Locale initialization runs automatically when this module is imported.
 */
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

/** Creates a translation helper whose keys are derived from a nested locale type. */
export function createLocales<T extends Record<string, any>>() {
  type Keys = FlattenObjectKeys<T>;
  return <K extends Keys>(key: K, ...args: any[]) => locale(key, ...args);
}
