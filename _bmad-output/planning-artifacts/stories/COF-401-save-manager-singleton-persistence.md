# COF-401: Save Manager Singleton Persistence

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/autoload/save_manager.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** que ma progression soit sauvegardée automatiquement,  
**Afin de** reprendre où j'en étais à chaque session.

---

## Description

`SaveManager` est un Singleton (Autoload) qui gère toute la persistance du jeu : monnaie, progression, upgrades, équipement, statistiques et paramètres.

---

## Critères d'Acceptation

- [x] Autoload singleton accessible via `SaveManager`
- [x] Sauvegarde JSON dans `user://save_data.json`
- [x] Backup automatique dans `user://save_data.backup.json`
- [x] Version de format pour migrations futures (`SAVE_VERSION = 1`)
- [x] Sauvegarde automatique à la fermeture de l'app
- [x] Signaux :
  - `save_completed()`
  - `load_completed()`
  - `save_error(message: String)`
  - `currency_changed(new_amount: int)`
  - `progression_changed()`

---

## Implémentation

```gdscript
extends Node

const SAVE_PATH := "user://save_data.json"
const BACKUP_PATH := "user://save_data.backup.json"
const SAVE_VERSION := 1

var data: Dictionary = {}
var is_loaded: bool = false

func _ready() -> void:
    _initialize_default_data()
    load_game()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
        save_game()
```

---

## Structure de Données

```gdscript
data = {
    "version": 1,
    "currency_sc": 0,
    "current_planet": 0,
    "current_wave": 0,
    "highest_planet_completed": -1,
    "unlocked_skills": [],
    "unlocked_companions": [],
    "upgrades": {
        "heal_power": 0,
        "max_hp": 0,
        "dodge_chance": 0,
        "attack_power": 0
    },
    "equipment": {
        "weapon": "",
        "armor": "",
        "helmet": ""
    },
    "owned_equipment": [],
    "boosters": [],
    "statistics": {
        "total_kills": 0,
        "total_deaths": 0,
        "bosses_defeated": [],
        "play_time_seconds": 0,
        "total_currency_earned": 0
    },
    "settings": {
        "music_volume": 0.8,
        "sfx_volume": 1.0,
        "vibration_enabled": true
    }
}
```

---

## Gestion des Backups

```gdscript
func save_game() -> void:
    # Créer backup d'abord
    if FileAccess.file_exists(SAVE_PATH):
        var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
        if backup:
            var original := FileAccess.open(SAVE_PATH, FileAccess.READ)
            if original:
                backup.store_string(original.get_as_text())
                original.close()
            backup.close()

    # Sauvegarder nouvelles données
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
    save_completed.emit()
```

---

## Chargement avec Fallback

```gdscript
func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        is_loaded = true
        load_completed.emit()
        return

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var json := JSON.new()

    if json.parse(file.get_as_text()) != OK:
        # Fichier corrompu, essayer backup
        _load_from_backup()
        return

    _merge_save_data(json.data)
    is_loaded = true
    load_completed.emit()
```

---

## Tests de Validation

1. ✅ Premier lancement → données par défaut
2. ✅ Modifier currency → sauvegarde automatique
3. ✅ Fermer app → save_game() appelé
4. ✅ Fichier corrompu → backup restauré
5. ✅ `SaveManager.get_currency()` accessible partout

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: Tous les menus et systèmes de jeu
