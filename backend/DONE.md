# Done — Статус готовности

## Готово

### Инфраструктура
- [x] NestJS проект инициализирован и настроен
- [x] TypeScript, ESLint, Prettier сконфигурированы
- [x] Swagger документация на `/api/docs`
- [x] ValidationPipe (transform, whitelist)
- [x] Repository Pattern с DI-токенами (Symbol)

### Аутентификация
- [x] Device-based auth (`POST /auth/device`)
- [x] JWT стратегия (Passport)
- [x] JwtAuthGuard для защищённых эндпоинтов
- [x] `@CurrentUser()` декоратор

### Профиль пользователя
- [x] Получение профиля (`GET /users/profile`)
- [x] Обновление профиля (`PATCH /users/profile`) — имя, вес, рост, возраст, противопоказания
- [x] Валидация полей (min/max, типы)

### Каталог упражнений
- [x] Пагинация (`GET /exercises?page=&limit=`)
- [x] Фильтрация по: противопоказаниям, оборудованию, целевым мышцам, поиску
- [x] Похожие упражнения (`GET /exercises/:slug/similar`)
- [x] Антагонистические упражнения (`GET /exercises/:slug/antagonist`)
- [x] Резолвинг slug-ссылок в полные объекты (мышцы, части тела, оборудование)

### Справочники
- [x] Части тела (`GET /bodyparts`)
- [x] Оборудование (`GET /equipments`)
- [x] Мышцы с антагонистами (`GET /muscles`)
- [x] Противопоказания (`GET /contraindications`)

### Данные
- [x] JSON-хранилище для всех сущностей
- [x] Скрипт обогащения упражнений (перевод, movementPattern, difficulty, exerciseType, variations)

### Тестирование
- [x] E2E тест для health-check (`GET /`)

## Не готово / Планируется

- [ ] База данных (MongoDB/PostgreSQL) вместо JSON-файлов
- [ ] Docker / Docker Compose
- [ ] CRUD для упражнений (создание, редактирование, удаление)
- [ ] Модуль тренировок (создание тренировки из упражнений)
- [ ] История тренировок пользователя
- [ ] Unit-тесты для сервисов и репозиториев
- [ ] Rate limiting
- [ ] Кэширование
- [ ] `.env.example` файл
- [ ] CI/CD pipeline
