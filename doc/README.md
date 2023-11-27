
# Подробнее про инфру и технологии
Проект реализован с помощью сервисов YandexCloud:
- MDB PostgreSQL;
- Instance Group;
- Network Load Balancer;

- Compute Instance опционален и использовался для отладки и настройки мониторинга (эту часть не автоматизировал);

На VM в инстанс группе все развертывается через cloud-init с помощью docker compose.


# Подробнее про результаты

Чего не сделано:
- Не автоматизировано развертывание Grafana и Prometheus.
- Пароль к БД передается через cloud-config (по правильному было бы через интеграцию с lockbox сделать).
- Не автоматизировано добавление индексов в БД (выглядит как добавить еще один контейнер который сделает `CREATE UNIQUE INDEX ON customers (id); CREATE UNIQUE INDEX ON movies (id); CREATE UNIQUE INDEX ON sessions (id);)`
- более строгое описание доступных эндпоинтов на реверспрокси.
- из-за использования openresty (да, можно было еще рядом воткнуть nginx или что-то еще, но время) и недоступности udp/443 на NLB в моем каталоге не удалось сделать http3.
- не автоматизировал развертывание DB;

Что удалось сделать (или было необходимо для работы приложения):
- развертывание с одного terraform apply;
- описание всех необходимых доступов в том числе в сторону интернета в SG;
- потюнил БД;
- реализация autoheal и healthcheck в compose;
- использование реп c mirror.yandex.ru;
- экспорт metrics с помощью openresty lua (см дальше подробнее про метрики);
- используется FROM scratch;
- найти папки откуда оно берет конфиг и куда пишет логи (с помощью strace);
- коды удалось найти с использованием strings в том числе :)

# Подробнее про мониторинг
Метрики выглядят примерно так:
```
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie",le="0.2"} 1
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie",le="0.4"} 1
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie",le="+Inf"} 1
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="0.0001"} 130
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="0.01"} 1613
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="0.1"} 3768
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="0.2"} 3839
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="0.4"} 3845
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/movie/",le="+Inf"} 3845
request_duration_seconds_bucket{host="",status="200",method="GET",endpoint="/api/session",le="+Inf"} 2
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/"} 15
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/api/customer/"} 3900
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/api/movie"} 1
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/api/movie/"} 3845
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/api/session"} 2
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/api/session/"} 3892
request_duration_seconds_count{host="",status="200",method="GET",endpoint="/config"} 1
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/"} 0.007
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/api/customer/"} 129.165
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/api/movie"} 0.157
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/api/movie/"} 90.692
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/api/session"} 21.893
request_duration_seconds_sum{host="",status="200",method="GET",endpoint="/api/session/"} 150.01
requests_total{host="",status="200",method="GET",endpoint="/"} 15
requests_total{host="",status="200",method="GET",endpoint="/api/customer/"} 3900
requests_total{host="",status="200",method="GET",endpoint="/api/movie"} 1
requests_total{host="",status="200",method="GET",endpoint="/api/movie/"} 3845
requests_total{host="",status="200",method="GET",endpoint="/api/session"} 2
requests_total{host="",status="200",method="GET",endpoint="/api/session/"} 3892
requests_total{host="",status="200",method="GET",endpoint="/config"} 1
requests_total{host="",status="200",method="GET",endpoint="/db_dummy"} 4129
```

В графане
![Grafana dash](/doc/grafana.png "Dash")

# How to Deploy

1. `export YC_TOKEN=$(yc iam create-token) YC_CLOUD_ID=$(yc config get cloud-id) export YC_FOLDER_ID=$(yc config get folder-id)`
2. `terraform init`
3. `terraform appy`
4. Wait 2 min.
