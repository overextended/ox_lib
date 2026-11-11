import type { TsdownPlugin } from "tsdown";

const RE = /\bGetHashKey\(\s*(["'`])((?:(?!\1)[^\\]|\\.)*)\1\s*\)/g;

function joaat(str: string): number {
  str = str.toLowerCase();
  let hash = 0;

  for (let i = 0; i < str.length; i++) {
    let c = str.charCodeAt(i);

    hash += c;
    hash += hash << 10;
    hash ^= hash >>> 6;
    hash >>>= 0;
  }

  hash += hash << 3;
  hash ^= hash >>> 11;
  hash += hash << 15;

  return hash | 0;
}

export default function (): TsdownPlugin {
  return {
    name: "joaat",

    transform(code) {
      return {
        code: code.replace(RE, (_, quote, value) => {
          if (quote === "`" && value.includes("${")) return _;

          return String(joaat(value));
        }),
        map: null,
      };
    },
  };
}
