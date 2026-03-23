# AI Twitter Marketing Agent

Agente de IA que gera conteúdo de marketing e posta automaticamente no Twitter/X diariamente.

## Stack

- **Python + FastAPI** — API e dashboard web
- **Claude (Anthropic)** — Geração de conteúdo inteligente
- **Tweepy** — Integração com Twitter/X API
- **APScheduler** — Agendamento diário automático
- **SQLite** — Armazenamento local dos posts

## Setup

### 1. Instalar dependências

```bash
cd ai-twitter-marketing-agent
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
# Edite o .env com suas credenciais
```

Você precisa de:
- **Twitter API keys** — Crie um app em [developer.twitter.com](https://developer.twitter.com)
- **Anthropic API key** — Obtenha em [console.anthropic.com](https://console.anthropic.com)

### 3. Executar

```bash
python main.py
```

Acesse o dashboard em `http://localhost:8000`

## Funcionalidades

- **Geração automática de tweets** usando Claude AI
- **Postagem diária agendada** (horário configurável via `.env`)
- **Dashboard web** para acompanhar todos os posts
- **Botão "Postar Agora"** para postagem manual
- **Histórico completo** com status de cada post (publicado, falhou, pendente)

## Configuração do Agente

No arquivo `.env`, configure o perfil da marca:

| Variável | Descrição |
|---|---|
| `BRAND_NAME` | Nome da marca |
| `BRAND_DESCRIPTION` | Descrição do negócio |
| `BRAND_TONE` | Tom de voz (ex: profissional, divertido) |
| `BRAND_TOPICS` | Tópicos para os posts |
| `POST_HOUR` | Hora da postagem diária (0-23) |
| `POST_MINUTE` | Minuto da postagem diária (0-59) |
