#!/usr/bin/env bash
# deploy.sh - Скрипт для запуска Ansible playbook SafeLine WAF
# ===============================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

PLAYBOOK="site.yml"
INVENTORY="inventory.ini"

printf "\n==== SafeLine WAF Ansible Deployment ===="
printf "\nПроект: %s" "$PROJECT_DIR"
printf "\nPlaybook: %s" "$PLAYBOOK"
printf "\nInventory: %s" "$INVENTORY"
printf "\n==========================================\n"

# Проверка наличия ansible
if ! command -v ansible >/dev/null 2>&1; then
  echo "[Ошибка] Ansible не установлен! Установите Ansible и повторите запуск." >&2
  exit 1
fi

# Проверка синтаксиса playbook
ansible-playbook "$PLAYBOOK" -i "$INVENTORY" --syntax-check

# Запуск playbook с возможностью ограничения по тегам
if [[ $# -gt 0 ]]; then
  echo "Запуск playbook с тегами: $*"
  ansible-playbook "$PLAYBOOK" -i "$INVENTORY" --tags "$*" -e "ansible_python_interpreter=/usr/bin/python3"
else
  echo "Запуск полного playbook..."
  ansible-playbook "$PLAYBOOK" -i "$INVENTORY" -e "ansible_python_interpreter=/usr/bin/python3"
fi

echo "\n==== Развертывание завершено ===="