# vim static build

This repo is fork from <https://github.com/dtschan/vim-static>,
to be used in docker.

## example build step

```sh
docker build --build-arg VIM_VERSION=v8.2.2845 -t build-vim-8 .
```

`VIM_VERSION` is tag name in <https://github.com/vim/vim>.
