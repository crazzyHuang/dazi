#!/bin/bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃                      🎯 同频搭子项目部署和运维工具                  ┃
# ┃                                                                   ┃
# ┃  一键部署 | 服务管理 | 环境配置 | 日志监控 | 资源清理               ┃
# ┃                                                                   ┃
# ┃  作者: AI Assistant  |  版本: 2.0.0  |  更新: 2024-01-XX           ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# 图标定义
ICON_ROCKET="🚀"
ICON_GEAR="⚙️"
ICON_CHECK="✅"
ICON_ERROR="❌"
ICON_INFO="ℹ️"
ICON_WARN="⚠️"
ICON_STAR="⭐"
ICON_HEART="💖"
ICON_SPARK="✨"

# 工具函数
print_header() {
    echo -e "\n${BLUE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BLUE}┃${NC} ${ICON_STAR} $1${NC}"
    echo -e "${BLUE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}\n"
}

print_section() {
    echo -e "\n${CYAN}┌─ $1${NC}"
    echo -e "${CYAN}└──────────────────────────────────────────────────────────────────┘${NC}"
}

print_success() {
    echo -e "${GREEN}${ICON_CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}${ICON_ERROR} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${ICON_INFO} $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}${ICON_WARN} $1${NC}"
}

# 显示主菜单
show_main_menu() {
    clear
    echo -e "${MAGENTA}"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃                      🎯 同频搭子项目部署和运维工具                  ┃"
    echo "┃                                                                   ┃"
    echo "┃  一键部署 | 服务管理 | 环境配置 | 日志监控 | 资源清理               ┃"
    echo "┃                                                                   ┃"
    echo "┃  作者: AI Assistant  |  版本: 2.0.0  |  更新: 2024-01-XX           ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "${NC}"

    echo -e "${WHITE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${ICON_SPARK} 请选择操作类型:${NC}                                            ${WHITE}║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_ROCKET} [1] 部署管理                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 全新部署、环境配置、系统初始化                     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_GEAR} [2] 服务管理                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 启动、停止、重启、状态查看、日志监控               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_HEART} [3] 快速更新                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 只更新代码和重启服务                                 ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_INFO} [4] 系统信息                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 服务状态、系统资源、环境信息                       ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_ERROR} [5] 退出系统                                              ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# 显示部署菜单
show_deploy_menu() {
    clear
    echo -e "${GREEN}"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃                          🚀 部署管理菜单                          ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "${NC}"

    echo -e "${WHITE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${ICON_ROCKET} 选择部署环境:${NC}                                           ${WHITE}║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_SPARK} [1] 开发环境 (Development)                            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 端口: 3001 | 数据库: tongpin_db_dev                ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_GEAR} [2] 测试环境 (Staging)                               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 端口: 3002 | 数据库: tongpin_db_staging             ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_HEART} [3] 生产环境 (Production)                           ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 端口: 3000 | 数据库: tongpin_db_prod               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_INFO} [4] 返回主菜单                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# 显示服务管理菜单
show_service_menu() {
    clear
    echo -e "${YELLOW}"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃                          ⚙️ 服务管理菜单                          ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "${NC}"

    echo -e "${WHITE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${WHITE}║${NC} ${ICON_GEAR} 选择服务操作:${NC}                                          ${WHITE}║${NC}"
    echo -e "${WHITE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_ROCKET} [1] 启动所有服务                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 启动数据库 + 用户服务                               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_ERROR} [2] 停止所有服务                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 停止所有容器服务                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_SPARK} [3] 重启所有服务                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 重启数据库 + 重建用户服务                            ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_INFO} [4] 查看服务状态                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 显示所有服务运行状态                               ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_HEART} [5] 查看实时日志                                        ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 实时监控服务日志                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_WARN} [6] 清理Docker资源                                     ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}      └─ 清理未使用的镜像、容器、卷                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}  ${ICON_INFO} [7] 返回主菜单                                          ${WHITE}║${NC}"
    echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
    echo -e "${WHITE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

print_header "🎯 同频搭子项目部署和运维工具"

# 检查是否为root用户
if [[ $EUID -ne 0 ]]; then
   print_error "此脚本需要root权限运行"
   print_info "请使用: sudo ./deploy.sh"
   exit 1
fi

# 解析命令行参数
if [[ $# -eq 0 ]]; then
    # 交互式菜单系统
    while true; do
        show_main_menu
        read -p "请选择操作 (1-5): " MAIN_CHOICE

        case $MAIN_CHOICE in
            1)
                while true; do
                    show_deploy_menu
                    read -p "请选择部署环境 (1-4): " DEPLOY_CHOICE
                    case $DEPLOY_CHOICE in
                        1) MODE_CHOICE=1; break 2 ;;
                        2) MODE_CHOICE=2; break 2 ;;
                        3) MODE_CHOICE=3; break 2 ;;
                        4) break ;;
                        *) print_error "无效选择，请重新输入" && sleep 2 ;;
                    esac
                done
                ;;
            2)
                while true; do
                    show_service_menu
                    read -p "请选择服务操作 (1-7): " SERVICE_CHOICE
                    case $SERVICE_CHOICE in
                        1) MODE_CHOICE=5; break 2 ;;
                        2) MODE_CHOICE=6; break 2 ;;
                        3) MODE_CHOICE=7; break 2 ;;
                        4) MODE_CHOICE=8; break 2 ;;
                        5) MODE_CHOICE=9; break 2 ;;
                        6) MODE_CHOICE=10; break 2 ;;
                        7) break ;;
                        *) print_error "无效选择，请重新输入" && sleep 2 ;;
                    esac
                done
                ;;
            3)
                MODE_CHOICE=4
                break
                ;;
            4)
                print_header "📊 系统信息"
                echo -e "${CYAN}服务状态:${NC}"
                docker-compose ps 2>/dev/null || print_warn "Docker Compose 未运行"
                echo
                echo -e "${CYAN}系统资源:${NC}"
                echo "CPU: $(uptime | awk '{print $NF}')"
                echo "内存: $(free -h | awk 'NR==2{printf "%.1fG/%.1fG (%.0f%%)", $3/1024, $2/1024, $3*100/$2}')"
                echo "磁盘: $(df -h / | awk 'NR==2{print $3"/"$2" ("$5")"}')"
                echo
                read -p "按回车键继续..."
                ;;
            5)
                print_success "感谢使用，再见！👋"
                exit 0
                ;;
            *)
                print_error "无效选择，请重新输入"
                sleep 2
                ;;
        esac
    done
