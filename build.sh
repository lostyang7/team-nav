#!/bin/bash

# 团队导航服务 - 一键构建脚本
# 构建前后端一体化的可执行jar包

set -e

echo "=========================================="
echo "团队导航服务 - 开始构建"
echo "=========================================="

# 检查Java环境
if ! command -v java &> /dev/null; then
    echo "❌ 错误: 未找到Java环境，请先安装JDK 8或更高版本"
    exit 1
fi

# 检查Maven环境
if ! command -v mvn &> /dev/null; then
    echo "❌ 错误: 未找到Maven环境，请先安装Maven"
    exit 1
fi

echo "✅ Java版本: $(java -version 2>&1 | head -n 1)"
echo "✅ Maven版本: $(mvn -version | head -n 1)"

# 清理之前的构建
echo "🧹 清理之前的构建文件..."
mvn clean

# 构建项目（包含前端构建）
echo "🔨 开始构建项目..."
echo "📦 这将自动执行以下步骤："
echo "   1. 安装Node.js和npm"
echo "   2. 安装前端依赖"
echo "   3. 构建前端项目"
echo "   4. 复制前端文件到后端资源目录"
echo "   5. 打包Spring Boot应用"
echo ""

# 执行Maven构建
mvn clean package -Dmaven.npm.skip=false

# 检查构建结果
if [ -f "target/team-nav.jar" ]; then
    echo ""
    echo "=========================================="
    echo "✅ 构建成功！"
    echo "=========================================="
    echo "📦 生成的文件: target/team-nav.jar"
    echo "📏 文件大小: $(du -h target/team-nav.jar | cut -f1)"
    echo ""
    echo "🚀 启动命令:"
    echo "   java -jar target/team-nav.jar"
    echo ""
    echo "🔧 自定义配置启动:"
    echo "   java -jar target/team-nav.jar --spring.profiles.active=mysql"
    echo ""
    echo "📋 其他启动选项:"
    echo "   - 指定端口: java -jar target/team-nav.jar --server.port=8082"
    echo "   - 指定配置文件: java -jar target/team-nav.jar --spring.config.location=classpath:application-mysql.yml"
    echo ""
    echo "📚 更多信息请查看 README.md"
else
    echo ""
    echo "❌ 构建失败！请检查错误信息"
    exit 1
fi 