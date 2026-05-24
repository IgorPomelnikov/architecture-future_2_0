# Task2Advanced — Terraform + remote state (S3) + CI/CD
## Структура проекта

```
Task2Advanced/
├── docker-compose.minio.yml   # MinIO для локальной разработки
├── scripts/
│   ├── setup-minio.sh         # создание bucket
│   └── terraform-init.sh      # init с backend.hcl
├── modules/vm/                # Docker: nginx + volume + network
└── envs/
    ├── dev/
    ├── stage/
    └── prod/
```

У каждого контура:

- свой ключ state в bucket: `task2advanced/<контур>/terraform.tfstate`;
- свой `terraform.tfvars` (порт, CPU, RAM);
- свой `backend.hcl` (не в git, только `backend.hcl.example`).

## Требования

| Компонент | Версия |
|-----------|--------|
| Terraform | >= 1.5 |
| Docker Desktop | для apply nginx |
| MinIO (локально) или Yandex Object Storage / AWS S3 | для state |

---

## 1. Remote backend (S3)

В `envs/<контур>/main.tf` задан пустой backend — параметры передаются при `init`:

```hcl
backend "s3" {}
```

Секреты и endpoint **не хранятся в репозитории**, только в `backend.hcl` (локально) или в CI secrets.

### Ключи state (изоляция контуров)

| Контур | Ключ в bucket |
|--------|----------------|
| dev | `task2advanced/dev/terraform.tfstate` |
| stage | `task2advanced/stage/terraform.tfstate` |
| prod | `task2advanced/prod/terraform.tfstate` |

---

## 2. Локальный запуск (MinIO)

### 2.1. Запуск MinIO

```bash
cd Task2Advanced
docker compose -f docker-compose.minio.yml up -d
```

- API: `http://127.0.0.1:9000`
- Консоль: `http://127.0.0.1:9001` (логин/пароль: `minioadmin` / `minioadmin`)

### 2.2. Создание bucket

```bash
chmod +x scripts/*.sh
./scripts/setup-minio.sh
```

Переменные (опционально):

| Переменная | По умолчанию |
|------------|--------------|
| `TF_STATE_ENDPOINT` | `http://127.0.0.1:9000` |
| `TF_STATE_BUCKET` | `terraform-state` |
| `AWS_ACCESS_KEY_ID` | `minioadmin` |
| `AWS_SECRET_ACCESS_KEY` | `minioadmin` |

### 2.3. Backend config

```bash
cd envs/dev
cp backend.hcl.example backend.hcl
# при необходимости отредактируйте backend.hcl
```

### 2.4. Init / plan / apply

```bash
# из корня Task2Advanced
./scripts/terraform-init.sh dev
cd envs/dev
terraform plan
terraform apply
```

Для stage/prod:

```bash
./scripts/terraform-init.sh stage
./scripts/terraform-init.sh prod
```

Проверка, что state в MinIO (через `mc`):

```bash
mc alias set local http://127.0.0.1:9000 minioadmin minioadmin
mc ls local/terraform-state/task2advanced/dev/
```

**В git не коммитить:** `backend.hcl`, `*.tfstate`, `backend.ci.hcl`.

---

## 3. Yandex Object Storage / AWS S3

Пример для Yandex: `envs/backend.yandex.hcl.example`.

1. Создайте bucket в Object Storage.
2. Выпустите статические ключи сервисного аккаунта.
3. Скопируйте пример в `envs/dev/backend.hcl`, укажите `bucket`, `key`, `endpoint`.
4. Ключи задайте через окружение:

```bash
export AWS_ACCESS_KEY_ID="YCA..."
export AWS_SECRET_ACCESS_KEY="YCP..."
terraform init -backend-config=backend.hcl
```

Для AWS S3 уберите `endpoint` и MinIO-флаги `skip_*`, укажите реальный `region`; при необходимости добавьте `dynamodb_table` для блокировок.

---

## 4. CI/CD (GitHub Actions)

### Workflows

| Файл | Триггер | Действия |
|------|---------|----------|
| `.github/workflows/task2-terraform.yml` | PR, push в main | `fmt` → `init` → `validate` → `plan` (dev, stage, prod) |
| `.github/workflows/task2-terraform-apply.yml` | `workflow_dispatch` (вручную) | `init` → `plan` → `apply` |

На PR **apply не выполняется** — только план.

### MinIO в CI

В pipeline поднимается сервис **MinIO** (bitnami), bucket `terraform-state` создаётся автоматически. Это позволяет проверять backend без внешнего облака.

Для боевого S3/Yandex задайте secrets в репозитории (Settings → Secrets and variables → Actions):

| Secret | Описание |
|--------|----------|
| `AWS_ACCESS_KEY_ID` | Access key |
| `AWS_SECRET_ACCESS_KEY` | Secret key |
| `TF_STATE_BUCKET` | Имя bucket |
| `TF_STATE_ENDPOINT` | Напр. `https://storage.yandexcloud.net` |
| `TF_STATE_REGION` | Напр. `ru-central1` или `us-east-1` |

Если secrets не заданы, CI использует MinIO на `127.0.0.1:9000` с `minioadmin`.

### Ручной apply (approval)

1. GitHub → **Actions** → **Task2 Terraform (apply)** → **Run workflow**.
2. Выберите контур: `dev`, `stage` или `prod`.
3. Для **prod** настройте Environment `prod` с required reviewers (Settings → Environments).

### Параметры контуров

| Контур | Порт | CPU | RAM (МБ) |
|--------|------|-----|----------|
| dev | 8080 | 1 | 512 |
| stage | 8081 | 2 | 1024 |
| prod | 8082 | 4 | 2048 |

---

## 5. Скрипты (подробно)

### `scripts/setup-minio.sh`

- Назначение: создать bucket для Terraform state в MinIO.
- Зависимости: запущенный MinIO, утилита `mc`.
- Переменные: `TF_STATE_ENDPOINT`, `TF_STATE_BUCKET`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`.

### `scripts/terraform-init.sh <dev|stage|prod>`

- Назначение: `terraform init -backend-config=backend.hcl` для выбранного контура.
- Требует файл `envs/<контур>/backend.hcl` (скопировать из `backend.hcl.example`).

---

## 6. Безопасность и изоляция (для ревью)

| Практика | Реализация |
|----------|------------|
| State не локально | `backend "s3"`, `.gitignore` для `*.tfstate` |
| Изоляция контуров | Разные `key` в S3, префиксы имён Docker (`dev-nginx`, …) |
| Секреты не в git | `backend.hcl` в ignore, ключи в CI secrets |
| Apply под контролем | Только `workflow_dispatch`; prod — GitHub Environment |
| Plan на PR | Без изменений инфраструктуры |

---

## 7. Pull Request

1. Ветка с папкой `Task2Advanced/`.
2. Убедитесь, что в коммите **нет** `terraform.tfstate`, `backend.hcl`, ключей.
3. Откройте PR — сработает `task2-terraform.yml`.
4. В описании PR укажите, как запустить apply вручную.

---

## 8. Уничтожение ресурсов

```bash
cd envs/dev
terraform destroy
```

MinIO остановить:

```bash
docker compose -f docker-compose.minio.yml down
```
