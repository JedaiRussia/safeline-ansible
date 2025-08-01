# SafeLine WAF + VPS - Ansible Playbook

<img width="718" height="174" alt="image" src="https://github.com/user-attachments/assets/f036c8c1-1979-450c-bf80-3e3e882c1cd6" />

## 📋 Описание

**Production-ready** Ansible playbook для автоматического развертывания **SafeLine WAF Community Edition** на VPS (Ubuntu/Debian) с комплексной защитой и мониторингом. 

🎯 **Особенность**: Оптимизирован как для удаленного развертывания, так и для **localhost** (установка на той же машине).

### 🚀 Основные возможности

- ✅ **Автоматическая установка Docker + Docker Compose** (версия 2.24.0+)
- ✅ **Развертывание SafeLine WAF** в изолированных контейнерах
- ✅ **Расширенная настройка UFW + fail2ban** с исправлением известных проблем
- ✅ **Опциональный reverse-proxy Nginx** с GeoIP-фильтрацией
- ✅ **Системное укрепление безопасности** (kernel parameters, SSH hardening)
- ✅ **Автоматическое создание swap** и оптимизация производительности
- ✅ **Теги для выборочного запуска** компонентов
- ✅ **Комплексный мониторинг и логирование**
- ✅ **Резервное копирование** и восстановление конфигураций
- 🏠 **Localhost оптимизации** для запуска на той же машине

### 🛡️ Безопасность

- **Fail2ban интеграция** с UFW (исправлена проблема "Invalid position 1")
- **SSH укрепление** с отключением парольной аутентификации
- **Kernel security parameters** для защиты от атак
- **Ограничение доступа** к админ-панели по IP
- **Автоматическая ротация логов** с сжатием

### 📦 Поддерживаемые ОС

- ✅ **Ubuntu**: 20.04 LTS, 22.04 LTS, 24.04 LTS
- ✅ **Debian**: 10 (Buster), 11 (Bullseye), 12 (Bookworm)

## 🏗️ Структура проекта

```
safeline-ansible/
├── ansible.cfg                 # Глобальная конфигурация Ansible
├── inventory.ini               # Инвентарь (оптимизирован для localhost)
├── site.yml                    # Главный playbook с проверками
├── deploy.sh                   # Скрипт автоматического запуска
├── .gitignore                  # Исключения для Git
├── group_vars/
│   └── all.yml                 # Основные переменные (localhost оптимизации)
├── host_vars/                  # Переменные для конкретных хостов
└── roles/
    ├── common/                 # Базовая подготовка системы
    │   ├── tasks/main.yml      # Основные задачи
    │   └── handlers/main.yml   # Обработчики событий
    ├── docker/                 # Установка Docker/Compose
    ├── firewall/               # UFW + fail2ban (исправленная интеграция)
    │   ├── tasks/main.yml
    │   ├── handlers/main.yml
    │   └── templates/
    │       ├── ufw.conf.j2     # Исправленная конфигурация UFW
    │       └── jail.local.j2   # Конфигурация fail2ban
    ├── safeline/               # Установка SafeLine WAF
    └── nginx/                  # Reverse-proxy (опционально)
```

## 🚀 Быстрый старт

### 📥 1. Установка

```bash
# Клонируйте репозиторий
git clone https://github.com/JedaiRussia/safeline-ansible.git
cd safeline-ansible

# Убедитесь, что Ansible установлен
sudo apt update && sudo apt install -y ansible
```

### 🖥️ 2. Настройка для localhost (рекомендуется)

Если вы устанавливаете SafeLine WAF **на ту же машину**, с которой запускаете Ansible:

**inventory.ini уже настроен для localhost:**
```ini
[safeline_servers]
localhost ansible_connection=local ansible_python_interpreter=/usr/bin/python3
```

