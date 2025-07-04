echo "docker socket"
sudo groupadd -f docker && sudo usermod -aG docker vscode
sudo chown root:docker /var/run/docker.sock