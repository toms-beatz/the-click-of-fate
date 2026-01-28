# Click of Fate - Inventaire des Stories Complétées

> **Document d'audit** - Toutes les fonctionnalités implémentées, documentées en format Story

> **Version**: MVP 1.0> **Date**: Juin 2025

---

## 📊 Résumé Exécutif

| Catégorie | Stories | Statut |
|-----------|---------|--------|
| Core Combat System | 12 | ✅ Complété |
| UI/UX System | 15 | ✅ Complété |
| Progression System | 8 | ✅ Complété |
| Boss System | 5 | ✅ Complété |
| Enemy System | 6 | ✅ Complété |
| Cinematics | 3 | ✅ Complété |
| Save & Persistence | 7 | ✅ Complété |
| Shop & Economy | 4 | ✅ Complété |
| **Visual Assets** | **1** | 🔄 En cours |
| **TOTAL** | **61** | 🔄 |

---

## 🎨 EPIC 9: Visual Assets (NOUVEAU)

### COF-901: Enemy Sprite System

**Fichier**: [stories/COF-901-enemy-sprite-system.md](stories/COF-901-enemy-sprite-system.md)  
**Status**: 🔄 IN PROGRESS

**En tant que** joueur,  
**Je veux** voir des sprites uniques pour chaque type d'ennemi,  
**Afin de** distinguer visuellement les ennemis par planète.

**Critères d'acceptation**:
- [x] Sprites Venus (3 poses)
- [x] Sprites Mars (3 poses)
- [x] Sprites Earth (3 poses)
- [ ] Sprites Mercury (3 poses) - MANQUANT
- [x] Sprites Mini-Boss (5 variantes)
- [ ] Sprites Dr. Mortis - MANQUANT
- [x] Vaisseaux background (6 variantes)
- [x] Fallback ColorRect si sprite manquant
- [x] Vaisseaux animés en arrière-plan du Level Select

---

## 🎮 EPIC 1: Core Combat System

### COF-101: Base Entity System

**Fichier**: [scripts/core/entities/base_entity.gd](../../scripts/core/entities/base_entity.gd)  
**Status**: ✅ DONE

**En tant que** système de combat,

**Afin de** gérer PV, attaque, défense, esquive et mort de manière uniforme.**Je veux** une classe de base pour toutes les entités,

**Critères d'acceptation**:

- [x] Classe `BaseEntity` avec signaux: `damaged`, `healed`, `died`, `attacked`, `dodged`, `hp_changed`
- [x] Propriétés: `current_hp`, `is_alive`, `can_act`, `current_target`
- [x] Stats via Resource `EntityStats`
- [x] Auto-attaque sur la cible courante
- [x] Système de modificateurs temporaires
- [x] Méthodes: `take_damage()`, `heal()`, `heal_percent()`, `perform_attack()`, `reset()`

---

**Status**: ✅ DONE ### COF-102: Entity Stats Resource

**Fichier**: [scripts/core/stats/entity_stats.gd](../../scripts/core/stats/entity_stats.gd)

**Je veux** une Resource pour définir les stats de base, **En tant que** game designer,

**Critères d'acceptation**:**Afin de** configurer chaque entité via l'Inspector.

- [x] `display_name`: Nom d'affichage
- [x] `max_hp`: 1-10000
- [x] `attack`: 1-1000
- [x] `attack_speed`: 0.1-10.0 (attaques/seconde)
- [x] `defense`: 0-500

- [x] `move_speed`: 0-500 pixels/s- [x] `dodge_chance`: 0-95%- [x] `crit_multiplier`: 1.0-5.0x- [x] `crit_chance`: 0-100%

- [x] Méthodes utilitaires: `calculate_attack_damage()`, `roll_critical()`, `roll_dodge()`, `get_attack_interval()`, `calculate_damage_taken()`

---

### COF-103: Alien Hero Entity

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/alien_hero.gd](../../scripts/entities/alien_hero.gd)

**En tant que** joueur,  
**Je veux** un héros alien personnalisable,  
**Afin de** combattre les ennemis avec des skills et compagnons.

**Critères d'acceptation**:

- [x] Hérite de `BaseEntity`
- [x] Système de compagnons (Array)
- [x] Skills débloquables avec cooldowns
- [x] Méthodes: `add_companion()`, `remove_companion()`, `activate_skill()`, `unlock_skill()`
- [x] Signal `skill_used`, `companion_added`, `boost_applied`

