@echo off
chcp 65001 >nul

echo ==========================================
echo 团队导航服务 - 开始构建
echo ==========================================

REM 检查Java环境
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Java环境，请先安装JDK 8或更高版本
    pause
    exit /b 1
)

REM 检查Maven环境
mvn -version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Maven环境，请先安装Maven
    pause
    exit /b 1
)

echo ✅ Java版本: 
java -version 2>&1 | findstr "version"
echo ✅ Maven版本: 
mvn -version | findstr "Apache Maven"

REM 清理之前的构建
echo 🧹 清理之前的构建文件...
call mvn clean

REM 构建项目（包含前端构建）
echo 🔨 开始构建项目...
echo 📦 这将自动执行以下步骤：
echo    1. 安装Node.js和npm
echo    2. 安装前端依赖
echo    3. 构建前端项目
echo    4. 复制前端文件到后端资源目录
echo    5. 打包Spring Boot应用
echo.

REM 执行Maven构建
call mvn clean package -Dmaven.npm.skip=false

REM 检查构建结果
if exist "target\team-nav.jar" (
    echo.
    echo ==========================================
    echo ✅ 构建成功！
    echo ==========================================
    echo 📦 生成的文件: target\team-nav.jar
    
    REM 获取文件大小
    for %%A in (target\team-nav.jar) do echo 📏 文件大小: %%~zA bytes
    
    echo.
    echo 🚀 启动命令:
    echo    java -jar target\team-nav.jar
    echo.
    echo 🔧 自定义配置启动:
    echo    java -jar target\team-nav.jar --spring.profiles.active=mysql
    echo.
    echo 📋 其他启动选项:
    echo    - 指定端口: java -jar target\team-nav.jar --server.port=8082
    echo    - 指定配置文件: java -jar target\team-nav.jar --spring.config.location=classpath:application-mysql.yml
    echo.
    echo 📚 更多信息请查看 README.md
) else (
    echo.
    echo ❌ 构建失败！请检查错误信息
    pause
    exit /b 1
)

pause 