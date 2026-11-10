import os
import json
from openai import OpenAI

# 1. Inisialisasi Klien OpenAI dengan Endpoint & API Key 9Router Anda
client = OpenAI(
    api_key="sk-197d7847bef72cde-s0329i-60f82c59", 
    base_url="http://localhost:20128/v1"
)

# ---------------------------------------------------------
# FUNGSI-FUNGSI UTAMA (TOOLS) UNTUK MANIPULASI FAIL
# ---------------------------------------------------------

def list_files(directory="."):
    """Melihat senarai fail dan folder dalam projek"""
    try:
        files_list = []
        for root, dirs, files in os.walk(directory):
            # Abaikan folder berat/sistem supaya tidak membebankan
            dirs[:] = [d for d in dirs if d not in ['.git', '.dart_tool', 'build', 'node_modules', '__pycache__']]
            for file in files:
                files_list.append(os.path.relpath(os.path.join(root, file), directory))
        return json.dumps(files_list[:50]) # Hadkan maksimum 50 fail
    except Exception as e:
        return f"Error: {e}"

def read_file(filepath):
    """Membaca isi kandungan sesebuah fail"""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            return f.read()
    except Exception as e:
        return f"Gagal membaca fail {filepath}: {e}"

def write_file(filepath, content):
    """Membuat fail baharu atau mengubah/kemaskini kod dalam fail sedia ada"""
    try:
        folder = os.path.dirname(filepath)
        if folder:
            os.makedirs(folder, exist_ok=True)
        with open(filepath, "w", encoding="utf-8") as f:
            f.write(content)
        return f"Berjaya mengubah/menulis fail: {filepath}"
    except Exception as e:
        return f"Gagal menulis ke fail {filepath}: {e}"

# Pemetaan nama fungsi
available_tools = {
    "list_files": list_files,
    "read_file": read_file,
    "write_file": write_file,
}

# Skema Tools untuk diserahkan kepada AI Model
tools_schema = [
    {
        "type": "function",
        "function": {
            "name": "list_files",
            "description": "Melihat senarai fail dalam projek.",
            "parameters": {"type": "object", "properties": {}, "required": []}
        }
    },
    {
        "type": "function",
        "function": {
            "name": "read_file",
            "description": "Membaca kod atau kandungan dari fail tertentu.",
            "parameters": {
                "type": "object",
                "properties": {
                    "filepath": {"type": "string", "description": "Laluan (path) fail, contohnya 'lib/main.dart'"}
                },
                "required": ["filepath"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "write_file",
            "description": "Menulis atau mengubah kod di dalam fail.",
            "parameters": {
                "type": "object",
                "properties": {
                    "filepath": {"type": "string", "description": "Laluan fail yang hendak diubah/dicipta"},
                    "content": {"type": "string", "description": "Kandungan kod baharu yang lengkap"}
                },
                "required": ["filepath", "content"]
            }
        }
    }
]

# ---------------------------------------------------------
# SIKLUS UTAMA PERCAKAPAN & EKSEKUSI AGENT
# ---------------------------------------------------------

def run_agent():
    print("=== AGENT AI CODING (BOLEH BACA & UBAH FAIL) ===")
    print("Taip 'exit' atau 'keluar' untuk berhenti.\n")

    messages = [
        {
            "role": "system",
            "content": (
                "Anda adalah Agent AI Pengaturcara. Anda mempunyai akses kepada tools "
                "untuk melihat struktur fail (list_files), membaca fail (read_file), dan menulis/mengubah fail (write_file). "
                "Gunakan tools tersebut secara automatik apabila diminta membaca atau mengubah kod projek."
            )
        }
    ]

    while True:
        user_input = input("\nAnda: ")
        if user_input.lower() in ["exit", "keluar"]:
            break
        if not user_input.strip():
            continue

        messages.append({"role": "user", "content": user_input})

        # Gelung interaksi dengan AI (Termasuk penggunaan tool)
        while True:
            try:
                response = client.chat.completions.create(
                    model="cx/codex-auto-review",  # Menggunakan model anda
                    messages=messages,
                    tools=tools_schema,
                    tool_choice="auto"
                )

                response_message = response.choices[0].message
                messages.append(response_message)

                # Semak sekiranya AI meminta untuk menggunakan sebarang Tool
                if response_message.tool_calls:
                    for tool_call in response_message.tool_calls:
                        func_name = tool_call.function.name
                        func_args = json.loads(tool_call.function.arguments)

                        print(f" -> [Agent Melaksanakan Tool]: {func_name}({func_args})")
                        
                        tool_output = available_tools[func_name](**func_args)

                        # Hantar semula hasil pembacaan/penulisan fail kepada AI
                        messages.append({
                            "tool_call_id": tool_call.id,
                            "role": "tool",
                            "name": func_name,
                            "content": str(tool_output),
                        })
                else:
                    # AI selesai berfikir & memberikan jawapan akhir
                    print(f"\nHermes Agent: {response_message.content}")
                    break

            except Exception as e:
                print(f"\n[Ralat]: {e}")
                break

if __name__ == "__main__":
    run_agent()