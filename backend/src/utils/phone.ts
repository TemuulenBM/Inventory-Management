/**
 * Phone Number Validation Utility
 *
 * Монгол утасны дугаар шалгах utility.
 * Format: +976XXXXXXXX (8 оронтой дугаар)
 */

/**
 * Монгол утасны дугаар шалгах
 *
 * Зөвшөөрөгдөх форматууд:
 * - +97699119911
 * - 97699119911
 * - 99119911
 *
 * @param phone - Шалгах утасны дугаар
 * @returns Стандарт формат руу хөрвүүлсэн дугаар эсвэл null
 */
export function validatePhone(phone: string): string | null {
  // Whitespace арилгах
  const cleaned = phone.replace(/\s/g, '');

  // Pattern matching
  const patterns = [
    /^\+976(\d{8})$/, // +97699119911
    /^976(\d{8})$/,   // 97699119911
    /^(\d{8})$/,      // 99119911
  ];

  for (const pattern of patterns) {
    const match = cleaned.match(pattern);
    if (match) {
      const localNumber = match[1];

      // Эхний цифр 6, 7, 8, 9 байх ёстой (Mongolian mobile prefixes)
      if (['6', '7', '8', '9'].includes(localNumber[0])) {
        return `+976${localNumber}`;
      }
    }
  }

  return null;
}

/**
 * Утасны дугаар зөв эсэхийг шалгах (boolean)
 *
 * @param phone - Шалгах утасны дугаар
 * @returns Зөв бол true, үгүй бол false
 */
export function isValidPhone(phone: string): boolean {
  return validatePhone(phone) !== null;
}

/**
 * Утасны дугаарыг format хийх (display хийхэд ашиглана)
 *
 * Example: +97699119911 → +976 9911 9911
 *
 * @param phone - Format хийх дугаар
 * @returns Formatted дугаар эсвэл original string
 */
export function formatPhone(phone: string): string {
  const validated = validatePhone(phone);
  if (!validated) {
    return phone;
  }

  // +97699119911 → +976 9911 9911
  return validated.replace(/^\+976(\d{4})(\d{4})$/, '+976 $1 $2');
}

/**
 * Хоёр утасны дугаар ижил эсэхийг харьцуулах
 *
 * @param phone1 - Эхний дугаар
 * @param phone2 - Хоёрдугаар дугаар
 * @returns Ижил бол true
 */
export function phoneEquals(phone1: string, phone2: string): boolean {
  const validated1 = validatePhone(phone1);
  const validated2 = validatePhone(phone2);

  if (!validated1 || !validated2) {
    return false;
  }

  return validated1 === validated2;
}
