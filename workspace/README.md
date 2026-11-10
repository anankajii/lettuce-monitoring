# Workspace Pengujian Dataset YOLOv8

Letakkan dataset berikut di folder ini:

```text
workspace/
└── lettuce-detection.v1i.yolov8/
    ├── data.yaml
    ├── train/
    │   ├── images/
    │   └── labels/
    ├── valid/
    │   ├── images/
    │   └── labels/
    └── test/
        ├── images/
        └── labels/
```

Sumber dataset:
`C:\Users\LENOVO\Downloads\lettuce-detection.v1i.yolov8`

Folder dataset sengaja tidak dimasukkan ke `assets` Flutter karena dataset training biasanya berukuran besar dan bukan aset runtime aplikasi.

## Menyalin dataset dengan PowerShell

Jalankan dari root project Flutter:

```powershell
Copy-Item "C:\Users\LENOVO\Downloads\lettuce-detection.v1i.yolov8" `
  -Destination ".\workspace\" -Recurse
```

## Pemeriksaan awal

Pastikan file berikut tersedia setelah penyalinan:

```text
workspace/lettuce-detection.v1i.yolov8/data.yaml
workspace/lettuce-detection.v1i.yolov8/train/images
workspace/lettuce-detection.v1i.yolov8/train/labels
```

Setelah folder disalin, minta bantuan untuk memeriksa `data.yaml`, pasangan gambar-label, dan integrasi model ke Flutter.
