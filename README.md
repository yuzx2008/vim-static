# vim build

- linux: x64 static; do not depend on libc;

- win32: x86; no OLE. (older vim version may not build since github actions use vs2019)

This repo is fork from <https://github.com/dtschan/vim-static>,
to be used in docker.

For win32,
[build.bat](build.bat) is from <https://github.com/vim/vim-win32-installer>

## example build step (for linux)

```sh
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.

## about legacy vim version

vim minimum required version:

|plugin|version|reason|
|---|---|---|
|[vim-plug](https://github.com/junegunn/vim-plug) | 7.2.051 | globpath |
