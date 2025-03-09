param (
    [Parameter(Mandatory=$true)]
    [string]$ModelName
)

# Verfügbare Modelle und ihre Konfigurationsdateien
$availableModels = @{
    "deepseek" = "settings-ollama.yaml"  # Die ursprüngliche Datei verwendet deepseek
    "qwq" = "settings-qwq.yaml"
    # Fügen Sie hier weitere Modelle hinzu
}

# Prüfen, ob das angeforderte Modell verfügbar ist
if (-not $availableModels.ContainsKey($ModelName)) {
    Write-Host "Fehler: Modell '$ModelName' ist nicht verfügbar." -ForegroundColor Red
    Write-Host "Verfügbare Modelle: $($availableModels.Keys -join ', ')" -ForegroundColor Yellow
    exit 1
}

# Konfigurationsdatei für das gewählte Modell
$configFile = $availableModels[$ModelName]

# PrivateGPT mit dem ausgewählten Modell starten
Write-Host "Starte PrivateGPT mit Modell: $ModelName (Konfiguration: $configFile)" -ForegroundColor Green
$env:PGPT_PROFILES = $ModelName
poetry run python -m private_gpt

# Hinweis: Dieses Skript setzt voraus, dass jedes Modell einen Profilnamen hat, der dem Modellnamen entspricht
# z.B. für 'qwq' sollte die Umgebungsvariable PGPT_PROFILES auf 'qwq' gesetzt werden 