# vim build

- linux: x64 static; do not depend on libc;

- win32: x86 (source code modified! see below "about legacy vim version") / x64; no OLE.

For linux,
[archive/build.sh](archive/build.sh) is from <https://github.com/dtschan/vim-static>,
[modified](Dockerfile) to be used in docker.

For win32,
[archive/build.bat](archive/build.bat) is from <https://github.com/vim/vim-win32-installer>.

(But now I use [mingw 32bit](Dockerfile.mingw-x86) / [mingw 64bit](Dockerfile.mingw-x64) to compile instead; instruction can be found in
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

## example build step

```sh
# linux build
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .

# win32 x86 build
docker build --build-arg VIM_VERSION=v8.2.2845 -f Dockerfile.mingw-x86 -t build-vim-win32-x86 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.

## about legacy vim version

### Windows XP

The (officially) newest version running on Windows XP: [v9.0.0495](https://github.com/lxhillwind/vim-bin/releases/tag/v9.0.0495).

Version after it may work, but the compilation process requires patch (see
[Dockerfile.mingw-x86](Dockerfile.mingw-x86)); otherwise it won't even compile.

[legacy icon](./legacy-icon.ico) is from
<https://github.com/vim/vim/blob/v8.2.4544/src/vim.ico>; it is viewable in
Windows XP, though low resolution.

### plugin

vim minimum required version:

|plugin|version|reason|
|---|---|---|
|[vim-plug](https://github.com/junegunn/vim-plug) | 7.2.051 | globpath |
