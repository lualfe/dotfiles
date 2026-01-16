---
name: posting
description: Deve ser usado quando o usuário pedir para gerar collections do Posting com base em APIs escritas no código.
---

# Skill: Posting Collection Generator

Gera e atualiza collections do [Posting](https://posting.sh/) a partir de código de APIs HTTP.

## Quando usar

- Quando o usuário pedir para gerar collections do Posting
- Quando o usuário mencionar `/posting` ou pedir para criar requests para suas APIs
- Quando o usuário quiser documentar APIs existentes no formato Posting

## Fluxo de trabalho

### 1. Identificar o código da API

Pergunte ao usuário qual diretório contém o código da API, ou use o diretório fornecido.

### 2. Analisar o código

Use o agente Explore para encontrar:
- Arquivos de rotas/endpoints (ex: `routes.ts`, `router.go`, `urls.py`, `*Controller.java`)
- Handlers/Controllers que definem os endpoints
- Middlewares de autenticação
- Schemas/DTOs que definem os bodies das requests
- Documentação OpenAPI/Swagger se existir

### 3. Extrair informações de cada endpoint

Para cada endpoint encontrado, extraia:
- **Método HTTP**: GET, POST, PUT, PATCH, DELETE, etc.
- **URL/Path**: incluindo parâmetros de path (`:id`, `{id}`)
- **Query parameters**: parâmetros opcionais e obrigatórios
- **Headers requeridos**: Content-Type, Authorization, custom headers
- **Body**: estrutura JSON, form-data, etc.
- **Autenticação**: Bearer token, Basic auth, API key

### 4. Gerar arquivos .posting.yaml

Crie os arquivos seguindo a estrutura do Posting.

## Formato do arquivo .posting.yaml

```yaml
name: Nome descritivo da request
description: Descrição do que o endpoint faz
method: POST
url: https://api.example.com/users/:id
body:
  content: |
    {
      "field1": "value1",
      "field2": "value2"
    }
headers:
  - name: Content-Type
    value: application/json
  - name: Authorization
    value: Bearer ${AUTH_TOKEN}
params:
  - name: queryParam1
    value: "value"
  - name: queryParam2
    value: "value"
path_params:
  - name: id
    value: "1"
auth:
  type: bearer
  token: ${AUTH_TOKEN}
```

### Campos disponíveis

| Campo | Descrição | Obrigatório |
|-------|-----------|-------------|
| `name` | Nome descritivo da request | Sim |
| `description` | Descrição detalhada | Não |
| `method` | HTTP method (GET, POST, PUT, PATCH, DELETE) | Sim |
| `url` | URL completa do endpoint | Sim |
| `body` | Objeto com `content` contendo o body | Não |
| `headers` | Lista de objetos `{name, value}` | Não |
| `params` | Query parameters como lista `{name, value}` | Não |
| `path_params` | Parâmetros de path como lista `{name, value}` | Não |
| `auth` | Configuração de autenticação | Não |

### Tipos de autenticação

```yaml
# Bearer Token
auth:
  type: bearer
  token: ${AUTH_TOKEN}

# Basic Auth
auth:
  type: basic
  username: ${USERNAME}
  password: ${PASSWORD}

# Digest Auth
auth:
  type: digest
  username: ${USERNAME}
  password: ${PASSWORD}
```

### Variáveis

Use a sintaxe `${VARIABLE_NAME}` ou `$VARIABLE_NAME` para interpolação de variáveis.

As variáveis são definidas em arquivos `.env`:
- `posting.env` - carregado automaticamente
- Arquivos customizados via `posting --env file.env`

## Estrutura de diretórios recomendada

```
collection/
├── posting.env              # Variáveis de ambiente
├── auth/
│   ├── login.posting.yaml
│   └── register.posting.yaml
├── users/
│   ├── list-users.posting.yaml
│   ├── get-user.posting.yaml
│   ├── create-user.posting.yaml
│   ├── update-user.posting.yaml
│   └── delete-user.posting.yaml
└── products/
    ├── list-products.posting.yaml
    └── create-product.posting.yaml
```

## Exemplo de arquivo .env

```env
# posting.env
BASE_URL=http://localhost:3000
AUTH_TOKEN=your-token-here
API_KEY=your-api-key
```

## Boas práticas

1. **Nomes de arquivos**: Use kebab-case descritivo (ex: `create-user.posting.yaml`)
2. **Organização**: Agrupe requests por recurso/domínio em subdiretórios
3. **Variáveis**: Use variáveis para URLs base, tokens, e valores que mudam entre ambientes
4. **Descrições**: Inclua descrições claras do propósito de cada endpoint
5. **Exemplos realistas**: Use valores de exemplo que façam sentido para o domínio
6. **Path params**: Sempre inclua valores padrão para facilitar testes

## Exemplo completo

Para um endpoint POST `/api/users` que cria um usuário:

```yaml
name: Create User
description: Creates a new user in the system. Requires admin authentication.
method: POST
url: ${BASE_URL}/api/users
body:
  content: |
    {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "user"
    }
headers:
  - name: Content-Type
    value: application/json
  - name: X-Request-ID
    value: ${REQUEST_ID}
auth:
  type: bearer
  token: ${AUTH_TOKEN}
```

## Atualização de collections existentes

Quando atualizar uma collection existente:

1. Leia os arquivos `.posting.yaml` existentes
2. Compare com os endpoints encontrados no código
3. Identifique endpoints novos, modificados ou removidos
4. Pergunte ao usuário como proceder com cada mudança
5. Mantenha customizações feitas pelo usuário (descrições, exemplos personalizados)

## Frameworks suportados

O skill deve ser capaz de analisar APIs escritas em:

- **Node.js**: Express, Fastify, NestJS, Hono, Koa
- **Python**: FastAPI, Flask, Django REST
- **Go**: Gin, Echo, Chi, net/http
- **Ruby**: Rails, Sinatra
- **Java/Kotlin**: Spring Boot, Quarkus
- **Rust**: Actix-web, Axum, Rocket
- **PHP**: Laravel, Symfony

Para cada framework, procure pelos padrões específicos de definição de rotas.