else
    case $1 in
        --deploy)
            case $2 in
                dev|development)
                    MODE_CHOICE=1
                    ;;
                staging|staging)
                    MODE_CHOICE=2
                    ;;
                prod|production)
                    MODE_CHOICE=3
                    ;;
                *)
                    echo "❌ 无效的环境参数: $2"
                    echo "💡 可用环境: dev, staging, prod"
                    exit 1
                    ;;
            esac
            ;;
        --update)
            MODE_CHOICE=4
            ;;
        --start)
            MODE_CHOICE=5
            ;;
        --stop)
            MODE_CHOICE=6
            ;;
        --restart)
            MODE_CHOICE=7
            ;;
        --status)
            MODE_CHOICE=8
            ;;
        --logs)
            MODE_CHOICE=9
            ;;
        --clean)
            MODE_CHOICE=10
            ;;
        --help|-h)
            echo -e "${MAGENTA}"
            echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
            echo "┃                      🎯 同频搭子项目部署和运维工具                  ┃"
            echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
            echo -e "${NC}"

            echo -e "${WHITE}╔═══════════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${WHITE}║${NC} ${ICON_ROCKET} 部署命令:${NC}                                                ${WHITE}║${NC}"
            echo -e "${WHITE}╠═══════════════════════════════════════════════════════════════════╣${NC}"
            echo -e "${WHITE}║${NC}  $0                    ${ICON_SPARK} 交互式部署菜单                       ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --deploy dev       ${ICON_GEAR} 部署开发环境                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --deploy staging   ${ICON_GEAR} 部署测试环境                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --deploy prod      ${ICON_GEAR} 部署生产环境                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --update           ${ICON_HEART} 只更新代码和重启服务                  ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC} ${ICON_GEAR} 运维命令:${NC}                                                ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --start            ${ICON_ROCKET} 启动所有服务                        ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --stop             ${ICON_ERROR} 停止所有服务                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --restart          ${ICON_SPARK} 重启所有服务                        ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --status           ${ICON_INFO} 查看服务状态                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --logs             ${ICON_HEART} 查看实时日志                         ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --clean            ${ICON_WARN} 清理Docker资源                       ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC} ${ICON_INFO} 其他命令:${NC}                                                ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}  $0 --help             ${ICON_INFO} 显示此帮助信息                       ${WHITE}║${NC}"
            echo -e "${WHITE}║${NC}                                                                   ${WHITE}║${NC}"
            echo -e "${WHITE}╚═══════════════════════════════════════════════════════════════════╝${NC}"
            echo
            echo -e "${CYAN}📚 使用示例:${NC}"
            echo -e "  ${GREEN}sudo ./deploy.sh${NC}              # 进入交互式菜单"
            echo -e "  ${GREEN}sudo ./deploy.sh --deploy dev${NC}   # 部署开发环境"
            echo -e "  ${GREEN}sudo ./deploy.sh --start${NC}        # 启动所有服务"
            echo -e "  ${GREEN}sudo ./deploy.sh --logs${NC}         # 查看实时日志"
            echo
            echo -e "${YELLOW}💡 提示:${NC}"
            echo -e "  • 首次运行需要完整的部署流程"
            echo -e "  • 开发时建议使用 --update 快速更新"
            echo -e "  • 生产环境会自动配置系统服务"
            echo
            exit 0
            ;;
        *)
            echo "❌ 未知参数: $1"
            echo "💡 使用 $0 --help 查看帮助"
            exit 1
            ;;
    esac
