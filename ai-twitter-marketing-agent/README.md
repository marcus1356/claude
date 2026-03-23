# AI Social Media Marketing Agent

<p align="center">
  <strong>Agente de IA que gera conteudo de marketing com Claude e posta automaticamente em multiplas redes sociais.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.11+-blue?logo=python&logoColor=white" alt="Python 3.11+">
  <img src="https://img.shields.io/badge/FastAPI-0.115-009688?logo=fastapi&logoColor=white" alt="FastAPI">
  <img src="https://img.shields.io/badge/Claude_API-Anthropic-6B4FBB?logo=anthropic&logoColor=white" alt="Claude API">
  <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
</p>

---

## Visao Geral

Este projeto automatiza a criacao e publicacao de conteudo de marketing em redes sociais usando inteligencia artificial. O agente utiliza a API do Claude (Anthropic) para gerar posts adaptados a cada plataforma, respeitando limites de caracteres, tom e boas praticas de cada rede.

### Principais Funcionalidades

- **Geracao de conteudo com IA** — Posts unicos e personalizados via Claude Sonnet
- **Multi-plataforma** — Twitter/X, LinkedIn e Bluesky prontos para uso
- **Agendamento automatico** — Publicacao diaria em horario configuravel
- **Dashboard web** — Interface visual para monitorar e gerenciar posts
- **Modo demo** — Funciona sem API keys para testes e demonstracoes
- **Arquitetura extensivel** — Adicione novas plataformas facilmente

---

## Plataformas Suportadas

| Plataforma | Limite | Integracao | Tom do Conteudo |
|:----------:|:------:|:----------:|:---------------:|
| **Twitter/X** | 280 caracteres | Tweepy (API v2) | Conciso, hashtags, engajamento |
| **LinkedIn** | 3.000 caracteres | OAuth 2.0 REST API | Profissional, hooks, 3-5 hashtags |
| **Bluesky** | 300 caracteres | AT Protocol | Conversacional, comunidade, sem hashtags |

---

## Stack Tecnologica

| Camada | Tecnologia | Funcao |
|--------|-----------|--------|
| Backend | **FastAPI** + Uvicorn | API REST e servidor web |
| IA | **Claude API** (Anthropic) | Geracao de conteudo inteligente |
| Banco de Dados | **SQLite** + aiosqlite | Historico de posts (async) |
| Agendamento | **APScheduler** | Cron job diario configuravel |
| Twitter | **Tweepy** 4.14 | Integracao com Twitter API v2 |
| LinkedIn | **Requests** + OAuth 2.0 | Integracao com LinkedIn API |
| Bluesky | **Requests** + AT Protocol | Integracao com Bluesky |
| Frontend | **HTML/CSS/JS** puro | Dashboard responsivo (sem frameworks) |

---

## Inicio Rapido

### Pre-requisitos

