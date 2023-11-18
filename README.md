# Pandoc + Emoji filter


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


