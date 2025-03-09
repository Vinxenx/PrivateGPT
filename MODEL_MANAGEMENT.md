# Modellverwaltung für PrivateGPT

Diese Dokumentation beschreibt, wie Sie mehrere Modelle in PrivateGPT verwalten können.

## Verfügbare Modelle

Aktuell sind folgende Modelle konfiguriert:

| Modellname | Konfigurationsdatei | Beschreibung             |
|------------|---------------------|--------------------------|
| deepseek   | settings-ollama.yaml | DeepSeek-Coder R1 (14B/32B) |
| qwq        | settings-qwq.yaml   | Qwen/QwQ-32B             |

## Neues Modell hinzufügen

Um ein neues Modell hinzuzufügen, folgen Sie diesen Schritten:

1. **Modell in Ollama installieren**:
   ```powershell
   ollama pull modellname
   ```

2. **Konfigurationsdatei erstellen**:
   Erstellen Sie eine neue Datei mit dem Namen `settings-modellname.yaml` im Stammverzeichnis des Projekts.
   Kopieren Sie den Inhalt einer bestehenden Konfigurationsdatei und passen Sie die relevanten Einstellungen an:
   
   ```yaml
   server:
     env_name: ${APP_ENV:modellname}
   
   llm:
     mode: ollama
     # weitere LLM-Einstellungen...
   
   ollama:
     llm_model: modellname
     # weitere Ollama-Einstellungen...
   ```

3. **Modell zum Switch-Skript hinzufügen**:
   Bearbeiten Sie `switch_model.ps1` und fügen Sie Ihr neues Modell zur `$availableModels`-Tabelle hinzu:
   
   ```powershell
   $availableModels = @{
       # bestehende Modelle...
       "modellname" = "settings-modellname.yaml"
   }
   ```

## Modell verwenden

Sie können ein Modell auf zwei Arten verwenden:

### 1. Mit dem Switch-Skript

Verwenden Sie das Switch-Skript, um zwischen Modellen zu wechseln:

```powershell
.\switch_model.ps1 -ModelName qwq
```

### 2. Manuell

Setzen Sie die Umgebungsvariable und starten Sie PrivateGPT:

```powershell
$env:PGPT_PROFILES="modellname"
poetry run python -m private_gpt
```

## Modell-Spezifische Einstellungen

Jedes Modell kann eigene Einstellungen haben, die seine Leistung optimieren:

### DeepSeek

DeepSeek funktioniert gut mit der Standardkonfiguration.

### QwQ

QwQ bietet gute Leistung für allgemeine Textgenerierung mit den folgenden Einstellungen:
- temperature: 0.1 (für faktenbasierte Antworten)
- context_window: 3900 (Standard-Kontextfenster)

## Fehlersuche

Wenn ein Modell nicht korrekt geladen wird:

1. Überprüfen Sie, ob das Modell in Ollama verfügbar ist: `ollama list`
2. Stellen Sie sicher, dass die Konfigurationsdatei den korrekten Modellnamen verwendet
3. Prüfen Sie die Logs auf spezifische Fehlermeldungen 