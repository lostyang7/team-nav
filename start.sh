#!/bin/bash

# 团队导航服务 - 启动脚本

set -e

# 默认配置
JAR_FILE="target/team-nav.jar"
JAVA_OPTS="-Xms512m -Xmx1024m"
SPRING_PROFILES=""
SERVER_PORT=""
CONFIG_FILE=""

# 显示帮助信息
show_help() {
    echo "团队导航服务 - 启动脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -h, --help              显示此帮助信息"
    echo "  -j, --jar <file>        指定jar文件路径 (默认: target/team-nav.jar)"
    echo "  -p, --port <port>       指定服务端口 (默认: 8080)"
    echo "  -d, --profile <profile> 指定Spring Profile (h2/mysql/postgresql)"
    echo "  -c, --config <file>     指定配置文件路径"
    echo "  -m, --memory <size>     指定JVM内存大小 (默认: 512m-1024m)"
    echo ""
    echo "示例:"
    echo "  $0                                    # 使用默认配置启动"
    echo "  $0 -p 8082                           # 指定端口8082"
    echo "  $0 -d mysql -p 8082                  # 使用MySQL数据库，端口8082"
    echo "  $0 -m 1g-2g                          # 指定内存1g-2g"
    echo "  $0 -c ./config/application.yml       # 使用外部配置文件"
    echo ""
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -j|--jar)
            JAR_FILE="$2"
            shift 2
            ;;
        -p|--port)
            SERVER_PORT="--server.port=$2"
            shift 2
            ;;
        -d|--profile)
            SPRING_PROFILES="--spring.profiles.active=$2"
            shift 2
            ;;
        -c|--config)
            CONFIG_FILE="--spring.config.location=file:$2"
            shift 2
            ;;
        -m|--memory)
            JAVA_OPTS="-Xms${2%-*}-Xmx${2#*-}"
            shift 2
            ;;
        *)
            echo "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 检查jar文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "❌ 错误: 找不到jar文件: $JAR_FILE"
    echo "请先运行构建命令: mvn clean package -Dmaven.npm.skip=false"
    exit 1
fi

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未找到Java环境，请先安装JDK 8或更高版本"
    exit 1
fi

echo "=========================================="
echo "团队导航服务 - 启动中"
echo "=========================================="
echo "📦 JAR文件: $JAR_FILE"
echo "🔧 JVM参数: $JAVA_OPTS"
echo "🌐 服务端口: ${SERVER_PORT:-8080 (默认)}"
echo "🗄️  数据库配置: ${SPRING_PROFILES:-h2 (默认)}"
echo "📄 配置文件: ${CONFIG_FILE:-内置配置}"
echo ""

# 构建启动命令
START_CMD="java $JAVA_OPTS -jar $JAR_FILE"

if [ -n "$SPRING_PROFILES" ]; then
    START_CMD="$START_CMD $SPRING_PROFILES"
fi

if [ -n "$SERVER_PORT" ]; then
    START_CMD="$START_CMD $SERVER_PORT"
fi

if [ -n "$CONFIG_FILE" ]; then
    START_CMD="$START_CMD $CONFIG_FILE"
fi

echo "🚀 启动命令: $START_CMD"
echo ""

# 启动应用
echo "⏳ 正在启动应用..."
exec $START_CMD 