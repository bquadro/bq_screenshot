window.addEventListener('DOMContentLoaded', () => {
  const versionNode = document.getElementById('electron-version');
  if (versionNode && window.electronAPI) {
    versionNode.innerText = window.electronAPI.getElectronVersion();
  }
});