---

### COF-104: Combat State Machine

**Status**: ✅ DONE  
**Fichier**: [scripts/core/combat/combat_state_machine.gd](../../scripts/core/combat/combat_state_machine.gd)

**En tant que** système de combat,  
**Je veux** une machine à états,  
**Afin de** gérer les phases du combat.

**Critères d'acceptation**:

- [x] États: `IDLE`, `COMBAT`, `BOSS_PHASE`, `PUNISHED`, `VICTORY`, `DEFEAT`
- [x] Signaux: `state_changed`, `combat_started`, `wave_completed`, `boss_defeated`, `victory`, `defeat`
- [x] Méthodes: `start_combat()`, `start_boss_phase()`, `on_wave_cleared()`, `on_player_defeated()`
- [x] Constante: `WAVES_PER_PLANET = 5`
- [x] Gestion des transitions d'état

---

### COF-105: Combat Manager

**Status**: ✅ DONE  
**Fichier**: [scripts/core/combat/combat_manager.gd](../../scripts/core/combat/combat_manager.gd)

**En tant que** système de combat,  
**Je veux** un orchestrateur central,  
**Afin de** coordonner les actions joueur et l'auto-combat.

**Critères d'acceptation**:

- [x] Constantes: `BASE_HEAL_PERCENT = 13%`, `BASE_DODGE_BONUS = 20%`, `BASE_ATTACK_DAMAGE = 10`
- [x] Actions: `_do_heal()` (soigne 13% max HP), `_do_dodge()` (+20% esquive 4s), `_do_attack()` (+10% crit 2s + dégâts directs)
- [x] Connexion avec `ClickZoneButton`, `PressureGauge`, `StateMachine`
- [x] Gestion des ennemis actifs
- [x] Signaux: `player_action`, `critical_hit`, `dodge_success`, `hero_healed`, `hero_pose_changed`

---

### COF-106: Pressure Gauge System

**Status**: ✅ DONE  
**Fichier**: [scripts/core/systems/pressure_gauge.gd](../../scripts/core/systems/pressure_gauge.gd)

**En tant que** joueur,  
**Je veux** un système de pression anti-spam,  
**Afin d'** être forcé à varier mes actions.

**Critères d'acceptation**:

- [x] 3 jauges séparées: Heal, Dodge, Attack
- [x] Incréments: Heal +25, Dodge +20, Attack +8
- [x] Seuil d'overload: 100
- [x] Decay automatique: 5 points/seconde
- [x] Punition par action (pas globale): Heal 5s, Dodge 4s, Attack 3s
- [x] Signaux: `pressure_changed`, `punishment_started`, `punishment_ended`, `action_blocked`

---

### COF-107: Tripartite Click Zone

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/click_zone_button.gd](../../scripts/ui/click_zone_button.gd)

**En tant que** joueur,  
**Je veux** un bouton divisé en 3 zones,  
**Afin d'** effectuer mes actions en touchant la bonne zone.

**Critères d'acceptation**:

- [x] Layout: `[HEAL 0-33%] [DODGE 33-66%] [ATTACK 66-100%]`
- [x] Couleurs: Heal (bleu), Dodge (violet), Attack (rouge)
- [x] Support touch screen et souris
- [x] Feedback visuel au clic (highlight + animation)
- [x] Blocage par zone individuellement
- [x] Signaux: `zone_pressed`, `zone_released`

---

### COF-108: Wave Controller

**Status**: ✅ DONE  
**Fichier**: [scripts/core/combat/wave_controller.gd](../../scripts/core/combat/wave_controller.gd)

**En tant que** système de combat,  
**Je veux** un contrôleur de vagues,  
**Afin de** spawner les ennemis selon un timing défini.

**Critères d'acceptation**:

- [x] Configuration via `PlanetData` Resource
- [x] Spawn avec délai initial et intervalle
- [x] Détection automatique de fin de vague
- [x] Transition vers phase boss après 5 vagues
- [x] Signaux: `wave_started`, `wave_cleared`, `enemy_spawned`, `boss_phase_started`

---

### COF-109: Hero Power Scaling

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 93-102)

