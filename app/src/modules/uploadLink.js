export function useUploadLink({ settingsForm, uploadService, uploadedLink, linkStatus, t }) {
  const updateUploadLink = async (filePath) => {
    if (!filePath) {
      uploadedLink.value = '';
      linkStatus.value = '';
      return;
    }
    if (!settingsForm.uploadToS3) {
      uploadedLink.value = '';
      linkStatus.value = '';
      return;
    }

    try {
      const { url, error } = await uploadService.upload(filePath);
      if (url) {
        uploadedLink.value = url;
        linkStatus.value = t('capture.linkCopied');
      } else {
        uploadedLink.value = '';
        linkStatus.value = error ? `${t('capture.linkUploadError')} ${error}` : t('capture.linkUploadFailed');
      }
    } catch (uploadError) {
      uploadedLink.value = '';
      linkStatus.value = `${t('capture.linkUploadError')} ${uploadError?.message || ''}`;
    }
  };

  const copyUploadedLink = async () => {
    if (!uploadedLink.value) {
      return;
    }
    try {
      await navigator.clipboard.writeText(uploadedLink.value);
      linkStatus.value = t('capture.linkCopied');
    } catch (error) {
      console.error('clipboard copy', error);
      linkStatus.value = `${t('capture.linkUploadError')} ${error?.message || ''}`;
    }
  };

  return { updateUploadLink, copyUploadedLink };
}
