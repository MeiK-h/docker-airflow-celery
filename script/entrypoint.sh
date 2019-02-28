#!/usr/bin/env bash

TRY_LOOP="20"

# 设置 Redis 的配置
: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

# 设置 MySQL 的配置
: "${MYSQL_HOST:="mysql"}"
: "${MYSQL_PORT:="3306"}"
: "${MYSQL_USER:="airflow"}"
: "${MYSQL_PASSWORD:="airflow"}"
: "${MYSQL_DATABASE:="airflow"}"

# Defaults and back-compat
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"
: "${AIRFLOW__CORE__EXECUTOR:="CeleryExecutor"}"

export \
  AIRFLOW__CELERY__BROKER_URL \
  AIRFLOW__CELERY__RESULT_BACKEND \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN \


# Load DAGs exemples (default: No)
if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]
then
  AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

# Install custom python package if requirements.txt is present
if [ -e "/requirements/requirements.txt" ]; then
    $(which pip) install -r /requirements/requirements.txt
fi

# 拼接 Redis 连接字符串
if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_PREFIX=root:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

# 使用 nc 命令检查对应端口是否开放
wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

# 配置相应的连接配置
AIRFLOW__CORE__SQL_ALCHEMY_CONN="mysql+mysqldb://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
AIRFLOW__CELERY__RESULT_BACKEND="db+mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/1"
wait_for_port "MySQL" "$MYSQL_HOST" "$MYSQL_PORT"
wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"

# 根据不同的输入执行命令
case "$1" in
  webserver)
    airflow initdb
    exec airflow webserver
    ;;
  worker|scheduler)
    exec airflow "$@"
    ;;
  flower)
    exec airflow "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
