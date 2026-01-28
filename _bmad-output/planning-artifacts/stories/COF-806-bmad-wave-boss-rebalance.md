# COF-806: BMAD Mode - Wave 5 & Boss Rebalance

**Epic**: BMAD Mode - Difficulty Balance  
**Status**: 📋 READY FOR IMPLEMENTATION

- `scenes/game_combat_scene.gd` (Enemy counts, boss scaling)**Target Files**:**Priority**: High

---

## User Story

**En tant que** designer/joueur,

**Je veux** que Wave 5 soit challengeant mais pas impossible et le boss plus imposant en difficulté,

**Afin de** créer une courbe de difficulté satisfaisante sans frustration excessive.

---

## Context

**Problème identifié**:

Après COF-805 (boss size 25%→60%), le problème de difficulté subsiste:

1. **Wave 5 trop dure**:
   - Earth Wave 5: 16 ennemis × stats élevées × wave scaling (+50% boost)

   - Temps estimé: 50+ secondes = fatigue mentale - Total HP à éliminer: ~3200+ (avec héros lvl 4: 600 HP, 60 ATK)

2. **Boss trop facile après**:
   - Dr. Mortis: 1500 HP × 1.3 (final) × ~1.1 progression = ~2150 HP
   - Mais héros a maintenant 1.50x stats (vague 5 boost accumulé)

   - Boss devient "one-shot" pratiquement

   - Vague 1-3: progression lisse3. **Courbe de difficulté irrégulière**:

   - Boss: retour trop facile - Vague 4-5: spike brutal

## Proposed Solutions---

### Option 1: Réduire Wave 5 (RECOMMANDÉE ⭐)

**Philosophie**: "Moins de mobs, plus d'engagement"

**Changements**:

```gdscript

```

```} 3: [10, 12, 12, 14, 12],   # Earth: Réduit 16→12 (25% reduction!)	2: [8, 10, 12, 12, 12],    # Mars: Réduit 14→12	1: [8, 10, 10, 12, 10],    # Venus: Réduit 12→10	0: [6, 8, 8, 10, 8],       # Mercury: Réduit 10→8const ENEMIES_PER_WAVE := {

```

**Justification**:

- Wave 5 devient plus court (10-12 mobs vs 12-16)

- Sensation de "dernière vague importante" préservée
- Temps réel de combat: ~30-35s vs 50s+ actuellement
- Moins fatigant mentalement = plus amusant

**Impact**:

- Wave 5 ennemis: ~2500 HP totaux (vs ~3200)
- Plus facile pour joueurs occasionnels
- Hardcore peut encore overcomplicating avec formation stratégique

### Option 2: Augmenter Boss HP & ATK (COMPLÉMENTAIRE)

**Changements**:

```gdscript
const PLANET_BOSSES := {
	0: {"name": "Mercury Guardian", "hp": 400, "atk": 20, "speed": 1.0, ...},
	1: {"name": "Venus Queen", "hp": 550, "atk": 25, "speed": 0.9, ...},
	2: {"name": "Mars Warlord", "hp": 700, "atk": 30, "speed": 0.8, ...},
	3: {"name": "DR. MORTIS", "hp": 1800, "atk": 45, "speed": 0.6, ...},  # +300 HP, +5 ATK
}
```

**Justification**:

- Dr. Mortis devient VRAI final boss (pas "juste un mob de plus")
- Avec héros à 1.50x stats après Wave 5: boss dure ~5-8s vs 2-3s
- Progression: Wave 4 boss → Wave 5 boss → Final boss (chacun distinct)

**Impact**:

- Dr. Mortis HP: ~2340 (vs ~2150): +9% difficulté
- ATK: 45 vs 40: +12.5% plus agressif
- Sensation: "Boss final terrifying, pas trivial"

### Option 3: Ajuster Wave Scaling (NUANCE)

**Alternative** (moins recommandée):

- Réduire boost de 10% → 8% par vague
- Permet aux joueurs "faibles" de se rattraper
- Mais dilue l'impact de la progression

**Non recommandé** car:

- COF-805 déjà balance les vagues
- Mieux de réduire vague 5 enemies directement
- Plus facile à comprendre pour joueur

---

## Recommended Implementation Path

### Phase 1 (Immédiat) - Option 1: Réduire Wave 5

```gdscript
// game_combat_scene.gd ~ ligne 215
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 8],       # Mercury Wave 5: 10→8
	1: [8, 10, 10, 12, 10],    # Venus Wave 5: 12→10
	2: [8, 10, 12, 12, 12],    # Mars Wave 5: 14→12
	3: [10, 12, 12, 14, 12],   # Earth Wave 5: 16→12
}
```