**Настройте admin_allowed_ips в group_vars/all.yml:**
```yaml
admin_allowed_ips:
  - 127.0.0.1/32       # Localhost доступ
  - ::1/128             # IPv6 localhost
  # - YOUR_EXTERNAL_IP/32  # Раскомментируйте для внешнего доступа
```

### 🌐 3. Настройка для удаленного сервера

Если устанавливаете на **удаленный сервер**:

```ini
# inventory.ini
[safeline_servers]
your-server.example.com ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-key.pem

[safeline_servers:vars]
ansible_python_interpreter=/usr/bin/python3
```

**⚠️ КРИТИЧЕСКИ ВАЖНО**: Отредактируйте `group_vars/all.yml`:
```yaml
admin_allowed_ips:
  - YOUR_REAL_IP/32     # Замените на ваш реальный IP!
  # Узнать свой IP: curl ifconfig.me
```

### 🔧 4. Проверка и развертывание

```bash
# Проверка синтаксиса
ansible-playbook site.yml --syntax-check

# Тестовый запуск (dry-run)
ansible-playbook site.yml --check

# Полное развертывание
./deploy.sh

# Выборочная установка (теги)
./deploy.sh common,docker,safeline
```

## ⚙️ Основные переменные

| Переменная | Описание | По умолчанию |
|------------|----------|--------------|
| `safeline_directory` | Каталог установки SafeLine | `/opt/safeline` |
| `safeline_admin_port` | Порт админ-панели (HTTPS) | `9443` |
| `admin_allowed_ips` | IP для доступа к админке | `[127.0.0.1/32, ::1/128]` ⚠️ |
| `install_nginx` | Установить Nginx reverse-proxy | `false` |
| `ufw_enabled` | Включить UFW firewall | `true` |
| `fail2ban_enabled` | Включить fail2ban | `true` |
| `backup_enabled` | Включить резервное копирование | `true` |
| `swap_file_size` | Размер swap файла | `2G` |
| `timezone` | Временная зона | `Europe/Moscow` |
| `localhost_mode` | Оптимизации для localhost | `true` |


📋 Полный список переменных

### Системные настройки
- `target_user` - Пользователь для SafeLine (автоматически текущий пользователь для localhost)
- `additional_packages` - Дополнительные пакеты
- `max_open_files` - Лимит открытых файлов (65536)
- `kernel_parameters` - Параметры ядра для оптимизации

### Безопасность
- `fail2ban_bantime` - Время блокировки IP (24h)
- `fail2ban_maxretry` - Максимум попыток (3)
- `ssh_hardening` - Настройки укрепления SSH
- `disable_services` - Отключаемые сервисы

### Мониторинг
- `enable_system_monitoring` - Системный мониторинг
- `logrotate_configs` - Ротация логов
- `backup_retention_days` - Хранение бэкапов (30 дней)

### Localhost оптимизации
- `localhost_mode` - Режим localhost
- `single_node_deployment` - Одноузловое развертывание
- `local_backup_path` - Локальный путь для бэкапов



## 🏷️ Теги для выборочного запуска

| Тег | Описание | Включает |
|-----|----------|----------|
| `common` | Базовая настройка системы | Пакеты, swap, пользователи, лимиты |
| `docker` | Установка Docker/Compose | Docker CE, Docker Compose 2.24.0+ |
| `firewall` | Настройка защиты | UFW, fail2ban, правила доступа |
| `safeline` | Установка SafeLine WAF | Контейнеры, конфигурация, скрипты |
| `nginx` | Reverse-proxy | Nginx, GeoIP (если включено) |

```bash
# Примеры использования тегов
./deploy.sh common,docker          # Только система и Docker
./deploy.sh firewall,safeline      # Только защита и WAF
./deploy.sh nginx                  # Только Nginx
```

## 🔍 Проверка состояния

### ✅ Статус SafeLine

```bash
# Проверка контейнеров
cd /opt/safeline && docker compose ps

# Просмотр логов
cd /opt/safeline && docker compose logs -f

# Получение пароля администратора
safeline-password
# или
sudo docker exec safeline-mgt resetadmin
```

