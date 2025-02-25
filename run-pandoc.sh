#!/bin/bash -x

# Docker command and arguments
ARGS="--rm -e TERM -u $(id -u):$(id -g) -e HOME=/data -v $(pwd):/data -w /data"
if [[ "$OSTYPE" == "darwin"* ]]; then
    ARGS="$ARGS --platform linux/amd64"
fi
if [[ "${DRY_RUN}" == "true" ]]; then
    DOCKER="echo docker"
elif [[ -z "${DOCKER}" ]]; then
    DOCKER=docker
fi

function run_shell() {
    ${DOCKER} run ${ARGS} --entrypoint="" "${PANDOCK}" "$@"
}

function run_pandoc() {
    ${DOCKER} run ${ARGS} "${PANDOCK}" "$@"
}

# Convert markdown to PDF (container-relative paths)
function run_pdf() {
    mkdir -p ${WORKDIR}

    ${DOCKER} run ${ARGS} \
        "${PANDOCK}" \
        --pdf-engine-opt=-output-dir="${WORKDIR}" \
        --pdf-engine-opt=-outdir="${WORKDIR}" \
        -d /commonhaus/pdf-common.yaml \
        -M date-meta:"$(date +%B\ %d,\ %Y)" \
        -V footer-left:"${FOOTER}" \
        -V github:"${URL}" \
        "$@"

    echo "$?"
}

# Convert markdown to DOCX (container-relative paths)
function run_docx() {
    local config="/commonhaus/agreements.yaml"
    if [[ "${DRAFT}" == "true" ]]; then
        config="/commonhaus/draft-agreements.yaml"
    fi

    ${DOCKER} run ${ARGS} \
        "${PANDOCK}" \
        -d ${config} \
        -M date-meta:"$(date +%B\ %d,\ %Y)" \
        -V github:"${URL}" \
        "$@"

    echo "$?"
}

DATE=$(date "+%Y-%m-%d")
DRAFT=
FOOTER="${DATE}"
URL=https://github.com/commonhaus/foundation
PANDOCK=ghcr.io/commonhaus/pandoc-pdf:3.1
WORKDIR=./.pandoc

for x in "$@"; do
  case "$x" in
    --help)
      echo "Usage: $0 [options] [sh|raw|docx|pdf] [ARGS]"
      echo
      echo "To run pandoc standalone: $0 raw [pandoc command arguments]"
      echo "To run a shell commandin the container: $0 sh [command]"
      echo "To create a docx: $0 docx [additional pandoc arguments]"
      echo "To create a pdf: $0 pdf [additional pandoc arguments]"
      echo
      echo "The default action is raw (run pandoc with no arguments for help)"
      echo
      echo "Options:
    --draft
    --footer=\"alternate document footer\"
    --pandock=\"pandoc/container/tag:version\"
    --wd=\"workingDirectory\"
    --url=\"https://github.com/organization/repository\"
"
      exit 0
      ;;
    --draft)
      DRAFT=true
      shift
      ;;
    --footer=*)
      FOOTER="${x#*=}"
      shift
      ;;
    --pandock=*)
      PANDOCK="${x#*=}"
      shift
      ;;
    --wd=*)
      WORKDIR="${x#*=}"
      shift
      ;;
    --url=*)
      URL="${x#*=}"
      shift
      ;;
    *)
      ;;
  esac
done

TO_CMD=${1:-noargs}
if [[ "${TO_CMD}" == "noargs" ]]; then
    TO_CMD=raw
else
    ## an argument was specified, should start with sh|raw|docx|pdf
    ## remove that from the list of args passed to command
    shift
fi
echo "$@"

# Invoke a shell command in the pandock container with common docker arguments
if [[ "${TO_CMD}" == "sh" ]]; then
    run_shell "$@"
    exit 0
fi

# Invoke pandoc with common docker arguments
if [[ "${TO_CMD}" == "raw" ]]; then
    run_pandoc "$@"
    exit 0
fi

# Create a docx with common attributes and provided arguments
if [[ "${TO_CMD}" == "docx" ]]; then
    run_docx "$@"
    exit 0
fi

# Create a docx with common attributes and provided arguments
if [[ "${TO_CMD}" == "pdf" ]]; then
    run_pdf "$@"
    exit 0
fi

