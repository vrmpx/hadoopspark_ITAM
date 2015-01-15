#!/bin/bash 
mirror=http://apache.webxcreen.org/hadoop/common/
version=hadoop-1.2.1

#######################################
# Script para instalar Hadoop + Spark
#######################################

apt-get install --yes python-software-properties
add-apt-repository --yes ppa:ferramroberto/java
apt-get update

# Install Sun Java 6
apt-get install --yes sun-java6-jdk
update-java-alternatives -s java-6-sun

######################################
# Get Hadoop
######################################

cd /tmp 
wget "$mirror/$version".tar.gz 
tar -xzf "$version".tar.gz
mv  $version /usr/local/hadoop
rm "$version".tar.gz


########################################
# User group + User
########################################
addgroup hadoop
adduser --ingroup hadoop hduser

########################################
# Hadoop Conf
# Script taken from https://github.com/okaram/scripts/blob/master/hadoop/install-hadoop-1.1.sh
########################################

#modify hadoop-env
cd /usr/local/$version/conf
echo "export JAVA_HOME=/usr" >> hadoop-env.sh
echo "export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> hadoop-env.sh

#get configuration files
rm core-site.xml
wget https://raw.github.com/okaram/scripts/master/hadoop/conf/core-site.xml
rm mapred-site.xml
wget https://raw.github.com/okaram/scripts/master/hadoop/conf/mapred-site.xml
rm hdfs-site.xml
wget https://raw.github.com/okaram/scripts/master/hadoop/conf/hdfs-site.xml

# chmod, symbolic links
cd /usr/local
ln -s $version hadoop
chown -R hduser.hadoop $version
chown hduser.hadoop $version

su - hduser -c "/usr/local/hadoop/bin/hadoop namenode -format"

#ssh stuff
su - hduser -c "echo | ssh-keygen -t rsa -P \"\""
cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys
su - hduser -c "ssh -o StrictHostKeyChecking=no localhost echo " #login once, to add to known hosts

su - hduser -c "/usr/local/hadoop/bin/hadoop namenode -format"