# 团队导航服务 - Docker部署指南

本文档介绍如何使用Docker部署团队导航服务，并配合浏览器插件使用。

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+（可选，用于简化部署）
- 至少2GB可用内存
- 至少10GB可用磁盘空间

## 快速部署

### 方法一：使用Docker命令

```bash
# 拉取最新镜像
docker pull registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6

# 创建数据目录
mkdir -p /opt/team-nav/{logs,database,ext-resources}

# 启动容器
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/database:/database \
  -v /opt/team-nav/ext-resources:/ext-resources \
  -e nav-name="团队导航服务" \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

### 方法二：使用Docker Compose

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  team-nav:
    image: registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
    container_name: team-nav
    ports:
      - "8082:8080"
    volumes:
      - ./logs:/logs
      - ./database:/database
      - ./ext-resources:/ext-resources
    environment:
      - nav-name=团队导航服务
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/card/tree"]
      interval: 30s
      timeout: 10s
      retries: 3
```

启动服务：

```bash
docker-compose up -d
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `nav-name` | 团队导航服务 | 导航服务显示名称 |
| `spring.profiles.active` | h2 | 数据库类型（h2/mysql/postgresql） |
| `spring.datasource.url` | - | 数据库连接URL |
| `spring.datasource.username` | - | 数据库用户名 |
| `spring.datasource.password` | - | 数据库密码 |

### 数据卷

| 挂载路径 | 说明 |
|----------|------|
| `/logs` | 应用日志文件 |
| `/database` | 数据库文件（H2模式） |
| `/ext-resources` | 自定义图标、附件等资源文件 |

### 端口映射

| 容器端口 | 主机端口 | 说明 |
|----------|----------|------|
| 8080 | 8082 | 应用服务端口 |

## 数据库配置

### 使用H2数据库（默认）

```bash
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/database:/database \
  -v /opt/team-nav/ext-resources:/ext-resources \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

### 使用MySQL数据库

```bash
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/ext-resources:/ext-resources \
  -e spring.profiles.active=mysql \
  -e spring.datasource.url=jdbc:mysql://mysql-host:3306/team_nav?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8 \
  -e spring.datasource.username=root \
  -e spring.datasource.password=123456 \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

### 使用PostgreSQL数据库

```bash
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/ext-resources:/ext-resources \
  -e spring.profiles.active=postgresql \
  -e spring.datasource.url=jdbc:postgresql://postgres-host:5432/team_nav \
  -e spring.datasource.username=postgres \
  -e spring.datasource.password=123456 \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

## 完整部署示例

### 使用Docker Compose部署完整环境

创建 `docker-compose.yml` 文件：

```yaml
version: '3.8'

services:
  # MySQL数据库
  mysql:
    image: mysql:8.0
    container_name: team-nav-mysql
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: team_nav
      MYSQL_CHARACTER_SET_SERVER: utf8mb4
      MYSQL_COLLATION_SERVER: utf8mb4_unicode_ci
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"
    restart: unless-stopped

  # 团队导航服务
  team-nav:
    image: registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
    container_name: team-nav
    depends_on:
      - mysql
    ports:
      - "8082:8080"
    volumes:
      - ./logs:/logs
      - ./ext-resources:/ext-resources
    environment:
      - nav-name=团队导航服务
      - spring.profiles.active=mysql
      - spring.datasource.url=jdbc:mysql://mysql:3306/team_nav?useUnicode=true&characterEncoding=utf8&zeroDateTimeBehavior=convertToNull&useSSL=true&serverTimezone=GMT%2B8
      - spring.datasource.username=root
      - spring.datasource.password=123456
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/api/v1/card/tree"]
      interval: 30s
      timeout: 10s
      retries: 3

  # Nginx反向代理（可选）
  nginx:
    image: nginx:alpine
    container_name: team-nav-nginx
    depends_on:
      - team-nav
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    restart: unless-stopped

volumes:
  mysql_data:
```

创建 `nginx.conf` 文件：

