#!/bin/bash -eu

CURDIR=`pwd`

rm -f ${CURDIR}/build/*

VM_ROOT="$HOME/.vagrant.d/vms"

X86_VM=${VM_ROOT}/arch
WIN32_VM=${VM_ROOT}/arch
AMD64_VM=${VM_ROOT}/ubuntu-amd64

X86_HOST=33.33.33.10
WIN32_HOST=33.33.33.10
AMD64_HOST=33.33.33.11

JARK="jark-0.4"
UPLOAD="${CURDIR}/upload"

echo "Building target: X86"
cd $X86_VM
vagrant up
ssh vagrant@${X86_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make'
scp vagrant@${X86_HOST}:~/jark-client/build/${JARK}-i686 ${UPLOAD}/${JARK}-x86/

echo "Building target: WIN32"
cd $WIN32_VM
vagrant up
ssh vagrant@${WIN32_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make exe'
scp vagrant@${WIN32_HOST}:~/jark-client/build/jark.exe ${UPLOAD}/${JARK}-win32/

echo "Building target: X86_64/AMD64"
cd $AMD64_VM
vagrant up
ssh vagrant@${AMD64_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make'
scp vagrant@${AMD64_HOST}:~/jark-client/build/${JARK}-x86_64 ${UPLOAD}/${JARK}-x86_64/

echo "Building target: X86_64 MAC OSX"
cd ${CURDIR}
make
cp build/${JARK}-x86_64 ${UPLOAD}/${JARK}-x86_64_macosx/

cd $UPLOAD
rm -f *.tar.gz
tar zcf ${JARK}-x86.tar.gz ${JARK}-x86/
tar zcf ${JARK}-win32.tar.gz ${JARK}-win32/
tar zcf ${JARK}-x86_64.tar.gz ${JARK}-x86_64/
tar zcf ${JARK}-x86_64_macosx.tar.gz ${JARK}-x86_64_macosx/


upload.rb ${JARK}-x86.tar.gz icylisper/jark-client
upload.rb ${JARK}-win32.tar.gz icylisper/jark-client
upload.rb ${JARK}-x86_64.tar.gz icylisper/jark-client
upload.rb ${JARK}-x86_64_macosx.tar.gz icylisper/jark-client
