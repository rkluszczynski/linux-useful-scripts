#!/bin/sh

#wget "http://ftp.debian.org/debian/pool/main/a/authbind/authbind_1.2.0.tar.gz"
wget "http://ftp.debian.org/debian/pool/main/a/authbind/authbind_2.1.1.tar.gz"
tar -zxvf authbind_2.1.1.tar.gz

(
        cd authbind-2.1.1
        make && make install
)

rm -rf authbind*