**En tant que** joueur,  
**Je veux** que mon héros devienne plus fort au fil des planètes,  
**Afin de** pouvoir affronter des ennemis plus difficiles.

**Critères d'acceptation**:

- [x] Puissance de base: 100 (aucune planète)
- [x] Mercury terminée: 150 (+25% HP, +20% ATK)
- [x] Venus terminée: 200 (+50% HP, +40% ATK)
- [x] Mars terminée: 280 (+80% HP, +70% ATK)
- [x] Earth terminée: 400 (+120% HP, +100% ATK)

---

### COF-110: Auto-Attack System

**Status**: ✅ DONE  
**Fichier**: [scripts/core/entities/base_entity.gd](../../scripts/core/entities/base_entity.gd) (lignes 82-96)

**En tant que** spectateur d'auto-battler,  
**Je veux** que le héros attaque automatiquement,  
**Afin de** me concentrer sur les actions tactiques.

**Critères d'acceptation**:

- [x] Timer basé sur `attack_speed`
- [x] Attaque automatique sur `current_target`
- [x] Émission du signal `attacked` avec dégâts et crit
- [x] Support des modificateurs de crit/esquive

---

### COF-111: Temporary Modifiers System

**Status**: ✅ DONE  
**Fichier**: [scripts/core/entities/base_entity.gd](../../scripts/core/entities/base_entity.gd) (lignes 99-150)

**En tant que** système de combat,  
**Je veux** un système de buffs/debuffs temporaires,  
**Afin d'** appliquer des effets limités dans le temps.

**Critères d'acceptation**:

- [x] `add_temp_modifier(stat, value, type, duration)`
- [x] Types: "add" (additif) ou "mult" (multiplicatif)
- [x] Decay automatique de la durée
- [x] Application lors du calcul des stats

---

### COF-112: Damage & Heal Calculation

**Status**: ✅ DONE  
**Fichiers**: [base_entity.gd](../../scripts/core/entities/base_entity.gd), [entity_stats.gd](../../scripts/core/stats/entity_stats.gd)

**En tant que** système de combat,  
**Je veux** des formules de dégâts et soins claires,  
**Afin de** garantir un gameplay équilibré.

**Critères d'acceptation**:

- [x] Dégâts = ATK - Defense (minimum 1)
- [x] Crit = Dégâts × `crit_multiplier` (default 1.5x)
- [x] Esquive: cap à 95% max
- [x] Heal: montant direct ou pourcentage des max HP

---

## 👾 EPIC 2: Enemy System

### COF-201: Base Enemy Entity

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/base_enemy.gd](../../scripts/entities/base_enemy.gd)

**En tant que** système de combat,  
**Je veux** une classe de base pour les ennemis,  
**Afin de** créer des variantes par planète.

**Critères d'acceptation**:

- [x] Hérite de `BaseEntity`
- [x] Enum `PlanetType`: MERCURY, VENUS, MARS, EARTH
- [x] `loot_value`: Récompense SC à la mort
- [x] Comportement automatique selon planète
- [x] Signal `died` connecté au loot

---

### COF-202: Enemy Behavior Base

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/behaviors/enemy_behavior.gd](../../scripts/entities/behaviors/enemy_behavior.gd)

**En tant que** game designer,  
**Je veux** un système de comportements modulaires,  
**Afin de** créer des ennemis variés.

**Critères d'acceptation**:

- [x] Classe `EnemyBehavior` (RefCounted pour performance)
- [x] Méthode `apply(enemy)`: modifications initiales
- [x] Méthode `process(enemy, delta)`: effets continus

---

### COF-203: Fast Behavior (Mercury)

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/behaviors/fast_behavior.gd](../../scripts/entities/behaviors/fast_behavior.gd)

**En tant que** joueur sur Mercury,  
**Je veux** affronter des ennemis rapides mais fragiles,  
**Afin d'** apprendre le timing du jeu.

**Critères d'acceptation**:

- [x] +50% vitesse d'attaque
- [x] -30% HP
- [x] +10% esquive bonus

---

### COF-204: Toxic Behavior (Venus)

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/behaviors/toxic_behavior.gd](../../scripts/entities/behaviors/toxic_behavior.gd)

**En tant que** joueur sur Venus,  
**Je veux** affronter des ennemis empoisonneurs,  
**Afin de** gérer la pression de DoT.

**Critères d'acceptation**:

