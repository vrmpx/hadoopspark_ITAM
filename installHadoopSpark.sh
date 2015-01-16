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
wget "$mirror/$version/$version".tar.gz 
tar -xzf "$version".tar.gz
mv  $version /usr/local/
rm "$version".tar.gz


########################################
# User group + User
########################################
addgroup hadoop
adduser --disabled-password --gecos "" --ingroup hadoop hduser

########################################
# Hadoop Conf
# Script taken from https://github.com/okaram/scripts/blob/master/hadoop/install-hadoop-1.1.sh
########################################

# Tmp folder
mkdir -p /app/hadoop/tmp
chown -R hduser.hadoop /app/hadoop/tmp
chmod 750 /app/hadoop/tmp

#modify hadoop-env
cd /usr/local/$version/conf
echo "export JAVA_HOME=/usr/lib/jvm/java-6-sun" >> hadoop-env.sh
echo "export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true" >> hadoop-env.sh

#get configuration files
rm core-site.xml
wget https://raw.githubusercontent.com/vrmpx/hadoopspark_ITAM/master/conf/hadoop/core-site.xml
rm mapred-site.xml
wget https://raw.githubusercontent.com/vrmpx/hadoopspark_ITAM/master/conf/hadoop/mapred-site.xml
rm hdfs-site.xml
wget https://raw.githubusercontent.com/vrmpx/hadoopspark_ITAM/master/conf/hadoop/hdfs-site.xml

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

######################################
# Get Scala
######################################
apt-get install --yes scala 

######################################
# Get Spark
######################################
$sparkmirror=http://apache.webxcreen.org/spark/spark-1.2.0/
$sparkversion=spark-1.2.0

cd /tmp
wget "$sparkmirror/$sparkversion".tgz
tar -xzf $sparkversion.tgz 
mv $sparkversion /usr/local/
rm "$sparkversion".tgz

cd /usr/local/
ln -s $sparkversion spark
chown -R hduser.hadoop $sparkversion
chown hduser.hadoop $sparkversion