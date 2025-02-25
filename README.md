# Pandoc + Emoji filter

## Formatting

Config, content, and filters are provided for standard Commonhaus formatting.

`run-pandoc.sh` is not included in the container. 

Use it to launch the container locally. A variant is used by GitHub Actions in the 
Commonhaus Foundation repository to generate pdf and docx files for Bylaws, Policies, 
and Agreements.

## Font settings

```tex
\directlua{luaotfload.add_fallback
   ("emojifallback",
    {
      "NotoColorEmoji:mode=harf;"
    }
   )}
% Setting the main font to IBM Plex Sans
\setmainfont{IBMPlexSans-Regular}[
  Extension      = .otf ,
  BoldFont       = IBMPlexSans-Bold,
  ItalicFont     = IBMPlexSans-Italic,
  BoldItalicFont = IBMPlexSans-BoldItalic,
  RawFeature={fallback=emojifallback}
]

% Setting the monospace font to IBM Plex Mono
\setmonofont{IBMPlexMono-Regular}[
  Extension      = .otf ,
  BoldFont       = IBMPlexMono-Bold,
  ItalicFont     = IBMPlexMono-Italic,
  BoldItalicFont = IBMPlexMono-BoldItalic
]
```


