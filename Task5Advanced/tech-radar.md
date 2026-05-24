# Tech Radar — Future 2.0

Технологический радар на горизонт **3 лет** для трансформации «Будущего 2.0»: событийная платформа, Data Mesh, витрина самообслуживания, вывод DWH SQL Server 2008 / Camel / PowerBuilder.

## Легенда статусов

| Статус | Смысл |
|--------|--------|
| **Adopt** | Целевая основа, использовать по умолчанию |
| **Trial** | Пилоты и домены 1–2 волны (0–18 мес.) |
| **Assess** | Изучение, ограниченные PoC |
| **Hold** | Не развивать; только мост миграции |

---

## Радар (сводная таблица)

| Категория | Технология / паттерн | Статус | Роль в целевой архитектуре | Комментарий |
|-----------|-------------------|--------|---------------------------|-------------|
| **Architecture** | Event-Driven Architecture | **Adopt** | Интеграция BC: Booking, Payment, Patient Care, Research | Замена ESB-оркестрации |
| **Architecture** | Domain-Driven Design (Bounded Contexts) | **Adopt** | Границы доменов и ownership | 4 BC на Event Storming + расширение (Fintech, Analytics) |
| **Architecture** | Data Mesh | **Trial** | Data products по доменам, federated governance | Пилот: patient flow + billing; масштаб 9–24 мес. |
| **Architecture** | Self-service BI / Data Portal | **Adopt** | Витрина без медкарт и PHI | Только semantic layer + policies |
| **Architecture** | Strangler Fig Pattern | **Adopt** | Миграция DWH / Camel / PowerBuilder | CDC из legacy, постепенный cutover |
| **Architecture** | Anti-Corruption Layer | **Adopt** | Изоляция от моделей DWH и банка | Обязателен для Camel и SQL Server 2008 |
| **Architecture** | CQRS (операции vs read models) | **Trial** | Разделение OLTP и витрин | Точечно в Patient Care и Analytics |
| **Architecture** | BFF (Backend for Frontend) | **Adopt** | Patient App / Operator UI | Java + TypeScript/React; см. To-Be |
| **Architecture** | ABAC (PEP / PDP / PIP) | **Adopt** | Доступ к мед и фин данным | Keycloak + policy engine; см. To-Be |
| **Architecture** | Synchronous ESB-centric Integration | **Hold** | Не целевой паттерн | Apache Camel — только мост |
| **Architecture** | Central DWH as integration hub | **Hold** | Не добавлять бизнес-логику | MS SQL 2008 — decommission 18–36 мес. |
| **Data** | Lakehouse on Object Storage (S3 / MinIO) | **Adopt** | raw / curated / serving | MinIO dev; S3 prod; замена роли центрального DWH |
| **Data** | PostgreSQL + Patroni + pgAudit | **Adopt** | Доменные OLTP (пациент, визит, счёт) | HA, аудит, региональные кластеры |
| **Data** | MS SQL Server 2008 DWH | **Hold** | Переходный слой | Только read/CDC, без новой логики |
| **Data** | Debezium (CDC) | **Adopt** | Вынос данных из DWH и банка | Уже в стеке компании; → Kafka |
| **Data** | Apache Airflow + Python | **Adopt** | Batch ELT, оркестрация data pipelines | Близко к текущим компетенциям |
| **Data** | dbt | **Trial** | Трансформации, тесты, документация data products | Пилот с Analytics Engineer |
| **Data** | Kafka Streams / Flink | **Trial** | Near-real-time витрины, stream marts | Пилот 6–18 мес.; на To-Be — Kafka Streams |
| **Data** | Semantic Layer / Metrics Store | **Adopt** | Единые KPI для self-service | Снижает расхождение метрик между доменами |
| **Data** | Data Catalog (Apache Atlas) | **Adopt** | Discovery, ownership, классификация | Основа Data Mesh governance |
| **Data** | Schema Registry (Confluent / совместимое) | **Adopt** | Версии событий Booking→Payment→Care | Обязательно с этапа 0–6 мес. |
| **Data** | OpenLineage | **Adopt** | Lineage data products и пайплайнов | Интеграция с Airflow / dbt |
| **Data** | Redis | **Trial** | Кэш BFF, сессии, rate limit | Не как primary store |
| **Integration** | Apache Kafka | **Adopt** | Событийная шина доменов | |
| **Integration** | Apache Camel ESB | **Hold** | Временная совместимость | Вывод с critical path |
| **Integration** | REST/JSON APIs | **Adopt** | BFF, партнёры, sync-границы | Patient / Payment / Operator API |
| **Integration** | HAProxy / API Gateway | **Adopt** | Балансировка, TLS termination | Kong/облачный gateway — Assess при выборе cloud |
| **Integration** | gRPC (internal) | **Assess** | Высоконагруженные internal calls | Точечно (ИИ, streaming) |
| **Apps** | React + TypeScript | **Adopt** | Patient App, Operator Interface | Замена PowerBuilder |
| **Apps** | Java (микросервисы + модульный монолит) | **Adopt** | SelfService, Payment, ABAC, операторский backend | Основной enterprise-стек |
| **Apps** | Golang | **Trial** | Финтех-микросервисы | Уже в ландшафте банка |
| **Apps** | Python | **Adopt** | ИИ-сервисы, Anonymizer, Airflow | Research / ML |
| **Apps** | PowerBuilder UI | **Hold** | Только до миграции операторов | Не развивать |
| **AI/ML** | Python ML Services | **Adopt** | Диагностика, анализ исследований | Событие `ПройденоИсследованиеИИ` |
| **AI/ML** | Model Registry & Monitoring | **Trial** | Версии моделей, drift | Обязательно к масштабированию ИИ |
| **AI/ML** | Feature Store | **Assess** | Online/offline признаки | После пилота ML use cases |
| **Platform** | Kubernetes | **Adopt** | Runtime сервисов и data workloads | Prod; Docker Compose — dev/test |
| **Platform** | Docker Compose | **Trial** | Локальная разработка, CI (MinIO, Kafka) | Как в Task2Advanced |
| **Platform** | Terraform / OpenTofu | **Adopt** | IaC облака и платформы | Task1–2, облачные среды по доменам |
| **Platform** | GitHub Actions / GitLab CI | **Adopt** | CI/CD сервисов и data platform | Policy checks, IaC validate |
| **Platform** | OpenTelemetry | **Adopt** | Трассировка, корреляция `eventId` | Сквозная observability |
| **Platform** | Prometheus + Grafana | **Adopt** | Метрики SLO, Kafka lag, pipelines | Platform + SRE |
| **Platform** | ELK Stack | **Adopt** | Централизованные логи | Корреляция с OTel trace id |
| **Security** | Keycloak + OIDC + Active Directory | **Adopt** | SSO внутренних и внешних пользователей | To-Be: 2 realm |
| **Security** | HashiCorp Vault | **Adopt** | Секреты, ключи, rotation | Не хранить в git/CI |
| **Security** | Apache Ranger | **Trial** | Политики доступа к lakehouse / каталогу | Дополняет ABAC на витринах |
| **Security** | MaxPatrol SIEM | **Adopt** | Мониторинг ИБ, инциденты | Соответствие мед/фин регуляторике |
| **Security** | Column/Row Level Security | **Adopt** | Self-service BI и data portal | Критично для витрины |
| **Security** | Zero Trust | **Trial** | Сегментация, mTLS между доменами | Поэтапно с K8s/network policies |
| **BI** | Power BI | **Trial** | Фронт BI на переходный период | Подключение к semantic layer, не к raw DWH |
| **BI** | Custom Data Portal (React) | **Trial** | Целевая витрина самообслуживания | 6–12 мес. MVP |

---

## Связь с этапами трансформации

| Период | Фокус Adopt | Фокус Trial | Hold (сокращать) |
|--------|-------------|-------------|------------------|
| 0–6 мес. | Kafka, Schema Registry, Debezium, PostgreSQL, Keycloak, OTel | Data Mesh pilot, dbt | Новая логика в DWH |
| 6–18 мес. | Lakehouse, Atlas, Airflow, semantic layer | Kafka Streams, Ranger, Power BI → portal | Camel на non-critical |
| 18–36 мес. | Domain analytics, full event choreography | Feature Store | SQL DWH, PowerBuilder |

---

## Исключения и принципы выбора

1. **Медкарты и результаты исследований** не попадают в lakehouse/витрину — только агрегаты и анонимизированные потоки (Anonymizer, Python).
2. **MongoDB** — не в базовом стеке; Assess только при явной документной модели партнёра.
3. **Service Mesh** (Istio/Linkerd) — Assess до 12 мес.; сначала gateway + network policies.
4. Стек **TypeScript/React + Java + Python + Golang** сохраняет текущие компетенции и To-Be.
