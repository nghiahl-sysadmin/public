#!/bin/bash
echo -e 'ubuntu\nubuntu' | passwd root
echo -e 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj3nBL1Mfw6e9hx2zEtjP7b+JTi0AiSI2uEB4Hv5Qmi6zvCZETLTg4dHC9t2l0ZSokTr1Xng2hNKhW7PsnosEA14u1pxUUdv75J0iUIgRAJ9N3E2t8HLOLtRLcd30KkgCCeqqXGn+ZXVv3GL2zKbt+jRkmbplPnd1ur5LKQ2IrGLzdZzb4LBJ70PirpZL0Szt63gNyY3CWhtp4cTeAeQKca2XmeUhkonWKBuZGDPIdVswYD3nExES9XDFuda6ZyuIS9QbH2NuIXUgWKoK+r23OJfgYpY9RzEWz2cYO8Tg7JCJGu/gwpNRaYFNE1fnmDvpaPQdT7I1wa8GWt4mSoxKz Administrator' >> /root/.ssh/authorized_keys
echo 'PermitRootLogin=yes' >> /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
timedatectl set-timezone Asia/Ho_Chi_Minh
echo 'Host *
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null' | sudo tee /root/.ssh/config
systemctl restart sshd.service
apt -y update
apt -y install net-tools make apt-transport-https ca-certificates curl
apt -y upgrade
apt -y autoremove
container_version=1.7.2
wget https://github.com/containerd/containerd/releases/download/v$container_version/containerd-$container_version-linux-amd64.tar.gz
sudo tar Czxvf /usr/local containerd-$container_version-linux-amd64.tar.gz
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /usr/lib/systemd/system/
rm -rf containerd-$container_version-linux-amd64.tar.gz
RUNC_VERSION=1.1.7
wget https://github.com/opencontainers/runc/releases/download/v$RUNC_VERSION/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
sudo mkdir -p /etc/containerd/
containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
rm -rf runc.amd64
sudo systemctl daemon-reload && systemctl enable --now containerd && systemctl status containerd
cat > /etc/sysctl.d/99-k8s-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
EOF
sysctl --system
modprobe overlay; modprobe br_netfilter
echo -e overlay\\nbr_netfilter > /etc/modules-load.d/k8s.conf
swapoff -a; sed -i 's/^\/swap/#&/' /etc/fstab
sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=0"/g' /etc/default/grub
update-grub
sudo mkdir -p /etc/apt/keyrings/
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt -y update
kubernetes_version=1.26.3-00
sudo apt -y install kubelet=$kubernetes_version kubeadm=$kubernetes_version kubectl=$kubernetes_version
cat > /etc/default/kubelet <<EOF
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint=unix:///run/containerd/containerd.sock
EOF
interface=enp0s8
node_ip=$(ip addr show $interface | awk '$1 == "inet" {gsub(/\/.*$/, "", $2); print $2}')
kubelet_config="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
sudo sed -i "s|Environment=\"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf\"|Environment=\"KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --node-ip=$node_ip\"|" $kubelet_config
echo -e "1\n" | update-alternatives --config iptables
systemctl restart containerd.service && systemctl status containerd
reboot
