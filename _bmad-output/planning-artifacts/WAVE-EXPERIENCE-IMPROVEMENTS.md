# Wave Experience Improvements - 28 Janvier 2026

**Objectif**: Améliorer le sentiment de "vague" d'ennemis en rendant l'expérience plus épique et immersive.

---

## Changements Implémentés

### 1. **Nombre d'ennemis par vague - AUGMENTÉ**

Pour créer un sentiment d'armée massive, les ennemis par vague ont été augmentés de **50-100%**.

|---------|-----------------|-----------------|--------------|| Planète | Ancienne Config | Nouvelle Config | Augmentation |

| **Mercury** | [3, 4, 4, 5, 5] | [6, 8, 8, 10, 10] | +100% |

| **Mars** | [4, 5, 6, 6, 7] | [8, 10, 12, 12, 14] | +100% || **Venus** | [4, 5, 5, 6, 6] | [8, 10, 10, 12, 12] | +100% |

**Total ennemis par niveau:**| **Earth** | [5, 6, 6, 7, 8] | [10, 12, 12, 14, 16] | +100% |

- Mercury: 21 → 42 ennemis
- Venus: 26 → 52 ennemis
- Mars: 28 → 56 ennemis

- Earth: 32 → 64 ennemis

---

```gdscriptLes ennemis sont maintenant **40% plus grands** à l'écran pour une présence plus imposante.### 2. **Taille des ennemis - AUGMENTÉE**

```

# AVANT:

var body_width: int = mini(50, int(viewport_size.x \* 0.07))

# = augmentation de 60% en pixels (50 → 80)var body_width: int = mini(80, int(viewport_size.x \* 0.11))# APRÈS:

````

**Visual Scale par type:**
- Fast: 0.8x → 1.1x
- Toxic: 1.0x → 1.2x

































































































































































**Après:** ARMÉE MASSIVE d'ennemis faibles → **ÉPIQUE!** 🎮💥**Avant:** Petit groupe de forts ennemis  ## Résultat Final---- [ ] Audio (sfx) n'est pas overwhelming- [ ] Droplet/rewards visibilité OK avec plus d'ennemis- [ ] Pas de lag de spawning- [ ] FPS stable avec 10+ ennemis à l'écran- [ ] Équilibre de difficulté: pas trop facile- [ ] Confirmer que les vagues SE SENTENT plus épiques- [ ] Vérifier que le héros est bien plus grand visuellement- [ ] Tester sur mobile (720p) pour performance## Testing Checklist---   - Augmenté body_width des ennemis (50 → 80)   - Augmenté sprite_width du héros (150 → 200)3. **game_combat_scene.gd**   - Réduit poison_damage et regen_rate   - Augmenté scale pour meilleure présence visuelle   - Réduit HP et Damage pour chaque type2. **COF-802-enemy-type-definitions.md**   - Mis à jour enemies_per_wave pour chaque planète1. **COF-801-planet-data-configuration.md**## Fichiers Modifiés---```Poison total: (5 × 3) = 15 DPS → (10 × 2) = 20 DPS (+33%)DPS total (sans poison) après: (10 × 7) = 70 DPS (+40%)DPS total (sans poison) avant: (5 × 10) = 50 DPSAPRÈS: 35 HP, 7 DMG, scale 1.2x, 2 poison DPS, 8-12 par vagueAVANT: 50 HP, 10 DMG, scale 1.0x, 3 poison DPS, 4-6 par vague```### Toxic Enemies (Venus)```→ Plus d'ennemis, but feeling is different (army vs difficulty)HP total après: (8 × 20) = 160 HP (+33%)HP total avant: (4 × 30) = 120 HPDPS total après: (8 × 5) = 40 DPS (+25%)DPS total avant: (4 × 8) = 32 DPSAPRÈS: 20 HP, 5 DMG, scale 1.1x, 6-10 par vagueAVANT: 30 HP, 8 DMG, scale 0.8x, 3-5 par vague```### Fast Enemies (Mercury)## Réduction des Stats Détaillée---  - Total drops/vague: plus nombreux mais répartis  - Total dégâts/sec: similaire- **Économie de combat**:  - Progression "facile mais épique"  - Feedback positif pour le joueur- **Difficulté Perçue**: L'expérience PARAÎT plus difficile mais l'est en fait moins  - Optimiser le culling si nécessaire  - Tester sur appareils mobiles cibles- **Performance**: Plus d'ennemis = plus d'objets à rendu### ⚠️ Considérations   - Total de menace reste comparable   - Moins de DPS par ennemi = joueur ne se sent pas puni   - Moins de HP par ennemi = flow de combat plus fluide4. **Équilibre DPS**   - Ratio visuel travaille en harmonie   - Ennemis 60% plus grands = vagues imposantes   - Héros 33% plus grand = plus dominant3. **Échelle Visuelle Cohérente**   - Le momentum est meilleur avec plus d'ennemis   - Chaque kill contribue vraiment au sentiment de victoire   - Tuer 10 ennemis par vague se sent mieux que 52. **Progression Satisfaisante**   - Le chaos visuel est plus satisfaisant   - Les ennemis plus grands occupent plus l'écran   - Doubler le nombre d'ennemis crée un vrai sentiment d'armée1. **Épique Wave Feeling**### ✅ Sentiments Améliorés## Analyse d'Impact---| Regen | - | - | 5 HP/s | 3 HP/s || Toxic | 3 DPS | 2 DPS | - | - ||------|---------------------|---------|--------------|---------|| Type | Ancien Poison Damage | Nouveau | Ancien Regen | Nouveau |Les effets spéciaux (poison, régénération) ont été réduits proportionnellement.### 6. **Spéciales - LÉGÈREMENT RÉDUITES**---**Justification:** Avec 2x plus d'ennemis, les HP individuels doivent être réduits pour que le joueur progress et ne stagne pas.| Tank | 150 | 110 | -27% || Regen | 80 | 55 | -31% || Toxic | 50 | 35 | -30% || Fast | 30 | 20 | -33% ||------|-----------|------------|-----------|| Type | Ancien HP | Nouveau HP | Réduction |Moins de HP pour que l'armée soit plus fluide à combattre et que le joueur sente sa progression.### 5. **HP des ennemis - RÉDUITS**---**Formule d'attaque:** Plus d'ennemis = chacun fait moins de dégâts = sensation d'armée au lieu de menace concentrée.| Tank | 20 | 14 | -30% || Regen | 15 | 11 | -27% || Toxic | 10 | 7 | -30% || Fast | 8 | 5 | -37% ||------|---------------|----------------|-----------|| Type | Ancien Damage | Nouveau Damage | Réduction |Les ennemis font moins de dégâts pour adapter à la quantité accrue et éviter une pénalité injuste au joueur.### 4. **Dégâts des ennemis - RÉDUITS**---```# = augmentation de 33% (150 → 200)var sprite_width: int = mini(200, int(viewport_size.x * 0.28))# APRÈS:var sprite_width: int = mini(150, int(viewport_size.x * 0.20))# AVANT:```gdscriptLe héros alien est maintenant **33% plus grand** pour rester visuellement dominant face aux vagues d'ennemis.### 3. **Taille du héros - AUGMENTÉE**---- Tank: 1.4x → 1.5x- Regen: 1.2x → 1.3x```
````
