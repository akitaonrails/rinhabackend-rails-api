# Rinha Backend - API

To run this application:

    docker-compose up

Just for the first time run:

    docker-compose exec api1 rails db:create
    docker-compose exec api1 rails db:migrate

Application should respond at:

    http://0.0.0.0:9999

Challenge description:

    https://github.com/zanfranceschi/rinha-de-backend-2023-q3/blob/main/INSTRUCOES.md
