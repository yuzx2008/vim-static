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

## note for Windows

winpty is not included; download it manually from
<https://github.com/rprichard/winpty/releases>.

```sh
# example for x86:
curl -L https://github.com/rprichard/winpty/releases/download/0.4.3/winpty-0.4.3-msys2-2.7.0-ia32.tar.gz -o winpty.tar.gz
tar --strip-components=1 -xf winpty.tar.gz
cp bin/winpty.dll $VIMRUNTIME/winpty32.dll
cp bin/winpty-agent.exe $VIMRUNTIME/
```

### note for Windows XP

`vim/vim82/libwinpthread-1.dll` in win32 build comes from Alpine Linux (pkg:
mingw-w64-winpthreads), and it does not work in Windows XP.

To fix it, just download it from other distribution's package, like Fedora 34
(pkg: mingw32-winpthreads), and replace the file.

## example build step

```sh
# linux build
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .

# win32 x86 build
docker build --build-arg VIM_VERSION=v8.2.2845 -f Dockerfile.mingw -t build-vim-8-win32 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.


## when builds failed...

### mingw

Check if `src/Make_cyg_ming.mak` in vim source code changed.

TODO: generate [`Make_cyg_ming.mak`](Make_cyg_ming.mak) with configure.

## about legacy vim version

vim minimum required version:

|plugin|version|reason|
|---|---|---|
|[vim-plug](https://github.com/junegunn/vim-plug) | 7.2.051 | globpath |
