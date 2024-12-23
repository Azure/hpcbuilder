#!/bin/bash 
if ! grep -q cycle_server /etc/fstab; then
    parted /dev/disk/azure/scsi1/lun0 --script -- mklabel gpt
    parted -a optimal /dev/disk/azure/scsi1/lun0 mkpart primary 0% 100%
    sleep 10s
    mkfs -t xfs /dev/disk/azure/scsi1/lun0-part1
    mkdir -p /opt/cycle_server
    disk_uuid=$(/usr/sbin/blkid -o value -s UUID  /dev/disk/azure/scsi1/lun0-part1)
    /usr/bin/echo "UUID=$disk_uuid /opt/cycle_server xfs defaults,nofail 1 2" >> /etc/fstab
    /usr/bin/mount /opt/cycle_server
fi 

# disabling selinux
setenforce 0
sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config


#installing cyclecloud
sudo cat > /etc/yum.repos.d/cyclecloud.repo <<EOF
[cyclecloud]
name=cyclecloud
baseurl=https://packages.microsoft.com/yumrepos/cyclecloud
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF

sudo yum -y install cyclecloud8-8.6.5-3340


  
