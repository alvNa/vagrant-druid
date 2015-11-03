####################################################################################################################
# Script para los nodos master
####################################################################################################################

$master_script = <<SCRIPT
#!/bin/bash

# TODO - Meter las instrucciones Unix que quiero ejecutar en la máquina master

# Instalamos wget

sudo apt-get install -qy wget;


sed -e '/templatedir/ s/^#*/#/' -i.back /etc/puppet/puppet.conf

## set local/fastest mirror and local timezone
mv /etc/apt/sources.list /etc/apt/sources.list.orig
cat > /etc/apt/sources.list <<EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse

EOF
sudo apt-get update
export tz=`wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/p'` &&  sudo timedatectl set-timezone $tz

mkdir -p /etc/puppet/modules;
if [ ! -d /etc/puppet/modules/file_concat ]; then
 puppet module install ispavailability/file_concat
fi
if [ ! -d /etc/puppet/modules/apt ]; then
 puppet module install puppetlabs-apt --version 1.8.0
fi
if [ ! -d /etc/puppet/modules/java ]; then
 puppet module install puppetlabs-java
fi

SCRIPT

####################################################################################################################
# Script para los nodos hijos
####################################################################################################################

$node_script = <<SCRIPT
#!/bin/bash

# TODO - Meter las instrucciones Unix que quiero ejecutar en la máquina master

# Instalamos wget

sudo apt-get install -qy wget;


sed -e '/templatedir/ s/^#*/#/' -i.back /etc/puppet/puppet.conf

## set local/fastest mirror and local timezone
mv /etc/apt/sources.list /etc/apt/sources.list.orig
cat > /etc/apt/sources.list <<EOF
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt trusty-security main restricted universe multiverse

EOF
sudo apt-get update
export tz=`wget -qO - http://geoip.ubuntu.com/lookup | sed -n -e 's/.*<TimeZone>\(.*\)<\/TimeZone>.*/\1/p'` &&  sudo timedatectl set-timezone $tz

mkdir -p /etc/puppet/modules;
if [ ! -d /etc/puppet/modules/file_concat ]; then
 puppet module install ispavailability/file_concat
fi
if [ ! -d /etc/puppet/modules/apt ]; then
 puppet module install puppetlabs-apt --version 1.8.0
fi
if [ ! -d /etc/puppet/modules/java ]; then
 puppet module install puppetlabs-java
fi
if [ ! -d /etc/puppet/modules/jowy-druid ]; then
 puppet module install jowy-druid
fi

SCRIPT

####################################################################################################################
# Script para configurar el host.conf
####################################################################################################################
$hosts_script = <<SCRIPT
cat > /etc/hosts <<EOF
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

EOF
SCRIPT

####################################################################################################################
# Script para instalar y configurar druid
####################################################################################################################
$druid_script = <<SCRIPT
#!/bin/bash

#Descargamos el tar

wget -qO - http://static.druid.io/artifacts/releases/druid-0.8.1-bin.tar.gz

SCRIPT


Vagrant.configure("2") do |config|

  # Imagen base Ubuntu Trusty 64bits con Puppet instalado
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
  config.vm.box_version = "1.0.1"

  config.vm.synced_folder "#{ENV['HOME']}/vagrant-druid-master/shared/", "#{ENV['HOME']}/vagrant-druid-master/data", :mount_options => ["dmode=777","fmode=777"] , :create => true
  

  # Manage /etc/hosts on host and VMs
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false


  # MASTER NODE CONFIGURATION
  config.vm.define :master do |master|
    master.vm.provider :virtualbox do |v|
      v.name = "vm-influxbd-master"
      v.customize ["modifyvm", :id, "--memory", "2048"]
    end
    #master.vm.network "forwarded_port", guest: 8086, host: 8086
    #master.vm.network :private_network, ip: "10.0.2.15"
    master.vm.hostname = "vm-druid-master"
    master.vm.provision :shell, :inline => $hosts_script
    master.vm.provision :hostmanager
    master.vm.provision :shell, :inline => $master_script
    master.vm.provision "puppet",  manifest_file: "default_master.pp"
  end
  
  # WORKER NODE CONFIGURATION
#  config.vm.define "node1" do |node1|
#    node1.vm.provider :virtualbox do |v|
#      v.name = "vm-druid-node1"
#      v.customize ["modifyvm", :id, "--memory", "2048"]
#    end
#    node1.vm.network :private_network, ip: "10.0.2.16"
#    node1.vm.hostname = "vm-druid-node1"
#    node1.vm.provision :shell, :inline => $hosts_script
#    node1.vm.provision :hostmanager
#    node1.vm.provision :shell, :inline => $node_script
#    node1.vm.provision "puppet",  manifest_file: "default_nodes.pp"
#  end


end
