const fs = require('fs');

const version = process.env.TGT_RELEASE_VERSION;
const newVersion = version.replace('v', '');

const packageFile = fs.readFileSync('package/package.json', { encoding: 'utf8' });

const newFileContent = packageFile.replace(/"version":\s+"(.*)",$/gm, `"version": "${newVersion}",`);

fs.writeFileSync('package/package.json', newFileContent);
