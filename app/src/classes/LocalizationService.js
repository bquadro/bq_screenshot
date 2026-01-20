export default class LocalizationService {
  constructor(dictionary, defaultLanguage = 'ru') {
    // Храним словари переводов и инициализируем язык.
    this.dictionary = dictionary;
    this.currentLanguage = defaultLanguage;
  }

  t(key) {
    // Возвращает перевод по ключу для текущего языка, или fallback на русский.
    return (
      this.dictionary[this.currentLanguage]?.[key] ??
      this.dictionary.ru[key] ??
      ''
    );
  }

  setLanguage(value) {
    // Меняет текущий язык, если значение допустимо, иначе сбрасывает на русский.
    if (!value || !this.dictionary[value]) {
      this.currentLanguage = 'ru';
    } else {
      this.currentLanguage = value;
    }
  }
}
