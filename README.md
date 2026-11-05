# PostgreSQL

Создает 3 таблицы в БД, и заполняет данными из задания.

## Docker compose

Установите Docker и запустите проект:

```
docker compose up -d
```

При первом запуске выполняются `sql/init.sql` (таблицы и данные)
и `sql/report.sql` (функция). Результаты можно увидеть в консоли или выполнить команду вручную.

## Подключение IDE

PostgreSQL данные:

Host: `localhost` 
Port: `5433`
Database: `postgres` 
User: `test`
Password: `test`
JDBC URL `jdbc:postgresql://localhost:5433/postgres`

После создания соединения в консоли выполнить команду: 

```SELECT *
FROM абоненты_с_задолженностью('2021-07-01', 2)
ORDER BY месяцев_оплачено, абонент;```