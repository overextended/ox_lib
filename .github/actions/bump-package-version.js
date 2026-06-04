const packageJson = await Bun.file('./package/package.json').json();

const newVersion = process.env.TGT_RELEASE_VERSION;
packageJson.version = newVersion.replace('v', '');

await Bun.write('./package/package.json', JSON.stringify(packageJson, null, 2));
