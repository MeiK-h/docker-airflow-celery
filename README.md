# docker-airflow

## Usage

配置环境变量

```bash
export MYSQL_HOST=10.2.59.242
export MYSQL_USER=airflow
export MYSQL_PASSWORD=airflow
export MYSQL_DATABASE=airflow
export MYSQL_ROOT_PASSWORD=password
export REDIS_HOST=10.2.59.242
export REDIS_PASSWORD=airflow
```

第一次 `up` 会运行报错（因为 Scheduler 等启动时 MySQL 的初始化还未完成），可以提前初始化数据库：

```bash
docker-compose up mysql  # 创建 MySQL 库
^C
docker-compose up webserver  # initdb 初始化表
^C
```

### Master 节点

```bash
docker-compose up -d
```

Master 节点自带一个 Worker。

### Worker 节点

```bash
docker-compose up -d worker
```

## 为 WebServer 启用密码

```bash
export AIRFLOW__WEBSERVER__AUTHENTICATE=True
export AIRFLOW_USER=airflow
export AIRFLOW_PASSWORD=airflow
```

## 使用已有的 MySQL 和 redis

首先配置环境变量，填入已有 MySQL 和 redis 的配置。

```bash
export MYSQL_HOST=10.2.59.242
export MYSQL_USER=airflow
export MYSQL_PASSWORD=airflow
export MYSQL_DATABASE=airflow
export REDIS_HOST=10.2.59.242
export REDIS_PASSWORD=airflow
```

MySQL 应该修改配置 `explicit_defaults_for_timestamp = 1`

```bash
docker-compose -f docker-compose-without-db.yml up
```

## 自定义 WebServer 个数、Worker 个数与 Worker 的名称

Worker 的名称会在 flower 中显示。

在配置较低的云服务器上，可以通过降低 Worker 和 WebServer 的个数来减少系统压力。

```shell
export AIRFLOW_WEBSERVER_NUMBER=1
export AIRFLOW_WORKER_PROCESS_NUMBER=2
export AIRFLOW_WORKER_NAME=worker
```
