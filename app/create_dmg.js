#!/usr/bin/env node
const path = require('node:path');
const fs = require('node:fs');
const { execFileSync } = require('node:child_process');
const installer = require('electron-installer-dmg');

const rootDir = path.resolve(__dirname, '..');
const appDir = path.join(rootDir, 'app');
const makeDir = path.join(appDir, 'out', 'make');

const pkg = require(path.join(appDir, 'package.json'));
const productName = pkg.productName || pkg.name || 'App';
const iconPath = path.join(appDir, 'src', 'assets', 'app-icon.icns');

if (!fs.existsSync(makeDir)) {
  console.error('❌ out/make directory not found – run `npm run make` first');
  process.exit(1);
}

const findBuiltApps = () =>
  fs
    .readdirSync(makeDir, { withFileTypes: true })
    .filter((dirent) => dirent.isDirectory() && dirent.name.includes('darwin'))
    .map((dirent) => path.join(makeDir, dirent.name, `${productName}.app`))
    .filter((appPath) => fs.existsSync(appPath));

const zipDir = path.join(makeDir, 'zip');
const findZipFiles = (dir) => {
  if (!fs.existsSync(dir)) {
    return [];
  }
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const entryPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      return findZipFiles(entryPath);
    }
    if (entry.isFile() && entry.name.endsWith('.zip')) {
      return [entryPath];
    }
    return [];
  });
};

const unzipArchive = (zipPath) => {
  const tmpDir = path.join(makeDir, 'zip-extracted', path.basename(zipPath, '.zip'));
  fs.rmSync(tmpDir, { recursive: true, force: true });
  fs.mkdirSync(tmpDir, { recursive: true });
  execFileSync('unzip', ['-o', zipPath, '-d', tmpDir], { stdio: 'inherit' });
  const extractedBundles = fs
    .readdirSync(tmpDir, { withFileTypes: true })
    .filter((entry) => entry.isDirectory() && entry.name.endsWith('.app'))
    .map((entry) => path.join(tmpDir, entry.name));
  return extractedBundles;
};

let appBundles = findBuiltApps();

if (!appBundles.length) {
  const zipFiles = findZipFiles(zipDir);
  if (!zipFiles.length) {
    console.error('❌ No packaged .app bundles found under out/make');
    process.exit(1);
  }
  appBundles = zipFiles.flatMap((zipPath) => unzipArchive(zipPath));
}

const normalizedBundles = appBundles
  .filter((bundle) => bundle && typeof bundle === 'string')
  .map((bundle) => path.resolve(bundle))
  .filter((bundle) => fs.existsSync(bundle));

if (!normalizedBundles.length) {
  console.error('❌ No unpackaged .app bundles found under out/make');
  process.exit(1);
}

if (normalizedBundles.length !== appBundles.length) {
  console.warn('⚠️ Some app bundles were ignored because the path was invalid');
}

appBundles = normalizedBundles;

const outputDir = path.join(makeDir, 'dmg');
fs.mkdirSync(outputDir, { recursive: true });

const createDmg = async (appPath, index) => {
  const suffix = index > 0 ? `-${index + 1}` : '';
  const dmgPath = path.join(outputDir, `${productName}${suffix}.dmg`);
  await installer({
    appPath,
    name: productName,
    icon: iconPath,
    out: outputDir,
    overwrite: true,
    debug: false,
    appBundleId: pkg.buildId || pkg.appId || 'com.bqscreenshot.app',
    dmgPath,
  });
  return dmgPath;
};

(async () => {
  console.log('🌟 Creating DMG(s) for', productName);
  try {
    for (let i = 0; i < appBundles.length; i += 1) {
      const dmg = await createDmg(appBundles[i], i);
      console.log('✅ Created', dmg);
    }
  } catch (error) {
    console.error('❌ DMG creation failed:', error);
    process.exit(1);
  }
})();
