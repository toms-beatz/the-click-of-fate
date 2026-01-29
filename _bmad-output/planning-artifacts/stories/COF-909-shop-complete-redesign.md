# COF-909: Shop Complete Redesign

**Epic**: UI/UX  
**Status**: ✅ DONE  
**Priority**: High  
**Sprint**: Current

---

## User Story

**En tant que** joueur,  
**Je veux** un shop moderne, pixel-art et futuriste avec effet néon,  
**Afin de** mieux visualiser les offres et avoir une expérience user-friendly.

---

## Changements Demandés

### 1. Suppression des Boosters Temporaires
- ❌ Supprimer complètement la section "Boosters"
- ❌ Supprimer `BOOSTERS` constant
- ❌ Supprimer `_populate_boosters()` et `_create_booster_item()`
- ❌ Supprimer `_on_buy_booster()`

### 2. Refonte des Packs SC (Coffres)
- 4 coffres en grille 2x2
- Ordre: basique, plus, luxueux, royal
- Images: `assets/sprites/ui/coffres/coffre-*.png`
- Format carte: Titre en haut, Image au centre, Prix en bas
- Style: Rectangle avec bordure néon

### 3. Refonte des Équipements
- 3 items par ligne (armes, armures, casques)
- Épées → Pistolets
- Images depuis `assets/sprites/ui/équipements/*/`
- Ordre: basique, plus fort, royal
- Format carte: Titre en haut, Image au centre, Nom en bas
- Style: Pixel-art futuriste néon

### 4. Background
- Même style que le menu principal
- Dégradé spatial/futuriste

---

## Assets Disponibles

### Coffres
- `res://assets/sprites/ui/coffres/coffre-basique.png`
- `res://assets/sprites/ui/coffres/coffre-plus.png`
- `res://assets/sprites/ui/coffres/coffre-luxueux.png`
- `res://assets/sprites/ui/coffres/coffre-royal.png`

### Armes (Pistolets)
- `res://assets/sprites/ui/équipements/armes/pistolet basique.png`
- `res://assets/sprites/ui/équipements/armes/pistolet plus fort.png`
- `res://assets/sprites/ui/équipements/armes/pistolet royal.png`

### Armures
- `res://assets/sprites/ui/équipements/armures/armure basique.png`
- `res://assets/sprites/ui/équipements/armures/armure_plus_fort.png`
- `res://assets/sprites/ui/équipements/armures/armure royal.png`

### Casques
- `res://assets/sprites/ui/équipements/casques/casque basique.png`
- `res://assets/sprites/ui/équipements/casques/casque plus fort.png`
- `res://assets/sprites/ui/équipements/casques/casque royal.png`

---

## Fichiers à Modifier

| Fichier | Modifications |
|---------|---------------|
| `scripts/ui/shop_menu.gd` | Refonte complète |

---

## Estimation

**Effort**: 2-3 heures
**Complexité**: Moyenne