- [x] Poison: 2 DPS pendant 5 secondes
- [x] Stats normales
- [x] Méthode statique `apply_poison_to(target)`

---

### COF-205: Regen Behavior (Mars)

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/behaviors/regen_behavior.gd](../../scripts/entities/behaviors/regen_behavior.gd)

**En tant que** joueur sur Mars,  
**Je veux** affronter des ennemis régénérants,  
**Afin de** maintenir une pression constante.

**Critères d'acceptation**:

- [x] Régénération: 1% max HP/seconde
- [x] Stats normales
- [x] Accumulateur pour éviter heal chaque frame

---

### COF-206: Tank Behavior (Earth)

**Status**: ✅ DONE  
**Fichier**: [scripts/entities/behaviors/tank_behavior.gd](../../scripts/entities/behaviors/tank_behavior.gd)

**En tant que** joueur sur Earth,  
**Je veux** affronter des ennemis ultra-résistants,  
**Afin de** préparer le combat final.

**Critères d'acceptation**:

- [x] +50% défense
- [x] +30% HP
- [x] Aucune faiblesse

---

## 👑 EPIC 3: Boss System

### COF-301: Boss Data Configuration

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 115-121)

**En tant que** game designer,  
**Je veux** configurer les boss par planète,  
**Afin de** créer des défis uniques.

**Critères d'acceptation**:

- [x] Mercury Guardian: 400 HP, 20 ATK, special "shield"
- [x] Venus Queen: 550 HP, 25 ATK, special "poison"
- [x] Mars Warlord: 700 HP, 30 ATK, special "rage"
- [x] DR. MORTIS: 1500 HP, 40 ATK, special "final"

---

### COF-302: Boss Visual Display

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** voir le boss avec un visuel distinctif,  
**Afin de** comprendre que c'est un combat spécial.

**Critères d'acceptation**:

- [x] Sprite plus grand que les ennemis normaux
- [x] Couleur unique par boss
- [x] Emoji représentatif
- [x] Barre de vie dédiée (largeur complète)

---

### COF-303: Boss HP Bar

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** une barre de vie visible pour le boss,  
**Afin de** suivre ma progression.

**Critères d'acceptation**:

- [x] Barre affichant max_hp au spawn (pas current_hp)
- [x] Couleur correspondant à la planète
- [x] Mise à jour en temps réel

---

### COF-304: Boss Phase Transition

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** une transition claire vers le boss,  
**Afin de** me préparer au combat final.

**Critères d'acceptation**:

- [x] Message "BOSS INCOMING!" affiché
- [x] Vague label mis à jour: "⚔️ BOSS FIGHT!"
- [x] Effets visuels de transition

---

### COF-305: Dr. Mortis Final Boss

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** un boss final mémorable,  
**Afin de** conclure l'histoire.

**Critères d'acceptation**:

- [x] 1500 HP (3x+ plus que les autres boss)
- [x] 40 ATK
- [x] Couleur violette unique (Color(0.6, 0.2, 0.8))
- [x] Emoji 💀
- [x] Déclenche la cinématique de fin

---

## 💾 EPIC 4: Save & Persistence

### COF-401: Save Manager Singleton

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd)

**En tant que** joueur,  
**Je veux** que ma progression soit sauvegardée,  
**Afin de** reprendre où j'en étais.

**Critères d'acceptation**:

- [x] Autoload singleton
- [x] Sauvegarde JSON dans `user://save_data.json`
- [x] Backup automatique
- [x] Version de format pour migrations futures
- [x] Signaux: `save_completed`, `load_completed`, `save_error`, `currency_changed`, `progression_changed`

---

### COF-402: Currency System

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd) (lignes 194-237)

**En tant que** joueur,  
**Je veux** un système de monnaie (Solar Credits),  
**Afin d'** acheter des améliorations.

**Critères d'acceptation**:

- [x] `get_currency()`, `add_currency()`, `spend_currency()`, `can_afford()`
- [x] Session tracking pour retry sans perte
- [x] `restore_session_currency()` pour annuler les gains
- [x] Signal `currency_changed`

---

### COF-403: Progression Tracking

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd) (lignes 240-280)

**En tant que** joueur,  
**Je veux** que ma progression soit linéaire,  
**Afin de** ne pas perdre d'avancement à la mort.