```nginx
events {
    worker_connections 1024;
}

http {
    upstream team-nav {
        server team-nav:8080;
    }

    server {
        listen 80;
        server_name your-domain.com;

        location / {
            proxy_pass http://team-nav;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # 静态网站访问
        location /ext-resources/modules {
            alias /opt/team-nav/ext-resources/modules;
            index index.html index.htm;
        }
    }
}
```

启动服务：

```bash
docker-compose up -d
```

## 浏览器插件配置

部署完成后，配置浏览器插件：

1. 安装浏览器插件（参考 `browser-extension/README.md`）
2. 点击插件图标，设置导航服务器地址：
   - 本地部署：`http://localhost:8082`
   - 服务器部署：`http://your-server-ip:8082`
   - 域名部署：`https://your-domain.com`

## 管理操作

### 查看服务状态

```bash
# 查看容器状态
docker ps

# 查看服务日志
docker logs team-nav

# 查看实时日志
docker logs -f team-nav
```

### 备份数据

```bash
# 备份数据库
docker exec team-nav tar -czf /database/backup-$(date +%Y%m%d).tar.gz /database/

# 备份资源文件
docker exec team-nav tar -czf /ext-resources/resources-$(date +%Y%m%d).tar.gz /ext-resources/
```

### 更新服务

```bash
# 停止服务
docker stop team-nav

# 删除容器
docker rm team-nav

# 拉取新镜像
docker pull registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:latest

# 重新启动（使用相同的配置）
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/database:/database \
  -v /opt/team-nav/ext-resources:/ext-resources \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:latest
```

### 清理数据

```bash
# 停止并删除容器
docker stop team-nav
docker rm team-nav

# 删除数据卷（谨慎操作，会丢失所有数据）
docker volume rm team-nav-data
```

## 故障排除

### 服务无法启动

1. 检查端口是否被占用：
   ```bash
   netstat -tulpn | grep 8082
   ```

2. 检查Docker服务状态：
   ```bash
   systemctl status docker
   ```

3. 查看详细错误日志：
   ```bash
   docker logs team-nav
   ```

### 无法访问服务

1. 检查防火墙设置：
   ```bash
   # Ubuntu/Debian
   sudo ufw allow 8082
   
   # CentOS/RHEL
   sudo firewall-cmd --permanent --add-port=8082/tcp
   sudo firewall-cmd --reload
   ```

2. 检查容器网络：
   ```bash
   docker network ls
   docker network inspect bridge
   ```

### 数据库连接问题

1. 检查数据库服务状态
2. 验证数据库连接参数
3. 确认数据库用户权限

## 性能优化

### 资源限制

```bash
docker run -d \
  --name team-nav \
  --memory=1g \
  --cpus=1.0 \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/database:/database \
  -v /opt/team-nav/ext-resources:/ext-resources \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

### JVM参数优化

```bash
docker run -d \
  --name team-nav \
  -p 8082:8080 \
  -v /opt/team-nav/logs:/logs \
  -v /opt/team-nav/database:/database \
  -v /opt/team-nav/ext-resources:/ext-resources \
  -e PARAMS="-Xms512m -Xmx1024m -XX:+UseG1GC" \
  registry.cn-chengdu.aliyuncs.com/tuituidan/team-nav:2.0.6
```

## 安全建议

1. **修改默认端口**：避免使用默认端口8082
2. **使用HTTPS**：在生产环境中配置SSL证书
3. **限制访问**：使用防火墙限制访问来源
4. **定期备份**：定期备份数据库和资源文件
5. **更新镜像**：定期更新到最新版本

## 监控告警

### 健康检查

```bash
# 检查服务健康状态
curl -f http://localhost:8082/api/v1/card/tree

# 设置监控脚本
#!/bin/bash
if ! curl -f http://localhost:8082/api/v1/card/tree > /dev/null 2>&1; then
    echo "Team Nav service is down!" | mail -s "Service Alert" admin@example.com
fi
```

### 日志监控

```bash
# 监控错误日志
docker logs -f team-nav | grep -i error

# 监控访问日志
docker logs -f team-nav | grep "GET\|POST"
``` 