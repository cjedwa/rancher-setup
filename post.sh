#!/bin/bash

# add repos for kubectl
if ! which kubectl > /dev/null; then
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
fi
if ! which kompose > /dev/null; then
curl -L https://github.com/kubernetes/kompose/releases/download/v1.13.0/kompose-linux-amd64 -o /usr/local/bin/kompose
chmod +x /usr/local/bin/kompose
fi

# add nopasswd for sudo group
sed -i 's/%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers > /dev/null

cat <<EOF >/etc/profile.d/env.sh
EDITOR=vim
EOF

# install docker, kubectl, etc
apt-get update > /dev/null && \
apt-get remove -y \
        nano > /dev/null && \
apt-get install -y \
	docker.io \
        tmux \
	apt-transport-https \
        kubectl \
	jq > /dev/null && \
apt-get autoremove > /dev/null

# bring up rancher
if ! docker ps | grep rancher_server_container > /dev/null; then
docker run -d --name rancher_server_container \
       	--restart=unless-stopped \
        -p 8080:80 -p 4443:443 \
        rancher/rancher:latest > /dev/null
fi

echo "Access Rancher at https://localhost:4443"
echo "kubectl is installed but you'll need to grab the kube config file from Rancher after you provision a cluster"

