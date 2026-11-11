import { cp, readFile, writeFile, access } from "node:fs/promises";
import fg from "fast-glob";
import { dirname, extname } from "node:path";
import type Package from "../package.json";
import { generateInterface } from "./typegen.ts";
import { $ } from "zx";

function reduceArray(name: string, files?: string[]): string {
  return files?.[0]
    ? `\n${name} {${files.reduce((acc, value) => {
        return value ? `${acc}\n\t'${value}',` : acc;
      }, "")}\n}\n`
    : "";
}

async function generateDirectoryGlobs(root: string, useRoot = false) {
  const files = await fg("**/*", {
    cwd: root,
    onlyFiles: true,
  });

  const groups = new Map<string, Set<string>>();

  for (const file of files) {
    const dir = dirname(file);

    let ext = extname(file);

    if (ext === ".") {
      ext = "";
    }

    let exts = groups.get(dir);

    if (!exts) {
      exts = new Set();
      groups.set(dir, exts);
    }

    exts.add(ext);
  }

  const path = useRoot ? root : "dist";

  return [...groups.entries()].flatMap(([dir, exts]) => {
    const prefix = dir === "." ? `${path}/` : `${path}/${dir}/`;

    return [...exts].map((ext) => {
      return ext ? `${prefix}*${ext}` : `${prefix}*`;
    });
  });
}

let buildCount = 0;
let fxmanifest = "";
let watch = process.argv[2] === "--watch";

export default async function () {
  if (++buildCount < 2) return;

  const { name, author, version, license, description }: typeof Package = JSON.parse(
    await readFile("./package.json", "utf8"),
  );

  const files = await generateDirectoryGlobs("public");

  files.unshift(
    "init.lua",
    "require.lua",
    "resource/settings.lua",
    "imports/**/client.lua",
    "imports/**/shared.lua",
    "locales/*.json",
    "modules/*.lua",
    "modules/**/*.lua",
  );

  let body = Object.entries({
    name,
    author: author.name,
    version,
    license,
    description,
  }).reduce((acc, [key, value]) => (value ? `${acc}${key} '${value}'\n` : acc), "");

  body += `fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
games { 'rdr3', 'gta5' }
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
    '/onesync',
    'require',
}

fx_dependencies {
    'require: 1.0.2',
}

shared_scripts {
    'resource/init.lua',
    'resource/**/shared.lua'
}

client_scripts {
    'resource/**/client.lua',
    'resource/**/client/*.lua'
}

server_scripts {
    'imports/callback/server.lua',
    'imports/hook/shared.lua',
    'imports/registerHook/shared.lua',
    'imports/getFilesInDirectory/server.lua',
    'resource/**/server.lua',
    'resource/**/server/*.lua',
}

client_script 'dist/client.js'
server_script 'dist/dummy.js'
`;

  try {
    await access("./web");

    if (!watch) await $`nub run webbuild`;

    files.push(...(await generateDirectoryGlobs("web/build", true)));

    body += `\nui_page 'web/build/index.html'\n`;
  } catch {}

  body += reduceArray("files", files);

  if (body === fxmanifest) return;

  const dummy = `require("./dist/server/server.js");`;
  fxmanifest = body;

  generateInterface("public");

  await Promise.all([
    writeFile("./fxmanifest.lua", body),
    writeFile("./dist/dummy.js", dummy),
    cp("./public", "./dist", { recursive: true }),
  ]);

  console.log(`Generated new fxmanifest.lua`);
}
