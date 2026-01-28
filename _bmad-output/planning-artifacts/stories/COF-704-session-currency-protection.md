# COF-704: Session Currency Protection

**Epic**: Economy  
**Status**: ✅ DONE  
**Priority**: Critical  
**Fichier**: `scripts/autoload/save_manager.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** que les SC gagnés dans un run échoué soient restaurés,  
**Afin de** ne pas être pénalisé pour avoir essayé un niveau difficile.

---

## Description

Le système de session protège le joueur : les SC ne sont confirmés qu'à la victoire. En cas de défaite ou de quit, les SC reviennent au niveau du début de la session.

---

## Critères d'Acceptation

- [x] `start_session()` mémorise le SC actuel
- [x] Victoire → SC confirmés
- [x] Défaite → SC restaurés au début de session
- [x] Quit en combat → SC restaurés
- [x] Impossible de perdre de l'argent en jouant

---

## Implémentation

```gdscript
var _session_start_currency: int = 0
var _session_active: bool = false

func start_session() -> void:
    """Appelé au début d'un niveau de combat."""
    _session_start_currency = get_currency()
    _session_active = true
    print("[SaveManager] Session started with %d SC" % _session_start_currency)

func confirm_session() -> void:
    """Appelé à la victoire - les gains sont permanents."""
    _session_active = false
    print("[SaveManager] Session confirmed. Final: %d SC" % get_currency())

func restore_session_currency() -> void:
    """Appelé à la défaite ou quit - annule les gains de la session."""
    if _session_active:
        var lost_gains := get_currency() - _session_start_currency
        data["currency_sc"] = _session_start_currency
        _session_active = false
        currency_changed.emit(_session_start_currency)
        save_game()
        print("[SaveManager] Session currency restored. Lost %d SC gains" % lost_gains)

func is_session_active() -> bool:
    return _session_active
```

---

## Flow Complet

### Cas 1: Victoire

```
Joueur a 1000 SC
    │
    ▼
start_session() → session_start = 1000
    │
    ▼
Combat: tue 20 ennemis, termine 5 vagues
    │ add_currency() appelé pour chaque kill/vague
    │ currency = 1360
    │
    ▼
Victoire! add_currency(100) → currency = 1460
    │
    ▼
confirm_session() → session terminée
    │
    ▼
Joueur a maintenant 1460 SC ✅
```

### Cas 2: Défaite

```
Joueur a 1000 SC
    │
    ▼
start_session() → session_start = 1000
    │
    ▼
Combat: tue 15 ennemis, fait 3 vagues
    │ currency = 1195
    │
    ▼
Mort!
    │
    ▼
restore_session_currency() → currency = 1000
    │
    ▼
Joueur a toujours 1000 SC ✅
```

### Cas 3: Quit Volontaire

```
Joueur a 1000 SC
    │
    ▼
start_session() → session_start = 1000
    │
    ▼
Combat: tue 10 ennemis
    │ currency = 1080
    │
    ▼
Pause → "Main Menu" → Confirm Quit
    │
    ▼
restore_session_currency() → currency = 1000
    │
    ▼
Joueur a toujours 1000 SC ✅
```

---

## Intégration Combat

```gdscript
# Dans GameCombatScene

func _ready() -> void:
    SaveManager.start_session()
    # ... setup combat

func _on_victory() -> void:
    SaveManager.add_currency(LEVEL_VICTORY_REWARD)
    SaveManager.confirm_session()
    _show_victory_screen()

func _on_defeat() -> void:
    SaveManager.restore_session_currency()
    SaveManager.retry_level()  # Incrémente deaths
    _show_defeat_screen()

func _on_quit_to_menu_confirmed() -> void:
    SaveManager.restore_session_currency()
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
```

---

## Sécurité: Fermeture de l'App

```gdscript
# Dans SaveManager._notification()
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        if is_session_active():
            # L'app ferme pendant un combat
            restore_session_currency()
        save_game()
        get_tree().quit()
```

---

## Affichage dans le HUD

```gdscript
# Deux affichages distincts
func _update_hud_currency() -> void:
    # Currency gagnée ce run (provisoire)
    run_currency_label.text = "+%d SC" % (get_currency() - session_start)

    # Currency totale confirmée
    total_currency_label.text = "💰 %d SC" % session_start
```

---

## Tests de Validation

1. ✅ Victoire → SC confirmés définitivement
2. ✅ Défaite → SC restaurés exactement
3. ✅ Quit pause menu → SC restaurés
4. ✅ Fermer app en combat → SC restaurés
5. ✅ Impossible de descendre sous session_start

---

## Dépendances

- **Requiert**: SaveManager base (COF-401)
- **Utilisé par**: Combat, Pause Menu, Defeat/Victory screens
