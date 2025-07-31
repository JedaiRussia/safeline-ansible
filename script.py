# Создадим структуру файлов согласно техническому заданию
import os

# Создаем основную структуру директорий
dirs_to_create = [
    'safeline-ansible',
    'safeline-ansible/group_vars',
    'safeline-ansible/host_vars',
    'safeline-ansible/roles',
    'safeline-ansible/roles/common',
    'safeline-ansible/roles/common/tasks',
    'safeline-ansible/roles/docker',
    'safeline-ansible/roles/docker/tasks',
    'safeline-ansible/roles/firewall',
    'safeline-ansible/roles/firewall/tasks',
    'safeline-ansible/roles/safeline',
    'safeline-ansible/roles/safeline/tasks',
    'safeline-ansible/roles/safeline/handlers',
    'safeline-ansible/roles/nginx',
    'safeline-ansible/roles/nginx/tasks',
    'safeline-ansible/roles/nginx/templates'
]

for dir_path in dirs_to_create:
    os.makedirs(dir_path, exist_ok=True)
    print(f"Создана директория: {dir_path}")

print("\nСтруктура директорий создана успешно!")