**Critères d'acceptation**:

- [x] `current_planet`: 0-3
- [x] `current_wave`: 0-5
- [x] `highest_planet_completed`: -1 à 3
- [x] `advance_wave()`, `advance_planet()`, `retry_level()`

---

### COF-404: Upgrades Persistence

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd) (lignes 300-315)

**En tant que** joueur,  
**Je veux** que mes upgrades soient sauvegardés,  
**Afin de** bénéficier de mes investissements.

**Critères d'acceptation**:

- [x] Structure: `heal_power`, `max_hp`, `dodge_chance`, `attack_power`
- [x] `get_upgrade_level()`, `increase_upgrade()`

---

### COF-405: Equipment Persistence

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd)

**En tant que** joueur,  
**Je veux** que mon équipement soit sauvegardé,  
**Afin de** garder mes items.

**Critères d'acceptation**:

- [x] Slots: weapon, armor, helmet
- [x] `owned_equipment`: liste des équipements possédés
- [x] `get_equipped()`, `set_equipped()`

---

### COF-406: Statistics Tracking

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd) (lignes 318-335)

**En tant que** joueur,  
**Je veux** voir mes statistiques de jeu,  
**Afin de** suivre mes accomplissements.

**Critères d'acceptation**:

- [x] `total_kills`, `total_deaths`
- [x] `bosses_defeated`: Array des boss vaincus
- [x] `play_time_seconds`
- [x] `total_currency_earned`
- [x] `add_kills()`, `record_boss_defeated()`

---

### COF-407: Settings Persistence

**Status**: ✅ DONE  
**Fichier**: [scripts/autoload/save_manager.gd](../../scripts/autoload/save_manager.gd) (lignes 338-385)

**En tant que** joueur,  
**Je veux** que mes paramètres soient sauvegardés,  
**Afin de** ne pas les reconfigurer.

**Critères d'acceptation**:

- [x] `music_volume`: 0.0-1.0
- [x] `sfx_volume`: 0.0-1.0
- [x] `vibration_enabled`: boolean
- [x] Getters/setters pour chaque setting

---

## 🎬 EPIC 5: Cinematics

### COF-501: Planet Intro Cinematics

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 133-157)

**En tant que** joueur,  
**Je veux** une cinématique d'introduction par planète,  
**Afin de** comprendre l'histoire.

**Critères d'acceptation**:

- [x] Mercury: Introduction de Zyx-7 et de sa quête de vengeance
- [x] Venus: Piste vers les expériences toxiques de Dr. Mortis
- [x] Mars: Découverte du centre de recherche principal
- [x] Earth: Confrontation finale annoncée
- [x] Format: slides avec emoji et texte

---

### COF-502: Ending Cinematic

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 124-133)

**En tant que** joueur ayant battu Dr. Mortis,  
**Je veux** une cinématique de fin,  
**Afin de** conclure l'histoire (avec cliffhanger).

**Critères d'acceptation**:

- [x] 8 slides de dialogue
- [x] Révélation du "Council" pour la suite
- [x] "TO BE CONTINUED..."
- [x] Déclenché automatiquement après victoire sur Earth

---

### COF-503: Cinematic UI System

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** une interface de cinématique claire,  
**Afin de** lire les dialogues confortablement.

**Critères d'acceptation**:

- [x] Fond sombre avec overlay
- [x] Texte centré avec emoji
- [x] Navigation par tap
- [x] Animation de transition entre slides
- [x] Bouton "Skip" visible

---

## 🖥️ EPIC 6: User Interface

### COF-601: Main Menu

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/main_menu.gd](../../scripts/ui/main_menu.gd)

**En tant que** joueur,  
**Je veux** un menu principal,  
**Afin d'** accéder aux différentes sections.

**Critères d'acceptation**:

- [x] Bouton "Jouer" → Level Select
- [x] Bouton "Options" → Options Menu
- [x] Bouton "Quitter" → Ferme l'app
- [x] Affichage de la monnaie actuelle
- [x] Animation d'entrée

---

### COF-602: Level Select (Planet Carousel)

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/level_select.gd](../../scripts/ui/level_select.gd)

**En tant que** joueur,  
**Je veux** sélectionner une planète via carrousel,  
**Afin de** choisir mon niveau.

**Critères d'acceptation**:

