echo "Starting postaction on VM" >> /tmp/vm.log

sudo yum -y install git
sudo yum -y install docker

sudo mkdir /app
sudo cd /app
sudo git clone https://github.com/EqualExperts/node-js-getting-started.git nodejs
sudo cp /tmp/Dockerfile /app/
docker build -t akhilesh0/nodejs-starter .
docker run -d -P --name nodejs akhilesh0/nodejs-starter
