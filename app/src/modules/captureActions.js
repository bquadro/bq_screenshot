export function createCaptureActions({
  captureService,
  settingsForm,
  captureStatus,
  previewUrl,
  editorImage,
  areaImage,
  currentPage,
  isCapturing,
  screenshotPath,
  updateUploadLink,
  t,
}) {
  const showWindowAfterCapture = async () => {
    if (!window.electronAPI?.showMainWindow) {
      return;
    }
    try {
      await window.electronAPI.showMainWindow();
    } catch (error) {
      console.error('show window', error);
    }
  };

  const captureFullScreen = async () => {
    captureStatus.value = t('capture.statusSaving');
    isCapturing.value = true;
    previewUrl.value = '';

    try {
      const base64 = await captureService.capture();
      editorImage.value = `data:image/png;base64,${base64}`;
      currentPage.value = 'editor';
      captureStatus.value = t('capture.statusEditorOpen');

      const saved = await captureService.save(base64);
      if (saved?.filePath) {
        screenshotPath.value = saved.filePath;
        await updateUploadLink(saved.filePath);
      } else {
        captureStatus.value = t('capture.statusNoPath');
      }

      await showWindowAfterCapture();
    } catch (error) {
      console.error('capture', error);
      captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusUnknownError')}`;
      previewUrl.value = '';
    } finally {
      isCapturing.value = false;
    }
  };

  const captureArea = async () => {
    captureStatus.value = t('capture.areaSelecting');
    isCapturing.value = true;
    previewUrl.value = '';

    try {
      const base64 = await captureService.capture();
      areaImage.value = `data:image/png;base64,${base64}`;
      currentPage.value = 'area';

      const saved = await captureService.save(base64);
      if (saved?.filePath) {
        screenshotPath.value = saved.filePath;
        await updateUploadLink(saved.filePath);
      } else {
        captureStatus.value = t('capture.statusNoPath');
      }

      await showWindowAfterCapture();
    } catch (error) {
      console.error('capture area', error);
      captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusAreaError')}`;
    } finally {
      isCapturing.value = false;
    }
  };

  const handleEditorSave = async (dataUrl) => {
    currentPage.value = 'home';
    isCapturing.value = true;
    captureStatus.value = t('capture.statusSaving');

    try {
      const base64Payload = dataUrl.split(',')[1];
      const result = await captureService.save(base64Payload, screenshotPath.value);
      if (result?.filePath) {
        screenshotPath.value = result.filePath;
        await updateUploadLink(result.filePath);
      }
      previewUrl.value = dataUrl;
      captureStatus.value = `${t('capture.statusSaved')} ${result.filePath}`;
    } catch (error) {
      console.error('editor save', error);
      captureStatus.value = `${t('capture.statusError')} ${error?.message || t('capture.statusUnknownError')}`;
    } finally {
      isCapturing.value = false;
      editorImage.value = '';
    }
  };

  const handleEditorCancel = () => {
    currentPage.value = 'home';
    captureStatus.value = t('capture.statusEditorCanceled');
    isCapturing.value = false;
    editorImage.value = '';
  };

  const startRecording = () => {
    captureStatus.value = t('capture.recordingPlaceholder');
  };

  return {
    captureFullScreen,
    captureArea,
    handleEditorSave,
    handleEditorCancel,
    startRecording,
  };
}
