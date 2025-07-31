# SafeLine WAF + VPS - Ansible Playbook

![SafeLine Logo]([https://waf.chaitin.com/assets/images/logo.svg](https://github.com/chaitin/SafeLine/blob/main/images/banner.png))

## Описание

Данный репозиторий содержит **production-ready** Ansible сценарий для автоматического развертывания **SafeLine WAF Community Edition** на VPS (Ubuntu/Debian) с дополнительной защитой:

* автоматическая установка Docker + Docker Compose
* поднятие SafeLine WAF в контейнерах
* опциональный reverse-proxy Nginx с GeoIP-фильтрацией
* настройка UFW + fail2ban
* создание swap, базовая системная подготовка
* теги для выборочного запуска (`common`, `docker`, `firewall`, `safeline`, `nginx`)
* удобный `deploy.sh` для запуска

> Протестировано на Ubuntu 20.04/22.04/24.04 и Debian 10/11/12.

## Структура проекта

```
safeline-ansible/
├── ansible.cfg              # глобальная конфигурация ansible
├── inventory.ini            # пример инвентаря
├── site.yml                 # главный playbook
├── deploy.sh                # скрипт запуска
├── group_vars/
│   └── all.yml              # общие переменные
├── host_vars/               # переменные для конкретных хостов
├── roles/
│   ├── common/              # базовая подготовка системы
│   ├── docker/              # установка Docker/Compose
│   ├── firewall/            # UFW + fail2ban
│   ├── safeline/            # установка SafeLine WAF
│   └── nginx/               # reverse-proxy (опционально)
└── README.md                # вы читаете его
```

## Быстрый старт

1. **Клонируйте репозиторий** и перейдите в каталог:
   ```bash
   git clone https://github.com/yourorg/safeline-ansible.git
   cd safeline-ansible
   ```
2. **Отредактируйте `inventory.ini`** и задайте IP/пользователя.
3. **Настройте переменные** в `group_vars/all.yml` (особенно `admin_allowed_ips`).
4. **Запустите скрипт**:
   ```bash
   ./deploy.sh
   ```

> Для выборочного запуска используйте теги, например:
> `./deploy.sh common,docker,safeline`

## Переменные

Полный список переменных с комментариями находится в `group_vars/all.yml`. Ключевые:

| Переменная | Описание | Значение по умолчанию |
|------------|----------|-----------------------|
| `safeline_directory` | каталог установки SafeLine | `/opt/safeline` |
| `safeline_admin_port` | порт админ-панели | `9443` |
| `admin_allowed_ips` | список IP для доступа к админке | `[]` |
| `install_nginx` | установить ли Nginx reverse-proxy | `false` |
| `ufw_enabled` | включить UFW | `true` |
| `fail2ban_enabled` | включить fail2ban | `true` |

## Теги

* `common` — базовая настройка системы
* `docker` — установка Docker/Compose
* `firewall` — UFW + fail2ban
* `safeline` — SafeLine WAF
* `nginx` — reverse-proxy (если включён)

## Проверка состояния

* Статус контейнеров:
  ```bash
  cd /opt/safeline && docker compose ps
  ```
* Получить пароль администратора:
  ```bash
  safeline-password
  ```
* Управление WAF:
  ```bash
  safeline-ctl {start|stop|restart|status|logs|update|backup}
  ```

## Troubleshooting

* **Нет доступа к панеле?**
  Убедитесь, что ваш IP входит в `admin_allowed_ips` и порт `9443` открыт в UFW.
* **Контейнеры не запускаются?**
  Проверьте `docker compose logs -f` в директории SafeLine.
* **Недостаточно ресурсов** — минимальные требования: 1 CPU, 1 GB RAM + 5 GB диска.

## Лицензия

MIT.
