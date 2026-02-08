# LanguageTool Ukrainian — Docker

[🇺🇦 Українська](#українська) | [🇬🇧 English](#english)

---

## Українська

Локальний LanguageTool сервер із кастомними правилами для перевірки нативності українського тексту. Виявляє русизми, кальки, стилістичні помилки та проблеми зі сполучуваністю. Правила згенеровані з корпусу [UA-GEC](https://github.com/grammarly/ua-gec) (Grammarly).

### Швидкий старт

```bash
# Збілдити та запустити
docker compose up -d --build

# Перевірити роботу правил
./test.sh

# Налаштувати браузерне розширення (див. нижче)
```

### Структура проєкту

```
lt-docker/
├── Dockerfile               # Кастомний образ з правилами
├── docker-compose.yml       # Конфігурація сервісу
├── test.sh                  # Тестування правил
└── rules/
    ├── grammar-fluency-ua.xml   # 132 правила: кальки, стиль, сполучуваність, плавність
    └── agreement-yi.xml         # 44 правила: узгодження і/й/та
```

### Категорії правил

#### grammar-fluency-ua.xml

| Категорія | Кількість | Приклади |
|-----------|-----------|----------|
| **Кальки** (UA_GEC_CALQUE) | 54 | на протязі → протягом, являється → є, слідуючий → наступний |
| **Сполучуваність** (UA_GEC_COLLOCATION) | 6 | грає роль → відіграє роль |
| **Плавність** (UA_GEC_POORFLOW) | 53 | прийняти міри → вжити заходів, задавати питання → ставити запитання |
| **Стиль** (UA_GEC_STYLE) | 19 | як правило → зазвичай, даний → цей |

#### agreement-yi.xml

| Категорія | Кількість | Опис |
|-----------|-----------|------|
| **Узгодження (POS-теги)** | правила на основі частин мови | й/і перед приголосними/голосними |
| **Узгодження (часті слова)** | найпоширеніші контексти | та/і у сталих зворотах |
| **Узгодження (дистантне)** | міжслівні зв'язки | й/і з урахуванням контексту |
| **Узгодження (прийменник)** | прийменник + займенник | з/із, в/у узгодження |

### Налаштування браузерного розширення

#### Chrome / Firefox / Edge

1. Відкрити розширення LanguageTool → ⚙️ (Settings)
2. Прокрутити до **Advanced settings** або **Experimental settings**
3. Обрати **Other server** (або **Local server**)
4. Ввести: `http://localhost:8010/v2`
5. Зберегти

#### LibreOffice

1. **Tools → LanguageTool → Settings**
2. Встановити Server URL: `http://localhost:8010/v2`

### Параметри Docker

В `docker-compose.yml`:

| Змінна | Значення | Опис |
|--------|----------|------|
| `Java_Xms` | `512m` | Мінімальна пам'ять JVM |
| `Java_Xmx` | `2g` | Максимальна пам'ять JVM |
| `langtool_pipelinePrewarming` | `true` | Прогрів pipeline при старті |

### Використання API

```bash
# Перевірити текст
curl -s "http://localhost:8010/v2/check" \
  -d "language=uk" \
  --data-urlencode "text=Він являється головним спеціалістом." | python3 -m json.tool

# Список мов
curl -s "http://localhost:8010/v2/languages" | python3 -m json.tool

# Перевірити з конкретними категоріями
curl -s "http://localhost:8010/v2/check" \
  -d "language=uk" \
  -d "enabledCategories=UA_GEC_CALQUE,UA_GEC_STYLE,UA_GEC_COLLOCATION,UA_GEC_POORFLOW" \
  --data-urlencode "text=Ваш текст тут"
```

### Додавання своїх правил

Відредагуйте `rules/grammar-fluency-ua.xml` і перебілдіть:

```bash
docker compose up -d --build
```

Формат правила:

```xml
<rule id="MY_RULE_001" name="моє правило">
  <pattern>
    <token>помилкове</token>
    <token>слово</token>
  </pattern>
  <message>Краще: <suggestion>правильний варіант</suggestion></message>
  <example correction="правильний варіант">Це <marker>помилкове слово</marker> у тексті.</example>
  <example>Це правильний варіант у тексті.</example>
</rule>
```

### Управління

```bash
docker compose up -d          # Запустити у фоні
docker compose down           # Зупинити
docker compose logs -f        # Логи
docker compose restart        # Перезапустити
docker compose up -d --build  # Перебілдити після змін у правилах
```

---

## English

Local LanguageTool server with custom rules for checking Ukrainian text nativeness. Detects calques (loan translations from Russian), stylistic issues, collocations, and flow problems. Rules are generated from the [UA-GEC](https://github.com/grammarly/ua-gec) corpus (Grammarly).

### Quick start

```bash
# Build and start
docker compose up -d --build

# Test the rules
./test.sh

# Configure browser extension (see below)
```

### Project structure

```
lt-docker/
├── Dockerfile               # Custom image with rules
├── docker-compose.yml       # Service configuration
├── test.sh                  # Rule testing script
└── rules/
    ├── grammar-fluency-ua.xml   # 132 rules: calques, style, collocations, flow
    └── agreement-yi.xml         # 44 rules: і/й/та conjunction agreement
```

### Rule categories

#### grammar-fluency-ua.xml

| Category | Count | Description |
|----------|-------|-------------|
| **Calques** (UA_GEC_CALQUE) | 54 | Russian loan translations: на протязі → протягом, являється → є |
| **Collocations** (UA_GEC_COLLOCATION) | 6 | Wrong word combinations: грає роль → відіграє роль |
| **Flow** (UA_GEC_POORFLOW) | 53 | Unnatural phrasing: прийняти міри → вжити заходів |
| **Style** (UA_GEC_STYLE) | 19 | Stylistic issues: як правило → зазвичай, даний → цей |

#### agreement-yi.xml

Handles Ukrainian conjunction agreement (і/й/та) based on surrounding phonetic context — similar to English "a/an" but more complex.

### Browser extension setup

#### Chrome / Firefox / Edge

1. Open LanguageTool extension → ⚙️ (Settings)
2. Scroll to **Advanced settings** or **Experimental settings**
3. Select **Other server** (or **Local server**)
4. Enter: `http://localhost:8010/v2`
5. Save

#### LibreOffice

1. **Tools → LanguageTool → Settings**
2. Set Server URL: `http://localhost:8010/v2`

### Docker parameters

In `docker-compose.yml`:

| Variable | Default | Description |
|----------|---------|-------------|
| `Java_Xms` | `512m` | Minimum JVM memory |
| `Java_Xmx` | `2g` | Maximum JVM memory |
| `langtool_pipelinePrewarming` | `true` | Prewarm pipeline on startup for fast first request |

### API usage

```bash
# Check text
curl -s "http://localhost:8010/v2/check" \
  -d "language=uk" \
  --data-urlencode "text=Він являється головним спеціалістом." | python3 -m json.tool

# List languages
curl -s "http://localhost:8010/v2/languages" | python3 -m json.tool

# Check with specific categories
curl -s "http://localhost:8010/v2/check" \
  -d "language=uk" \
  -d "enabledCategories=UA_GEC_CALQUE,UA_GEC_STYLE,UA_GEC_COLLOCATION,UA_GEC_POORFLOW" \
  --data-urlencode "text=Your Ukrainian text here"
```

### Adding custom rules

Edit `rules/grammar-fluency-ua.xml` and rebuild:

```bash
docker compose up -d --build
```

Rule format:

```xml
<rule id="MY_RULE_001" name="my rule">
  <pattern>
    <token>wrong</token>
    <token>phrase</token>
  </pattern>
  <message>Better: <suggestion>correct phrase</suggestion></message>
  <example correction="correct phrase">This is a <marker>wrong phrase</marker> in text.</example>
  <example>This is a correct phrase in text.</example>
</rule>
```

### Management

```bash
docker compose up -d          # Start in background
docker compose down           # Stop
docker compose logs -f        # View logs
docker compose restart        # Restart
docker compose up -d --build  # Rebuild after rule changes
```

## License

[MIT](LICENSE)
