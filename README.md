# Pandoc + Emoji filter

## Generating documents

Use the shell script to build documents.

```console
docker pull ghcr.io/commonhaus/pandoc-pdf:edge-3
wget https://raw.githubusercontent.com/commonhaus/pandoc-pdf/refs/heads/main/build.sh

./build.sh

# Execute a command in the container
./build.sh sh -c 'ls /data'

# Invoke pandoc with arguments
./build.sh raw --help
```

## Agreements

> [!NOTE]
> `dirname` is the relative path to the file within the commonhaus/foundation repository.
> It is used by a filter to resolve intra-repository links.

### Asset transfer agreement

```console
./build.sh docx \
    -V dirname:./agreements/project-contribution/ \
    -o ./asset-transfer-agreement.docx \
      ./asset-transfer-agreement.md

# There are a few more settings specifically for agreements (vs policies or bylaws):

./build.sh pdf \
    -V dirname:./agreements/project-contribution/ \
    -o ./asset-transfer-agreement.pdf \
    -d /commonhaus/pandoc/agreements-pdf.yaml \
    -M 'title:Asset Transfer Agreement' \
    -M bodyTitle:true \
    ./asset-transfer-agreement.md
```

### Fiscal Sponsorship agreement

```console
./build.sh docx \
    -V dirname:./agreements/project-contribution/ \
    -o ./fiscal-sponsorship-agreement.docx \
      ./fiscal-sponsorship-agreement.md

# There are a few more settings specifically for agreements (vs policies or bylaws):

./build.sh pdf \
    -V dirname:./agreements/project-contribution/ \
    -o ./fiscal-sponsorship-agreement.pdf \
    -d /commonhaus/pandoc/agreements-pdf.yaml \
    -M 'title:Fiscal Sponsorship Agreement' \
    -M bodyTitle:true \
    ./fiscal-sponsorship-agreement.md
```


## Tex configuration

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
