eval $(keychain --eval --agents ssh -Q --quiet id_rsa)

export _JAVA_OPTIONS='-Dawt.useSystemAAFontSettings=lcd'
export QT_STYLE_OVERRIDE="gtk"

# change global path
if [ -d "$HOME/bin" ]; then
    PATH=$HOME/bin:$PATH
fi

