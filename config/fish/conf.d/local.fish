fish_add_path --prepend $HOME/bin

#general
alias l='lsd -l'
alias ll='lsd -la'
alias la='lsd -a'
alias lazyupdate='yay -Syu && yay -Yc && sudo paccache -r'

#vpn
alias @gabriel='ssh -i .ssh/id_ed25519_solid  tarso@solidserverbr.ddns.net -p 1978'

#oracle VPS
alias @vps-urcadefiles='ssh ubuntu@urcade-files.ddns.net'
alias @website='ssh ubuntu@tarsogalvao.ddns.net'

#pcs [ethernet]
alias @marcela='ssh -X msperandio@192.168.15.201'
alias @urcade='ssh -X urcade@192.168.15.202'

#pcs [wifi]
alias @tarsotop='ssh -X tarso@192.168.15.100'

#vms [.220 - .229]
alias @dom0='ssh root@192.168.15.220'
alias @xo='ssh root@xo.server.lan'
alias @pihole='ssh root@192.168.15.222'
alias @copyparty='ssh copyparty@copyparty.server.lan'
alias @media='ssh root@media.server.lan'
alias @vault='ssh root@vaultwarden.server.lan'
alias @minecraft='ssh root@192.168.15.226'
alias @dashboards='ssh dash@192.168.15.227'
alias @emulatorjs='ssh root@192.168.15.228'
alias @openvpn='ssh root@192.168.15.229'
