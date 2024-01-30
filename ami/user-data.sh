#!/bin/bash
# Copyright 2024 ke.liu#foxmail.com

sudo add-apt-repository ppa:oisf/suricata-stable
sudo apt-get update -y && sudo apt-get install -y jq curl nginx unzip suricata suricata-update grepcidr

# aws cli
cd ${HOME}
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# iptables
sudo bash -c "echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.conf"
sudo sysctl -p

GENEVESH=/usr/local/bin/geneve.sh
TMPGENEVESH=/tmp/geneve.sh
cat > ${TMPGENEVESH} << EoF
#!/bin/bash -x
# Copyright 2024 ke.liu#foxmail.com

curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document > /tmp/instance.json
my_ip=\$(cat /tmp/instance.json | jq -r '.privateIp')
my_id=\$(cat /tmp/instance.json | jq -r '.instanceId')
my_region=\$(cat /tmp/instance.json | jq -r '.region')
my_mac=\$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/)
my_vpc=\$(curl --silent  http://169.254.169.254/latest/meta-data/network/interfaces/macs/\${my_mac}vpc-id)
my_subnet_cidr=\$(curl --silent http://169.254.169.254/latest/meta-data/network/interfaces/macs/\${my_mac}subnet-ipv4-cidr-block)
# Basic iptables setup
iptables -t nat -F
iptables -I FORWARD -j NFQUEUE

# Configure nat table to hairpin traffic back to GWLB. Supports cross zone LB.
gwlb_ips=\$(aws --region \${my_region} ec2 describe-network-interfaces --filters Name=vpc-id,Values=\${my_vpc} --query 'NetworkInterfaces[?InterfaceType==\`gateway_load_balancer\`].PrivateIpAddress' --output text)

### in the same subnet, insert 1st to priority
for ip in \${gwlb_ips} ; do
  echo "\${ip}" | grepcidr "\${my_subnet_cidr}"
  if [[ \$? -eq 0 ]]; then
    iptables -t nat -A PREROUTING -p udp -s \$ip --dport 6081 -d \$my_ip -j DNAT --to-destination \$ip:6081
  fi
done

### not in the same subnet
for ip in \${gwlb_ips} ; do
  echo "\${ip}" | grepcidr "\${my_subnet_cidr}"
  if [[ \$? -eq 1 ]]; then
    iptables -t nat -A PREROUTING -p udp -s \$ip --dport 6081 -d \$my_ip -j DNAT --to-destination \$ip:6081
  fi
done

# all output to UDP:6081, change source IP
iptables -t nat -A POSTROUTING -p udp --dport 6081 -j SNAT --to \${my_ip}
EoF
sudo cp ${TMPGENEVESH} ${GENEVESH}
sudo chmod +x ${GENEVESH}
rm ${TMPGENEVESH}

# setup script
TMPCRON=/tmp/crontabl.tmp
sudo bash -c "crontab -l > ${TMPCRON}"
sudo bash -c "echo '@reboot /usr/local/bin/geneve.sh' > ${TMPCRON}"
sudo bash -c "echo '0 8 * * * suricata-update' >> ${TMPCRON}"
sudo crontab ${TMPCRON}
sudo rm -rf ${TMPCRON}

# config suricata
sudo sed -i 's/LISTENMODE=.*/LISTENMODE=nf-queue/' /etc/default/suricata
iface=$(ip route get 1 | awk '{print $5}')
sudo sed  -i "s/IFACE=.*/IFACE=${iface}/" /etc/default/suricata

sudo bash -c "echo 'modify-conf: /etc/suricata/modify.conf'  > /etc/suricata/update.yaml"
sudo bash -c "echo 're:. ^alert drop' >  /etc/suricata/modify.conf"

sudo suricata-update update-sources
for src in $(suricata-update list-sources | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]//g" | awk '/Name/ {print $2}')
do
   sudo suricata-update enable-source ${src} secret-code=Free
done
sudo suricata-update