- Python 3.11 ou superior
- Conta na [Anthropic](https://console.anthropic.com/) (opcional — modo demo disponivel)
- Credenciais das plataformas que deseja usar (opcional)

### 1. Clonar e instalar

```bash
git clone https://github.com/marcus1356/claude.git
cd claude/ai-twitter-marketing-agent

python3 -m venv .venv
source .venv/bin/activate    # Linux/Mac
# .venv\Scripts\activate     # Windows

pip install -r requirements.txt
```

### 2. Configurar variaveis de ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env`:

```env
# Chave da API Anthropic (deixe vazio para modo demo)
ANTHROPIC_API_KEY=sk-ant-...

# Horario de postagem diaria (24h)
POST_HOUR=9
POST_MINUTE=0

# Configuracao da marca
BRAND_NAME=MinhaMarca
BRAND_DESCRIPTION=Uma empresa inovadora que cria solucoes com IA
BRAND_TONE=profissional, amigavel, inovador
BRAND_TOPICS=tecnologia, inovacao, produtividade, inteligencia artificial
```

### 3. Configurar contas de redes sociais

```bash
cp accounts.json.example accounts.json
```

Edite `accounts.json` com as credenciais das suas contas:

```json
[
  {
    "name": "twitter-main",
    "platform": "twitter",
    "enabled": true,
    "credentials": {
      "api_key": "...",
      "api_secret": "...",
      "access_token": "...",
      "access_token_secret": "...",
      "bearer_token": "..."
    }
  },
  {
    "name": "linkedin-corp",
    "platform": "linkedin",
    "enabled": true,
    "credentials": {
      "access_token": "...",
      "person_id": "..."
    }
  },
  {
    "name": "bluesky-main",
    "platform": "bluesky",
    "enabled": true,
    "credentials": {
      "handle": "usuario.bsky.social",
      "app_password": "..."
    }
  }
]
```

> **Dica:** Defina `"enabled": false` para desativar uma conta sem remover as credenciais.

### 4. Executar

```bash
python main.py
```

Acesse o dashboard em **http://localhost:8000**

---

## Dashboard

O dashboard web possui tema escuro inspirado no Twitter/X e oferece:

- **Cards de estatisticas** — Total, Publicados, Falhas, Pendentes
- **Lista de posts recentes** — Com conteudo, plataforma, status e links
- **Filtro por plataforma** — Visualize posts de uma rede especifica
- **Botao "Postar Agora"** — Dispare posts manualmente para uma ou todas as contas
- **Indicadores de conta** — Veja quais contas estao ativas
- **Auto-refresh** — Atualiza automaticamente a cada 30 segundos

> Tambem existe um `preview.html` que funciona offline para demonstracao.

---

## API Endpoints

| Metodo | Rota | Descricao | Parametros |
|:------:|------|-----------|------------|
| `GET` | `/` | Dashboard web | — |
| `GET` | `/api/posts` | Lista posts | `limit`, `offset`, `platform` |
| `GET` | `/api/stats` | Estatisticas | `platform` |
| `GET` | `/api/accounts` | Contas configuradas | — |
| `POST` | `/api/post-now` | Posta imediatamente | `account` (opcional) |

### Exemplos de uso

```bash
# Listar todos os posts
curl http://localhost:8000/api/posts

# Filtrar posts do Twitter (ultimos 10)
curl "http://localhost:8000/api/posts?platform=twitter&limit=10"

# Ver estatisticas
curl http://localhost:8000/api/stats

# Postar em todas as contas ativas
curl -X POST http://localhost:8000/api/post-now

# Postar em uma conta especifica
curl -X POST "http://localhost:8000/api/post-now?account=twitter-main"
```

---

## Arquitetura

```
ai-twitter-marketing-agent/
├── main.py                        # App FastAPI, rotas e lifecycle
├── requirements.txt               # Dependencias Python
├── .env.example                   # Template de configuracao
├── accounts.json.example          # Template de contas
├── preview.html                   # Dashboard offline (standalone)
│
├── app/
│   ├── agent.py                   # Orquestrador: gera conteudo + posta
│   ├── content_generator.py       # Integracao com Claude API
│   ├── database.py                # Operacoes SQLite (async)
│   ├── scheduler.py               # APScheduler (cron diario)
│   └── platforms/
│       ├── base.py                # Classe abstrata PlatformClient
│       ├── registry.py            # Carrega contas do accounts.json
│       ├── twitter.py             # Cliente Twitter (Tweepy v2)
│       ├── linkedin.py            # Cliente LinkedIn (OAuth 2.0)
│       └── bluesky.py             # Cliente Bluesky (AT Protocol)
│
├── templates/
│   └── dashboard.html             # Template do dashboard
│
└── static/                        # Assets estaticos
```

### Fluxo de Funcionamento

```
                    ┌─────────────┐
                    │  Scheduler  │  (APScheduler - cron diario)
                    │  ou Manual  │  (POST /api/post-now)
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Agent     │  (app/agent.py)
                    │ Orquestrador│
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
     ┌────────▼───┐ ┌──────▼─────┐ ┌───▼────────┐
     │  Content   │ │  Database  │ │  Platform   │
     │ Generator  │ │  (SQLite)  │ │  Registry   │
     │ (Claude AI)│ │            │ │             │
     └────────────┘ └────────────┘ └──────┬──────┘
                                          │
                              ┌───────────┼───────────┐
                              │           │           │
                        ┌─────▼──┐  ┌─────▼──┐  ┌────▼───┐
                        │Twitter │  │LinkedIn│  │Bluesky │
                        │ Client │  │ Client │  │ Client │
                        └────────┘  └────────┘  └────────┘
```

1. O **Scheduler** dispara diariamente (ou via API manual)
2. O **Agent** solicita conteudo ao **Content Generator**
3. O **Content Generator** chama a API do Claude com regras da plataforma e dados da marca
4. O conteudo gerado e salvo no **Database** com status "pending"
5. O **Agent** envia o post pela **Platform** correspondente
6. O status e atualizado para "posted" (sucesso) ou "failed" (erro)

---

## Modo Demo

Se a variavel `ANTHROPIC_API_KEY` estiver vazia ou nao configurada, o sistema entra automaticamente em **modo demo**:

- Conteudo e gerado a partir de templates pre-escritos
- Posts simulados recebem IDs ficticios
- Todas as funcionalidades do dashboard continuam operando
- Ideal para testar a interface e o fluxo sem custos

---

## Adicionando uma Nova Plataforma

1. Crie o arquivo `app/platforms/nova_rede.py`:

```python
from app.platforms.base import PlatformClient, PostResult

class NovaRedeClient(PlatformClient):
    platform_name = "nova_rede"
    max_length = 500

    def __init__(self, account_name: str, credentials: dict):
        super().__init__(account_name, credentials)
        # Inicialize o cliente da API

    def post(self, content: str) -> PostResult:
        # Publique o conteudo na plataforma
        return PostResult(external_id="123", url="https://...")

    def validate_credentials(self) -> bool:
        # Valide se as credenciais funcionam
        return True

    def get_content_rules(self) -> str:
        return "- Maximo 500 caracteres\n- Tom casual"
```

2. Registre em `app/platforms/registry.py`:

```python
PLATFORM_CLASSES = {
    "twitter": ("app.platforms.twitter", "TwitterClient"),
    "linkedin": ("app.platforms.linkedin", "LinkedInClient"),
    "bluesky": ("app.platforms.bluesky", "BlueskyClient"),
    "nova_rede": ("app.platforms.nova_rede", "NovaRedeClient"),  # Adicione aqui
}
```

3. Adicione a conta em `accounts.json`:

```json
{
  "name": "nova-rede-principal",
  "platform": "nova_rede",
  "enabled": true,
  "credentials": { "token": "..." }
}
```

---

## Banco de Dados

O SQLite armazena o historico completo de posts:

| Coluna | Tipo | Descricao |
|--------|------|-----------|
| `id` | INTEGER | Chave primaria auto-incremento |
| `content` | TEXT | Texto do post gerado |
| `platform` | TEXT | twitter / linkedin / bluesky |
| `account_name` | TEXT | Nome da conta (de accounts.json) |
| `external_id` | TEXT | ID do post na plataforma |
| `external_url` | TEXT | URL para visualizar o post |
| `status` | TEXT | pending / posted / failed |
| `error_message` | TEXT | Mensagem de erro (se falhou) |
| `created_at` | TEXT | Timestamp de criacao (ISO 8601) |
| `posted_at` | TEXT | Timestamp de publicacao (ISO 8601) |

O banco e criado automaticamente em `posts.db` na primeira execucao.

---

## Configuracao do Agendamento

O agendamento e controlado pelas variaveis de ambiente:

```env
POST_HOUR=9      # Hora (0-23)
POST_MINUTE=0    # Minuto (0-59)
```

O agente publica automaticamente todos os dias no horario configurado em **todas as contas ativas**.

Para desativar o agendamento e usar apenas o modo manual, basta nao configurar contas ativas.

---

## Obtendo Credenciais

### Twitter/X
1. Acesse [developer.twitter.com](https://developer.twitter.com)
2. Crie um projeto e app
3. Gere API Key, API Secret, Access Token e Access Token Secret
4. O plano "Free" permite 1.500 tweets/mes

### LinkedIn
1. Crie um app em [linkedin.com/developers](https://www.linkedin.com/developers/)
2. Solicite permissao `w_member_social`
3. Gere um Access Token via OAuth 2.0
4. Encontre seu `person_id` via API `/v2/me`

### Bluesky
1. Acesse [bsky.app/settings/app-passwords](https://bsky.app/settings/app-passwords)
2. Crie uma App Password
3. Use seu handle (ex: `usuario.bsky.social`) e a app password

---

## Dependencias

```
fastapi==0.115.6
uvicorn==0.34.0
anthropic==0.43.0
tweepy==4.14.0
requests==2.32.3
apscheduler==3.10.4
aiosqlite==0.20.0
python-dotenv==1.0.1
jinja2==3.1.4
```

---

## Licenca

MIT License - use livremente para fins comerciais e pessoais.
