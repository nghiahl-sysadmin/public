echo -e 'ubuntu\nubuntu' | passwd root
echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj3nBL1Mfw6e9hx2zEtjP7b+JTi0AiSI2uEB4Hv5Qmi6zvCZETLTg4dHC9t2l0ZSokTr1Xng2hNKhW7PsnosEA14u1pxUUdv75J0iUIgRAJ9N3E2t8HLOLtRLcd30KkgCCeqqXGn+ZXVv3GL2zKbt+jRkmbplPnd1ur5LKQ2IrGLzdZzb4LBJ70PirpZL0Szt63gNyY3CWhtp4cTeAeQKca2XmeUhkonWKBuZGDPIdVswYD3nExES9XDFuda6ZyuIS9QbH2NuIXUgWKoK+r23OJfgYpY9RzEWz2cYO8Tg7JCJGu/gwpNRaYFNE1fnmDvpaPQdT7I1wa8GWt4mSoxKz Administrator' >> /root/.ssh/authorized_keys
echo 'PermitRootLogin=yes' >> /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd.service
echo 'Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null' | sudo tee /root/.ssh/config
#apt -y update
#apt -y upgrade
#reboot
