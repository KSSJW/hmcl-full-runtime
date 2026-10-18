#!/usr/bin/env bash

set -Eeuo pipefail

_HMCL_VERSION='3.16.4'
_HMCL_SHA256='98f0123f38e86a606aa583f74d21ae74128679e921ea7ec0c43ab26303767e9e'
_ICON_SHA256=''

_DISTRO_VERSION='25.36.205'
_JAVA_VERSION='25.0.4.1'
_RUNTIME_X86_64_SHA256='270ee89dfba987bbd2e16dc3c6e47a4c6c282ff777cf6f06c143de38eb10c1e2'
_RUNTIME_AARCH64_SHA256='9a1b93b5218d426b5c14392518eb2cc3158b67d764fd96f51036d1aa8bfee231'

_TOOL_SHA256=''

ARCH="$(uname -m)"
case "$ARCH" in
    x86_64)
        JAVA_ARCH='x64'
        TOOL_ARCH='x86_64'
        RUNTIME_SHA256="${_RUNTIME_X86_64_SHA256}"
        ;;
    aarch64)
        JAVA_ARCH='aarch64'
        JOOL_ARCH='aarch64'
        RUNTIME_SHA256="${_RUNTIME_AARCH64_SHA256}"
        ;;
    *)
        echo "Unsupported architecture: $ARCH" >&2
        exit 1
        ;;
esac

_RUNTIME_URL="https://cdn.azul.com/zulu/bin/zulu${_DISTRO_VERSION}-ca-fx-jre${_JAVA_VERSION}-linux${JAVA_ARCH}.tar.gz"

HMCL_URL="https://github.com/HMCL-dev/HMCL/releases/download/v${_HMCL_VERSION}/HMCL-${_HMCL_VERSION}.jar"
ICON_URL="https://raw.githubusercontent.com/HMCL-dev/HMCL/refs/heads/main/HMCL/src/main/resources/assets/img/icon%408x.png"
TOOL_URL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${TOOL_ARCH}.AppImage"

APPDIR='HMCL.AppDir'

RUNTIME_FILE='runtime.tar.gz'
HMCL_FILE='hmcl.jar'
ICON_FILE='hmcl.png'
TOOL_FILE='appimagetool.AppImage'

cd "$(dirname "$0")"
cd appimage

download() {
    local file="$1"
    local url="$2"
    local sha256="$3"
    local tmp="${file}.part"

    if [[ -n "$sha256" && -f "$file" ]] &&
       echo "$sha256  $file" | sha256sum -c --status; then
        echo "$file already exists and passed SHA-256 verification."
        return 0
    fi

    if [[ -z "$sha256" && -f "$file" ]]; then
        echo "Warning: SHA-256 is empty; skipping verification for existing file: $file" >&2
        return 0
    fi

    rm -f "$file" "$tmp"

    echo "Downloading $file ..."
    curl -fL --retry 3 -o "$tmp" "$url"

    if [[ -n "$sha256" ]]; then
        echo "$sha256  $tmp" | sha256sum -c -
    else
        echo "Warning: SHA-256 is empty; skipping verification for $file" >&2
    fi

    mv "$tmp" "$file"
}

mkdir -p \
    "$APPDIR/usr/lib/jvm" \
    "$APPDIR/usr/share/hmcl"

download "$RUNTIME_FILE" "$_RUNTIME_URL" "$RUNTIME_SHA256"
download "$HMCL_FILE" "$HMCL_URL" "$_HMCL_SHA256"
download "$ICON_FILE" "$ICON_URL" "$_ICON_SHA256"
download "$TOOL_FILE" "$TOOL_URL" "$_TOOL_SHA256"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

tar -xzf "$RUNTIME_FILE" -C "$TMP_DIR"

JAVA_PATH="$(find "$TMP_DIR" -type f -path '*/bin/java' -print -quit)"
if [[ -z "$JAVA_PATH" || ! -x "$JAVA_PATH" ]]; then
    echo "Error: Java executable not found in runtime archive." >&2
    exit 1
fi

JRE_DIR="${JAVA_PATH%/bin/java}"

rm -rf "$APPDIR/usr/lib/jvm/java"
mv "$JRE_DIR" "$APPDIR/usr/lib/jvm/java"

install -m 0644 "$HMCL_FILE" \
    "$APPDIR/usr/share/hmcl/hmcl.jar"
install -m 0644 "$ICON_FILE" "$APPDIR/hmcl.png"

chmod +x "$APPDIR/AppRun"
chmod +x "$TOOL_FILE"

ARCH="${TOOL_ARCH}" "./$TOOL_FILE" "$APPDIR" 'HMCL.AppImage'

mkdir -p ../build
mv 'HMCL.AppImage' '../build'
echo 'Built: build/HMCL.AppImage'
