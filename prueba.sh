#!/bin/bash



export IP_NODE=$1
echo "La IP que asignaremos a éste nodo es:$IP_NODE"

## Modificamos la configuración de las IP de los ficheros

echo "Ajustando plantilla de configuración MySQL"
cp mysql/my.cnf mysql/my.cnf_config
sed -e 's/IP_NODE/'$IP_NODE'/g' -i mysql/my.cnf_config

