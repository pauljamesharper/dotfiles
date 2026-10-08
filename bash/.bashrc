# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
eval "$(~/.local/bin/mise activate bash)"
### bling.sh source start
test -f /usr/share/bazzite-cli/bling.sh && source /usr/share/bazzite-cli/bling.sh
### bling.sh source end
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# fastfetch: Aurora's profile.d alias forces its own config; use
# ~/.config/fastfetch/config.jsonc (from dotfiles) instead
alias fastfetch='/usr/bin/fastfetch -c ~/.config/fastfetch/config.jsonc'

# Emacs in the terminal, through the running daemon
alias e='emacsclient -nw'
### bling.sh source start
test -f /usr/share/ublue-os/bling/bling.sh && source /usr/share/ublue-os/bling/bling.sh
### bling.sh source end
