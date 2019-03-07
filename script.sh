echo "Starting postaction on VM" >> /tmp/vm.log

echo "demopass@123" | sudo -S yum -y install git
echo "demopass@123" | sudo -S yum -y install docker
echo "demopass@123" | sudo -S service docker start
echo "demopass@123" | sudo -S mkdir /app
echo "demopass@123" | sudo -S cd /app
echo "demopass@123" | sudo -S git clone https://github.com/EqualExperts/node-js-getting-started.git nodejs
echo "demopass@123" | sudo -S cp /tmp/Dockerfile /app/
echo "demopass@123" | sudo -S docker build -t akhilesh0/nodejs-starter .
echo "demopass@123" | sudo -S docker run -d -P --name nodejs akhilesh0/nodejs-starter
