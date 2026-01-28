# Product Requirements Document (PRD)

## Click of Fate - Mobile RPG Auto-Battler

---

| Field | Value |## 📋 Document Info

| **Version** | 0.1.0 (MVP) || **Product Name** | Click of Fate ||-------|-------|

| **Platform** | Mobile (Android/iOS) |

| **Language** | GDScript || **Engine** | Godot 4.5.1 |

---| **Last Updated** | 2026-01-28 |

## 🎯 Vision Statement

**Click of Fate** est un RPG auto-battler arcade mobile où le joueur influence le combat en temps réel via une **zone de clic tripartite** (Heal/Dodge/Attack). Le héros combat automatiquement, mais le joueur doit gérer stratégiquement ses actions pour éviter la **surcharge de pression** tout en progressant à travers 4 planètes jusqu'à affronter le boss final: **Dr. Mortis**.

---

## 🎮 Core Gameplay Loop

```
1. Sélectionner une planète (Mercury → Venus → Mars → Earth)
```

3. Cliquer sur la zone tripartite pour:2. Combattre 5 vagues d'ennemis + 1 Boss
   - HEAL (bleu) - Soigner le héros

4. Éviter l'overload (action bloquée temporairement)4. Gérer la pression (chaque action remplit une jauge) - ATTACK (rouge) - Attaque bonus - DODGE (violet) - Préparer une esquive

5. Utiliser les 4 skills spéciaux

6. Vaincre le boss pour débloquer la planète suivante
7. Affronter Dr. Mortis sur Earth pour la victoire finale

---```

```


































































- ✅ Interface en anglais- ✅ Sauvegarde de progression- ✅ UI responsive pour tous écrans- ✅ Cinématiques intro/ending- ✅ 4 boss (Mercury Guardian → Dr. Mortis)- ✅ 4 planètes avec progression- ✅ Système de pression avec overload par action- ✅ Zone tripartite Heal/Dodge/Attack- ✅ Combat auto-battler fonctionnel### v0.1.0 (MVP) - 2026-01-28## 📅 Historique des Versions---2. Éviter les transitions circulaires dans les signaux1. Ne pas utiliser l'état PUNISHED global → overload par action individuellement### State Machine4. Safe area margins pour les encoches3. Tailles min avec `mini(fixed, viewport.x * percent)`2. Positions en % du viewport, pas en pixels fixes1. `project.godot`: `stretch/aspect = "keep_height"` pour téléphones allongés### Mobile Responsive4. Integer division warning → utiliser `float()` pour les positions3. `mini()` retourne int, `minf()` retourne float - attention au narrowing conversion2. Les signaux doivent être déclarés avec `signal nom(params)` sans types dans la signature1. `get_viewport().size` retourne un type non-inférable → utiliser `get_viewport().get_visible_rect().size` avec type explicite### Godot 4.x Specifics## 🚧 Contraintes Techniques Découvertes---| Crash rate | < 1% || Taux de complétion Earth | 20-30% || Taux de complétion Mercury | > 80% || Temps de session moyen | 5-10 min ||----------|-------|| Métrique | Cible |## 📊 Métriques de Succès (MVP)---4. **Boss System** - Boss unique par planète avec scaling3. **Power Scaling** - 100 → 150 → 200 → 280 → 400 selon progression2. **Combat State Machine** - IDLE → COMBAT → BOSS_PHASE → VICTORY/DEFEAT1. **Pressure System** - Jauge par action avec overload individuel### Systèmes Clés| `save_manager.gd` | Sauvegarde/Progression | ~100 || `base_enemy.gd` | Entité ennemi | ~150 || `base_hero.gd` | Entité héros | ~200 || `click_zone_button.gd` | UI zone tripartite | ~150 || `pressure_gauge.gd` | Système de pression | ~200 || `combat_state_machine.gd` | États du combat | ~150 || `combat_manager.gd` | Logique de combat | ~300 || `game_combat_scene.gd` | Scène de combat principale | ~2400 ||---------|----------------|--------|| Fichier | Responsabilité | Lignes |### Fichiers Principaux## 🏗️ Architecture Technique
```
