mkdir -p /tmp/weston
chmod 0700 /tmp/weston/
export XDG_RUNTIME_DIR=/tmp/weston
export QT_QPA_PLATFORM=wayland

#launch weston on login
if [[ $(tty) = /dev/tty1 ]]; then
    modprobe uvesafb
    /usr/bin/weston -Bfbdev-backend.so --log=/var/log/weston.log --tty=1
fi
