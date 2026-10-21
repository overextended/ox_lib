const legacyCopy = (value: string) => {
  const clipElem = document.createElement('textarea');
  clipElem.value = value;
  clipElem.style.position = 'fixed';
  clipElem.style.opacity = '0';
  document.body.appendChild(clipElem);
  clipElem.focus();
  clipElem.select();
  try {
    document.execCommand('copy');
  } finally {
    document.body.removeChild(clipElem);
  }
};

export const setClipboard = (value: string) => {
  if (navigator.clipboard?.writeText) {
    navigator.clipboard.writeText(value).catch(() => legacyCopy(value));
    return;
  }

  legacyCopy(value);
};
