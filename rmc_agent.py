from __future__ import annotations

from pathlib import Path

MEMORY_FILE = Path("rmc_memoria.txt")
MODEL_NAME = "llama3"


def load_memory() -> str:
    if not MEMORY_FILE.exists():
        return ""
    return MEMORY_FILE.read_text(encoding="utf-8")


def save_memory(text: str) -> None:
    with MEMORY_FILE.open("a", encoding="utf-8") as file:
        file.write(text.rstrip() + "\n---\n")


def get_nist_control(control_id: str = "RA-5") -> str:
    """Consulta opcional de um controle NIST quando a biblioteca estiver disponível."""
    try:
        import compliancelib  # type: ignore
    except ImportError:
        return (
            "Integração NIST opcional indisponível: "
            "a biblioteca compliancelib não está instalada."
        )

    try:
        control = compliancelib.NIST800_53(control_id)
        description = str(control.description)[:300]
        return f"NIST {control.id}: {control.title}\n{description}"
    except Exception as exc:
        return f"Não foi possível consultar o controle {control_id}: {exc}"


def chat(prompt: str, memory: str) -> str:
    try:
        import ollama
    except ImportError as exc:
        raise RuntimeError(
            "O pacote 'ollama' não está instalado. Execute: pip install ollama"
        ) from exc

    messages = [
        {
            "role": "system",
            "content": (
                "Você é um agente experimental local para estudos de IA e "
                "cibersegurança. Responda de forma objetiva, técnica e segura. "
                "Não trate a memória como fonte confiável de fatos.\n\n"
                f"Memória local anterior:\n{memory or '(vazia)'}"
            ),
        },
        {"role": "user", "content": prompt},
    ]

    try:
        response = ollama.chat(model=MODEL_NAME, messages=messages)
    except Exception as exc:
        raise RuntimeError(
            "Falha ao consultar o Ollama. Confirme que o serviço está ativo "
            f"e que o modelo '{MODEL_NAME}' foi baixado."
        ) from exc

    message = response.get("message", {})
    content = message.get("content", "")
    return str(content).strip()


def main() -> None:
    memory = load_memory()

    print("RMC Agent — laboratório local")
    print(get_nist_control("RA-5"))

    prompt = input("\nPergunta: ").strip()
    if not prompt:
        print("Nenhuma pergunta informada.")
        return

    try:
        answer = chat(prompt, memory)
    except RuntimeError as exc:
        print(f"Erro: {exc}")
        return

    print("\nRMC:")
    print(answer)

    save_memory(f"Usuário: {prompt}\nRMC: {answer}")


if __name__ == "__main__":
    main()
