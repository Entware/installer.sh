#!/bin/sh

TYPE='generic'
#TYPE='alternative'

unset LD_LIBRARY_PATH
unset LD_PRELOAD

echo 'Info: Checking for prerequisites and creating folders...'
if [ -d /opt ]; then
    echo 'Warning: Folder /opt exists!'
else
    mkdir /opt
fi
# no need to create many folders. entware-opt package creates most
for folder in bin etc lib/opkg tmp var/lock
do
  if [ -d "/opt/$folder" ]; then
    echo "Warning: Folder /opt/$folder exists!"
    echo 'Warning: If something goes wrong please clean /opt folder and try again.'
  else
    mkdir -p /opt/$folder
  fi
done

echo 'Info: Opkg package manager deployment...'
DLOADER='ld.so.1'
URL='http://bin.entware.net/mipselsf-k3.4/installer'
wget $URL/opkg -O /opt/bin/opkg
chmod 755 /opt/bin/opkg
wget $URL/opkg.conf -O /opt/etc/opkg.conf
wget $URL/ld-2.27.so -O /opt/lib/ld-2.27.so
wget $URL/libc-2.27.so -O /opt/lib/libc-2.27.so
wget $URL/libgcc_s.so.1 -O /opt/lib/libgcc_s.so.1
wget $URL/libpthread-2.27.so -O /opt/lib/libpthread-2.27.so
cd /opt/lib
chmod 755 ld-2.27.so
ln -s ld-2.27.so $DLOADER
ln -s libc-2.27.so libc.so.6
ln -s libpthread-2.27.so libpthread.so.0

echo 'Info: Basic packages installation...'
/opt/bin/opkg update
if [ $TYPE = 'alternative' ]; then
  /opt/bin/opkg install busybox
fi
/opt/bin/opkg install entware-opt

# Fix for multiuser environment
chmod 777 /opt/tmp

for file in passwd group shells shadow gshadow localtime; do
  if [ $TYPE = 'generic' ]; then
    if [ -f /etc/$file ]; then
      ln -sf /etc/$file /opt/etc/$file
    else
      [ -f /opt/etc/$file.1 ] && cp /opt/etc/$file.1 /opt/etc/$file
    fi
  else
    if [ -f /opt/etc/$file.1 ]; then
      cp /opt/etc/$file.1 /opt/etc/$file
    else
      [ -f /etc/$file ] && ln -sf /etc/$file /opt/etc/$file
    fi
  fi
done

echo 'Info: Congratulations!'
echo 'Info: If there are no errors above then Entware was successfully initialized.'
echo 'Info: Add /opt/bin & /opt/sbin to $PATH variable'
echo 'Info: Add "/opt/etc/init.d/rc.unslung start" to startup script for Entware services to start'
if [ $TYPE = 'alternative' ]; then
  echo 'Info: Use ssh server from Entware for better compatibility.'
fi
echo 'Info: Found a Bug? Please report at https://github.com/Entware/Entware/issues'
