let state = (Date.now() ^ (Math.random() * 0xffffffff)) >>> 0;

function byte() {
  state ^= state << 13;
  state ^= state >>> 17;
  state ^= state << 5;

  return (state >>> 0) & 0xff;
}

const hex = (n: number) => n.toString(16).padStart(2, '0');

export const uuid = {
  /** Generates a UUID v7 string. */
  generate() {
    let timestamp = Date.now();
    const bytes = Array(16);

    for (let i = 0; i < 6; i++) {
      bytes[i] = (timestamp >> (40 - i * 8)) & 0xff;
    }

    for (let i = 6; i < 16; i++) {
      bytes[i] = byte();
    }

    bytes[6] = (bytes[6] & 0x0f) | 0x70;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    return bytes
      .map(hex)
      .join('')
      .replace(/^(.{8})(.{4})(.{4})(.{4})(.{12})$/, '$1-$2-$3-$4-$5');
  },

  /** Checks if a string is a valid UUID v7. */
  validate(str: string) {
    if (typeof str !== 'string' || str.length !== 36) return false;

    const re = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

    if (!re.test(str)) return false;

    const version = parseInt(str[14], 16);
    const variant = parseInt(str[19], 16);

    return version === 7 && (variant & 0x8) === 0x8;
  },
};
