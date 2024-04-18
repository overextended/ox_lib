## Enhance RadialMenu Component Scalability and Text Handling

### Before

![alt text](https://i.imgur.com/kz4OyAn.png)

### After

_there are some visual changes made to this in order to better visualise each menu option_

![alt text](https://i.imgur.com/v0sKHJd.png)

This change introduces two main enhancements to the `RadialMenu` component:

1. **Improved Text Wrapping**: Implements conditional logic to better handle text wrapping within the SVG, ensuring that long labels do not overlap with other UI elements and are more readable.

2. **Dynamic Scaling**: Adjusts the SVG dimensions to scale the entire component by an additional 5% to accommodate interface scalability requirements.

## Changes Detail

### 1. Text Splitting Utility: `splitTextIntoLines`

To address the challenge of text wrapping in SVG elements within React, which do not support automatic line breaking, I introduced a utility function named `splitTextIntoLines`. This function splits a single string of text into an array of strings, where each string represents a line that fits within a specified maximum character length. This approach ensures text does not overflow its designated area and remains readable.

**Functionality:**
The function takes two parameters:

- `text`: The string of text to be split into lines.
- `maxCharPerLine`: The maximum number of characters allowed per line.

It processes the text by splitting it at spaces to respect word boundaries and then reassembles lines until adding another word would exceed the `maxCharPerLine` limit. This method ensures that words are not abruptly cut off, maintaining readability and aesthetic appeal.

**File Affected:**

- `RadialMenu.tsx`

**Code Snippet:**

```typescript
const splitTextIntoLines = (text: string, maxCharPerLine: number): string[] => {
  const words = text.split(" ");
  const lines: string[] = [];
  let currentLine = words[0];

  for (let i = 1; i < words.length; i++) {
    if (currentLine.length + words[i].length + 1 <= maxCharPerLine) {
      currentLine += " " + words[i];
    } else {
      lines.push(currentLine);
      currentLine = words[i];
    }
  }
  lines.push(currentLine);
  return lines;
};
```

### Rationale

- **Adaptability**: By dynamically adjusting to the length of text content, the function helps prevent UI clutter and overlap, enhancing user interaction with the menu.

- **Scalability**: This function allows text elements within the SVG to gracefully handle varying amounts of content, which is particularly important for applications with internationalization where text length can vary significantly.

### 2. Conditional Icon Spacing in Text Wrapping

- Introduced a utility function `calculateIconYOffset` to adjust icon placement based on whether the associated text wraps to multiple lines.
- Used a ternary operator to conditionally apply vertical spacing, improving the legibility and aesthetic of the menu items when text labels extend beyond a single line.

**File Affected:**

- `RadialMenu.tsx`

**Code Snippet:**

```typescript
const calculateIconYOffset = (label: string, maxCharPerLine: number): number => {
  const lines = splitTextIntoLines(label, maxCharPerLine);
  return lines.length > 1 ? 4 : 0; // Adjust icon position based on line count
};

...
<text
  y={iconY + calculateIconYOffset(item.label, 15)}
  ...
>
  {item.label}
</text>
```

### 3. SVG Scaling

- Updated the SVG `width` and `height` attributes to scale the component size by a total of 110.25% relative to the original dimensions. This was achieved by compounding an additional 5% increase on the previously scaled size.

- Adjusted the `viewBox` to maintain the original component's internal coordinate system, ensuring that the elements scale proportionally.

- Recalculated the radial dimensions and positions within the SVG to maintain visual and functional integrity at the new size.

**File Affected:**

- `RadialMenu.tsx`

**Code Snippet:**

```typescript
const baseDimension = 350;
const scale = 1.1025; // compounded scale factor
const newDimension = baseDimension * scale;

return (
  <svg width={`${newDimension}px`} height={`${newDimension}px`} viewBox="0 0 350 350" transform="rotate(90)">
    ...
  </svg>
);
```

### Rationale

- **Scalability:** As the application's user interface is used in varied screen sizes and resolutions, scaling the RadialMenu ensures it remains functional and visually consistent across devices.

- **Readability:** Handling text wrapping effectively prevents UI elements from overlapping, which is crucial in dense information displays like radial menus. The conditional positioning of icons ensures that the interface remains uncluttered and easy to interact with.

### Conclusion

These changes aim to enhance the usability and visual quality of the `Radial Menu` within ox_lib.
I've not been using React for very long and I'd appreciate some feedback on these changes. My hope is that it'll provide easier use for those who don't want to tinker around and rebuild the app.

---

A FiveM library and resource implementing reusable modules, methods, and UI elements.

![](https://img.shields.io/github/downloads/overextended/ox_lib/total?logo=github)
![](https://img.shields.io/github/downloads/overextended/ox_lib/latest/total?logo=github)
![](https://img.shields.io/github/contributors/overextended/ox_lib?logo=github)
![](https://img.shields.io/github/v/release/overextended/ox_lib?logo=github)

## 📚 Documentation

https://overextended.dev/ox_lib

## 💾 Download

https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip

## npm Package

https://www.npmjs.com/package/@overextended/ox_lib

## Lua Language Server

- Install [Lua Language Server](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) to ease development with annotations, type checking, diagnostics, and more.
- Install [cfxlua-vscode](https://marketplace.visualstudio.com/items?itemName=overextended.cfxlua-vscode) to add natives and cfxlua runtime declarations to LLS.
- You can load ox_lib into your global development environment by modifying workspace/user settings "Lua.workspace.library" with the resource path.
  - e.g. "c:/fxserver/resources/ox_lib"
