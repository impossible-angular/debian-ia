# =====
# Identify the SD Card Partition
lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINTS

# ===== TEST True Size
# instantly test
f3probe --destructive /dev/sda
# write files
f3write --end-at=4 /mnt/sdcard
# read data
f3read /mnt/sdcard

# ===== Format flash, SD
umount /dev/sdX*
wipefs --all --force /dev/sdX
dd if=/dev/zero of=/dev/sdX bs=1M count=100 status=progress conv=fdatasync
# Re-create the partition table with optimal 1MiB alignment
parted -s /dev/sdX mklabel msdos mkpart primary ext4 1MiB 100%
# fromat to ext4
mkfs.ext4 -L "USB_X" /dev/sdX1
# Disable the Ext4 journal
tune2fs -O ^has_journal /dev/sdX1

# FAT
wipefs --all --force /dev/sdX
parted -s /dev/sdX mklabel msdos mkpart primary fat32 1MiB 100%
mkfs.vfat -F 32 -n "USB2G" /dev/sdX1




# Reload partition table
partprobe /dev/sda

#TEST write speed
mount /dev/sda1 /mnt/usb_1
fio --name=test_video_copy --directory=/mnt/usb_1 --rw=write --bs=1M --size=500M --direct=1 --group_reporting
fio --name=test_video_copy --directory=/mnt/usb_1 --rw=write --bs=4M --size=2G --direct=1 --group_reporting

fio --name=test_video_copy --directory=/mnt/usb_1 --rw=read --bs=1M --size=500M --direct=1 --group_reporting


mount /dev/sda1 /mnt/sd1/

umount /dev/sda*
wipefs --all --force /dev/sda
dd if=/dev/zero of=/dev/sda bs=1M count=100 status=progress conv=fdatasync
parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 100%
mkfs.ext4 -L "USB64G" /dev/sda1
tune2fs -O ^has_journal /dev/sda1


wipefs --all --force /dev/sda
parted -s /dev/sda mklabel msdos mkpart primary fat32 1MiB 100%
mkfs.vfat -F 32 -n "USB64G" /dev/sda1

wipefs --all --force /dev/sda
parted -s /dev/sda mklabel msdos mkpart primary ext4 1MiB 10.93G
mkfs.ext4 -L "SD_Lenovo" /dev/sda1
tune2fs -O ^has_journal /dev/sda1

# free space
df -hT -x tmpfs -x devtmpfs -x squashfs
#Mount all
mergerfs -o defaults,allow_other,use_ino /mnt/usb_1:/mnt/usb_2:/mnt/usb_3:/mnt/usb_4 /mnt/usb_all
mergerfs -o defaults,allow_other,use_ino,minfreespace=100M \
  /mnt/usb_1:/mnt/usb_2:/mnt/usb_3:/mnt/usb_4 \
  /mnt/usb_all
