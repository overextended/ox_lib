import { readdirSync, writeFileSync } from "node:fs";
import path from "node:path";

function normalize(file: string): string {
  return file.replace(/\\/g, "/");
}

function walk(dir: string): string[] {
  const entries = readdirSync(dir, { withFileTypes: true });

  return entries.flatMap((entry) => {
    const full = path.join(dir, entry.name);

    return entry.isDirectory() ? walk(full) : [full];
  });
}

export function generateInterface(dir: string) {
  const files = walk(dir);
  const name = dir.charAt(0).toUpperCase() + dir.slice(1);
  const lines: string[] = ["/* auto-generated */", "", `declare interface ${name} {`];

  for (const file of files) {
    const relative = normalize(path.relative(".", file));
    const extension = path.extname(file);
    let type = "string";

    switch (extension) {
      case ".json":
      case ".js":
        type = `typeof import("../${relative}")`;
        break;
    }

    lines.push(`\t"${relative}": ${type};`);
  }

  lines.push("}");

  writeFileSync(`types/${dir}.d.ts`, lines.join("\n"), "utf8");
}