fi

case $MODE_CHOICE in
     1)
         ENVIRONMENT="development"
         PROJECT_NAME="dazi-dev"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     2)
         ENVIRONMENT="staging"
         PROJECT_NAME="dazi-staging"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     3)
         ENVIRONMENT="production"
         PROJECT_NAME="dazi-prod"
         PROJECT_DIR="/home/app/dazi/${PROJECT_NAME}"
         ;;
     4)
         ENVIRONMENT="update"
         # 查找现有的项目目录
         if [[ -d "/home/app/dazi/dazi-dev" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-dev"
         elif [[ -d "/home/app/dazi/dazi-staging" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-staging"
         elif [[ -d "/home/app/dazi/dazi-prod" ]]; then
             PROJECT_DIR="/home/app/dazi/dazi-prod"
         else
             echo "❌ 未找到现有项目目录"
             exit 1
         fi
         ;;
     5)
         OPERATION="start"
         # 查找现有的项目目录
         find_project_dir
         ;;
     6)
         OPERATION="stop"
         find_project_dir
         ;;
     7)
         OPERATION="restart"
         find_project_dir
         ;;
     8)
         OPERATION="status"
         find_project_dir
         ;;
     9)
         OPERATION="logs"
         find_project_dir
         ;;
     10)
         OPERATION="clean"
         ;;
     *)
         echo "❌ 无效选择"
         exit 1
         ;;
esac

# 查找项目目录的函数
find_project_dir() {
    if [[ -d "/home/app/dazi/dazi-dev" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-dev"
    elif [[ -d "/home/app/dazi/dazi-staging" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-staging"
    elif [[ -d "/home/app/dazi/dazi-prod" ]]; then
        PROJECT_DIR="/home/app/dazi/dazi-prod"
    else
        echo "❌ 未找到现有项目目录"
        exit 1
    fi
}

# 检查Docker和Docker Compose
check_docker_compose() {
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker未运行，请先启动Docker"
        exit 1
    fi

    if ! command -v docker-compose > /dev/null 2>&1; then
        echo "❌ docker-compose未安装"
        exit 1
    fi
}

# 服务管理函数
manage_services() {
    cd ${PROJECT_DIR}

    case $OPERATION in
        "start")
            echo "🚀 启动所有服务..."
            docker-compose up -d postgres redis mongodb elasticsearch
            echo "⏳ 等待数据库服务启动..."
            sleep 10
            check_database_connectivity
            docker-compose up -d --build user-service
            echo "⏳ 等待用户服务启动..."
            sleep 5
            check_service_health
            echo "✅ 所有服务启动成功！"
            ;;
        "stop")
            echo "🛑 停止所有服务..."
            docker-compose down
            echo "✅ 所有服务已停止"
            ;;
        "restart")
            echo "🔄 重启所有服务..."
            docker-compose restart postgres redis mongodb elasticsearch
            echo "🔧 重建并重启用户服务..."
            docker-compose up -d --build user-service
            echo "✅ 所有服务已重启"
            ;;
        "status")
            echo "📊 服务状态："
            docker-compose ps
            ;;
        "logs")
            echo "📋 实时日志（按 Ctrl+C 退出）："
            docker-compose logs -f
            ;;
        "clean")
            echo "🧹 清理Docker资源..."
            docker system prune -f
            docker volume prune -f
            docker image prune -f
            echo "✅ Docker资源清理完成"
            ;;
    esac
}

