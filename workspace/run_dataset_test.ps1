#requires -Version 5.1
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$source = 'C:\Users\LENOVO\Downloads\lettuce-detection.v1i.yolov8'
$dataset = Join-Path $PSScriptRoot 'lettuce-detection.v1i.yolov8'

Write-Host '=== Persiapan dan validasi dataset YOLOv8 ===' -ForegroundColor Cyan

if (-not (Test-Path $source)) {
    Write-Host "Dataset tidak ditemukan di: $source" -ForegroundColor Red
    Write-Host 'Periksa nama folder atau ubah variabel `$source pada script ini.'
    exit 1
}

if (-not (Test-Path $dataset)) {
    Write-Host 'Menyalin dataset ke workspace...' -ForegroundColor Yellow
    Copy-Item $source $dataset -Recurse
} else {
    Write-Host 'Dataset sudah tersedia, penyalinan dilewati.' -ForegroundColor Green
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host 'Python tidak ditemukan. Instal Python terlebih dahulu.' -ForegroundColor Red
    exit 1
}

Write-Host 'Memasang dependency validasi...' -ForegroundColor Yellow
python -m pip install pyyaml
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host 'Menjalankan validasi dataset...' -ForegroundColor Yellow
python (Join-Path $PSScriptRoot 'validate_dataset.py')
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Validasi gagal. Perbaiki error di atas sebelum training.' -ForegroundColor Red
    exit $LASTEXITCODE
}

$choice = Read-Host 'Lanjut training uji 3 epoch? (y/n)'
if ($choice -notmatch '^(y|ya)$') {
    Write-Host 'Selesai. Dataset valid dan siap untuk training.' -ForegroundColor Green
    exit 0
}

Write-Host 'Memasang Ultralytics...' -ForegroundColor Yellow
python -m pip install ultralytics
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

$dataYaml = Join-Path $dataset 'data.yaml'
Write-Host 'Memulai training uji...' -ForegroundColor Yellow
yolo detect train data="$dataYaml" model=yolov8n.pt epochs=3 imgsz=640 batch=4 name=lettuce_dataset_test
if ($LASTEXITCODE -ne 0) {
    Write-Host 'Training gagal. Periksa pesan error di atas.' -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host 'Training uji berhasil.' -ForegroundColor Green
Write-Host 'Model tersimpan di runs\detect\lettuce_dataset_test\weights\best.pt'
Write-Host 'Untuk prediksi, jalankan:'
Write-Host "yolo detect predict model=runs\detect\lettuce_dataset_test\weights\best.pt source=\"$(Join-Path $dataset 'test\images')\" save=True"