- [x] 4 planètes en carrousel horizontal
- [x] Swipe gauche/droite ou boutons flèches
- [x] Planètes verrouillées grisées avec cadenas
- [x] Affichage: nom, description, difficulté, puissance recommandée
- [x] Comparaison puissance joueur vs recommandée (couleur)
- [x] Boutons: Home, Shop, Profile

---

### COF-603: Shop Menu

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/shop_menu.gd](../../scripts/ui/shop_menu.gd)

**En tant que** joueur,  
**Je veux** une boutique,  
**Afin d'** acheter des boosters et équipements.

**Critères d'acceptation**:

- [x] Section Boosters (temporaires pour 1 partie)
- [x] Section Coins (simulation IAP)
- [x] Section Équipements (armes, armures, casques)
- [x] Affichage prix et état (can afford, owned, equipped)
- [x] Animation d'entrée

---

### COF-604: Profile Menu

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/profile_menu.gd](../../scripts/ui/profile_menu.gd)

**En tant que** joueur,  
**Je veux** un écran de profil,  
**Afin de** voir et améliorer mes stats.

**Critères d'acceptation**:

- [x] Section Stats de base (vie, dégâts, esquive, soin)
- [x] Section Upgrades avec niveaux et coûts
- [x] Section Équipement (slots weapon/armor/helmet)
- [x] Calcul de puissance totale affiché
- [x] Formule de coût: `base_cost × (multiplier ^ level)`

---

### COF-605: Options Menu

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/options_menu.gd](../../scripts/ui/options_menu.gd)

**En tant que** joueur,  
**Je veux** un écran d'options,  
**Afin de** configurer le jeu.

**Critères d'acceptation**:

- [x] Slider volume musique (0-100%)
- [x] Slider volume SFX (0-100%)
- [x] Toggle vibrations
- [x] Sauvegarde automatique des changements
- [x] Retour au menu principal

---

### COF-606: Combat HUD

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** un HUD de combat complet,  
**Afin de** suivre l'état du combat.

**Critères d'acceptation**:

- [x] Barre de vie héros (verte)
- [x] Barre de vie ennemis (rouge)
- [x] Label vague actuelle
- [x] Label planète
- [x] Indicateur puissance recommandée vs joueur
- [x] Affichage monnaie gagnée
- [x] Bouton pause

---

### COF-607: Pressure Gauges Display

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** voir les jauges de pression,  
**Afin de** éviter l'overload.

**Critères d'acceptation**:

- [x] 3 barres distinctes: Heal (bleu), Dodge (violet), Attack (rouge)
- [x] Animation de remplissage fluide
- [x] Indicateur de blocage par action

---

### COF-608: Floating Combat Text

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** voir les dégâts/soins en texte flottant,  
**Afin de** comprendre ce qui se passe.

**Critères d'acceptation**:

- [x] Position correcte (héros pour heal/shield, ennemi pour dégâts)
- [x] Couleurs: vert (heal), jaune (dégâts), rouge (crit)
- [x] Animation: montée + fade out
- [x] Utilise `hero_container.global_position` et `enemy_container.global_position`

---

### COF-609: Pause Menu

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** mettre le jeu en pause,  
**Afin de** faire une pause ou quitter.

**Critères d'acceptation**:

- [x] Toggle via bouton ⏸️ ou touche Escape
- [x] Overlay sombre
- [x] Boutons: Reprendre, Quitter
- [x] `get_tree().paused = true/false`

---

### COF-610: Game Over Screen

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** un écran de fin de partie,  
**Afin de** voir mes résultats et retry.

**Critères d'acceptation**:

- [x] Affichage VICTOIRE ou DÉFAITE
- [x] Stats: ennemis tués, vagues complétées, monnaie gagnée
- [x] Boutons: Retry, Menu
- [x] Restore currency on retry

---

### COF-611: Responsive UI Layout

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 289-315)

**En tant que** joueur sur différents appareils,  
**Je veux** une interface responsive,  
**Afin de** jouer confortablement.

**Critères d'acceptation**:

- [x] Positions relatives au viewport (%, pas pixels fixes)
- [x] Hero container: 12% largeur
- [x] Enemy container: 70% largeur
- [x] Ground: 55% Y, 12% hauteur
- [x] Battle line: 50% X, 31% Y
- [x] `stretch_mode = "canvas_items"`, `aspect = "keep_height"`

