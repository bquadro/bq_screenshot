const { FusesPlugin } = require('@electron-forge/plugin-fuses');
const { FuseV1Options, FuseVersion } = require('@electron/fuses');
const path = require('node:path');

const {
  APPLE_ID,
  APPLE_ID_PASSWORD,
  ASC_PROVIDER,
  CSC_NAME,
  CSC_KEY_PASSWORD,
  GITHUB_OWNER,
  GITHUB_REPO,
} = process.env;

const osxSign = {
  identity: CSC_NAME || 'Developer ID Application: bq screenshot',
  'hardened-runtime': true,
  'gatekeeper-assess': true,
};
if (CSC_KEY_PASSWORD) {
  osxSign['keychain'] = CSC_KEY_PASSWORD;
}

const osxNotarize =
  APPLE_ID && APPLE_ID_PASSWORD
    ? {
        appleId: APPLE_ID,
        appleIdPassword: APPLE_ID_PASSWORD,
        ascProvider: ASC_PROVIDER,
      }
    : undefined;

const publishers = [];
if (GITHUB_OWNER && GITHUB_REPO) {
  publishers.push({
    name: '@electron-forge/publisher-github',
    config: {
      repository: {
        owner: GITHUB_OWNER,
        name: GITHUB_REPO,
      },
      prerelease: false,
      draft: true,
    },
  });
}

module.exports = {
  packagerConfig: {
    asar: true,
    icon: path.join(__dirname, 'src', 'assets', 'app-icon'),
    osxSign,
    osxNotarize,
  },
  rebuildConfig: {},
  makers: [
    {
      name: '@electron-forge/maker-squirrel',
      config: {},
    },
    {
      name: '@electron-forge/maker-zip',
      platforms: ['darwin'],
    },
    {
      name: '@electron-forge/maker-deb',
      config: {},
    },
    {
      name: '@electron-forge/maker-rpm',
      config: {},
    },
  ],
  publishers,
  plugins: [
    {
      name: '@electron-forge/plugin-vite',
      config: {
        // `build` can specify multiple entry builds, which can be Main process, Preload scripts, Worker process, etc.
        // If you are familiar with Vite configuration, it will look really familiar.
        build: [
          {
            // `entry` is just an alias for `build.lib.entry` in the corresponding file of `config`.
            entry: 'src/main.js',
            config: 'vite.main.config.mjs',
            target: 'main',
          },
          {
            entry: 'src/preload.js',
            config: 'vite.preload.config.mjs',
            target: 'preload',
          },
        ],
        renderer: [
          {
            name: 'main_window',
            config: 'vite.renderer.config.mjs',
          },
        ],
      },
    },
    // Fuses are used to enable/disable various Electron functionality
    // at package time, before code signing the application
    new FusesPlugin({
      version: FuseVersion.V1,
      [FuseV1Options.RunAsNode]: false,
      [FuseV1Options.EnableCookieEncryption]: true,
      [FuseV1Options.EnableNodeOptionsEnvironmentVariable]: false,
      [FuseV1Options.EnableNodeCliInspectArguments]: false,
      [FuseV1Options.EnableEmbeddedAsarIntegrityValidation]: true,
      [FuseV1Options.OnlyLoadAppFromAsar]: true,
    }),
  ],
};
