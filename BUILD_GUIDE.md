# 团队导航服务 - 构建指南

本文档详细介绍如何构建前后端一体化的团队导航服务jar包。

## 🎯 构建目标

通过Maven构建，生成一个包含前后端的完整可执行jar包，实现：
- ✅ 前后端代码一体化打包
- ✅ 单个jar文件部署
- ✅ 仅需JDK环境即可运行
- ✅ 支持多种数据库配置

## 📋 系统要求

### 必需环境
- **JDK 8+** (推荐JDK 8或JDK 11)
- **Maven 3.6+**
- **Git** (用于代码管理)

### 可选环境
- **Node.js 16+** (如果本地已安装，可跳过自动安装)
- **npm 8+** (如果本地已安装，可跳过自动安装)

## 🚀 快速构建

### 方法一：使用构建脚本（推荐）

#### Linux/macOS
```bash
# 给脚本执行权限
chmod +x build.sh

# 执行构建
./build.sh
```

#### Windows
```cmd
# 双击执行或在命令行运行
build.bat
```

### 方法二：手动构建

```bash
# 1. 清理项目
mvn clean

# 2. 构建项目（包含前端构建）
mvn clean package -Dmaven.npm.skip=false
```

## 🔧 构建过程详解

### 1. 前端构建阶段

Maven构建过程中会自动执行以下前端构建步骤：

```xml
<!-- 安装Node.js和npm -->
<execution>
    <id>install node and npm</id>
    <goals>
        <goal>install-node-and-npm</goal>
    </goals>
</execution>

<!-- 安装前端依赖 -->
<execution>
    <id>npm install</id>
    <goals>
        <goal>npm</goal>
    </goals>
    <configuration>
        <arguments>install</arguments>
    </configuration>
</execution>

<!-- 构建前端项目 -->
<execution>
    <id>npm run build</id>
    <goals>
        <goal>npm</goal>
    </goals>
    <configuration>
        <arguments>run build</arguments>
    </configuration>
</execution>
```

### 2. 资源复制阶段

构建完成后，前端文件会被复制到后端资源目录：

```xml
<!-- 复制前端构建文件到后端资源目录 -->
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-resources-plugin</artifactId>
    <executions>
        <execution>
            <id>copy-frontend-resources</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>copy-resources</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.build.outputDirectory}/static</outputDirectory>
                <resources>
                    <resource>
                        <directory>web/dist</directory>
                        <filtering>false</filtering>
                    </resource>
                </resources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### 3. Spring Boot打包阶段

最后使用Spring Boot Maven插件打包成可执行jar：

```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <excludes>
            <exclude>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
            </exclude>
        </excludes>
    </configuration>
</plugin>
```

## 📦 构建产物

构建成功后，在`target/`目录下会生成以下文件：

```
target/
├── team-nav.jar              # 主jar包（可执行）
├── team-nav.jar.original     # 原始jar包（不含依赖）
├── classes/                  # 编译后的class文件
│   ├── static/              # 前端构建文件
│   └── ...
└── ...
```

## 🎯 启动应用

### 基本启动
```bash
java -jar target/team-nav.jar
```

### 自定义配置启动

#### 使用MySQL数据库
```bash
java -jar target/team-nav.jar --spring.profiles.active=mysql
```

#### 使用PostgreSQL数据库
```bash
java -jar target/team-nav.jar --spring.profiles.active=postgresql
```

#### 指定端口
```bash
java -jar target/team-nav.jar --server.port=8082
```

#### 指定外部配置文件
```bash
java -jar target/team-nav.jar --spring.config.location=file:./config/application.yml
```

#### 组合配置
```bash
java -jar target/team-nav.jar \
  --spring.profiles.active=mysql \
  --server.port=8082 \
  --spring.datasource.url=jdbc:mysql://localhost:3306/team_nav \
  --spring.datasource.username=root \
  --spring.datasource.password=123456
