# COF-804: BMAD Mode - Army Formation & Layout

**Epic**: BMAD Mode - Wave Experience Improvements  
**Status**: 📋 READY FOR IMPLEMENTATION  
**Priority**: High  
**Target File**: `scenes/game_combat_scene.gd`

---

## User Story

**En tant que** joueur,  
**Je veux** que les ennemis se regroupent comme une véritable armée compacte,  
**Afin de** sentir une vague massive et épique au lieu d'une petite escouade dispersée.

---

## Context

Suite aux améliorations BMAD Mode du 28 janvier 2026 (COF-801, COF-802):

- Les ennemis ont été doublés en quantité (42-64 par planète)
- Les dégâts et HP ont été équilibrés

**Problème restant**: Avec la formation linéaire actuelle, même 16 ennemis se sentent dispersés et non menaçants.

**Solution**:

1. Former une grille matricielle compacte (4 rangées)
2. Rapprocher les deux camps vers le centre
3. Créer une sensation de confrontation épique

---

## Critères d'Acceptation

### Formation des Ennemis

- [x] Les ennemis forment une **grille matricielle de 4 rangées**
- [x] Les colonnes s'ajustent dynamiquement selon le nombre d'ennemis
- [x] L'espacement horizontal est **55% plus compact** que l'ancienne formation
- [x] La formation est **centrée** autour du point d'origine du container
- [x] Formation fonctionne pour 6 à 16 ennemis

### Positionnement des Camps

- [x] Héros plus **rapproché du centre** (de 12% à 28% de la largeur)
- [x] Ennemis plus **rapprochés du centre** (de 70% à 68% de la largeur)
- [x] Les deux camps sont **vertically aligned** (même Y)
- [x] Le gap entre les deux camps est **réduit de 130px**
- [x] Les deux camps créent une **zone de confrontation centrale**

### Affichages Visuels

- [x] Les numéros de dégâts apparaissent sur l'ennemi correct
- [x] Les récompenses aparaissent sur l'ennemi mort (même dans grille)
- [x] Les effets du héros restent sur le héros
- [x] Aucun clipping entre formations
- [x] Tous les textes flottants sont lisibles

---

## Spécifications Techniques

### 1. Repositionnement des Containers

**Hero Container** (avant):

```gdscript
hero_container.position = Vector2(viewport_size.x * 0.12, viewport_size.y * 0.35)
```

**Hero Container** (après - TARGET):

```gdscript
hero_container.position = Vector2(viewport_size.x * 0.28, viewport_size.y * 0.40)
```

**Enemy Container** (avant):

```gdscript
enemy_container.position = Vector2(viewport_size.x * 0.70, viewport_size.y * 0.31)
```

**Enemy Container** (après - TARGET):

```gdscript
enemy_container.position = Vector2(viewport_size.x * 0.68, viewport_size.y * 0.40)
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_setup_combat_zone()`, lignes ~322-328

---

### 2. Formation Matricielle des Ennemis

**Ancien système** (avant):

```gdscript
var enemy_spacing: float = viewport_size.x * 0.10  # 10% de la largeur
enemy.position = Vector2(index * enemy_spacing, index * 35 - 35)
```

**Problème**: Ligne diagonale dispersée, ne se sent pas comme une armée

**Nouveau système** (TARGET):

```gdscript
# Formation matricielle: 4 rangées, colonnes dynamiques
var enemy_spacing_x: float = viewport_size.x * 0.045    # 4.5% (55% plus compact!)
var enemy_spacing_y: float = 35.0                       # Vertical spacing
var rows: int = 4
var cols: int = int((enemies_in_wave + rows - 1) / rows)
var row: int = int(index % rows)
var col: int = int(index / rows)

# Centrer la formation
var offset_x: float = -(cols - 1) * enemy_spacing_x * 0.5
var offset_y: float = -60.0

enemy.position = Vector2(col * enemy_spacing_x + offset_x, row * enemy_spacing_y + offset_y)
```

**Localisation**: `scenes/game_combat_scene.gd`, fonction `_spawn_enemy()`, lignes ~1125-1137

---

## Exemples de Formation

### Mercury Wave 1 (6 ennemis)

```
Calcul:
- rows = 4
- cols = ceil(6/4) = 2
- Formation:
  [E][E]  ← Row 0: enemies 0, 4
  [E][E]  ← Row 1: enemies 1, 5
  [E]     ← Row 2: enemy 2
  [E]     ← Row 3: enemy 3

Visual: Pair de colonnes compact, pas dispersé
```

### Mercury Wave 5 (10 ennemis)

