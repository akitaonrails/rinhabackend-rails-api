# Rinha Backend - API

To run this application:

    docker-compose up

Just for the first time run:

    docker-compose exec api1 rails db:create
    docker-compose exec api1 rails db:migrate

Application should respond at:

    http://0.0.0.0:9999


Run stress test:

    wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.9.5/gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    unzip gatling-charts-highcharts-bundle-3.9.5-bundle.zip
    sudo mv gatling-charts-highcharts-bundle-3.9.5-bundle /opt
    sudo ln -s /opt/gatling-charts-highcharts-bundle-3.9.5-bundle /opt/gatling

    cd ..
    git clone https://github.com/zanfranceschi/rinha-de-backend-2023-q3.git
    cd rinha-de-backend-2023-q3/stress-test

Edit the stress-test run-test.sh variables accordingly:

    GATLING_BIN_DIR=/opt/gatling/bin

    WORKSPACE=$HOME/Projects/rinha-de-backend-2023-q3/stress-test

Run the stress test:

    ./run-test.sh # after docker-compose up

On AWS EC2, create a t2.medium instance (2vCPUs 4GB RAM), download the .pem key:

    chmod 400 yourkey.pem
    ssh -i yourkey.pem -o IdentitiesOnly=yes ec2-user@yourinstanceaddress.com

SSH in:

    # Install Docker
    sudo amazon-linux-extras install docker
    sudo service docker start
    sudo usermod -a -G docker ec2-user

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    # install Git
    sudo yum update -y
    sudo yum install git -y
    git clone https://github.com/akitaonrails/rinhabackend-rails-api.git

    # run docker compose
    cd rinhabackend-rails-api
    docker-compose up --force-recreate -d

Challenge [INSTRUCTIONS](https://github.com/zanfranceschi/rinha-de-backend-2023-q3/blob/main/INSTRUCOES.md):

Challenge [STRESS TEST](https://github.com/zanfranceschi/rinha-de-backend-2023-q3/blob/main/stress-test/run-test.sh)

Don't forget to change run-test.sh and RinhaBackendSimulation.scala to add your own PATH and HOST name (in case you're running on AWS EC2). Also don't forget to edit docker-compose.yml to not build locally, but fetch the image from docker.io.
