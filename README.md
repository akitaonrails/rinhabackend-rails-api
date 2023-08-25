# Rinha Backend - API

To run this application:

    docker-compose up

Just for the first time run:

    docker-compose exec api1 rails db:create
    docker-compose exec api1 rails db:migrate

Application should respond at:

    http://0.0.0.0:9999

On AWS EC2, create a t2.medium instance (2vCPUs 4GB RAM), ssh in and:

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
    docker-compose up

Challenge description:

    https://github.com/zanfranceschi/rinha-de-backend-2023-q3/blob/main/INSTRUCOES.md