**Rationale**: Résout le problème principal (trop d'ennemis = frustration)

### Phase 2 (Follow-up) - Option 2: Augmenter Boss

```gdscript
// game_combat_scene.gd ~ ligne 172
const PLANET_BOSSES := {
	0: {"name": "Mercury Guardian", "hp": 400, "atk": 20, "speed": 1.0, ...},
	1: {"name": "Venus Queen", "hp": 550, "atk": 25, "speed": 0.9, ...},
	2: {"name": "Mars Warlord", "hp": 700, "atk": 30, "speed": 0.8, ...},
	3: {"name": "DR. MORTIS", "hp": 1800, "atk": 45, "speed": 0.6, ...},
}
```

**Rationale**: Rend le boss final impressionnant et challengeant

---

## Balance Calculations (Post-Implementation)

### Nouvelle Progression (avec Phase 1 & 2)

**Mercury** (Hero: 150 HP, 12 ATK base):

```
Wave 1: 6 × scout (1.0x) = 6 mobs
Wave 2: 8 × scout (1.15x HP, 1.1x ATK) = 8 mobs [+10% boost]
Wave 3: 8 × scout (1.32x HP, 1.21x ATK) = 8 mobs [+20% boost]
Wave 4: 10 × scout (1.52x HP, 1.33x ATK) = 10 mobs [+30% boost]
Wave 5: 8 × scout (1.75x HP, 1.46x ATK) = 8 mobs [+40% boost] ← RÉDUIT DE 10!
Boss: Mercury Guardian (400 HP, 20 ATK) - reste identique

Total combat time: ~90 seconds (Wave 1-5) + ~20 seconds (Boss) = 110s total
Difficulty curve: Smooth progression, satisfying boss fight
```

**Earth** (Hero: 300 HP, 24 ATK @ level 4):

```
Wave 1: 10 × mixed (1.0x-1.5x mult) = 10 mobs [difficulty spike START]
Wave 2: 12 × mixed (1.15-1.5x mult) = 12 mobs [+10% boost]
Wave 3: 12 × mixed (1.32-1.5x mult) = 12 mobs [+20% boost]
Wave 4: 14 × mixed (1.52-1.5x mult) = 14 mobs [+30% boost]
Wave 5: 12 × mixed (1.75-1.5x mult) = 12 mobs [+40% boost] ← RÉDUIT DE 4!
Boss: DR. MORTIS (1800 HP, 45 ATK) - NEW, plus challenging

Total combat time: ~120 seconds (Wave 1-5) + ~30 seconds (Boss) = 150s total
Difficulty curve: Epic progression, boss final threatening
```

### Before vs After Comparison

| Metric                    | Before | After | Change                |
| ------------------------- | ------ | ----- | --------------------- |
| Earth Wave 5 Enemies      | 16     | 12    | -25%                  |
| Earth Wave 5 Total HP     | ~3200  | ~2400 | -25%                  |
| Combat Duration (Wave 5)  | 50s    | 35s   | -30%                  |
| Dr. Mortis HP             | 1500   | 1800  | +20%                  |
| Dr. Mortis ATK            | 40     | 45    | +12.5%                |
| Boss Challenge Multiplier | 0.7x   | 1.0x  | +43% more challenging |

**Player Experience**:

- Wave 1-4: Same satisfying progression
- Wave 5: "Final push before boss" feeling vs "why so many mobs?"
- Boss: "This is truly the final threat" vs "easier than wave 5?"

---

## Why These Numbers?

### Why Reduce Wave 5 By ~25%?

1. **Mathematical threshold**:
   - Human attention span for repetitive actions: ~30-40 seconds peak
   - 12 mobs @ elevated stats ≈ 30-35 seconds
   - 16 mobs @ elevated stats ≈ 50-60 seconds (cognitive overload)

2. **Progression psychology**:
   - Players need to feel progression, not punishment
   - "Oh, now I'm strong enough!" vs "This is impossible"

3. **Mobile context**:
   - Shorter play sessions = less battery drain
   - Frustration = app uninstall
   - Satisfaction = retention

### Why Increase Boss HP/ATK?

1. **Justification**:
   - Boss is THE encounter, should be memorable
   - With wave 5 boost (1.50x), hero is MUCH stronger
   - Boss needs to match that power level

2. **Numbers**:
   - Dr. Mortis @ 1800 HP vs Hero @ 1.50x stats
   - Estimated fight duration: 25-30 seconds (good pacing)
   - Boss feels threatening but beatable

3. **Narrative**:
   - "DR. MORTIS, the final boss" should be hardest fight
   - Not Wave 5 trash, but the actual antagonist

---

## Testing Checklist

### Difficulty Validation

- [ ] Mercury Wave 5: Can beat with base hero (no power-ups)
- [ ] Venus Wave 5: Needs some strategy (dodge/heal)
- [ ] Mars Wave 5: Challenging but beatable
- [ ] Earth Wave 5: Exciting, not frustrating (30-40s duration)
- [ ] All Bosses: Tougher than their respective Wave 5

### Player Feedback

- [ ] No "this is impossible" sentiment (too hard)
- [ ] No "this is boring" sentiment (too easy)
- [ ] "That was fun!" feeling after Wave 5
- [ ] "Whoa, that boss is scary!" on first boss encounter
- [ ] Smooth difficulty curve from planet 0→3

### Technical Validation

- [ ] No stat overflow (hero ATK/HP stays reasonable)
- [ ] Boss stats correctly applied
- [ ] Wave clearing bonus (COF-805) still working
- [ ] No visual clipping with reduced enemy count

---

## Acceptance Criteria

✅ **Implementation Complete When**:

1. Wave 5 enemy counts reduced by ~25% across all planets
2. Dr. Mortis HP increased to 1800, ATK to 45
3. All 4 planets have smooth difficulty curves
4. Boss fights feel appropriately challenging
5. No spike from Wave 5 to Boss (smooth transition)
6. Total combat duration reasonable (~2-2.5 minutes per level)

---

## Optional Phase 3: Fine-tuning (After Testing)

If data shows:

**Too Easy** → Increase boss ATK slightly (+2-5) instead of HP
**Still Brutal** → Reduce Wave 5 by another 2 mobs (further tuning)
**Perfect** → Mark as ✅ BALANCED

---

## Files Affected

| File                          | Section   | Changes                     |
| ----------------------------- | --------- | --------------------------- |
| `scenes/game_combat_scene.gd` | Line ~215 | `ENEMIES_PER_WAVE` constant |
| `scenes/game_combat_scene.gd` | Line ~172 | `PLANET_BOSSES` constant    |

---

## Dependencies

- ✅ Requires COF-801 (enemies_per_wave system)
- ✅ Requires COF-802 (planet multipliers)
- ✅ Requires COF-805 (wave scaling)
- ⚠️ After this: All balance locked (good state)

---

## Implementation Notes

### Code Changes Required

**Change 1**: ENEMIES_PER_WAVE (3 lines modified)

```gdscript
// Before
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 10],
	1: [8, 10, 10, 12, 12],
	2: [8, 10, 12, 12, 14],
	3: [10, 12, 12, 14, 16],
}

// After
const ENEMIES_PER_WAVE := {
	0: [6, 8, 8, 10, 8],       // Wave 5: 10 → 8
	1: [8, 10, 10, 12, 10],    // Wave 5: 12 → 10
	2: [8, 10, 12, 12, 12],    // Wave 5: 14 → 12
	3: [10, 12, 12, 14, 12],   // Wave 5: 16 → 12
}
```

**Change 2**: PLANET_BOSSES (1 entry modified)

```gdscript
// Before
3: {"name": "DR. MORTIS", "hp": 1500, "atk": 40, "speed": 0.6, ...},

// After
3: {"name": "DR. MORTIS", "hp": 1800, "atk": 45, "speed": 0.6, ...},
```

---

## Success Metrics

**Post-Implementation Data** (to track):

1. **Playtime per level**: Should be ~2-2.5 minutes (down from 3+)
2. **Completion rate**: Should remain high (>80%)
3. **Player frustration signals**: Should decrease
4. **Boss fight intensity**: Should feel climactic
5. **Difficulty perception**: Smooth curve (1.0→3.5x, not 1.0→5.0x then 3.5x)

---

## Version History

| Date       | Author       | Version | Status                |
| ---------- | ------------ | ------- | --------------------- |
| 2026-01-28 | GameDesigner | 1.0     | Initial Proposal      |
|            |              |         | ✨ READY FOR APPROVAL |

---

## Conclusion

This rebalancing creates a **satisfying difficulty curve** that:

✅ Removes frustration (fewer Wave 5 enemies)  
✅ Adds challenge (stronger boss)  
✅ Improves pacing (better time distribution)  
✅ Enhances narrative (boss feels like THE threat)  
✅ Maintains progression (still feels rewarding)

**Recommendation**: Implement Phase 1 immediately, Phase 2 within 24 hours, then gather player feedback for Phase 3 tuning.