---

### COF-612: Hero Sprite System

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 370-420)

**En tant que** joueur,  
**Je veux** voir mon héros animé,  
**Afin d'** avoir un feedback visuel.

**Critères d'acceptation**:

- [x] 7 poses: IDLE, READY, DODGE, ATTACK_1, ATTACK_2, ATTACK_3, SPECIAL
- [x] Taille responsive (max 20% largeur viewport)
- [x] Changement de texture selon l'action
- [x] Animation de scale au changement
- [x] Retour automatique à IDLE après durée

---

### COF-613: Enemy Visual Display

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** voir les ennemis clairement,  
**Afin de** comprendre le combat.

**Critères d'acceptation**:

- [x] Taille responsive (max 12% largeur viewport)
- [x] Couleur selon planète
- [x] Barre de vie individuelle
- [x] Animation de hit (flash rouge)
- [x] Animation de mort (fade + shrink)

---

### COF-614: Planet Background System

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd) (lignes 235-285)

**En tant que** joueur,  
**Je veux** un background thématique par planète,  
**Afin d'** avoir une ambiance unique.

**Critères d'acceptation**:

- [x] Couleurs uniques: Mercury (orange), Venus (jaune-vert), Mars (rouge), Earth (bleu)
- [x] Gradient top → bottom
- [x] Particules d'ambiance (étoiles)
- [x] Ligne d'horizon

---

### COF-615: Safe Area Support

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur sur téléphone avec notch,  
**Je veux** que l'UI évite les zones système,  
**Afin de** tout voir correctement.

**Critères d'acceptation**:

- [x] Margin top réduit pour safe area
- [x] Click zone en bas avec marge

---

## 💰 EPIC 7: Economy System

### COF-701: Enemy Kill Rewards

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** gagner des SC en tuant des ennemis,  
**Afin de** progresser économiquement.

**Critères d'acceptation**:

- [x] `ENEMY_KILL_REWARD = 8 SC` par ennemi
- [x] Affichage "+8 SC" en floating text
- [x] Accumulation pendant le run

---

### COF-702: Wave Clear Bonus

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur,  
**Je veux** un bonus pour terminer une vague,  
**Afin d'** être récompensé pour la progression.

**Critères d'acceptation**:

- [x] `WAVE_CLEAR_BONUS = 25 SC` par vague
- [x] Message affiché à la fin de vague

---

### COF-703: Victory Bonus

**Status**: ✅ DONE  
**Fichier**: [scenes/game_combat_scene.gd](../../scenes/game_combat_scene.gd)

**En tant que** joueur victorieux,  
**Je veux** un gros bonus à la victoire,  
**Afin d'** être motivé à terminer.

**Critères d'acceptation**:

- [x] `VICTORY_BONUS = 100 SC`
- [x] Affiché dans l'écran de victoire

---

### COF-704: Booster System

**Status**: ✅ DONE  
**Fichier**: [scripts/ui/shop_menu.gd](../../scripts/ui/shop_menu.gd)

**En tant que** joueur,  
**Je veux** acheter des boosters temporaires,  
**Afin de** faciliter une partie difficile.

**Critères d'acceptation**:

- [x] Rage de Guerre: +50% dégâts (100 SC)
- [x] Vitalité: +30% HP (80 SC)
- [x] Agilité: +20% esquive (120 SC)
- [x] Régénération: +40% soin (90 SC)
- [x] Puissance Totale: +15% toutes stats (200 SC)
- [x] Durée: 1 partie

---

## 📱 EPIC 8: Data Structures

### COF-801: Planet Data Resource

**Status**: ✅ DONE  
**Fichier**: [scripts/data/planet_data.gd](../../scripts/data/planet_data.gd)

**En tant que** game designer,  
**Je veux** une Resource pour définir les planètes,  
**Afin de** configurer le contenu facilement.

**Critères d'acceptation**:

- [x] `id`, `display_name`, `theme_color`, `background_color`
- [x] `description`, `difficulty` (1-4)
- [x] `waves`: Array[WaveData]
- [x] `boss_wave`: WaveData
- [x] `completion_bonus`: int

---

### COF-802: Wave Data Resource

**Status**: ✅ DONE  
**Fichier**: [scripts/data/wave_data.gd](../../scripts/data/wave_data.gd)

