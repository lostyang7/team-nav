@echo off
chcp 65001 >nul

REM 团队导航服务 - 启动脚本

setlocal enabledelayedexpansion

REM 默认配置
set JAR_FILE=target\team-nav.jar
set JAVA_OPTS=-Xms512m -Xmx1024m
set SPRING_PROFILES=
set SERVER_PORT=
set CONFIG_FILE=

REM 显示帮助信息
:show_help
if "%1"=="-h" goto help
if "%1"=="--help" goto help
if "%1"=="" goto parse_args
goto parse_args

:help
echo 团队导航服务 - 启动脚本
echo.
echo 用法: %0 [选项]
echo.
echo 选项:
echo   -h, --help              显示此帮助信息
echo   -j, --jar ^<file^>        指定jar文件路径 (默认: target\team-nav.jar)
echo   -p, --port ^<port^>       指定服务端口 (默认: 8080)
echo   -d, --profile ^<profile^> 指定Spring Profile (h2/mysql/postgresql)
echo   -c, --config ^<file^>     指定配置文件路径
echo   -m, --memory ^<size^>     指定JVM内存大小 (默认: 512m-1024m)
echo.
echo 示例:
echo   %0                                    # 使用默认配置启动
echo   %0 -p 8082                           # 指定端口8082
echo   %0 -d mysql -p 8082                  # 使用MySQL数据库，端口8082
echo   %0 -m 1g-2g                          # 指定内存1g-2g
echo   %0 -c .\config\application.yml       # 使用外部配置文件
echo.
pause
exit /b 0

:parse_args
REM 解析命令行参数
:loop
if "%1"=="" goto check_jar
if "%1"=="-j" (
    set JAR_FILE=%2
    shift
    shift
    goto loop
)
if "%1"=="--jar" (
    set JAR_FILE=%2
    shift
    shift
    goto loop
)
if "%1"=="-p" (
    set SERVER_PORT=--server.port=%2
    shift
    shift
    goto loop
)
if "%1"=="--port" (
    set SERVER_PORT=--server.port=%2
    shift
    shift
    goto loop
)
if "%1"=="-d" (
    set SPRING_PROFILES=--spring.profiles.active=%2
    shift
    shift
    goto loop
)
if "%1"=="--profile" (
    set SPRING_PROFILES=--spring.profiles.active=%2
    shift
    shift
    goto loop
)
if "%1"=="-c" (
    set CONFIG_FILE=--spring.config.location=file:%2
    shift
    shift
    goto loop
)
if "%1"=="--config" (
    set CONFIG_FILE=--spring.config.location=file:%2
    shift
    shift
    goto loop
)
if "%1"=="-m" (
    set JAVA_OPTS=-Xms%2
    shift
    shift
    goto loop
)
if "%1"=="--memory" (
    set JAVA_OPTS=-Xms%2
    shift
    shift
    goto loop
)
echo 未知选项: %1
goto help

:check_jar
REM 检查jar文件是否存在
if not exist "%JAR_FILE%" (
    echo ❌ 错误: 找不到jar文件: %JAR_FILE%
    echo 请先运行构建命令: mvn clean package -Dmaven.npm.skip=false
    pause
    exit /b 1
)

REM 检查Java环境
java -version >nul 2>&1
if errorlevel 1 (
    echo ❌ 错误: 未找到Java环境，请先安装JDK 8或更高版本
    pause
    exit /b 1
)

echo ==========================================
echo 团队导航服务 - 启动中
echo ==========================================
echo 📦 JAR文件: %JAR_FILE%
echo 🔧 JVM参数: %JAVA_OPTS%
if "%SERVER_PORT%"=="" (
    echo 🌐 服务端口: 8080 (默认)
) else (
    echo 🌐 服务端口: %SERVER_PORT%
)
if "%SPRING_PROFILES%"=="" (
    echo 🗄️  数据库配置: h2 (默认)
) else (
    echo 🗄️  数据库配置: %SPRING_PROFILES%
)
if "%CONFIG_FILE%"=="" (
    echo 📄 配置文件: 内置配置
) else (
    echo 📄 配置文件: %CONFIG_FILE%
)
echo.

REM 构建启动命令
set START_CMD=java %JAVA_OPTS% -jar %JAR_FILE%

if not "%SPRING_PROFILES%"=="" (
    set START_CMD=%START_CMD% %SPRING_PROFILES%
)

if not "%SERVER_PORT%"=="" (
    set START_CMD=%START_CMD% %SERVER_PORT%
)

if not "%CONFIG_FILE%"=="" (
    set START_CMD=%START_CMD% %CONFIG_FILE%
)

echo 🚀 启动命令: %START_CMD%
echo.

REM 启动应用
echo ⏳ 正在启动应用...
%START_CMD%

pause 