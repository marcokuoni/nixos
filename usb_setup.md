ESP
LUKS
|- ROOT
|- SWAP

# Disk vorbereiten

`sudo parted /dev/nvme0n1 -- mklabel gpt`

# ESP anlegen

Boot partition
`sudo parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 513MiB`
`sudo parted /dev/nvme0n1 -- set 1 esp on`
`sudo mkfs.fat -F32 -n NIXOS_BOOT /dev/nvme0n1p1`

# LUKS container erstellen

`sudo parted /dev/nvme0n1 -- mkpart CRYPTROOT 513MiB 100%`
`sudo cryptsetup luksFormat --type luks2 /dev/nvme0n1p2`
`sudo cryptsetup open /dev/nvme0n1p2 cryptroot`

# LUKS partition LVM

`sudo pvcreate         /dev/mapper/cryptroot`
`sudo vgcreate lvmroot /dev/mapper/cryptroot`

`sudo lvcreate -L80G       lvmroot -n swap`
`sudo lvcreate -l 100%FREE      lvmroot -n root`

# LUKS Filessystem

`sudo mkfs.ext4 -L NIXOS_ROOT      /dev/mapper/lvmroot-root`
`sudo mkswap    -L NIXOS_SWAP      /dev/mapper/lvmroot-swap`

# Mount

`sudo mount /dev/disk/by-label/NIXOS_ROOT /mnt`
`sudo mkdir /mnt/boot`
`sudo mount -o umask=0077 /dev/disk/by-label/NIXOS_BOOT /mnt/boot`
`sudo swapon -L NIXOS_SWAP`

# NIXOS

`sudo mkdir -p /mnt/etc/nixos`
copy inside the nixos from git and all home backups you have remember to `sudo chown progressio:users /home/progressio -R`
`sudo nixos-install --root /mnt --flake /mnt/etc/nixos#laptop`
`sudo reboot`

Maybe you cant use sudo of your user. So change to root user and add a password for your sudo user
`sud -`
`passwd progressio`
