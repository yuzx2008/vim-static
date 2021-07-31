# vim build

- linux: x64 static; do not depend on libc;

- win32: x86; no OLE.

For linux,
[archive/build.sh](archive/build.sh) is from <https://github.com/dtschan/vim-static>,
[modified](Dockerfile) to be used in docker.

For win32,
[archive/build.bat](archive/build.bat) is from <https://github.com/vim/vim-win32-installer>.

(But now I use [mingw](Dockerfile.mingw) to compile instead; instruction can be found in
<https://github.com/vim/vim/blob/master/src/INSTALLpc.txt>
)

## example build step (for linux)

```sh
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .

docker build --build-arg VIM_VERSION=v8.2.2845 -f Dockerfile.mingw -t build-vim-8-win32 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.

## about legacy vim version

vim minimum required version:

|plugin|version|reason|
|---|---|---|
|[vim-plug](https://github.com/junegunn/vim-plug) | 7.2.051 | globpath |
