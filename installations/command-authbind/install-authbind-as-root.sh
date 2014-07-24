#!/bin/sh

wget "http://ftp.debian.org/debian/pool/main/a/authbind/authbind_1.2.0.tar.gz"
tar -zxvf authbind_1.2.0.tar.gz

(
        cd authbind_1.2.0
        make && make install
)

rm -rf authbind_1.2.0*

