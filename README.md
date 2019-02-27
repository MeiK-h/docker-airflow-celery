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

### Master 节点

```bash
docker-compose up -d
```

Master 节点自带一个 Worker。

### Worker 节点

```bash
docker-compose up -d worker
```