### 🛠️ Управление WAF

```bash
# Универсальная команда управления
safeline-ctl {start|stop|restart|status|logs|update|backup}

# Примеры
safeline-ctl status    # Статус сервисов
safeline-ctl logs      # Просмотр логов
safeline-ctl backup    # Создание резервной копии
```

### 🔒 Проверка безопасности

```bash
# Статус fail2ban
sudo fail2ban-client status

# Заблокированные IP
sudo fail2ban-client status sshd

# Правила UFW
sudo ufw status verbose

# Системные логи
sudo journalctl -u fail2ban -f
```

## 🖥️ Localhost режим (рекомендуется)

### ✅ Преимущества localhost режима

- ⚡ **Быстрее** - нет SSH соединений
- 🔒 **Безопаснее** - нет сетевого трафика  
- 🎯 **Проще** - не нужны SSH ключи
- 💾 **Меньше ресурсов** - нет SSH overhead

### 🏠 Доступ к панели (localhost)

После успешной установки:

```bash
# Получить пароль администратора
sudo docker exec safeline-mgt resetadmin

# Доступ к панели управления
https://localhost:9443
https://127.0.0.1:9443
```

### ⚙️ Настройки для localhost

По умолчанию для localhost настроено:
- Доступ к админ-панели только с `127.0.0.1` и `::1`
- Использование текущего пользователя системы
- Локальные пути для бэкапов: `/home/$USER/safeline-backups`
- Оптимизированные UFW правила для loopback
- Автоматический whitelist localhost в fail2ban

### 🌐 Внешний доступ (опционально)

Если нужен доступ извне, раскомментируйте в `group_vars/all.yml`:
```yaml
admin_allowed_ips:
  - 127.0.0.1/32
  - ::1/128
  - YOUR_EXTERNAL_IP/32    # Раскомментируйте и замените
```

## 🔧 Расширенная настройка

### 📧 Уведомления по email

Раскомментируйте в `group_vars/all.yml`:

```yaml
fail2ban_destemail: admin@yourdomain.com
fail2ban_sendername: 'Fail2Ban SafeLine Server'

notifications:
  enabled: true
  email:
    smtp_server: smtp.gmail.com
    smtp_port: 587
    username: notifications@yourdomain.com
    password: "{{ vault_smtp_password }}"
```

### 🌐 Nginx с GeoIP

```yaml
install_nginx: true
nginx_geoip_enabled: true
nginx_blocked_countries:
  - CN  # Китай
  - RU  # Россия (пример)
```

### 🏢 Переменные для конкретного хоста

Создайте `host_vars/your-server.yml`:

```yaml
# Специфичные настройки для production сервера
admin_allowed_ips:
  - 203.0.113.5/32        # Конкретный IP для этого сервера

fail2ban_bantime: '48h'   # Более строгие правила
fail2ban_maxretry: 2

swap_file_size: '4G'      # Больше памяти для продакшена
```

## 🛠️ Troubleshooting

### ❌ Проблемы доступа

**Нет доступа к админ-панели на порту 9443?**

1. Проверьте, что ваш IP входит в `admin_allowed_ips`
2. Убедитесь, что порт открыт в UFW: `sudo ufw status`
3. Проверьте статус контейнеров: `docker compose ps`

```bash
# Для localhost проверьте
curl -k https://localhost:9443
curl -k https://127.0.0.1:9443
```

**Контейнеры не запускаются?**

```bash
cd /opt/safeline
docker compose logs -f
```

### ⚠️ Проблемы с ресурсами

**Недостаточно ресурсов**

Минимальные требования:
- **CPU**: 1 core (рекомендуется 2+)
- **RAM**: 1 GB (рекомендуется 4 GB)
- **Диск**: 5 GB свободного места
- **Архитектура**: x86_64 с поддержкой SSSE3 или ARM64

