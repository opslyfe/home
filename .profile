#!/bin/sh

export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_CACHE_HOME=$HOME/.cache
export XDG_RUNTIME_DIR=/run/user/$(id -u)

[ -e $XDG_RUNTIME_DIR ] || mkdir -p -m 0700 $XDG_RUNTIME_DIR

export GNUPGHOME=$XDG_CONFIG_HOME/gnupg
export SECRET_STORAGE=$XDG_CONFIG_HOME/pass
export SQLITE_HISTORY=$XDG_CACHE_HOME/history/sqlite3
export LESSHISTFILE=-
export HISTFILE=$XDG_CACHE_HOME/history/bash
export GOPATH=$XDG_DATA_HOME/go
export MANPATH=$HOME/.local/share/man:/usr/share/man
export PATH=$HOME/.local/bin:$GOPATH/bin:/usr/bin
export VAGRANT_DEFAULT_PROVIDER=libvirt

export TZ=Europe/Moscow
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_COLLATE=C
export EDITOR=vis
export PAGER='less -R'
export MANWIDTH=80
