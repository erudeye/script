#!/bin/sh
set -e

hadoop_version=3.3.0
jdk_version=8
hadoop_user="hadoopu"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if grep -c ""$hadoop_user":" /etc/passwd; then
    echo "User "$hadoop_user" exist, bypass add user."
else
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 0600 ~/.ssh/authorized_keys
fi

# install java
if command_exists java; then
    echo "Java already installed."
else
    sudo apt install openjdk-$jdk_version-jdk -y
fi

# install hadoop
hadoop_file=hadoop-$hadoop_version.tar.gz
if test -f "$hadoop_file"; then
    echo ""$hadoop_file" exist, skip download."
else
    wget https://downloads.apache.org/hadoop/common/hadoop-$hadoop_version/hadoop-$hadoop_version.tar.gz
fi

if test -d "/usr/local/hadoop"; then
    echo "Hadoop file exist, skip extract."
    #sudo rm -rf /usr/local/hadoop
else
    tar -xvzf hadoop-$hadoop_version.tar.gz
    sudo mv hadoop-$hadoop_version /usr/local/hadoop
    sudo mkdir /usr/local/hadoop/logs
    sudo chown -R $hadoop_user:$hadoop_user /usr/local/hadoop
fi



# modify .bashrc env
if grep -c "# modify .bashrc by Hadoop Installer script." ~/.bashrc; then
    echo "Hadoop environment variables already exist in .bashrc"
else
    echo "Adding Hadoop environment variables..."
    echo "" >> ~/.bashrc
    echo "# modify .bashrc by Hadoop Installer script." >> ~/.bashrc
    echo "export HADOOP_HOME=/usr/local/hadoop" >> ~/.bashrc
    echo "export HADOOP_INSTALL=\$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_MAPRED_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_COMMON_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_HDFS_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export YARN_HOME=\$HADOOP_HOME" >> ~/.bashrc
    echo "export HADOOP_COMMON_LIB_NATIVE_DIR=\$HADOOP_HOME/lib/native" >> ~/.bashrc
    echo "export PATH=\$PATH:\$HADOOP_HOME/sbin:\$HADOOP_HOME/bin" >> ~/.bashrc
    echo "export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_HOME/lib/native\"" >> ~/.bashrc
    source ~/.bashrc
fi

echo "export JAVA_HOME=/usr/lib/jvm/java-"$jdk_version"-openjdk-amd64" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh
echo "export HADOOP_CLASSPATH+=\" \$HADOOP_HOME/lib/*.jar\"" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh

hadoop version
