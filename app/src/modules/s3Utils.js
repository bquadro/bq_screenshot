export const normalizeS3Endpoint = (value = '') => {
  const trimmed = (value || '').trim();
  if (!trimmed) {
    return '';
  }
  const withoutProtocol = trimmed.replace(/^[a-z]+:\/\//i, '');
  return withoutProtocol.replace(/\/.*$/, '');
};

export const ensureDomainEndpoint = (settingsForm) => {
  const normalized = normalizeS3Endpoint(settingsForm.s3Endpoint);
  if (normalized !== settingsForm.s3Endpoint) {
    settingsForm.s3Endpoint = normalized;
  }
};
