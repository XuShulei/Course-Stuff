#!/bin/sh

gcc ./mkfslab5.c -o ./mkfslab5

#format 
rm -f image
echo "=== Creating an empty image and format it with LAB5FS format ==="
echo ""
dd if=/dev/zero of=image bs=1024 count=8192
./mkfslab5 image

# Load the module
echo ""
echo "=== Loading the module... ==="
echo ""
insmod /lib/modules/2.6.9lab5/kernel/fs/lab5fs/lab5fs.ko

lsmod | grep lab5

echo ""
echo "=== Mount ==="
echo ""
mount -v -t lab5fs image /mnt/lab5fs -o loop

df -h

echo ""
echo "=== Change Directory and list files ==="
echo ""
cd /mnt/lab5fs
ls -la
echo ""
echo "=== Create an empty file and list files ==="
echo ""
touch test1.txt
ls -la

echo ""
echo "=== Create second empty file and list files ==="
echo ""
touch test2.txt
ls -la

echo ""
echo "=== Remove test2.txt and list files ==="
echo ""
rm test2.txt
ls -la

echo ""
echo "=== Link and list files ==="
echo ""
link test1.txt test1-link.txt
ls -la
echo ""
echo "=== Unlink and list files ==="
echo ""
unlink test1-link.txt
ls -la

echo ""
echo "=== Change permission of test1.txt to 755, and owner to user1 ==="
echo ""
chmod 755 test1.txt
chown user1:user1 test1.txt
ls -la

echo ""
echo "=== Write data to file 'test1.txt' (across 2 blocks), list files, and show the content ==="
echo ""
for i in `seq 1 1024`
do
    echo -n "0" >> test1.txt
done
echo "xxx" >> test1.txt
ls -la
cat test1.txt

echo ""
echo "=== Create new directory 'test_dir' (using 'mkdir') and 'cd' into it ==="
echo ""
mkdir test_dir
ls -la
cd test_dir
pwd
ls -la
cd -

echo ""
echo "=== Unmount ==="
echo ""
cd /root/lab5
umount /mnt/lab5fs

echo ""
echo "=== Mount again and list files ==="
echo ""
mount -v -t lab5fs image /mnt/lab5fs -o loop
ls -la /mnt/lab5fs

echo ""
echo "=== Done, unmount, remove the module, and exit... ==="
echo ""
umount /mnt/lab5fs
# Remove the module
rmmod lab5fs.ko
#lsmod | grep lab5
