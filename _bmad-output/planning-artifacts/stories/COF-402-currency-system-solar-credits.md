# COF-402: Currency System Solar Credits

**Epic**: Save & Persistence  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scripts/autoload/save_manager.gd` (lignes 194-237)

---

## User Story

**En tant que** joueur,  
**Je veux** un système de monnaie (Solar Credits),  
**Afin d'** acheter des améliorations et équipements.

---

## Description

Les Solar Credits (SC) sont la monnaie du jeu, gagnée en tuant des ennemis et en terminant des vagues. Le système gère aussi les sessions pour permettre le retry sans perte.

---

## Critères d'Acceptation

- [x] Méthodes de gestion :
  - `get_currency()` → int
  - `add_currency(amount)` → void
  - `spend_currency(amount)` → bool
  - `can_afford(amount)` → bool
- [x] Session tracking pour retry :
  - `start_session()` - Marque le début d'une partie
  - `restore_session_currency()` - Annule les gains de la session
- [x] Signal `currency_changed(new_amount)` à chaque modification
- [x] Statistique `total_currency_earned` mise à jour

---

## Implémentation

```gdscript
var _session_start_currency: int = 0

func start_session() -> void:
    _session_start_currency = get_currency()
    print("[SaveManager] Session started with %d SC" % _session_start_currency)

func get_currency() -> int:
    return data.get("currency_sc", 0)

func add_currency(amount: int) -> void:
    data["currency_sc"] = get_currency() + amount
    data["statistics"]["total_currency_earned"] += amount
    currency_changed.emit(get_currency())
    save_game()

func spend_currency(amount: int) -> bool:
    if get_currency() < amount:
        return false
    data["currency_sc"] = get_currency() - amount
    currency_changed.emit(get_currency())
    save_game()
    return true

func can_afford(amount: int) -> bool:
    return get_currency() >= amount

func restore_session_currency() -> void:
    data["currency_sc"] = _session_start_currency
    currency_changed.emit(_session_start_currency)
    save_game()
    print("[SaveManager] Currency restored to session start: %d SC" % _session_start_currency)
```

---

## Flow de Session

### Victoire

```
start_session() → currency = 100
    │
    ▼
kill enemies → add_currency(40)
    │
    ▼
victory → currency = 140 (gardé!)
```

### Défaite + Retry

```
start_session() → currency = 100, session_start = 100
    │
    ▼
kill enemies → add_currency(40) → currency = 140
    │
    ▼
defeat → restore_session_currency()
    │
    ▼
currency = 100 (restauré)
```

---

## Récompenses SC

| Action          | Récompense           |
| --------------- | -------------------- |
| Kill ennemi     | +8 SC                |
| Vague terminée  | +25 SC               |
| Victoire niveau | +100 SC              |
| Boss vaincu     | Inclus dans victoire |

---

## Tests de Validation

1. ✅ Tuer ennemi → +8 SC
2. ✅ Acheter item 50 SC → currency diminue
3. ✅ Pas assez de SC → `spend_currency()` retourne false
4. ✅ Retry → currency restauré au début de session
5. ✅ Signal `currency_changed` émis à chaque modification

---

## Dépendances

- **Requiert**: SaveManager structure (COF-401)
- **Utilisé par**: Shop, Profile, Combat rewards
