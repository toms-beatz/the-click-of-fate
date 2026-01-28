# COF-803: Combat Constants Configuration

**Epic**: Data Structures  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: Divers fichiers de configuration

---

## User Story

**En tant que** développeur,  
**Je veux** toutes les constantes de combat centralisées,  
**Afin de** facilement balancer le jeu.

---

## Description

Toutes les valeurs numériques importantes du jeu sont définies comme constantes dans des fichiers dédiés, facilitant le tuning sans chercher dans le code.

---

## Critères d'Acceptation

- [x] Constantes du héros centralisées
- [x] Constantes de pression centralisées
- [x] Constantes de récompenses centralisées
- [x] Constantes de combat centralisées
- [x] Documentation des valeurs

---

## Constantes du Héros

```gdscript
# hero_constants.gd ou dans alien_hero.gd

const HERO_BASE_HP := 150
const HERO_BASE_DAMAGE := 10
const HERO_BASE_HEAL := 8
const HERO_BASE_DODGE_CHANCE := 5  # 5%

const HEAL_PERCENT := 13  # % des HP max soignés par action
const DODGE_DURATION := 0.5  # Secondes d'invincibilité

const HP_PER_UPGRADE := 15
const ATK_PER_UPGRADE := 2
const DODGE_PER_UPGRADE := 2
const HEAL_PER_UPGRADE := 2
```

---

## Constantes de Pression

```gdscript
# pressure_constants.gd ou dans pressure_gauge.gd

const MAX_PRESSURE := 100.0
const OVERLOAD_THRESHOLD := 80.0  # 80%
const PRESSURE_DECAY := 5.0  # Points par seconde
```

- **Utilisé par**: Tous les systèmes du jeu- **Requiert**: Rien## Dépendances---5. ✅ Facile à modifier pour balancing4. ✅ Valeurs documentées ou auto-documentées3. ✅ Constantes utilisées partout où applicable2. ✅ Pas de magic numbers dans le code1. ✅ Toutes les constantes ont des noms explicites## Tests de Validation---5. **Type safety**: Constantes typées4. **Centralisation**: Tout au même endroit3. **Pas de magic numbers**: Code plus lisible2. **Documentation implicite**: Le nom de la constante explique son usage1. **Balancing facile**: Modifier une valeur, tester, itérer## Avantages---`heal_amount = max_hp * (HEAL_PERCENT / 100.0)  # Clair!# On utilise:heal_amount = max_hp * 0.13  # Magic number!# Au lieu de:if pressure >= OVERLOAD_THRESHOLD:  # Clair!# On utilise:if pressure >= 80:  # Magic number!# Au lieu de:`gdscript## Utilisation---| Combat | TIME_BETWEEN_WAVES | 3s | Pause entre vagues || Economy | WAVE_COMPLETE_REWARD | 25 SC | Par vague || Economy | ENEMY_KILL_REWARD | 8 SC | Par kill || Pressure | PRESSURE_DECAY | 5/s | Déclin par seconde || Pressure | OVERLOAD_THRESHOLD | 80% | Seuil d'overload || Pressure | MAX_PRESSURE | 100 | Jauge max || Hero | HEAL_PERCENT | 13% | Soin par action || Hero | HERO_BASE_HP | 150 | PV de base ||-----------|-----------|--------|-------------|| Catégorie | Constante | Valeur | Description |## Tableau Récapitulatif---`const CINEMATIC_SLIDE_DURATION := 0.15  # Transition fadeconst CLICK_ZONE_HEIGHT := 120const HP_BAR_HEIGHT := 8const HP_BAR_WIDTH := 60const FLOATING_TEXT_DISTANCE := 50   # Pixels vers le hautconst FLOATING_TEXT_DURATION := 0.8  # Secondes# ui_constants.gd`gdscript## Constantes d'Interface---`const HIT_FLASH_DURATION := 0.1const ATTACK_ANIMATION_TIME := 0.3const BOSS_SPAWN_DELAY := 2.0    # Secondes après la dernière vagueconst TIME_BETWEEN_WAVES := 3.0  # Secondesconst ENEMY_DESPAWN_Y := 1350 # Y où les ennemis sont détruitsconst ENEMY_SPAWN_Y := -50    # Y spawn des ennemis (hors écran)const HERO_Y_POSITION := 900  # Position Y du héros# combat_constants.gd ou dans combat_manager.gd`gdscript## Constantes de Combat---`}    "heal_power": 1.5,    "dodge_chance": 1.7,    "attack_power": 1.6,    "max_hp": 1.5,const UPGRADE_COST_MULTIPLIERS := {}    "heal_power": 60,    "dodge_chance": 100,    "attack_power": 75,    "max_hp": 50,const UPGRADE_BASE_COSTS := {}    "heal_power": 20,    "dodge_chance": 15,    "attack_power": 20,    "max_hp": 20,const UPGRADE_MAX_LEVELS := {# upgrade_constants.gd ou dans profile_menu.gd`gdscript## Constantes d'Upgrades---`const EQUIPMENT_POWER_MULTIPLIER := 1  # Chaque point de stat = 1 power# Pour le shopconst BOSS_KILL_REWARD := 100     # SC pour boss (inclus dans victoire)const WAVE_COMPLETE_REWARD := 25  # SC par vague terminéeconst ENEMY_KILL_REWARD := 8      # SC par kill# economy_constants.gd ou dans save_manager.gd`gdscript## Constantes de Récompenses---```const OVERLOAD_COOLDOWN_MULTIPLIER := 2.0 # Cooldown × 2const OVERLOAD_PENALTY_MULTIPLIER := 1.5 # Coûts × 1.5# Pénalité d'overloadconst ATTACK_PRESSURE_COST := 10.0const DODGE_PRESSURE_COST := 15.0const HEAL_PRESSURE_COST := 20.0# Coûts par action
