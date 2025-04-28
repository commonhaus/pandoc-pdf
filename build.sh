#!/bin/bash

# Docker image for pandoc
if [[ -z "${PANDOCK}" ]]; then
    PANDOCK=ghcr.io/commonhaus/pandoc-pdf:edge-3
fi

DATE=$(date "+%Y-%m-%d")
if [[ -z "${FOOTER}" ]]; then
    FOOTER=${DATE}
fi

if [[ -z "${GITHUB_URL}" ]]; then
    GITHUB_URL=https://github.com/commonhaus/foundation
fi

# Docker command and arguments
ARGS="--rm -e TERM -e HOME=/data -u $(id -u):$(id -g) -v $(pwd):/data -w /data"
if [[ "$OSTYPE" == "darwin"* ]]; then
    ARGS="$ARGS --platform linux/amd64"
elif [[ "$DOCKER" == "podman" ]] || docker version 2>/dev/null | grep -qi podman; then
    ARGS="$ARGS --userns=keep-id"
fi
# Set DOCKER if not already defined
if [[ -z "${DOCKER}" ]]; then
    DOCKER=docker
fi
if [[ "${DRY_RUN}" == "true" ]]; then
    DOCKER="echo ${DOCKER}"
fi

function run_shell() {
    ${DOCKER} run ${ARGS} --entrypoint="" "${PANDOCK}" "$@"
}

function run_pandoc() {
    ${DOCKER} run ${ARGS} "${PANDOCK}" "$@"
}

# Convert markdown to PDF
function run_pdf() {
    mkdir -p pdf-tmp

    ${DOCKER} run ${ARGS} \
        "${PANDOCK}" \
        --pdf-engine-opt=--output-directory=./pdf-tmp \
        --pdf-engine-opt=-output-dir=./pdf-tmp \
        --pdf-engine-opt=-outdir=./pdf-tmp \
        -d /commonhaus/pandoc/pdf-common.yaml \
        -M date-meta:"$(date +%B\ %d,\ %Y)" \
        -V footer-left:"${FOOTER}" \
        -V github:"${GITHUB_URL}" \
        "$@"

    echo "$?"
}

# Convert markdown to DOCX
function run_docx() {
    ${DOCKER} run ${ARGS} \
        "${PANDOCK}" \
        -d "/commonhaus/pandoc/agreements-docx.yaml" \
        -M date-meta:"$(date +%B\ %d,\ %Y)" \
        -V github:"${GITHUB_URL}" \
        "$@"

    echo "$?"
}

TO_CMD=${1:-noargs}
if [[ "${TO_CMD}" == "noargs" ]]; then
cat << HELP
Usage: $0 [sh|raw|docx|pdf]

  - sh: Invoke command in the container (e.g. sh -c 'ls -al /commonhaus')
  - raw: Pass remaining arguments to pandoc (e.g. --help)
  - docx: Create a docx with remaining arguments
  - pdf: Create a pdf with remaining arguments

For document creation, you should have a recent copy of CONTACTS.yaml in the 
current working directory.

Generating DOCX Agreements is the most straight-forward, you need only two parameters: 
-o to specify the output file, and the source markdown.

As an example (based on the foundation repo structure), the asset transfer agreement
could be built this way:

    ${0} docx \\
        -o ./output/public/asset-transfer-agreement.docx \\
         ./agreements/project-contribution/asset-transfer-agreement.md

Generating PDFs is a little more complicated. You still use -o to specify the pdf 
output file name, but there are other arguments that can also be useful.

If your source file is in a nested directory and it contains relative links, 
use '-V dirname:<relative_path>' to ensure that those relative paths can be resolved.

If you want a Table of Contents, include those options (--toc=true, --toc-depth=3)

PDFs look better when you specify a metadata title: -M "title:<your title>"

If your document also has a title (h1) that will be displayed in the content, 
avoid printing this metadata title using -M bodyTitle:true

If you want to avoid breaks at the beginning of sections, use: -M noHeaderBreak:true

If this pdf is for an agreement, also include the common agreement configuration:
   -d  "/commonhaus/pandoc/agreements-docx.yaml"

Examples:

Notes: 
- The variations of output directory options are used by different stages of pdf generation.

Building a PDF of our bylaws:

    $0 pdf \\
        -V dirname:./bylaws/ \\
        -o ./cf-bylaws.pdf \\
        --toc=true --toc-depth=3 \\
        -M title:Bylaws \\
        ./bylaws/1-preface.md ./bylaws/2-purpose.md ./bylaws/3-cf-membership.md \\
        ./bylaws/4-cf-council.md ./bylaws/5-cf-advisory-board.md \\
        ./bylaws/6-decision-making.md ./bylaws/7-notice-records.md \\
        ./bylaws/8-indemnification-dissolution.md ./bylaws/9-amendments.md

Building a PDF for a policy:

    $0 pdf \\
        -V dirname:./policies/ \\
        -o ./conflict-of-interest.pdf \\
        -M 'title:Conflict of Interest Policy' \\
        ./policies/conflict-of-interest.md

Building a PDF for an agreement:

    $0 pdf \\
        -V dirname:./agreements/... \\
        -o ./asset-transfer-agreement.pdf \\
        -d /commonhaus/pandoc/agreements-pdf.yaml \\
        -M 'title:Asset Transfer Agreement' \\
        -M bodyTitle:true \\
        ./agreements/project-contribution/asset-transfer-agreement.md

Note that dirname is the relative path to the file within the 
commonhaus/foundation repository. It is used by a filter to resolve 
intra-repository links.
HELP
exit
fi
# Invoke command in the pandock container with common docker arguments
if [[ "${TO_CMD}" == "sh" ]]; then
    # ./build.sh sh -c 'ls -ld /data/output'
    run_shell "$@"
    exit 0
fi

# Invoke pandoc with common docker arguments
if [[ "${TO_CMD}" == "raw" ]]; then
    shift
    run_pandoc "$@"
    exit 0
fi

if [[ ! -f CONTACTS.yaml ]]; then
    if ! wget https://raw.githubusercontent.com/commonhaus/foundation/refs/heads/main/CONTACTS.yaml; then
        echo "Please ensure that a copy of CONTACTS.yaml is available in the current
    working directory for resolution of mailing list links."
        exit 1
    fi
fi

# Invoke pandoc with common docker arguments
if [[ "${TO_CMD}" == "docx" ]]; then
    shift
    run_docx "$@"
    exit 0
fi

# Invoke pandoc with common docker arguments
if [[ "${TO_CMD}" == "pdf" ]]; then
    shift
    run_pdf "$@"
    exit 0
fi