# Claude Projects

<p align="center">
  <strong>Projetos de IA desenvolvidos com Claude (Anthropic) — agentes de marketing e aplicativo mobile.</strong>
</p>

---

## Projetos

### `ai-twitter-marketing-agent` — Agente de Marketing para Redes Sociais

Agente autônomo que gera e publica conteúdo de marketing em múltiplas redes sociais usando IA.

**Stack:** Python · FastAPI · Claude API · SQLite · APScheduler

**Funcionalidades:**
- Geração de posts com Claude (Anthropic)
- Publicação automática no Twitter/X, LinkedIn e Bluesky
- Integração com Google Trends BR para conteúdo baseado em tendências
- Dashboard web para monitorar e gerenciar posts
- Agendamento diário configurável
- Botão "Gerar Conteúdo" com preview antes de publicar

**Rodar:**
```bash
cd ai-twitter-marketing-agent
pip install -r requirements.txt
cp .env.example .env   # configure suas chaves
cp accounts.json.example accounts.json
python main.py
```
Dashboard: `http://localhost:8000`

---

### `cuidado-integrado` — App Mobile de Saúde

Aplicativo Flutter para gestão de cuidados integrados de saúde.

**Stack:** Flutter · Dart

**Telas:**
- Landing / Onboarding
- Login e Registro
- Home
- Perfil

**Rodar:**
```bash
cd cuidado-integrado
flutter pub get
flutter run
```

---

## Licença

MIT
