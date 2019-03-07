echo "Starting postaction on VM" >> /tmp/vm.log

echo "demopass@1213" | sudo yum -y install git
echo "demopass@1213" | sudo yum -y install docker
echo "demopass@1213" | sudo service docker start
echo "demopass@1213" | sudo mkdir /app
echo "demopass@1213" | sudo cd /app
echo "demopass@1213" | sudo git clone https://github.com/EqualExperts/node-js-getting-started.git nodejs
echo "demopass@1213" | sudo cp /tmp/Dockerfile /app/
echo "demopass@1213" | sudo docker build -t akhilesh0/nodejs-starter .
echo "demopass@1213" | sudo docker run -d -P --name nodejs akhilesh0/nodejs-starter
