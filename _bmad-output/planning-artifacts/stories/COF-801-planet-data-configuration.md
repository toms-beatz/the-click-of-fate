# COF-801: Planet Data Configuration

**Epic**: Data Structures  
**Status**: ✅ DONE  
**Priority**: High  
**Fichier**: `scenes/game_combat_scene.gd` (ligne 216-222)

---

## User Story

**En tant que** développeur,  
**Je veux** une configuration centralisée du nombre d'ennemis par vague,  
**Afin de** faciliter l'équilibrage et la progression par planète.

---

## Description

Le nombre d'ennemis par vague est configuré dans une constante dictionnaire qui mappe chaque planète à un tableau de 5 éléments (une vague par élément).

Ce configuration a été **augmentée le 28 janvier 2026** pour créer un sentiment d'armée plutôt qu'une petite escouade (BMAD Mode).

---

## Critères d'Acceptation

- [x] 4 planètes avec configurations distinctes
- [x] 5 vagues par planète
- [x] Progression croissante du nombre d'ennemis
- [x] Sentiment de "vague d'armée" bien présent

---

## Structure de Données - CONFIGURATION ACTUELLE

```gdscript
## Nombre d'ennemis par vague - par planète [Mercury, Venus, Mars, Earth]
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 10],      # Mercury (était [3,4,4,5,5])
	1: [8, 10, 10, 12, 12],    # Venus (était [4,5,5,6,6])
	2: [8, 10, 12, 12, 14],    # Mars (était [4,5,6,6,7])
	3: [10, 12, 12, 14, 16],   # Earth (était [5,6,6,7,8])
}
```

---

## Comparaison: Ancien vs Nouveau

| Planète | Ancien Total | Nouveau Total | Augmentation | Sentiment |
| ------- | ------------ | ------------- | ------------ | --------- |
| Mercury | 21 ennemis   | 42 ennemis    | +100%        | Armée! 👥 |
| Venus   | 26 ennemis   | 52 ennemis    | +100%        | Armée! 👥 |
| Mars    | 28 ennemis   | 56 ennemis    | +100%        | Armée! 👥 |
| Earth   | 32 ennemis   | 64 ennemis    | +100%        | Armée! 👥 |

**Impact global**: Au lieu d'affronter 17-32 ennemis par planète, le joueur affronte **42-64 ennemis**. C'est 2.5x plus de sentiment d'épopée!

---

## Utilisation en Code

```gdscript
func _spawn_wave() -> void:
	if is_boss_wave:
		wave_label.text = "⚠️ BOSS ⚠️"
	else:
		wave_label.text = "WAVE %d / %d" % [current_wave, total_waves]

	# Déterminer le nombre d'ennemis pour cette vague (selon la planète)
	var wave_idx := clampi(current_wave - 1, 0, 4)  # Max 5 waves
	var planet_enemies = ENEMIES_PER_WAVE.get(current_planet, ENEMIES_PER_WAVE[0])
	enemies_in_wave = planet_enemies[wave_idx]

	for i in range(enemies_in_wave):
		await get_tree().create_timer(0.4).timeout  # Délai entre spawns
		_spawn_enemy(i)
```

---

## Profil de Difficulté par Planète

### Mercury (Facile)

```
Vague 1: 6 ennemis
Vague 2: 8 ennemis
Vague 3: 8 ennemis
Vague 4: 10 ennemis
Vague 5: 10 ennemis (finale - 10 scouts rapides)
```

### Venus (Moyen)

```
Vague 1: 8 ennemis
Vague 2: 10 ennemis
Vague 3: 10 ennemis
Vague 4: 12 ennemis
Vague 5: 12 ennemis (finale)
```

### Mars (Difficile)

```
Vague 1: 8 ennemis
Vague 2: 10 ennemis
Vague 3: 12 ennemis ← augmentation notable
Vague 4: 12 ennemis
Vague 5: 14 ennemis (finale)
```

### Earth (Très Difficile)

```
Vague 1: 10 ennemis
Vague 2: 12 ennemis
Vague 3: 12 ennemis
Vague 4: 14 ennemis ← vraiment intense
Vague 5: 16 ennemis (finale - THE FINAL PUSH)
```

