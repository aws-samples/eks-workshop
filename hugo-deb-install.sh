TEMP_DEB="$(mktemp)" &&
wget -O "$TEMP_DEB" 'https://github.com/gohugoio/hugo/releases/download/v0.46/hugo_0.46_Linux-64bit.deb' &&
sudo dpkg -i "$TEMP_DEB"
rm -f "$TEMP_DEB"
