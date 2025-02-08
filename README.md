# vim build

解决的问题：
云上开发，或者本地基于 docker image 开发，遇到各种各样的 os 及版本，
对应 apt、yum 源中的 vim 版本参差不齐，
需要编译安装 vim，但是编译坑太多，这里采用静态编译方式 build vim，可以一次编译到处运行。

下载源码放到本地 fileserver，避免 docker build 上网问题

```bash
wget https://invisible-island.net/datafiles/release/ncurses.tar.gz
wget https://github.com/vim/vim/archive/v9.1.1069.tar.gz
wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
wget https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz
wget https://github.com/openssl/openssl/releases/download/openssl-3.4.0/openssl-3.4.0.tar.gz
```

build image

```bash
nerdctl build \
  --add-host=mirrors.tuna.tsinghua.edu.cn:101.6.15.130 \
  --add-host=github.com:20.205.243.166 \
  --buildkit-host=unix:///var/run/buildkit/buildkitd.sock \
  --build-arg=FILE_SERVER=http://192.168.3.8:8123 \
  --platform="amd64" \
  --file "Dockerfile.ubuntu" \
  -t "vim:0.0.1" \
  .

# 将静态编译的文件拷回到本地
sudo nerdctl run -it --rm \
  -v /data/downloads:/data/downloads \
  vim:0.0.1 \
  sh -c "cp /vim.tar.xz /data/downloads && \
  cp /tmux.tar.xz /data/downloads && \
  cp /ncurses.tar.xz /data/downloads"

```

使用

```bash
# coc.nvim 依赖
tar -xf /data/downloads/node-v22.12.0-linux-x64.tar.xz -C /opt
ln -sf -T /opt/node-v22.12.0-linux-x64 /opt/node

# 上面 build 的结果
tar -xf /data/downloads/vim.tar.xz -C /opt
tar -xf /data/downloads/tmux.tar.xz -C /opt
tar -xf /data/downloads/ncurses.tar.xz -C /opt

# 将 ~/.vim ~/.vimrc 和 ~/.config/coc 拷贝到 $HOME 中

export PATH=/opt/ncurses/bin:/opt/vim/bin:/opt/node/bin:/opt/tmux/bin:$PATH
vim
```
