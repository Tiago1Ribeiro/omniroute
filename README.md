# OmniRoute

**OmniRoute** é um proxy de API que roda localmente no **Windows** e unifica múltiplos providers de IA (Groq, OpenRouter, etc.) num único endpoint compatível com OpenAI, **VS Code Copilot** e Ollama.

> 🎯 **Para que serve?**  
> Em vez de configurares cada ferramenta (VS Code Copilot, OpenAI clients, etc.) com endpoints e chaves diferentes, apontas tudo para `http://localhost:20128/v1` e o OmniRoute encaminha para o melhor modelo disponível.  
> 
> Isto permite usar o **GitHub Copilot no VS Code** com modelos como Llama, DeepSeek, Mistral ou GPT através de providers como Groq ou OpenRouter — tudo sem precisar de subscrição do GitHub Copilot.

## 🚀 Setup rápido (Windows + VS Code)

```powershell
# 1. Clonar e configurar
git clone https://github.com/Tiago1Ribeiro/omniroute.git
cd omniroute
cp .env.example .env
# Editar .env com as tuas chaves de API

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
| `OMNIROUTER_API_KEY` | Chave local de autenticação |

### VS Code Copilot

1. O VS Code lê a API key da variável de ambiente `OMNIROUTER_API_KEY` (definida no `.env`)
2. Abrir o VS Code — o Copilot usa automaticamente o OmniRoute como provider

> 💡 O ficheiro `.vscode/settings.json` com a configuração do provider já existe no projeto (está no `.gitignore` por conter caminhos locais).

### Noutro laptop Windows

```powershell
git clone https://github.com/Tiago1Ribeiro/omniroute.git
cd omniroute
cp .env.example .env
# Preencher as mesmas chaves de API
.\start-omniroute.ps1
```

Tudo funciona sem alterar paths — os scripts usam `$PSScriptRoot` (diretório relativo).

## 📁 Estrutura

```
📦 omni-route
├── start-omniroute.ps1     # 🚀 Servidor persistente com auto-restart
├── test-omniroute.ps1      # ✅ Testes aos endpoints da API
├── .env                    # 🔑 API keys (NÃO comitar)
├── .env.example            # 📋 Template das variáveis de ambiente
├── .gitignore              # 🙈 Ficheiros ignorados
├── README.md               # 📖 Documentação
├── models.json             # ⚙️ Catálogo de modelos (gerado, ignorado)
├── cookies.txt             # 📝 Ficheiro local (ignorado)
└── .vscode/
    └── settings.json        # ⚙️ Config local do VS Code (ignorado)
```

## ⚡ Endpoints

| Endpoint | Descrição |
|---|---|
| `POST /v1/chat/completions` | Chat completions (OpenAI-compatível) |
| `POST /v1/responses` | Responses API |
| `POST /v1/completions` | Legacy completions |
| `GET /v1/models` | Listar modelos |

## 📋 Notas

- Desenvolvido para **Windows + VS Code**
- O servidor corre na porta `20128` por omissão
- `start-omniroute.ps1` faz auto-restart se o servidor crashar (até 10 tentativas)
- `models.json` é gerado pelo OmniRoute — não editar manualmente
- Seguro para commit: `.env`, `cookies.txt`, `models.json` e `.vscode/settings.json` estão no `.gitignore` — as chaves de API nunca saem da tua máquina