### 🚫 Проблемы с fail2ban

**Fail2ban не работает с UFW**

Эта проблема исправлена в playbook. Если всё же возникает:

```bash
# Проверка конфигурации
sudo fail2ban-client -vvv start
sudo tail -f /var/log/fail2ban.log
```

### 🐳 Проблемы с Docker

**Docker не устанавливается**

```bash
# Проверка репозиториев
sudo apt update
sudo apt-cache policy docker-ce

# Переустановка
sudo apt remove docker-ce docker-ce-cli containerd.io
./deploy.sh docker
```

### 🆘 Проблемы Ansible

**"listen is not a valid attribute"**

Эта проблема исправлена - handlers перенесены в отдельные файлы.

**Проблемы с localhost подключением**

```bash
# Проверьте настройки inventory
grep -n "ansible_connection" inventory.ini

# Должно быть: ansible_connection=local
```

## 📊 Мониторинг и логи

### 📈 Системные логи

```bash
# Основные логи SafeLine
sudo tail -f /opt/safeline/logs/*.log

# Fail2ban логи
sudo tail -f /var/log/fail2ban.log

# UFW логи
sudo tail -f /var/log/ufw.log

# Docker логи
sudo docker logs safeline-mgt -f
```

### 📊 Производительность

```bash
# Использование ресурсов контейнерами
docker stats

# Системная информация
htop
df -h
free -h
```

## 🔄 Обновление и обслуживание

### 🔄 Обновление SafeLine

```bash
# Автоматическое обновление
safeline-ctl update

# Ручное обновление
cd /opt/safeline
docker compose pull
docker compose up -d
```

### 💾 Резервное копирование

```bash
# Создание бэкапа
safeline-ctl backup

# Восстановление (в разработке)
# safeline-ctl restore /opt/backups/safeline-backup-YYYY-MM-DD.tar.gz
```

## 📈 Рекомендации для продакшена

### 🔐 Безопасность

1. **Используйте SSH ключи**, отключите парольную аутентификацию
2. **Настройте email уведомления** для fail2ban
3. **Регулярно обновляйте** систему и SafeLine
4. **Мониторьте логи** на предмет подозрительной активности
5. **Создавайте резервные копии** конфигураций

### ⚡ Производительность

1. **Увеличьте swap** для серверов с менее чем 4GB RAM
2. **Настройте мониторинг** ресурсов (CPU, RAM, disk)
3. **Оптимизируйте Docker** параметры в production_optimizations
4. **Используйте SSD** диски для лучшей производительности

### 🔧 Надежность

1. **Тестируйте изменения** на staging окружении
2. **Используйте теги** для постепенного обновления
3. **Документируйте изменения** в host_vars
4. **Настройте централизованное логирование**

## 🤝 Участие в разработке

### 🐛 Сообщения об ошибках

Создайте issue с подробным описанием:
- Версия ОС и окружения
- Режим развертывания (localhost/remote)
- Вывод команды с ошибкой
- Конфигурационные файлы (без чувствительных данных)

### 💡 Предложения по улучшению

Мы приветствуем:
- Новые роли и функции
- Исправления безопасности
- Оптимизации производительности
- Улучшения документации
- Localhost оптимизации

## 📝 Лицензия

MIT License - см. файл [LICENSE](LICENSE)

## ⭐ Благодарности

- [SafeLine WAF](https://waf.chaitin.com/) за отличный open-source WAF
- Сообществу Ansible за инструменты автоматизации
- Всем участникам, которые помогают улучшать проект

**🛡️ Защитите свои веб-приложения с SafeLine WAF + Ansible! 🛡️**

### 🚀 Быстрый localhost старт:
```bash
git clone https://github.com/JedaiRussia/safeline-ansible.git
cd safeline-ansible
./deploy.sh
# Доступ: https://localhost:9443
```