# Task1Advanced — Terraform (Docker)

Конфигурация для нескольких контуров (dev / stage / prod) с общим модулем и пайплайнами CI/CD.

## Структура

```
Task1Advanced/
├── modules/
│   └── vm/                 # nginx + volume + network (Docker)
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── envs/
    ├── dev/
    ├── stage/
    └── prod/
```

У каждого контура свой `terraform.tfstate` (по умолчанию — локальный backend).

## Требования

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5
- Запущенный Docker Desktop

## Локальный запуск

```bash
# Dev
cd Task1Advanced/envs/dev
terraform init
terraform plan
terraform apply

# Stage / Prod — отдельные папки, отдельный state
cd ../stage && terraform init && terraform apply
cd ../prod  && terraform init && terraform apply
```

| Контур | Порт | CPU | Память (МБ) |
|--------|------|-----|-------------|
| dev    | 8080 | 1   | 512         |
| stage  | 8081 | 2   | 1024        |
| prod   | 8082 | 4   | 2048        |

После `apply` откройте URL из outputs (например, `http://localhost:8080` для dev).

Имена ресурсов в Docker получают префикс контура: `dev-nginx`, `stage-network`, `prod-shared_volume` и т.д. — контуры на одном хосте не конфликтуют.

## CI/CD (GitHub Actions)

- **Pull request** — `terraform fmt`, `validate`, `plan` для dev, stage и prod (без изменений в инфраструктуре).
- **Ручной деплой** — workflow *Terraform Apply* (`workflow_dispatch`), выбор контура.

Для prod рекомендуется настроить [GitHub Environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-jobs) с именем `prod` и обязательным approval перед apply.

### Workflows

| Файл | Назначение |
|------|------------|
| `.github/workflows/terraform.yml` | Проверки на PR и push |
| `.github/workflows/terraform-apply.yml` | Ручной apply выбранного контура |

## Удалённый state (опционально)

Пример для S3/Azure/GCS — `envs/_backend.remote.example.hcl`. При переходе на remote backend замените блок `backend "local"` в `envs/<контур>/main.tf`.

## Полезные команды

```bash
terraform destroy          # удалить ресурсы контура
terraform output           # посмотреть outputs (nginx_url, container_name)
terraform fmt -recursive   # форматирование .tf файлов
```
