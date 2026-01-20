import hotkeys from 'hotkeys-js';

const TOKEN_EXPANSIONS = {
  cmdorctrl: ['command', 'ctrl'],
};

const normalizeToken = (token) => token.trim().toLowerCase();

const comboVariants = (combo = '') => {
  const tokens = combo.split('+').map(normalizeToken).filter(Boolean);
  if (!tokens.length) {
    return [];
  }
  const expand = (index, current) => {
    if (index === tokens.length) {
      return [current.join('+')];
    }
    const token = tokens[index];
    const options = TOKEN_EXPANSIONS[token] || [token];
    return options.flatMap((opt) => expand(index + 1, [...current, opt]));
  };
  return expand(0, []);
};

export default class HotkeyController {
  constructor() {
    // Храним мапу зарегистрированных комбинаций для последующей очистки.
    this.bindings = new Map();
  }

  register(bindings = {}) {
    // Перерегистрируем комбинации: очищаем старые и вешаем новые.
    this.clear();
    console.log(bindings);
    Object.entries(bindings).forEach(([combo, handler]) => {
      const variants = comboVariants(combo);
      variants.forEach((variant) => {
        if (!variant) {
          return;
        }
        const expectedKey = variant.split('+').pop();
        const compareKey = expectedKey?.toLowerCase();
        const wrapped = (event) => {
          const actual = (event.key || '').toLowerCase();
          if (compareKey && compareKey !== actual) {
            return;
          }
          event.preventDefault();
          handler();
        };
        hotkeys(variant, wrapped);
        this.bindings.set(variant, wrapped);
      });
    });
  }

  clear() {
    // Убираем обработчики для всех зарегистрированных комбинаций.
    this.bindings.forEach((_handler, combo) => {
      hotkeys.unbind(combo);
    });
    this.bindings.clear();
  }

  dispose() {
    // Полностью очищаем контроллер.
    this.clear();
  }
}