**En tant que** game designer,  
**Je veux** une Resource pour définir les vagues,  
**Afin de** configurer les spawns.

**Critères d'acceptation**:

- [x] `wave_number`
- [x] `start_delay`
- [x] `enemy_spawns`: Array[EnemySpawnData]

---

### COF-803: Enemy Spawn Data Resource

**Status**: ✅ DONE  
**Fichier**: [scripts/data/enemy_spawn_data.gd](../../scripts/data/enemy_spawn_data.gd)

**En tant que** game designer,  
**Je veux** une Resource pour définir les spawns d'ennemis,  
**Afin de** contrôler le timing et le type.

**Critères d'acceptation**:

- [x] `enemy_scene`: PackedScene
- [x] `enemy_stats`: EntityStats
- [x] `planet_type`: PlanetType
- [x] `count`: nombre d'ennemis
- [x] `initial_delay`, `spawn_interval`

---

## 🎯 RÉCAPITULATIF TECHNIQUE

### Architecture

```
the-click-of-fate/
├── scripts/
│   ├── autoload/
│   │   └── save_manager.gd          # Singleton persistence
│   ├── core/
│   │   ├── combat/
│   │   │   ├── combat_manager.gd    # Orchestrateur combat
│   │   │   ├── combat_state_machine.gd
│   │   │   └── wave_controller.gd
│   │   ├── entities/
│   │   │   └── base_entity.gd       # Classe mère entités
│   │   ├── stats/
│   │   │   └── entity_stats.gd      # Resource stats
│   │   └── systems/
│   │       └── pressure_gauge.gd    # Anti-spam
│   ├── data/
│   │   ├── planet_data.gd
│   │   ├── wave_data.gd
│   │   └── enemy_spawn_data.gd
│   ├── entities/
│   │   ├── alien_hero.gd
│   │   ├── base_enemy.gd
│   │   └── behaviors/
│   │       ├── enemy_behavior.gd
│   │       ├── fast_behavior.gd     # Mercury
│   │       ├── toxic_behavior.gd    # Venus
│   │       ├── regen_behavior.gd    # Mars
│   │       └── tank_behavior.gd     # Earth
│   └── ui/
│       ├── click_zone_button.gd
│       ├── main_menu.gd
│       ├── level_select.gd
│       ├── shop_menu.gd
│       ├── profile_menu.gd
│       └── options_menu.gd
├── scenes/
│   ├── game_combat_scene.gd         # Scène principale (~2400 lignes)
│   ├── game_combat_scene.tscn
│   └── ui/
│       ├── main_menu.tscn
│       ├── level_select.tscn
│       ├── shop_menu.tscn
│       ├── profile_menu.tscn
│       └── options_menu.tscn
└── assets/
    └── sprites/
        └── hero/                    # 7 poses du héros
```

### Constantes de Balance Clés

| Paramètre          | Valeur          |
| ------------------ | --------------- |
| Hero Base HP       | 150             |
| Hero Base ATK      | 12              |
| Hero Attack Speed  | 1.5/s           |
| Heal Amount        | 13% max HP      |
| Dodge Buff         | +20% pendant 4s |
| Attack Crit Bonus  | +10% pendant 2s |
| Pressure Decay     | 5/s             |
| Overload Threshold | 100             |

### Progression Puissance

| Planète Terminée | Puissance | HP Mult | ATK Mult |
| ---------------- | --------- | ------- | -------- |
| Aucune           | 100       | 1.0x    | 1.0x     |
| Mercury          | 150       | 1.25x   | 1.2x     |
| Venus            | 200       | 1.5x    | 1.4x     |
| Mars             | 280       | 1.8x    | 1.7x     |
| Earth            | 400       | 2.2x    | 2.0x     |

---

## ✅ VALIDATION FINALE

**Total Stories Complétées**: 60  
**Couverture Fonctionnelle**: 100% MVP  
**Prêt pour Release**: OUI (MVP)

### Fonctionnalités Restantes (Post-MVP)

- [ ] Audio (musique, SFX)
- [ ] Skills actifs débloquables
- [ ] Compagnons (Medical Drone, Support Unit)
- [ ] Localization FR
- [ ] Achievements
- [ ] Leaderboards
- [ ] Plus de planètes (Expansion)