```
Calcul:
- rows = 4
- cols = ceil(10/4) = 3
- Formation:
  [E][E][E]  ← Row 0: enemies 0, 4, 8
  [E][E][E]  ← Row 1: enemies 1, 5, 9
  [E][E]     ← Row 2: enemies 2, 6
  [E][E]     ← Row 3: enemies 3, 7

Visual: Grille compacte 3 colonnes, se sent comme armée
```

### Earth Wave 5 (16 ennemis)

```
Calcul:
- rows = 4
- cols = ceil(16/4) = 4
- Formation:
  [E][E][E][E]  ← Row 0
  [E][E][E][E]  ← Row 1
  [E][E][E][E]  ← Row 2
  [E][E][E][E]  ← Row 3

Visual: Carré dense 4x4, très menaçant et épique!
```

---

## Vérification des Affichages Visuels

### Damage Numbers

**Formule**: `enemy_container.position + enemy.position + Vector2(0, -100)`

- **Avant**: Suit position linéaire de l'ennemi
- **Après**: Suit position matricielle de l'ennemi (même calcul, juste position différente)
- **Résultat**: ✅ Fonctionne automatiquement, pas de changement nécessaire

### Reward Coins

**Formule**: `enemy_container.position + enemy.position + Vector2(0, -60)`

- **Avant**: Apparaît à position linéaire
- **Après**: Apparaît à position matricielle
- **Résultat**: ✅ Fonctionne automatiquement

### Hero Effects

**Formule**: `hero_container.position + Vector2(50, -Y)`

- **Avant**: Relative à hero_container à X=12%
- **Après**: Relative à hero_container à X=28%
- **Résultat**: ✅ Tous les effets restent sur le héros

### Vérification Finale

Avant de terminer:

1. Vérifier aucun clipping entre formations (gap minimum 150px)
2. Vérifier que tous les textes flottants sont lisibles
3. Vérifier que les dégâts critiques apparaissent bien
4. Vérifier pas d'erreur compilation

---

## Impact Attendu

### Visual

| Aspect            | Avant           | Après           | Amélior |
| ----------------- | --------------- | --------------- | ------- |
| Spread horizontal | 50% du viewport | 15% du viewport | -70%    |
| Sensation         | "Petit groupe"  | "Armée massive" | Épique! |
| Gap hero-ennemi   | 418px           | 288px           | -31%    |
| Menace perçue     | Moyenne         | Très élevée     | 👾👾👾  |

### Performance

- ✅ Même nombre d'entités (pas de surcharge)
- ✅ Même système de rendu (pas de changement architecture)
- ✅ Même calcul d'effets visuels (juste positions différentes)
- **Résultat**: 0 impact sur performance

---

## Fichier à Modifier

**Fichier Principal**: `scenes/game_combat_scene.gd`

- **Fonction 1**: `_setup_combat_zone()` (lines ~322-328)
  - Modifier hero_container.position
  - Modifier enemy_container.position

- **Fonction 2**: `_spawn_enemy(index: int)` (lines ~1125-1137)
  - Remplacer ancien système de positionnement
  - Implémenter formation matricielle

---

## Testing Checklist

Après implémentation, vérifier:

- [ ] Code compile sans erreur (warnings int division acceptés)
- [ ] Hero et ennemis plus proches du centre
- [ ] Ennemis forment une grille compacte
- [ ] Formation fonctionne pour 6 ennemis
- [ ] Formation fonctionne pour 10 ennemis
- [ ] Formation fonctionne pour 16 ennemis
- [ ] Dégâts apparaissent sur bon ennemi
- [ ] Récompenses apparaissent sur bon ennemi
- [ ] Pas de clipping visual
- [ ] Impression d'armée massive présente
- [ ] Confrontation épique au centre

---

## Notes Importants

1. **Matrix Formation Fixed**: 4 rangées toujours, colonnes s'ajustent
2. **Auto-Centering**: La grille se centre automatiquement via `offset_x`
3. **Container Relative**: Tous les calculs de position sont relatifs aux containers
4. **Backward Compat**: Aucun changement d'architecture, juste positionnement

---

## Dépendances

- **Basé sur**: COF-801 (enemies_per_wave config), COF-802 (enemy stats)
- **Requiert**: BaseEnemy, EntityStats (déjà implémentés)
- **Pas de nouvelles dépendances**

---

## Définition of Done

✅ Story complétée quand:

1. Tous les critères d'acceptation sont remplis
2. Code compile et pas d'erreurs runtime
3. Formation fonctionne pour toutes les tailles de vague
4. Tous les affichages visuels restent attachés aux bons personnages
5. Impression visuelle d'armée compacte et menaçante est présente
6. Testing checklist est 100% verte