---

## Spawn Timing

Les ennemis ne spawn **pas tous en même temps**. Il y a un délai de 0.4 secondes entre chaque spawn:

```gdscript
for i in range(enemies_in_wave):
	await get_tree().create_timer(0.4).timeout
	_spawn_enemy(i)
```

**Timeline exemple - Mercury Vague 5 (10 ennemis):**

- T=0.0s: Spawn #1
- T=0.4s: Spawn #2
- T=0.8s: Spawn #3
- T=1.2s: Spawn #4
- T=1.6s: Spawn #5
- T=2.0s: Spawn #6
- ...
- T=3.6s: Spawn #10

**Total time**: ~4 secondes pour spawner toute la vague. Cela crée un sentiment d'invasion progressive!

---

## Équilibre Gameplay

**Ancien système (17-32 ennemis total):**

- Tuer 5 ennemis = 1/5 à 1/4 de la planète
- Sentiment: petit groupe d'ennemis
- Progression: lente à se sentir

**Nouveau système (42-64 ennemis total):**

- Tuer 5 ennemis = 1/8 à 1/12 de la planète
- Sentiment: partie d'une grande armée
- Progression: mêmes pas petits mais sur plus d'ennemis

L'équilibre a été ajusté dans COF-802 pour compenser (moins HP/DMG par ennemi).

---

## Configuration par Niveau de Compétence

Si vous voulez ajuster pour **votre audience**:

```gdscript
# Mode Facile (moins d'ennemis)
const ENEMIES_PER_WAVE := {
	0: [4, 5, 5, 6, 6],
	1: [5, 6, 6, 7, 7],
	2: [5, 6, 7, 7, 8],
	3: [6, 7, 7, 8, 9],
}

# Mode Normal (actuel)
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 10],
	1: [8, 10, 10, 12, 12],
	2: [8, 10, 12, 12, 14],
	3: [10, 12, 12, 14, 16],
}

# Mode Hard (plus d'ennemis)
const ENEMIES_PER_WAVE := {
	0: [8, 10, 10, 12, 14],
	1: [10, 12, 14, 14, 16],
	2: [10, 12, 15, 16, 18],
	3: [12, 14, 16, 18, 20],
}
```

---

## Tests de Validation

1. ✅ Les 4 planètes ont des configurations distinctes
2. ✅ Chaque configuration a exactement 5 valeurs (1 par vague)
3. ✅ Les valeurs augmentent progressivement (sentiment de progression)
4. ✅ Le nombre d'ennemis s'affiche correctement dans wave_label
5. ✅ Spawn timing fonctionne sans lag

---

## Dépendances

- **Requiert**: BaseEnemy (COF-201), EntityStats
- **Utilisé par**: game_combat_scene.gd, \_spawn_wave()
- **Relate à**: COF-802 (enemy stats), COF-803 (scaling constants)
  var boss_data := planet["boss"]

  var boss := BossEnemy.new()
  boss.boss_name = boss_data["name"]
  boss.stats.max_hp = boss_data["hp"]
  boss.stats.damage = boss_data["damage"]
  boss.attack_cooldown = 1.0 / boss_data["attack_speed"]

````

---

## Extensibilité

```gdscript
# Pour ajouter une nouvelle planète (DLC/Update):
PLANET_DATA[4] = {
    "name": "Jupiter",
    "emoji": "🪐",
    "power_required": 400,
    "waves": 6,  # Plus de vagues!
    "enemy_types": ["electric"],  # Nouveau type
    "boss": {
        "name": "Storm King",
        "hp": 2000,
        # ...
    }
}
````

---

## Tests de Validation

1. ✅ 4 planètes configurées avec toutes les données
2. ✅ Données accessibles par index
3. ✅ Boss configuré par planète
4. ✅ Nombre d'ennemis par vague défini
5. ✅ Structure facile à étendre

---

## Dépendances

- **Requiert**: Rien
- **Utilisé par**: LevelSelect, WaveController, CombatScene
