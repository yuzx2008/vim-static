# vim static build

This repo is fork from <https://github.com/dtschan/vim-static>,
to be used in docker.

## example build step

```sh
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.

## about legacy vim version

vim minimum required version:

|plugin|version|reason|
|---|---|---|
|[vim-plug](https://github.com/junegunn/vim-plug) | 7.2.051 | globpath |
|[vim-shell.vim](https://github.com/Shougo/vimshell.vim) | 7.3 | |