# 检查数据库连接
check_database_connectivity() {
    echo "🔍 检查数据库连接..."

    # 检查PostgreSQL
    if docker-compose exec postgres pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
        echo "✅ PostgreSQL 已就绪"
    else
        echo "❌ PostgreSQL 连接失败"
    fi

    # 检查Redis
    if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
        echo "✅ Redis 已就绪"
    else
        echo "❌ Redis 连接失败"
    fi
}

# 检查服务健康状态
check_service_health() {
    if curl -f http://localhost:3001/health > /dev/null 2>&1; then
        echo "✅ 用户服务已就绪"
    else
        echo "❌ 用户服务启动失败"
    fi
}

# 如果是运维操作模式
if [[ -n "$OPERATION" ]]; then
    echo "🔧 执行运维操作: ${OPERATION}"
    echo "📁 项目目录: ${PROJECT_DIR}"
    check_docker_compose
    manage_services
    exit 0
fi

print_header "🚀 开始部署到 ${ENVIRONMENT} 环境"
print_info "项目目录: ${PROJECT_DIR}"

# 如果是跳过安装模式，直接进入更新流程
if [[ "${ENVIRONMENT}" == "update" ]]; then
    print_header "🔄 更新模式：只更新代码和重启服务"
    print_info "项目目录: ${PROJECT_DIR}"

    cd ${PROJECT_DIR}

    # 更新代码
    print_section "📥 更新项目代码"
    git pull origin main
    git checkout main
    print_success "代码更新完成"

    # 进入后端目录
    cd backend

    # 重新安装依赖
    print_section "📦 更新项目依赖"
    if [[ -f "pnpm-lock.yaml" ]]; then
        pnpm install --frozen-lockfile
    else
        pnpm install
    fi
    print_success "依赖更新完成"

    # 返回项目根目录
    cd ..

    # 重启所有服务
    print_section "🔄 重启所有服务"
    docker-compose down
    docker-compose up -d postgres redis mongodb elasticsearch
    sleep 10
    docker-compose up -d --build user-service

    print_success "✅ 更新完成！"
    echo
    echo -e "${CYAN}🔍 服务状态：${NC}"
    echo -e "   ${GREEN}docker-compose ps${NC}"
    echo
    echo -e "${CYAN}📝 查看日志：${NC}"
    echo -e "   ${GREEN}docker-compose logs -f${NC}"

    exit 0
fi

# 完整部署流程
print_header "📦 开始完整部署流程"

# 更新系统包
print_section "📦 更新系统包"
apt update && apt upgrade -y
print_success "系统包更新完成"

# 安装基础依赖
print_section "🔧 安装系统依赖"
apt install -y curl wget git htop vim nano
print_success "系统依赖安装完成"

# 安装 Node.js 18+
echo "🐢 安装 Node.js 18+..."
if ! command -v node &> /dev/null || [[ "$(node -v | cut -d'.' -f1)" -lt 18 ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
fi

# 安装 pnpm
echo "📦 安装 pnpm..."
if ! command -v pnpm &> /dev/null; then
    npm install -g pnpm
fi

# 安装 Docker 和 Docker Compose
echo "🐳 安装 Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh

    # 添加当前用户到docker组
    usermod -aG docker $SUDO_USER || true
fi

# 安装 Docker Compose
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# 创建项目目录
echo "📁 创建项目目录..."
mkdir -p ${PROJECT_DIR}
cd ${PROJECT_DIR}

# 克隆或更新代码
echo "📥 克隆项目代码..."
if [[ -d ".git" ]]; then
    echo "🔄 更新现有代码..."
    git pull origin main
    git checkout main
else
    echo "📥 克隆项目代码..."
    echo "请输入Git仓库地址 (留空使用示例地址):"
    read -p "Git URL: " GIT_URL

    if [[ -z "$GIT_URL" ]]; then
        GIT_URL="https://github.com/crazzyHuang/dazi.git"
    fi

    git clone $GIT_URL .
    git checkout main
fi

# 进入后端目录
cd backend

# 安装项目依赖
echo "📦 安装项目依赖..."
if [[ -f "pnpm-lock.yaml" ]]; then
    echo "🔒 检测到lockfile，使用锁定版本安装"
    pnpm install --frozen-lockfile
else
    echo "📦 未检测到lockfile，执行全新安装"
    pnpm install
    echo "🔒 生成lockfile文件"
fi

# 配置环境变量
echo "⚙️ 配置环境变量..."
if [[ ! -f "user-service/.env" ]]; then
    cp user-service/.env.example user-service/.env
    echo "✅ 已创建环境配置文件"
else
    echo "ℹ️  环境配置文件已存在"
fi

# 设置环境特定配置
case ${ENVIRONMENT} in
    "development")
        USER_SERVICE_PORT=3001
        DB_NAME="tongpin_db_dev"
        NODE_ENV="development"
        ;;
    "staging")
        USER_SERVICE_PORT=3002
        DB_NAME="tongpin_db_staging"
        NODE_ENV="staging"
        ;;
    "production")
        USER_SERVICE_PORT=3000
        DB_NAME="tongpin_db_prod"
        NODE_ENV="production"
        ;;
