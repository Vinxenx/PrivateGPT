param (
    [Parameter(Mandatory=$true)]
    [string]$ModelName,
    
    [Parameter(Mandatory=$false)]
    [switch]$PullModel = $false
)

# Überprüfen, ob das Modell bereits vorhanden ist
$configFile = "settings-$ModelName.yaml"
if (Test-Path $configFile) {
    Write-Host "Fehler: Konfigurationsdatei '$configFile' existiert bereits." -ForegroundColor Red
    exit 1
}

# Wenn gewünscht, das Modell aus Ollama abrufen
if ($PullModel) {
    Write-Host "Pulling Modell '$ModelName' von Ollama..." -ForegroundColor Yellow
    ollama pull $ModelName
    
    # Überprüfen, ob das Modell erfolgreich abgerufen wurde
    $modelExists = ollama list | Select-String -Pattern $ModelName
    if (-not $modelExists) {
        Write-Host "Fehler: Modell '$ModelName' konnte nicht von Ollama abgerufen werden." -ForegroundColor Red
        exit 1
    }
}

# Konfigurationsdatei aus Template erstellen
$templateContent = Get-Content -Path "settings-template.yaml" -Raw
$newContent = $templateContent -replace "MODELLNAME", $ModelName
$newContent | Set-Content -Path $configFile

# Modell zum switch_model.ps1 Skript hinzufügen
$switchScriptPath = "switch_model.ps1"
if (Test-Path $switchScriptPath) {
    $scriptContent = Get-Content -Path $switchScriptPath -Raw
    
    # Überprüfen ob das Modell bereits im Skript definiert ist
    if ($scriptContent -match [regex]::Escape("`"$ModelName`"")) {
        Write-Host "Modell '$ModelName' ist bereits im Switch-Skript definiert." -ForegroundColor Yellow
    } else {
        # Position zum Einfügen finden
        $modelsHashTable = $scriptContent -match '(\$availableModels\s*=\s*@\{.*?# Fügen Sie hier weitere Modelle hinzu)' | Select-Object -First 1
        if ($modelsHashTable) {
            $replacement = "`$1`n    `"$ModelName`" = `"$configFile`",  # Automatisch hinzugefügt"
            $scriptContent = $scriptContent -replace '(\$availableModels\s*=\s*@\{.*?# Fügen Sie hier weitere Modelle hinzu)', $replacement
            $scriptContent | Set-Content -Path $switchScriptPath
            Write-Host "Modell '$ModelName' erfolgreich zum Switch-Skript hinzugefügt." -ForegroundColor Green
        } else {
            Write-Host "Warnung: Konnte die Modelldeklaration im Switch-Skript nicht finden." -ForegroundColor Yellow
            Write-Host "Bitte fügen Sie das Modell manuell hinzu." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "Warnung: Switch-Skript nicht gefunden. Bitte erstellen Sie es und fügen Sie das Modell hinzu." -ForegroundColor Yellow
}

# Modell zur Dokumentation hinzufügen
$docsPath = "MODEL_MANAGEMENT.md"
if (Test-Path $docsPath) {
    $docsContent = Get-Content -Path $docsPath
    
    # Überprüfen ob das Modell bereits in der Dokumentation vorhanden ist
    $modelInDocs = $docsContent | Select-String -Pattern "^\| $ModelName\s+\|" | Select-Object -First 1
    if (-not $modelInDocs) {
        $tableHeader = $docsContent | Select-String -Pattern "^\| Modellname \|" | Select-Object -First 1
        if ($tableHeader) {
            $tableHeaderIndex = $docsContent.IndexOf($tableHeader)
            if ($tableHeaderIndex -ge 0) {
                $newLine = "| $ModelName | $configFile | Neues Modell |"
                $docsContent = $docsContent[0..($tableHeaderIndex+1)] + $newLine + $docsContent[($tableHeaderIndex+2)..($docsContent.Length-1)]
                $docsContent | Set-Content -Path $docsPath
                Write-Host "Modell '$ModelName' erfolgreich zur Dokumentation hinzugefügt." -ForegroundColor Green
            }
        } else {
            Write-Host "Warnung: Tabelle in der Dokumentation nicht gefunden." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Modell '$ModelName' ist bereits in der Dokumentation vorhanden." -ForegroundColor Yellow
    }
} else {
    Write-Host "Warnung: Dokumentationsdatei nicht gefunden." -ForegroundColor Yellow
}

Write-Host "Modell '$ModelName' wurde erfolgreich konfiguriert!" -ForegroundColor Green
Write-Host "Konfigurationsdatei: $configFile" -ForegroundColor Green
Write-Host "Sie können das Modell jetzt mit folgendem Befehl verwenden:" -ForegroundColor Cyan
Write-Host ".\switch_model.ps1 -ModelName $ModelName" -ForegroundColor Cyan 