```

## 🔍 构建参数说明

### Maven参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `-Dmaven.npm.skip=false` | 启用前端构建 | false |
| `-Dmaven.npm.skip=true` | 跳过前端构建 | false |
| `-DskipTests` | 跳过测试 | false |
| `-Dmaven.test.skip=true` | 跳过测试编译和执行 | false |

### 前端构建参数

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `node.version` | Node.js版本 | 16.20.0 |
| `npm.version` | npm版本 | 8.19.4 |
| `frontend-maven-plugin.version` | 前端插件版本 | 1.12.1 |

## 🛠️ 常见问题解决

### 1. Node.js安装失败

**问题**：构建时Node.js下载或安装失败

**解决方案**：
```bash
# 方案1：使用本地Node.js
# 确保本地已安装Node.js 16+，然后跳过自动安装
mvn clean package -Dmaven.npm.skip=false -Dskip.npm.install=true

# 方案2：手动安装Node.js
# 在web目录下手动执行
cd web
npm install
npm run build
cd ..
mvn clean package -Dmaven.npm.skip=true
```

### 2. 前端依赖安装失败

**问题**：npm install失败

**解决方案**：
```bash
# 清理npm缓存
cd web
npm cache clean --force
rm -rf node_modules package-lock.json
npm install
cd ..

# 重新构建
mvn clean package -Dmaven.npm.skip=false
```

### 3. 内存不足

**问题**：构建过程中内存不足

**解决方案**：
```bash
# 增加Maven内存
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512m"

# 或使用JVM参数
mvn clean package -Dmaven.npm.skip=false -Xmx2g
```

### 4. 网络问题

**问题**：下载依赖包时网络超时

**解决方案**：
```bash
# 使用国内镜像
# 在~/.m2/settings.xml中配置阿里云镜像
# 在web/.npmrc中配置淘宝npm镜像

# 或使用代理
mvn clean package -Dmaven.npm.skip=false -DproxySet=true -DproxyHost=proxy.company.com -DproxyPort=8080
```

## 📊 构建性能优化

### 1. 并行构建
```bash
# 使用Maven并行构建
mvn clean package -Dmaven.npm.skip=false -T 1C
```

### 2. 跳过测试
```bash
# 开发阶段可跳过测试
mvn clean package -Dmaven.npm.skip=false -DskipTests
```

### 3. 增量构建
```bash
# 只构建变更的部分
mvn compile -Dmaven.npm.skip=false
```

## 🔧 自定义构建配置

### 修改Node.js版本
在`pom.xml`中修改：
```xml
<properties>
    <node.version>18.17.0</node.version>
    <npm.version>9.6.7</npm.version>
</properties>
```

### 修改前端构建目录
在`pom.xml`中修改：
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-resources-plugin</artifactId>
    <configuration>
        <outputDirectory>${project.build.outputDirectory}/static</outputDirectory>
        <resources>
            <resource>
                <directory>web/dist</directory>  <!-- 修改这里 -->
            </resource>
        </resources>
    </configuration>
</plugin>
```

### 添加构建钩子
在`pom.xml`中添加：
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-antrun-plugin</artifactId>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>run</goal>
            </goals>
            <configuration>
                <target>
                    <echo message="构建完成，文件大小："/>
                    <exec executable="ls" osfamily="unix">
                        <arg value="-lh"/>
                        <arg value="${project.build.directory}/${project.build.finalName}.jar"/>
                    </exec>
                </target>
            </configuration>
        </execution>
    </executions>
</plugin>
```

## 📋 构建检查清单

构建前请确认：

- [ ] JDK 8+已安装并配置JAVA_HOME
- [ ] Maven 3.6+已安装并配置MAVEN_HOME
- [ ] Git已安装（用于版本控制）
- [ ] 网络连接正常（用于下载依赖）
- [ ] 磁盘空间充足（至少2GB可用空间）
- [ ] 防火墙允许下载依赖包

构建后请检查：

- [ ] `target/team-nav.jar`文件存在
- [ ] jar包大小合理（通常50-100MB）
- [ ] 可以正常启动应用
- [ ] 前端页面正常显示
- [ ] API接口正常响应

## 📚 相关文档

- [项目README](./README.md)
- [Docker部署指南](./DOCKER_DEPLOYMENT.md)
- [浏览器插件使用说明](./browser-extension/README.md)
- [项目总结文档](./PROJECT_SUMMARY.md) 