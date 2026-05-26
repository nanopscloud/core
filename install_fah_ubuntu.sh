# Install dependency
sudo apt install -y bzip2

# Download and extract
mkdir ~/fah && cd ~/fah
wget https://download.foldingathome.org/releases/public/fah-client/debian-stable-arm64/release/fah-client_8.5.5-64bit-release.tar.bz2
tar -xjf fah-client_8.5.5-64bit-release.tar.bz2
cd fah-client_8.5.5-64bit-release/

# Create user and install binary
sudo useradd -r -s /sbin/nologin -d /var/lib/fah-client fah-client
sudo cp fah-client /usr/bin/fah-client
sudo chmod +x /usr/bin/fah-client
sudo mkdir -p /etc/fah-client /var/lib/fah-client /var/log/fah-client
sudo chown fah-client:fah-client /var/lib/fah-client /var/log/fah-client

# Config
sudo tee /etc/fah-client/config.xml <<'EOF'
<config>
  <account-token v="YOUR_TOKEN_HERE"/>
  <machine-name v="YOUR_MACHINE_NAME"/>
</config>
EOF

# Service
sudo cp fah-client.service /etc/systemd/system/fah-client.service
sudo mkdir -p /etc/systemd/system/fah-client.service.d
sudo tee /etc/systemd/system/fah-client.service.d/override.conf <<'EOF'
[Service]
Nice=19
EOF

# Start
sudo systemctl daemon-reload
sudo systemctl enable --now fah-client
sudo systemctl status fah-client
