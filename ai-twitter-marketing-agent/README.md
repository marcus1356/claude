# AI Social Media Marketing Agent

Agente de IA que gera conteudo de marketing e posta automaticamente em multiplas redes sociais.

## Plataformas Suportadas

| Plataforma | Status | Descricao |
|---|---|---|
| **Twitter/X** | Pronto | Via Tweepy (Twitter API v2) |
| **LinkedIn** | Pronto | Via LinkedIn API (OAuth 2.0) |
| **Bluesky** | Pronto | Via AT Protocol |

Novas plataformas podem ser adicionadas criando uma classe que herda de `PlatformClient`.

## Stack

- **Python + FastAPI** — API e dashboard web
- **Claude (Anthropic)** — Geracao de conteudo adaptado por plataforma
- **SQLite** — Armazenamento local dos posts
- **APScheduler** — Agendamento diario automatico

## Setup

### 1. Instalar dependencias

```bash
cd ai-twitter-marketing-agent
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configurar variaveis de ambiente

```bash
cp .env.example .env
# Edite o .env com sua API key da Anthropic e configuracao da marca
```

### 3. Configurar contas

```bash
cp accounts.json.example accounts.json
# Edite accounts.json com as credenciais das suas contas
# Ative/desative contas com "enabled": true/false
```

### 4. Executar

```bash
python main.py
```

Acesse o dashboard em `http://localhost:8000`

## Arquitetura Multi-Plataforma

```
accounts.json          -> Define contas e credenciais
app/platforms/base.py  -> Classe base PlatformClient
app/platforms/twitter.py, linkedin.py, bluesky.py -> Implementacoes
app/platforms/registry.py -> Carrega e gerencia contas ativas
app/content_generator.py  -> Gera conteudo adaptado por plataforma
app/agent.py              -> Orquestra geracao + postagem
```

### Adicionando uma nova plataforma

1. Crie `app/platforms/minha_rede.py` com uma classe que herda `PlatformClient`
2. Implemente os metodos `post()`, `validate_credentials()` e `get_content_rules()`
3. Registre no dicionario `PLATFORM_CLASSES` em `app/platforms/registry.py`
4. Adicione a conta no `accounts.json`

## API Endpoints

| Metodo | Rota | Descricao |
|---|---|---|
| GET | `/` | Dashboard web |
| GET | `/api/posts?platform=twitter` | Lista posts (filtro opcional) |
| GET | `/api/stats?platform=twitter` | Estatisticas (filtro opcional) |
| GET | `/api/accounts` | Lista contas configuradas |
| POST | `/api/post-now?account=nome` | Posta agora (conta especifica ou todas) |
