# RMC Agent

Experimento local em Python para estudar agentes conversacionais com **memória persistente**, execução via **Ollama** e consultas opcionais a controles de segurança.

> Status: laboratório educacional. Não é um agente autônomo de produção.

## Objetivos

- praticar integração com modelos locais;
- persistir contexto textual de forma simples;
- organizar tratamento de erros;
- estudar integração de referências de segurança e compliance;
- evoluir posteriormente para armazenamento estruturado, testes e observabilidade.

## Requisitos

- Python 3.11 ou superior;
- Ollama instalado e em execução;
- um modelo disponível localmente, por exemplo `llama3`.

## Instalação

```bash
python -m venv .venv
source .venv/bin/activate
pip install ollama
```

No Windows PowerShell:

```powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install ollama
```

Baixe o modelo:

```bash
ollama pull llama3
```

## Execução

```bash
python rmc_agent.py
```

## Estrutura

```text
rmc_agent.py     agente experimental
rmc_memoria.txt  memória local gerada em runtime; não versionada
README.md        documentação
```

## Segurança e privacidade

- não inserir dados pessoais, institucionais ou sigilosos na memória de laboratório;
- `rmc_memoria.txt` permanece fora do Git;
- o projeto não executa ações externas automaticamente;
- erros de dependência/modelo são tratados sem expor credenciais;
- qualquer futura integração com APIs deve usar variáveis de ambiente.

## Limitações atuais

A memória é um arquivo texto simples e cresce indefinidamente. Isso é adequado apenas para laboratório. Uma evolução real deve usar armazenamento estruturado, política de retenção, limites de contexto e testes.

## Roadmap

- [ ] testes unitários;
- [ ] memória estruturada;
- [ ] sumarização de histórico;
- [ ] configuração por arquivo/variáveis de ambiente;
- [ ] logging estruturado;
- [ ] abstração de provedores de modelo;
- [ ] CI.
