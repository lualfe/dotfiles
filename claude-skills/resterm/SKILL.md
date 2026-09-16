---
name: resterm
description: Deve ser usado quando o usuário pedir para gerar collections do Resterm com base em APIs escritas no código.
---

# Skill: Resterm Collection Generator

Gera e atualiza collections do [Resterm](https://github.com/unkn0wn-root/resterm) a partir de código de APIs HTTP, GraphQL e gRPC.

## Quando usar

- Quando o usuário pedir para gerar collections do Resterm
- Quando o usuário mencionar `/resterm` ou pedir para criar requests para suas APIs
- Quando o usuário quiser documentar APIs existentes no formato Resterm
- Quando o usuário pedir para criar arquivos `.http` ou `.rest`

## Fluxo de trabalho

### 1. Identificar o código da API

Pergunte ao usuário qual diretório contém o código da API, ou use o diretório fornecido.

### 2. Analisar o código

Use o agente Explore para encontrar:
- Arquivos de rotas/endpoints (ex: `routes.ts`, `router.go`, `urls.py`, `*Controller.java`)
- Handlers/Controllers que definem os endpoints
- Arquivos `.proto` para gRPC
- Schemas GraphQL (`.graphql`, `schema.ts`)
- Middlewares de autenticação
- Schemas/DTOs que definem os bodies das requests
- Documentação OpenAPI/Swagger se existir

### 3. Extrair informações de cada endpoint

Para cada endpoint encontrado, extraia:

**HTTP:**
- Método HTTP: GET, POST, PUT, PATCH, DELETE
- URL/Path: incluindo parâmetros de path (`:id`, `{id}`)
- Query parameters
- Headers requeridos
- Body: estrutura JSON, form-data
- Autenticação

**GraphQL:**
- Queries e Mutations disponíveis
- Variáveis necessárias
- Endpoint GraphQL

**gRPC:**
- Serviços e métodos
- Arquivo de descriptor (.protoset)
- Estrutura das mensagens

### 4. Gerar arquivos .http

Crie os arquivos seguindo o formato do Resterm.

## Formato de arquivos .http / .rest

O Resterm usa arquivos de texto com extensão `.http` ou `.rest`. Cada request é separada por `###`.

### Estrutura básica

```http
### Nome da Request
# @name identificador-unico
# @description Descrição detalhada do endpoint
# @tag tag1 tag2
METHOD {{base_url}}/path/:param
Header-Name: value
Content-Type: application/json

{
  "field": "value"
}
```

## Diretivas disponíveis

### Metadados

| Diretiva | Sintaxe | Descrição |
|----------|---------|-----------|
| `@name` | `# @name id` | Identificador único da request |
| `@description` | `# @description texto` | Descrição do endpoint |
| `@tag` | `# @tag api users` | Tags para filtros |
| `@timeout` | `# @timeout 5s` | Timeout da request |
| `@no-log` | `# @no-log` | Omite body do histórico |

### Variáveis

| Diretiva | Sintaxe | Escopo |
|----------|---------|--------|
| `@const` | `# @const name value` | Imutável, arquivo inteiro |
| `@global` | `# @global name value` | Ambiente inteiro |
| `@file` | `# @file name value` | Apenas este arquivo |
| `@request` | `# @request name value` | Apenas esta request |

**Variáveis secretas:** Adicione `-secret` ao escopo (ex: `@global-secret`)

### Helpers dinâmicos

```
{{$uuid}}           - UUID v4
{{$guid}}           - Alias para uuid
{{$timestamp}}      - Unix timestamp
{{$timestampISO8601}} - ISO 8601 timestamp
{{$randomInt}}      - Inteiro aleatório
```

### Autenticação

```http
# Basic Auth
# @auth basic username password

# Bearer Token
# @auth bearer {{auth.token}}

# API Key
# @auth apikey header X-API-Key {{api_key}}

# OAuth 2.0 Client Credentials
# @auth oauth2 token_url={{oauth.token_url}} client_id={{oauth.client_id}} client_secret={{oauth.client_secret}} grant=client_credentials

# OAuth 2.0 Password Grant
# @auth oauth2 token_url={{oauth.token_url}} client_id={{oauth.client_id}} grant=password username={{user}} password={{pass}}
```

### Captura de dados

```http
# Capturar token da resposta para uso global
# @capture global-secret auth.token {{response.json.access_token}}

# Capturar ID para uso no arquivo
# @capture file created_id {{response.json.id}}
```

### Configurações de transporte

```http
# @setting timeout=5s
# @setting insecure=true
# @setting followredirects=true
# @setting proxy=http://proxy.local:8080
# @setting http-root-cas=./ca.pem
```

## Exemplos por tipo de API

### HTTP REST

```http
### List Users
# @name list-users
# @description Retorna lista paginada de usuários
# @tag users api
GET {{base_url}}/api/users?page=1&limit=10
Accept: application/json
Authorization: Bearer {{auth.token}}

### Get User by ID
# @name get-user
# @description Busca usuário por ID
# @tag users api
GET {{base_url}}/api/users/:id
Accept: application/json
Authorization: Bearer {{auth.token}}

### Create User
# @name create-user
# @description Cria novo usuário no sistema
# @tag users api
# @capture file created_user_id {{response.json.id}}
POST {{base_url}}/api/users
Content-Type: application/json
Authorization: Bearer {{auth.token}}

{
  "name": "John Doe",
  "email": "john@example.com",
  "role": "user"
}

### Update User
# @name update-user
# @description Atualiza dados do usuário
# @tag users api
PUT {{base_url}}/api/users/:id
Content-Type: application/json
Authorization: Bearer {{auth.token}}

{
  "name": "John Updated",
  "email": "john.updated@example.com"
}

### Delete User
# @name delete-user
# @description Remove usuário do sistema
# @tag users api
DELETE {{base_url}}/api/users/:id
Authorization: Bearer {{auth.token}}
```

### GraphQL

```http
### Fetch Workspace
# @name fetch-workspace
# @description Busca workspace por ID
# @tag graphql workspace
# @graphql
# @operation FetchWorkspace
POST {{graphql.endpoint}}
Content-Type: application/json
Authorization: Bearer {{auth.token}}

query FetchWorkspace($id: ID!) {
  workspace(id: $id) {
    id
    name
    createdAt
    members {
      id
      name
    }
  }
}

# @variables
{
  "id": "{{workspace_id}}"
}

### Create Project
# @name create-project
# @description Cria novo projeto no workspace
# @tag graphql project
# @graphql
# @operation CreateProject
POST {{graphql.endpoint}}
Content-Type: application/json
Authorization: Bearer {{auth.token}}

mutation CreateProject($input: CreateProjectInput!) {
  createProject(input: $input) {
    id
    name
    status
  }
}

# @variables
{
  "input": {
    "workspaceId": "{{workspace_id}}",
    "name": "New Project",
    "description": "Project description"
  }
}
```

### gRPC

```http
### Get User (gRPC)
# @name grpc-get-user
# @description Busca usuário via gRPC
# @tag grpc users
# @grpc user.UserService/GetUser
# @grpc-descriptor ./proto/user.protoset
# @grpc-metadata x-request-id: {{$uuid}}
GRPC {{grpc.host}}

{
  "user_id": "123"
}

### Create User (gRPC)
# @name grpc-create-user
# @description Cria usuário via gRPC
# @tag grpc users
# @grpc user.UserService/CreateUser
# @grpc-descriptor ./proto/user.protoset
# @grpc-plaintext true
GRPC {{grpc.host}}

{
  "name": "John Doe",
  "email": "john@example.com"
}

### List Users Stream (gRPC)
# @name grpc-list-users-stream
# @description Stream de usuários via gRPC
# @tag grpc users streaming
# @grpc user.UserService/ListUsersStream
# @grpc-descriptor ./proto/user.protoset
GRPC {{grpc.host}}

{
  "filter": "active"
}
```

### WebSocket

```http
### Chat Connection
# @name websocket-chat
# @description Conexão WebSocket para chat
# @tag websocket chat
# @websocket timeout=30s idle-timeout=10s
# @ws send {"type": "auth", "token": "{{auth.token}}"}
# @ws wait 1s
# @ws send-json {"type": "join", "room": "general"}
# @ws wait 5s
# @ws send-json {"type": "message", "text": "Hello!"}
# @ws close 1000 "Done"
GET wss://{{ws.host}}/chat
```

### SSE (Server-Sent Events)

```http
### Notifications Stream
# @name sse-notifications
# @description Stream de notificações via SSE
# @tag sse notifications
# @sse duration=5m idle=30s max-events=100
GET {{base_url}}/api/notifications/stream
Accept: text/event-stream
Authorization: Bearer {{auth.token}}
```

## Body de arquivo externo

```http
### Upload com body de arquivo
# @name upload-data
POST {{base_url}}/api/import
Content-Type: application/json
Authorization: Bearer {{auth.token}}

< ./payloads/import-data.json
```

## Workflows

```http
### Provision Account Workflow
# @name provision-account
# @description Fluxo completo de criação de conta
# @workflow provision-account on-failure=continue
# @step Authenticate using=login expect.statuscode=200
# @step CreateUser using=create-user vars.request.email={{email}}
# @step VerifyUser using=get-user

### Login
# @name login
POST {{base_url}}/auth/login
Content-Type: application/json

{
  "email": "{{email}}",
  "password": "{{password}}"
}
```

## Arquivo de ambiente (resterm.env.json)

```json
{
  "$schema": "https://raw.githubusercontent.com/unkn0wn-root/resterm/main/schema/env.json",
  "dev": {
    "base_url": "http://localhost:3000",
    "graphql.endpoint": "http://localhost:3000/graphql",
    "grpc.host": "localhost:50051",
    "ws.host": "localhost:3000",
    "auth.token": "dev-token-here",
    "oauth.token_url": "http://localhost:3000/oauth/token",
    "oauth.client_id": "dev-client",
    "oauth.client_secret": "dev-secret"
  },
  "staging": {
    "base_url": "https://staging-api.example.com",
    "graphql.endpoint": "https://staging-api.example.com/graphql",
    "grpc.host": "staging-grpc.example.com:443",
    "ws.host": "staging-api.example.com",
    "auth.token": "${STAGING_TOKEN}",
    "oauth.token_url": "https://staging-auth.example.com/oauth/token",
    "oauth.client_id": "${STAGING_CLIENT_ID}",
    "oauth.client_secret": "${STAGING_CLIENT_SECRET}"
  },
  "prod": {
    "base_url": "https://api.example.com",
    "graphql.endpoint": "https://api.example.com/graphql",
    "grpc.host": "grpc.example.com:443",
    "ws.host": "api.example.com",
    "auth.token": "${PROD_TOKEN}",
    "oauth.token_url": "https://auth.example.com/oauth/token",
    "oauth.client_id": "${PROD_CLIENT_ID}",
    "oauth.client_secret": "${PROD_CLIENT_SECRET}"
  }
}
```

## Estrutura de diretórios recomendada

```
collection/
├── resterm.env.json          # Variáveis por ambiente
├── proto/                    # Descriptors gRPC
│   └── services.protoset
├── payloads/                 # Bodies externos
│   └── import-data.json
├── auth/
│   ├── login.http
│   └── oauth.http
├── users/
│   ├── crud.http             # Operações CRUD
│   └── admin.http            # Operações admin
├── graphql/
│   ├── queries.http
│   └── mutations.http
├── grpc/
│   └── user-service.http
└── realtime/
    ├── websocket.http
    └── sse.http
```

## Boas práticas

1. **Nomes de arquivos**: Use kebab-case descritivo (ex: `user-crud.http`)
2. **Organização**: Agrupe requests por recurso/domínio ou por protocolo
3. **Variáveis**: Use variáveis para URLs base, tokens, e valores que mudam entre ambientes
4. **@name único**: Sempre defina um `@name` único para facilitar referências em workflows
5. **@description**: Inclua descrições claras do propósito de cada endpoint
6. **@tag**: Use tags para filtrar e organizar requests
7. **Exemplos realistas**: Use valores de exemplo que façam sentido para o domínio
8. **Captures**: Use `@capture` para encadear requests automaticamente

## Gerando descriptors gRPC

Para gRPC, é necessário gerar o arquivo `.protoset`:

```bash
# Usando protoc
protoc --descriptor_set_out=./proto/services.protoset \
       --include_imports \
       ./proto/*.proto

# Usando buf
buf build -o ./proto/services.protoset
```

## Atualização de collections existentes

Quando atualizar uma collection existente:

1. Leia os arquivos `.http` existentes
2. Compare com os endpoints encontrados no código
3. Identifique endpoints novos, modificados ou removidos
4. Pergunte ao usuário como proceder com cada mudança
5. Mantenha customizações feitas pelo usuário (descrições, exemplos personalizados, tags)
6. Preserve workflows e captures configurados

## Frameworks suportados

O skill deve ser capaz de analisar APIs escritas em:

**HTTP REST:**
- **Node.js**: Express, Fastify, NestJS, Hono, Koa
- **Python**: FastAPI, Flask, Django REST
- **Go**: Gin, Echo, Chi, net/http, Fiber
- **Ruby**: Rails, Sinatra
- **Java/Kotlin**: Spring Boot, Quarkus, Micronaut
- **Rust**: Actix-web, Axum, Rocket
- **PHP**: Laravel, Symfony

**GraphQL:**
- Apollo Server, graphql-yoga, Mercurius
- Strawberry, Ariadne, Graphene
- gqlgen, 99designs/gqlgen
- Spring GraphQL, Netflix DGS

**gRPC:**
- Qualquer implementação que use arquivos `.proto`
- grpc-node, grpc-go, tonic (Rust), grpc-java

Para cada framework, procure pelos padrões específicos de definição de rotas, schemas e serviços.
