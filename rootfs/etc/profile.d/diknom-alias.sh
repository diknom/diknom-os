#!/bin/sh
# ============================================
#   DIKNOM OS - Alias Bawaan Sistem
# ============================================

# dnpkg shortcuts
alias install='dnpkg install'
alias remove='dnpkg remove'
alias update='dnpkg update'
alias search='dnpkg search'

# Navigasi
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Sistem
alias df='df -h'
alias du='du -sh'
alias free='free -h'
alias top='htop'
alias ports='ss -tuln'
alias myip='curl -s ifconfig.me && echo'

# Shortcut help
alias h='help'
alias ?='help'
alias tolong='help'
alias bantuan='help'

# DIKNOM commands
alias info='dnfetch'
alias sysinfo='dnfetch'
