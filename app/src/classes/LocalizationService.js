export default class LocalizationService {
  constructor(dictionary, defaultLanguage = 'ru') {
    this.dictionary = dictionary;
    this.currentLanguage = defaultLanguage;
  }

  t(key, replacements = {}) {
    const text =
      this.dictionary[this.currentLanguage]?.[key] ??
      this.dictionary.ru[key] ??
      '';

    if (!text || !replacements || typeof replacements !== 'object') {
      return text;
    }

    return Object.entries(replacements).reduce((message, [placeholder, value]) => {
      if (!message) {
        return message;
      }
      const safeValue = value ?? '';
      const token = new RegExp(`\\{${placeholder}\\}`, 'g');
      return message.replace(token, safeValue);
    }, text);
  }

  setLanguage(value) {
    if (!value || !this.dictionary[value]) {
      this.currentLanguage = 'ru';
    } else {
      this.currentLanguage = value;
    }
  }
}
