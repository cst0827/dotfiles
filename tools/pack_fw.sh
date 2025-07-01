unpack () {
    gunzip ./initrd.gz
    if [ -d ./root ]; then
        sudo rm -rf ./root
    fi
    mkdir root
    cd root
    sudo cpio -i < ../initrd
    cd ..
}

pack () {
    cd root
    sudo find . | sudo cpio -o -H newc > ../initrd
    cd ..
    rm initrd.gz
    gzip initrd
}

if [ x$1 = 'xunpack' ]; then
    unpack
else
    pack
fi
