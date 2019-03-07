echo "Starting postaction on VM" >> /tmp/vm.log"

yum -y install git
yum -y install docker

mkdir /app
cd /app
git clone https://github.com/EqualExperts/node-js-getting-started.git nodejs

