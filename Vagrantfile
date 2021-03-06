####################################################################################################################
# VARIABLES DE ENTORNO VAGRANT
####################################################################################################################

$master_node_ip = "192.168.50.4";
$child_node_1_ip = "192.168.50.5";

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
if [ ! -d /etc/puppet/modules/mysql ]; then
 puppet module install puppetlabs-mysql
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
if [ ! -d /etc/puppet/modules/mysql ]; then
 puppet module install puppetlabs-mysql
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
# Script para instalar y configurar druid, zookeeper y configurar la base de datos
# ademas de otras utilidades:
# supervisor,vim,less,net-tools,inetutils-ping,curl,git,telnet,nmap,socat,dnsutils,netcat,software-properties-common,maven
####################################################################################################################
$druid_script = <<SCRIPT
#!/bin/bash

export IP_NODE=$1
echo "La IP que asignaremos a éste nodo es:$IP_NODE"

## Modificamos la configuración de las IP de los ficheros

echo "Ajustando plantilla de configuración MySQL"
cp /vagrant/mysql/my.cnf /vagrant/mysql/my.cnf_config
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/mysql/my.cnf_config

echo "Ajustando plantilla de configuración Supervisor"
cp /vagrant/supervisor/supervisord.conf /vagrant/supervisor/supervisord.conf_config
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/supervisor/supervisord.conf_config

echo "Ajustando plantilla de configuración Druid"
cp -rp /vagrant/config /vagrant/config_config
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/config_config/_common/common.runtime.properties
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/config_config/broker/runtime.properties
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/config_config/historical/runtime.properties
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/config_config/middleManager/runtime.properties
sed -e 's/IP_NODE/'$IP_NODE'/g' -i /vagrant/config_config/overlord/runtime.properties

apt-get install -y supervisor vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat software-properties-common maven

echo "Instalando Druid v0.8.1"
if [ ! -d "druid-services" ]; then

wget --quiet http://static.druid.io/artifacts/releases/druid-0.8.1-bin.tar.gz && \
  tar -zxf druid-*.gz && \
  mv druid-0.8.1 druid &&\
  mv druid/config druid/config.orig &&\
  cp -r /vagrant/config_config druid/config &&\
  chown -R vagrant:vagrant druid

wget http://central.maven.org/maven2/org/fusesource/sigar/1.6.4/sigar-1.6.4.jar && \
  mv sigar-1.6.4.jar druid/lib/

fi

echo "Instalando Zookeeper v3.4.6"

if [ ! -d "zookeeper" ]; then

wget --quiet http://mirrors.ibiblio.org/apache/zookeeper/zookeeper-3.4.6/zookeeper-3.4.6.tar.gz && \
  tar xzf zookeeper-*.tar.gz && \
  mv zookeeper-3.4.6 zookeeper && \
  cp zookeeper/conf/zoo_sample.cfg zookeeper/conf/zoo.cfg &&\
  chown -R vagrant:vagrant zookeeper
fi

# Ahora se instala con puppet
#DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server

DB_PASSWORD=vagrant

if mysqladmin -u root password $DB_PASSWORD 2>&1; then
  echo "Intial db root password is set now."
else
  echo "Existing db. root password is not changed."
fi

cp /vagrant/mysql/my.cnf_config /etc/mysql/my.cnf
/etc/init.d/mysql restart

cat <<EOF | mysql -u root --password=$DB_PASSWORD
create database if not exists druid default charset utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON druid.* TO 'druid'@'%' IDENTIFIED BY 'diurd';
FLUSH PRIVILEGES;
EOF

echo "Configurando los servicios."
mkdir -p /var/log/{zookeeper,druid} && \
chown -R vagrant:vagrant /var/log/{zookeeper,druid}
service supervisor restart
cp /vagrant/supervisor/supervisord.conf_config /etc/supervisor/conf.d/supervisord.conf
supervisorctl reload

echo "Limpiando temporales"
rm /vagrant/mysql/my.cnf_config
rm /vagrant/supervisor/supervisord.conf_config
rm -r /vagrant/config_config
SCRIPT


Vagrant.configure("2") do |config|

  # Manage /etc/hosts on host and VMs
  config.hostmanager.enabled = false
  config.hostmanager.manage_host = true
  config.hostmanager.include_offline = true
  config.hostmanager.ignore_private_ip = false


  # MASTER NODE CONFIGURATION
  config.vm.define :master do |master|
    # Imagen base Ubuntu Trusty 64bits con Puppet instalado
    # master.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"
    # master.vm.box_version = "1.0.1"
  
    # Box de Ubuntu sin Puppet instalado
    master.vm.box = "ubuntu/trusty64"
    

    master.vm.synced_folder "#{ENV['HOME']}/vagrant-druid-master/shared/", "#{ENV['HOME']}/vagrant-druid-master/data", :mount_options => ["dmode=777","fmode=777"] , :create => true
  
    master.vm.synced_folder ".", "/vagrant"
    
    master.vm.provider :virtualbox do |v|
      v.name = "vm-druid-master"
      v.customize ["modifyvm", :id, "--memory", "8096"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
    
    master.vm.hostname = "vm-druid-master"
    master.vm.network :private_network, ip: $master_node_ip
    
    # Si queremos redirigir puertos usando 'localhost' habilitar ésto
    #master.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
    #master.vm.network "forwarded_port", guest: 8081, host: 8081, auto_correct: true
    #master.vm.network "forwarded_port", guest: 8090, host: 8090, auto_correct: true
    #master.vm.network "forwarded_port", guest: 8082, host: 8082, auto_correct: true
    #master.vm.network "forwarded_port", guest: 8100, host: 8100, auto_correct: true

    # master.vm.provision :shell, :inline => $hosts_script    
    master.vm.provision "shell" do |hosts|
      hosts.inline = $hosts_script
      hosts.privileged = true
    end

    master.vm.provision :hostmanager
    
    # master.vm.provision :shell, :inline => $master_script, :args => $master_node_ip
    master.vm.provision "shell" do |masterscript|
      masterscript.inline = $master_script
      masterscript.args = $master_node_ip
      masterscript.privileged = true
    end

    master.vm.provision "puppet",  manifest_file: "default_master.pp"

    # master.vm.provision :shell, :inline => $druid_script, :args => $master_node_ip
    master.vm.provision "shell" do |druidscript|
      druidscript.inline = $druid_script
      druidscript.args = $master_node_ip
      druidscript.privileged = true
    end

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
