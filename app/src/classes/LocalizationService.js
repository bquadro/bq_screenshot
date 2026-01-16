export default class LocalizationService {
  constructor(dictionary, defaultLanguage = 'ru') {
    this.dictionary = dictionary;
    this.currentLanguage = defaultLanguage;
  }

  t(key) {
    return (
      this.dictionary[this.currentLanguage]?.[key] ??
      this.dictionary.ru[key] ??
      ''
    );
  }

  setLanguage(value) {
    if (!value || !this.dictionary[value]) {
      this.currentLanguage = 'ru';
    } else {
      this.currentLanguage = value;
    }
  }
}
