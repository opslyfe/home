#!/bin/sh

. $HOME/.profile

export GPG_TTY=$(tty)

CWD=$HOME
PS1='\w$ '

umask 022

alias e=${EDITOR}
alias c=cd
alias ap=ansible-playbook
alias apc='ansible-playbook --check --diff --step'
alias ls=eza
alias systemctl='systemctl --user'
alias journalctl='journalctl --user -r'

d() {
	echo "$CWD"
}

cd() {
	builtin cd $@ && CWD=$(pwd)
}

n() {
	builtin cd $HOME/notes
	e $@
	cd $CWD
}
