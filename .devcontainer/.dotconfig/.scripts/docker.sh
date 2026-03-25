echo "docker socket"
cat << "EOF" >> ~/.zshrc
# docker
sudo groupadd -f docker && sudo usermod -aG docker $(id -u -n)
sudo chown root:docker /var/run/docker.sock
EOF
