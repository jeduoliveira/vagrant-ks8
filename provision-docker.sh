#!/bin/bash
set -eux

# install docker.
 apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-get -y update
apt-get -y install  docker docker.io
apt-key fingerprint 0EBFCD88

# configure it.
# see https://kubernetes.io/docs/setup/production-environment/container-runtimes/
systemctl stop docker
cat >/etc/docker/daemon.json <<'EOF'
{
    "debug": false,
    "exec-opts": [
        "native.cgroupdriver=systemd"
    ],
    "labels": [
        "os=linux"
    ],
    "hosts": [
        "fd://",
        "tcp://0.0.0.0:2375"
    ]
}
EOF
systemctl enable docker.service
sed -i -E 's,^(ExecStart=/usr/bin/dockerd).*,\1,' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker

# let the vagrant user manage docker.
usermod -aG docker vagrant

# kick the tires.
echo "nameserver 8.8.8.8" > /etc/resolv.conf

docker version
docker info
docker network ls
ip link
bridge link
#docker run --rm hello-world
#docker run -t nginx