#!/bin/sh

gitSourcesURL=https://codeload.github.com/git/git/tar.gz/v1.9.2
makeCmd=gmake

dstDir=${HOME}/apps

mkdir ${dstDir}

wget --no-check-certificate -O git.tgz "${gitSourcesURL}" 
tar zxvfp git.tgz
cd git-1.9.2/
${makeCmd} prefix=${dstDir}
${makeCmd} prefix=${dstDir} install
cd -

