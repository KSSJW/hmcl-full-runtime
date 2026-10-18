# HMCL Full Runtime

Scripts for building portable HMCL packages for Linux with a bundled JavaFX runtime.

## Custom

You can edit the HMCL version, as well as the runtime distribution and version, to be included in the package (Zulu JRE FX is used by default).

Example:

```
_HMCL_VERSION='3.16.4'
_HMCL_SHA256='98f0123f38e86a606aa583f74d21ae74128679e921ea7ec0c43ab26303767e9e'

_DISTRO_VERSION='25.36.205'
_JAVA_VERSION='25.0.4.1'
_RUNTIME_X86_64_SHA256='270ee89dfba987bbd2e16dc3c6e47a4c6c282ff777cf6f06c143de38eb10c1e2'
_RUNTIME_AARCH64_SHA256='9a1b93b5218d426b5c14392518eb2cc3158b67d764fd96f51036d1aa8bfee231'

...

_RUNTIME_URL="https://cdn.azul.com/zulu/bin/zulu${_DISTRO_VERSION}-ca-fx-jre${_JAVA_VERSION}-linux${JAVA_ARCH}.tar.gz"
```

## Build

1. Clone or download this repository.
2. Make `MakeAppImage.sh` executable:

   ```bash
   chmod +x MakeAppImage.sh
   ```

3. Run the build script:

   ```bash
   ./MakeAppImage.sh
   ```

4. Find the generated packages in the `build` directory.
