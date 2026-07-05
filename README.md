# OmniRoute

Proxy de API que unifica múltiplos providers de IA (Groq, OpenRouter, etc.) num único endpoint compatível com OpenAI, VS Code Copilot e Ollama.

## 🚀 Setup rápido

```powershell
# 1. Configurar API keys
cp .env.example .env
# Editar .env com as tuas chaves

# 2. Iniciar servidor
.\start-omniroute.ps1

# 3. Testar endpoints
.\test-omniroute.ps1
```

## 🔧 Configuração

### Variáveis de ambiente (`.env`)

| Variável | Descrição |
|---|---|
| `GROQ_API_KEY` | Provider primário (mais rápido) |
| `OPENROUTER_API_KEY` | Provider fallback (mais modelos) |
| `HS_API_KEY` | Hallucinating Splines API |
| `OMNIROUTER_API_KEY` | Chave local para o VS Code |

### VS Code Copilot

1. Copiar `.vscode/settings.json.example` para `.vscode/settings.json`
2. Garantir que a variável `OMNIROUTER_API_KEY` está definida no ambiente

## 📁 Estrutura

```
📦 omni-route
├── start-omniroute.ps1    # Servidor persistente com auto-restart
├── test-omniroute.ps1     # Suite de testes da API
├── generate_chat_models.py# Gera modelos para chat a partir de models.json
├── parse_models.py        # Análise dos modelos disponíveis
├── models.json            # Catálogo de modelos (gerado)
├── cookies.txt            # Ficheiro de cookies (local)
├── .env                   # API keys (NÃO comitar)
└── .vscode/
    └── settings.json      # Config VS Code (NÃO comitar)
```

## ⚡ Endpoints

| Endpoint | Descrição |
|---|---|
| `POST /v1/chat/completions` | Chat completions (OpenAI-compatível) |
| `POST /v1/responses` | Responses API |
| `POST /v1/completions` | Legacy completions |
| `GET /v1/models` | Listar modelos |

## 📋 Notas

- O servidor corre na porta `20128` por omissão
- `start-omniroute.ps1` faz auto-restart se o servidor crashar
- `models.json` é gerado pelo OmniRoute e não deve ser editado manualmente
