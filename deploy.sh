#!/usr/bin/env bash
# deploy.sh - Скрипт для запуска Ansible playbook SafeLine WAF (Localhost версия)
# ================================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

PLAYBOOK="site.yml"
INVENTORY="inventory.ini"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printf "\n${BLUE}==== SafeLine WAF Ansible Deployment (Localhost) ====${NC}"
printf "\n${YELLOW}Проект:${NC} %s" "$PROJECT_DIR"
printf "\n${YELLOW}Playbook:${NC} %s" "$PLAYBOOK"
printf "\n${YELLOW}Inventory:${NC} %s" "$INVENTORY"
printf "\n${YELLOW}Режим:${NC} Localhost (без SSH)"
printf "\n${BLUE}========================================================${NC}\n"

# Проверка наличия ansible
if ! command -v ansible >/dev/null 2>&1; then
    echo -e "${RED}[Ошибка]${NC} Ansible не установлен! Установите Ansible и повторите запуск." >&2
    echo "Установка: sudo apt update && sudo apt install -y ansible"
    exit 1
fi

# Проверка прав sudo
if ! sudo -n true 2>/dev/null; then
    echo -e "${YELLOW}[Предупреждение]${NC} Для развертывания потребуются права sudo"
    echo "Убедитесь, что ваш пользователь имеет права sudo"
fi

# Проверка, что мы на localhost
if [[ "$INVENTORY" == *"localhost"* ]] || grep -q "ansible_connection=local" "$INVENTORY" 2>/dev/null; then
    echo -e "${GREEN}[Обнаружен localhost режим]${NC}"
    LOCAL_MODE=true
else
    echo -e "${YELLOW}[Режим обычного inventory]${NC}"
    LOCAL_MODE=false
fi

# Проверка синтаксиса playbook
echo -e "${BLUE}[Проверка синтаксиса...]${NC}"
if ansible-playbook "$PLAYBOOK" -i "$INVENTORY" --syntax-check; then
    echo -e "${GREEN}✓ Синтаксис корректен${NC}"
else
    echo -e "${RED}✗ Ошибка в синтаксисе playbook${NC}"
    exit 1
fi

# Формирование команды запуска
ANSIBLE_CMD="ansible-playbook \"$PLAYBOOK\" -i \"$INVENTORY\""

# Добавляем параметры для localhost
if [[ "$LOCAL_MODE" == "true" ]]; then
    ANSIBLE_CMD+=" -c local"
fi

# Всегда указываем Python интерпретер
ANSIBLE_CMD+=" -e \"ansible_python_interpreter=/usr/bin/python3\""

# Запуск playbook с возможностью ограничения по тегам
if [[ $# -gt 0 ]]; then
    echo -e "${GREEN}Запуск playbook с тегами: $*${NC}"
    ANSIBLE_CMD+=" --tags \"$*\""
else
    echo -e "${GREEN}Запуск полного playbook...${NC}"
fi

# Показываем команду которая будет выполнена
echo -e "${YELLOW}[Команда]${NC} $ANSIBLE_CMD"
echo ""

# Выполняем команду
eval "$ANSIBLE_CMD"

echo ""
echo -e "${GREEN}==== Развертывание завершено ====${NC}"
echo -e "${BLUE}Проверьте статус SafeLine:${NC}"
echo "  cd /opt/safeline && sudo docker compose ps"
echo -e "${BLUE}Получите пароль администратора:${NC}"  
echo "  sudo docker exec safeline-mgt resetadmin"
echo -e "${BLUE}Панель управления:${NC}"
echo "  https://localhost:9443"
echo "  https://127.0.0.1:9443"
