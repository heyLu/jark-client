#!/bin/bash -eu

CURDIR=`pwd`


VM_ROOT="$HOME/box"

X86_VM=${VM_ROOT}/arch
WIN32_VM=${VM_ROOT}/arch
AMD64_VM=${VM_ROOT}/ubuntu-amd64

X86_HOST=localhost
WIN32_HOST=localhost
AMD64_HOST=33.33.33.11

JARK="jark-0.4"
UPLOAD="${CURDIR}/upload"
PORT=2222

echo "Building target: X86"
cd $X86_VM
vagrant up
ssh -p ${PORT} vagrant@${X86_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make' &> /dev/null
scp -P ${PORT} vagrant@${X86_HOST}:~/jark-client/build/${JARK}-i686 ${UPLOAD}/${JARK}-x86/ &> /dev/null

echo "Building target: WIN32"
cd $WIN32_VM
vagrant up
ssh -p ${PORT} vagrant@${WIN32_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make exe' &> /dev/null
scp -P ${PORT} vagrant@${WIN32_HOST}:~/jark-client/build/jark.exe ${UPLOAD}/${JARK}-win32/ &> /dev/null

echo "Building target: X86_64/AMD64"
cd $AMD64_VM
vagrant up
ssh vagrant@${AMD64_HOST} 'cd /home/vagrant/jark-client && rm -f build/* && make' &> /dev/null
scp vagrant@${AMD64_HOST}:~/jark-client/build/${JARK}-x86_64 ${UPLOAD}/${JARK}-x86_64/ &> /dev/null

echo "Building target: X86_64 MAC OSX"
cd ${CURDIR}
make &> /dev/null
cp build/${JARK}-x86_64 ${UPLOAD}/${JARK}-x86_64_macosx/

cd $UPLOAD
rm -f *.tar.gz
tar zcf ${JARK}-x86.tar.gz ${JARK}-x86/
zip ${JARK}-win32.zip -r ${JARK}-win32/
tar zcf ${JARK}-x86_64.tar.gz ${JARK}-x86_64/
tar zcf ${JARK}-x86_64_macosx.tar.gz ${JARK}-x86_64_macosx/

echo "Uploading ${JARK}-x86.tar.gz .."
upload.rb ${JARK}-x86.tar.gz icylisper/jark-client

echo "Uploading ${JARK}-win32.zip .."
upload.rb ${JARK}-win32.zip icylisper/jark-client

echo "Uploading ${JARK}-x86_64.tar.gz .."
upload.rb ${JARK}-x86_64.tar.gz icylisper/jark-client

echo "Uploading ${JARK}-x86_64_macosx.tar.gz .."
upload.rb ${JARK}-x86_64_macosx.tar.gz icylisper/jark-client
