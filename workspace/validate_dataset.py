"""Validasi dasar dataset YOLOv8.

Jalankan dari root project:
    python workspace/validate_dataset.py
"""
from pathlib import Path
import sys
import yaml

ROOT = Path(__file__).parent / "lettuce-detection.v1i.yolov8"


def fail(message: str) -> None:
    print(f"[ERROR] {message}")


def main() -> int:
    if not ROOT.exists():
        fail(f"Dataset belum ditemukan: {ROOT}")
        print("Salin dataset dari folder Downloads ke workspace terlebih dahulu.")
        return 1

    yaml_path = ROOT / "data.yaml"
    if not yaml_path.exists():
        fail("data.yaml tidak ditemukan")
        return 1

    try:
        config = yaml.safe_load(yaml_path.read_text(encoding="utf-8")) or {}
    except Exception as exc:
        fail(f"data.yaml tidak valid: {exc}")
        return 1

    names = config.get("names", [])
    if isinstance(names, dict):
        names = list(names.values())
    if not isinstance(names, list) or not names:
        fail("names pada data.yaml kosong atau tidak valid")
        return 1

    print(f"Kelas ({len(names)}): {names}")
    errors = 0
    for split in ("train", "valid", "val", "test"):
        images = ROOT / split / "images"
        labels = ROOT / split / "labels"
        if not images.exists():
            continue
        image_files = [p for p in images.iterdir() if p.suffix.lower() in {".jpg", ".jpeg", ".png", ".bmp", ".webp"}]
        label_files = {p.stem for p in labels.glob("*.txt")} if labels.exists() else set()
        missing = [p.name for p in image_files if p.stem not in label_files]
        print(f"{split}: {len(image_files)} gambar, {len(label_files)} label")
        if missing:
            errors += len(missing)
            print(f"  [ERROR] Gambar tanpa label: {missing[:5]}")

        for label in labels.glob("*.txt") if labels.exists() else []:
            for line_no, line in enumerate(label.read_text(encoding="utf-8").splitlines(), 1):
                parts = line.split()
                if len(parts) != 5:
                    errors += 1
                    print(f"  [ERROR] Format {label.name}:{line_no} harus 5 nilai")
                    continue
                try:
                    class_id = int(parts[0])
                    values = [float(value) for value in parts[1:]]
                    if not 0 <= class_id < len(names) or any(not 0 <= value <= 1 for value in values):
                        raise ValueError
                except ValueError:
                    errors += 1
                    print(f"  [ERROR] Nilai label tidak valid: {label.name}:{line_no}")

    if errors:
        print(f"Validasi selesai dengan {errors} error.")
        return 1
    print("Validasi dasar berhasil.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
