# Route ssh-add and other tools to the 1Password SSH agent.
# (ssh/git read IdentityAgent from ~/.ssh/config; ssh-add does not.)
export OP_SSH_AUTH_SOCK="${OP_SSH_AUTH_SOCK:-$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock}"
if [[ -S "$OP_SSH_AUTH_SOCK" ]]; then
  export SSH_AUTH_SOCK="$OP_SSH_AUTH_SOCK"
fi

# Git commit signing via 1Password SSH keys
if [[ -x "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" ]]; then
  git config --global gpg.format ssh 2>/dev/null
  git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" 2>/dev/null
fi
