#!/bin/bash

## Variables
cert_loc="http://10.140.221.229/share/"
cert_file="iam.ind-west-1.staging.deprecated.jiocloudservices.com.crt"
ubuntu_ss_cert_loc="/usr/local/share/ca-certificates/selfsigned.crt"
rhel_ss_cert_loc="/etc/pki/ca-trust/source/anchors/"
ca_pkg="ca-certificates"

if [ "$1" == "stg" ]
then
	cert_file="iam.ind-west-1.staging.jiocloudservices.com.crt"
fi

echo "Checking Linux distribution"

grep -i ubuntu /etc/os-release >/dev/null
ubuntu_found=$?

if [ "$ubuntu_found" -eq 0 ]
then
	ca_cert_dir="/usr/local/share/ca-certificates"
else
	grep -iE 'fedora|redhat|centos' /etc/os-release >/dev/null
	rhel_found=$?
	if [ $rhel_found -eq 0 ]
	then
		ca_cert_dir="/etc/pki"
	fi
fi

if [ -z "$ca_cert_dir" ]
then
	echo "No supported linux distribution found, exitting :("
	exit 1
fi

echo "Checking $ca_cert_dir"
if [ -d "$ca_cert_dir" ]
then
	echo "$ca_cert_dir exists. Proceeding.."
else
	echo "$ca_cert_dir does not exist. Check that you have package $ca_pkg installed"
	exit 2
fi


if [ "$ubuntu_found" -eq 0 ]
then
	sudo rm ${ubuntu_ss_cert_loc}
	sudo wget ${cert_loc}/${cert_file} -O ${ubuntu_ss_cert_loc}
	sudo update-ca-certificates 
	certs_update=$?
	if [ $certs_update -eq 0 ]
	then
		echo "Self signed certificate ${cert_file} installed."
	else
		echo "Error installing Self signed certificate ${cert_file}."
		exit 3
	fi
fi

if [ "$rhel_found" -eq 0 ]
then
	sudo rm ${rhel_ss_cert_loc}/${cert_file}
	sudo wget ${cert_loc}/${cert_file} -O ${rhel_ss_cert_loc}/${cert_file}
	sudo update-ca-trust enable
	sudo update-ca-trust extract
	cd /etc/pki/tls/certs
	sudo rm $(openssl x509 -in ${cert_file} -noout -hash).0 $cert_file
	sudo wget ${cert_loc}/${cert_file}
	sudo ln -sv ${cert_file} $(openssl x509 -in ${cert_file} -noout -hash).0
	certs_update=$?
	if [ $certs_update -eq 0 ]
	then
		echo "Self signed certificate ${cert_file} installed."
	else
		echo "Error installing Self signed certificate ${cert_file}."
		exit 4
	fi
fi