esac

# 更新环境配置
echo "🔧 更新环境配置..."
sed -i "s/NODE_ENV=.*/NODE_ENV=${NODE_ENV}/" user-service/.env
sed -i "s/PORT=.*/PORT=${USER_SERVICE_PORT}/" user-service/.env
sed -i "s/DB_NAME=.*/DB_NAME=${DB_NAME}/" user-service/.env

# 创建日志目录
mkdir -p user-service/logs

# 进入项目根目录
cd ${PROJECT_DIR}

# 启动数据库服务
echo "🗄️  启动数据库服务..."
docker-compose up -d postgres redis mongodb elasticsearch

# 等待数据库启动
echo "⏳ 等待数据库服务启动..."
sleep 15

# 检查数据库状态
echo "🔍 检查数据库状态..."
if docker-compose exec postgres pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "✅ PostgreSQL 已就绪"
else
    echo "❌ PostgreSQL 连接失败"
fi

if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis 已就绪"
else
    echo "❌ Redis 连接失败"
fi

# 启动用户服务
echo "🚀 启动用户服务..."
docker-compose up -d --build user-service

# 等待服务启动
echo "⏳ 等待用户服务启动..."
sleep 10

# 检查服务健康状态
echo "🔍 检查服务健康状态..."
if curl -f http://localhost:${USER_SERVICE_PORT}/health > /dev/null 2>&1; then
    echo "✅ 用户服务已就绪"
else
    echo "❌ 用户服务启动失败"
fi

# 创建 systemd 服务（生产环境）
if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "🔧 创建系统服务..."

    cat > /etc/systemd/system/${PROJECT_NAME}.service << EOF
[Unit]
Description=同频搭子后端服务 (${ENVIRONMENT})
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=${PROJECT_DIR}
ExecStart=${PROJECT_DIR}/deploy.sh --start
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=${PROJECT_NAME}

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ${PROJECT_NAME}.service
    echo "✅ 系统服务已创建"
fi

echo ""
echo "🎉 部署完成！"
echo "================================="
echo ""
echo "📊 部署信息："
echo "   环境: ${ENVIRONMENT}"
echo "   端口: ${USER_SERVICE_PORT}"
echo "   目录: ${PROJECT_DIR}"
echo ""
echo "🔗 服务地址："
echo "   用户服务: http://localhost:${USER_SERVICE_PORT}"
echo "   健康检查: http://localhost:${USER_SERVICE_PORT}/health"
echo "   API文档:  http://localhost:${USER_SERVICE_PORT}/api/v1"
echo ""
echo "🛠️  管理命令："
echo "   查看状态: docker-compose ps"
echo "   查看日志: docker-compose logs -f"
echo "   查看用户服务日志: docker-compose logs -f user-service"
echo "   重启服务: docker-compose restart user-service"
echo "   重建并重启: docker-compose up -d --build user-service"
echo "   停止服务: docker-compose down"
echo ""

if [[ "${ENVIRONMENT}" == "production" ]]; then
    echo "🔧 生产环境管理："
    echo "   启动服务: systemctl start ${PROJECT_NAME}"
    echo "   停止服务: systemctl stop ${PROJECT_NAME}"
    echo "   查看状态: systemctl status ${PROJECT_NAME}"
    echo "   查看日志: journalctl -u ${PROJECT_NAME} -f"
    echo ""
fi

echo "📝 常用操作："
echo "   重新部署:           sudo ./deploy.sh --deploy dev"
echo "   只更新代码:         sudo ./deploy.sh --update"
echo "   启动服务:           sudo ./deploy.sh --start"
echo "   停止服务:           sudo ./deploy.sh --stop"
echo "   查看状态:           sudo ./deploy.sh --status"
echo "   查看日志:           sudo ./deploy.sh --logs"
echo "   清理Docker资源:     sudo ./deploy.sh --clean"
echo ""
echo "🎯 现在你可以开始开发和测试了！"