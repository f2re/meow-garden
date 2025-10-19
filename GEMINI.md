# GEMINI.md - Meow Garden Development Instructions

## Core Directive
**ALL CODE COMMENTS MUST BE WRITTEN IN RUSSIAN** (Все комментарии в коде должны быть на русском языке)

***

## Project Vision

**Meow Garden** - Wholesome 2D roguelike mobile game for Android/RuStore
- **Theme:** Non-violent garden management with cute cat protagonist
- **Core Loop:** Plant → Grow → Harvest → Upgrade
- **Aesthetic:** Pastel colors (white, pink, mint, lavender, peach)
- **Platform:** Godot Engine 4.x, targeting Android devices (2020+)
- **Target:** Casual players seeking cozy, relaxing gameplay

---

## Project Architecture

### Current ECS Structure

```
Meow Garden/
├── core/                          # Core systems (Autoloads)
│   ├── entity_manager.gd          # ECS entity/component management
│   ├── turn_manager.gd            # Turn-based gameplay controller
│   └── dungeon_generator.gd       # Procedural level generation
│
├── components/                    # Data containers (Resources)
│   ├── actor_component.gd         # Turn-taking entities marker
│   ├── position_component.gd      # Grid position (x, y)
│   ├── health_component.gd        # HP management
│   ├── combat_component.gd        # Combat stats
│   └── ai_component.gd            # AI behavior types
│
├── world/                         # Game world rendering
│   └── game_map.gd                # TileMap rendering & collision
│
├── player/                        # Player entity
│   ├── player.tscn                # Player scene
│   └── player.gd                  # Input handling & movement
│
├── main.tscn                      # Root scene
└── main.gd                        # Game initialization & loop
```

### Target Structure for Meow Garden

```
Meow Garden/
├── core/                          # Core systems
│   ├── entity_manager.gd          # [OPTIMIZE] Add query caching
│   ├── garden_turn_manager.gd     # [RENAME] Add plant growth phase
│   └── garden_generator.gd        # [REPLACE] Generate garden layouts
│
├── components/                    # Game components
│   ├── actor_component.gd         # Keep as-is
│   ├── position_component.gd      # Keep as-is
│   ├── energy_component.gd        # [RENAME] from health_component
│   ├── garden_tool_component.gd   # [RENAME] from combat_component
│   ├── creature_ai_component.gd   # [EXTEND] Add SHY/CURIOUS behaviors
│   ├── plant_component.gd         # [NEW] Growth stages & watering
│   ├── weed_component.gd          # [NEW] Spreading mechanics
│   └── inventory_component.gd     # [NEW] Seeds & harvest storage
│
├── world/                         # Game world
│   ├── game_map.gd                # [UPDATE] Support 5 tile types
│   └── plant_renderer.gd         # [NEW] Optimized plant rendering
│
├── player/                        # Player
│   ├── garden_player.tscn         # [UPDATE] Cat sprite
│   └── garden_player.gd           # [EXTEND] 6 action types
│
├── ui/                            # User interface
│   ├── inventory_ui.gd            # [NEW] Inventory display
│   ├── action_buttons.gd          # [NEW] Mobile touch controls
│   └── hud.gd                     # [NEW] Energy/day counter
│
├── assets/                        # Game assets
│   ├── sprites/                   # Character & plant sprites
│   ├── tiles/                     # TileSet textures
│   └── audio/                     # Sound effects & music
│
├── main.tscn                      # Root scene
└── main.gd                        # [UPDATE] Initialize garden mode
```

***

## Strategic Migration Path

### Phase Priorities (3-4 Month Timeline)

**Week 1-2: Foundation**
- Refactor components (Health→Energy, Combat→GardenTool, AI→CreatureAI)
- Create PlantComponent with 5 growth stages
- Update TurnManager to GardenTurnManager with plant growth phase

**Week 3-4: World Generation**
- Replace DungeonGenerator with GardenGenerator
- Create TileSet with 5 types: GRASS(0), WATER(1), STONE_PATH(2), SOIL(3), FENCE(4)
- Update GameMap to handle new tile types

**Week 5-6: Player Actions**
- Extend Player script with 6 actions: MOVE, PLANT, WATER, HARVEST, REMOVE_WEED, INTERACT
- Implement InventoryComponent for seeds/crops
- Add energy consumption per action

**Week 7-10: Content & Polish**
- Create WeedComponent with spreading logic
- Add 3-5 plant types with unique growth times
- Implement mobile UI (touch controls, action buttons)
- Add visual feedback animations

**Week 11-12: Optimization & Testing**
- Implement EntityManager query caching
- Add SpritePool for plant entities
- Performance testing on target Android devices
- Bug fixing & balance tuning

***

## GDScript Best Practices[1][2][5]

### File Organization Rules

**Script Member Order:**
1. `@tool` annotation
2. `class_name` (PascalCase)
3. `extends`
4. Documentation comment in Russian
5. `signal` declarations (snake_case)
6. `enum` declarations (PascalCase, CONSTANT_CASE members)
7. `const` declarations (CONSTANT_CASE)
8. `@export` variables (snake_case)
9. Public variables (snake_case)
10. Private variables (`_snake_case` with underscore prefix)
11. `@onready` variables (snake_case)
12. Built-in methods: `_init()`, `_ready()`, `_process()`, etc.
13. Public methods (snake_case)
14. Private methods (`_snake_case`)
15. Inner classes (PascalCase)

**Naming Conventions:**
- Files/folders: `snake_case`
- Classes: `PascalCase`
- Methods/variables: `snake_case`
- Private members: `_snake_case`
- Constants/enums: `CONSTANT_CASE`
- Signals: `snake_case`

**Comment Requirements:**
- **CRITICAL:** All comments MUST be in Russian (Все комментарии на русском)
- Use `# Описание функции` for single-line comments
- Use docstrings for complex methods
- Explain WHY, not WHAT (code should be self-explanatory)

### Code Architecture Principles[2][5]

**Entity-Component-System (ECS):**
- Entities = ID + components (no behavior)
- Components = data only (extend Resource)
- Systems = process entities with specific components
- Benefits: Modular, data-driven, easy to extend

**Scene Organization:**
- Keep scenes focused on single responsibility
- Group related assets with scenes in same folder
- Use scene instancing for reusability
- Prefix exclusive resources with scene name (e.g., `garden_player_sprite.png`)

**Signal-Driven Communication:**
- Use signals to decouple systems
- Avoid long node path references (`$../../Parent/Child`)
- Connect signals in `_ready()` method
- Document signal purpose in Russian comments

**Autoload Guidelines:**
- Use for global managers only (EntityManager, TurnManager)
- Keep autoloads lightweight
- Avoid circular dependencies between autoloads
- Max 3-5 autoloads per project

***

## Game Design Strategy

### Core Gameplay Pillars

**1. Garden Management Cycle**
- Player plants seeds on SOIL tiles
- Plants require watering every 2-3 turns
- Growth progression: SEED → SPROUT → GROWING → MATURE → WITHERED
- Harvest at MATURE stage for best quality
- Weeds spread naturally, requiring removal

**2. Energy System**
- Replace HP with Energy (current/max)
- Actions cost energy: Move(5), Plant(10), Water(5), Harvest(8), Remove Weed(variable)
- Energy regenerates +5 per turn or via consumable items
- Depleted energy = forced rest turn

**3. Turn-Based Rhythm**
- Player acts → Plants grow → Creatures move (every 2 turns) → Turn ends
- 10 turns = 1 in-game day
- Day cycle triggers: energy restoration, new weed spawns, shop refresh

**4. Non-Violent Encounters**
- Creatures have behaviors: SHY (flee from player), CURIOUS (follow at distance), FRIENDLY (stationary, can pet)
- No combat damage - interaction rewards small bonuses
- Encourage exploration over confrontation

### Progression Systems

**Short-Term (Single Run):**
- Collect diverse crops for recipes
- Unlock new garden plots within current map
- Discover rare seed types from weeds

**Long-Term (Meta-Progression):**
- Permanent tool upgrades (faster watering, larger harvest radius)
- New plant species unlocked between runs
- Garden decoration customization
- Cat appearance customization

***

## Mobile Optimization Targets[11][12]

### Performance Requirements

| Metric | Target | Optimization Strategy |
|--------|--------|----------------------|
| App Size | <100MB | Compress textures, use atlases, minimal audio files |
| RAM Usage | <512MB | Object pooling, cached queries, limit active entities |
| Frame Rate | Stable 60 FPS | Batch rendering, MultiMesh for plants, cull off-screen |
| Battery Drain | <15%/hour | Limit particle effects, optimize physics checks |
| Load Time | <60 seconds | Preload critical assets, lazy load UI |

### Critical Optimizations

**EntityManager Query Caching:**
- Cache `get_entities_with_components()` results
- Invalidate cache on entity add/remove/component change
- Reduces CPU load by 40-60% for frequent queries

**Sprite Pooling:**
- Preallocate 100 Sprite2D nodes in pool
- Reuse sprites instead of instantiate/free
- Eliminates garbage collection pauses

**MultiMesh Rendering:**
- Batch plant sprites into single MultiMeshInstance2D
- Reduces draw calls from 500 to 1
- Implement after MVP if performance issues arise

**Spatial Partitioning:**
- Implement grid-based position lookup for collision checks
- Avoid iterating all entities for `_is_position_occupied()`
- Critical when >50 entities on screen

***

## Development Workflow

### Version Control (Git)
- Main branch: stable builds only
- Feature branches: `feature/plant-system`, `feature/inventory-ui`
- Commit messages in English (code comments in Russian)
- `.gitignore`: Include `.godot/`, `.import/`, `*.tmp`

### Testing Checklist
- [ ] All 6 player actions function correctly
- [ ] Plant growth advances properly per turn
- [ ] Energy consumption prevents unlimited actions
- [ ] Weeds spread at appropriate rate
- [ ] Inventory correctly stores/retrieves items
- [ ] No crashes on low-end Android devices (test on 2GB RAM device)
- [ ] Touch controls responsive on 5-6 inch screens
- [ ] App launches in <60 seconds cold start

### RuStore Deployment Requirements
- Comply with Russian data protection laws (Federal Law No. 152-FZ)
- Localize all UI text to Russian
- Payment integration via RuStore SDK
- Age rating: 3+ (wholesome content)
- Privacy policy addressing data collection

***

## Mind Map: Game Loop Visualization

```
START TURN
    ↓
PLAYER ACTION PHASE
    ├─→ Movement (5 energy)
    ├─→ Plant Seed (10 energy)
    ├─→ Water Plant (5 energy)
    ├─→ Harvest Crop (8 energy)
    ├─→ Remove Weed (5-15 energy)
    └─→ Interact with Creature (0 energy)
    ↓
PLANT GROWTH PHASE (automatic)
    ├─→ Watered plants: advance growth stage
    ├─→ Unwatered plants: decrease water level
    └─→ Withered plants: removed after 3 turns
    ↓
CREATURE MOVEMENT PHASE (every 2 turns)
    ├─→ SHY creatures: move away from player
    ├─→ CURIOUS creatures: maintain distance
    └─→ FRIENDLY creatures: stay still
    ↓
TURN END PROCESSING
    ├─→ Increment turn counter
    ├─→ Check day cycle (10 turns = 1 day)
    └─→ Restore player energy (+5)
    ↓
[IF DAY ENDS]
    ├─→ Full energy restoration
    ├─→ Spawn new weeds (2-4 random locations)
    └─→ Trigger daily events
    ↓
LOOP BACK TO START TURN
```

***

## Risk Assessment & Mitigation

| Risk Level | Issue | Mitigation Strategy |
|------------|-------|---------------------|
| 🔴 HIGH | ECS complexity for beginner | Extensive Russian comments, modular testing |
| 🔴 HIGH | Mobile performance bottlenecks | Implement pooling, caching from start |
| 🟡 MEDIUM | Procedural generation balance | Playtest with multiple seeds, tune parameters |
| 🟡 MEDIUM | Touch controls cramped on small screens | Large button targets (min 48x48dp), test on 5" device |
| 🟢 LOW | Asset creation workload | Use free/CC0 assets initially, placeholder art acceptable |
| 🟢 LOW | RuStore deployment complexity | Follow official documentation, test early |

***

## MVP Feature Scope

**MUST HAVE (Week 1-8):**
- Basic player movement on garden map
- Plant 2 seed types (fast-growing, slow-growing)
- Visible 5-stage plant growth
- Harvest mechanic with inventory storage
- Energy system limiting actions
- Procedural garden generation (4x3 plot grid)
- Save/load game state

**SHOULD HAVE (Week 9-12):**
- Watering mechanic affecting growth speed
- 2-3 weed types with spreading
- 1-2 creature types (SHY behavior only)
- Basic mobile UI (action buttons, inventory screen)
- Day/night cycle visual feedback
- Sound effects for actions

**NICE TO HAVE (Post-MVP):**
- 5+ plant varieties with unique properties
- Recipe crafting system
- Decorative garden items
- Multiple garden biomes
- Meta-progression upgrades
- Achievements

***

## AI Coding Instructions

When generating code for this project:

1. **Always write comments in Russian** - No exceptions
2. **Follow ECS pattern strictly** - Components are data-only, systems process them
3. **Use snake_case** for all GDScript identifiers
4. **Prefix private members** with underscore (`_private_method`)
5. **Order script members** according to best practices section
6. **Minimize node path references** - Use signals for communication
7. **Optimize for mobile** - Consider performance impact of every feature
8. **Keep methods focused** - Single responsibility principle
9. **Use type hints** - `var player_id: int`, `func get_position() -> Vector2i`
10. **Document complex logic** - Explain WHY in Russian comments

**Code Review Questions to Ask:**
- Can this be simplified without losing clarity?
- Will this scale to 100+ entities on mobile?
- Is this component data-only or does it contain logic?
- Are node paths hardcoded or using flexible references?
- Are all comments in Russian?

***

## Success Metrics

**Technical Targets:**
- Zero crashes on 5 test devices (2GB RAM minimum)
- 60 FPS maintained with 100 entities on screen
- <100MB APK size after compression
- <3 second scene transition times

**Gameplay Targets:**
- Playtest feedback: "Relaxing and cute" from 8/10 testers
- Average session length: 15-30 minutes
- 30-day retention: >15%
- Tutorial completion rate: >80%

**Business Targets (RuStore):**
- 1000 downloads in first month
- Average rating: >4.0 stars
- ARPU: >$0.50 (via ethical ads/IAP)
- <5% negative reviews citing crashes/bugs

***

## Quick Reference Commands

**Autoload Setup (Project Settings → Autoload):**
- EntityManager: `res://core/entity_manager.gd`
- GardenTurnManager: `res://core/garden_turn_manager.gd`

**Input Actions (Project Settings → Input Map):**
- `ui_up`, `ui_down`, `ui_left`, `ui_right` (movement)
- `action_plant` (Key: P)
- `action_water` (Key: W)
- `action_harvest` (Key: H)
- `action_remove` (Key: R)
- `action_interact` (Key: E)

**Export Settings (Project → Export):**
- Platform: Android
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Architectures: arm64-v8a, armeabi-v7a
- Permissions: INTERNET (for ads/analytics only)

***

## Final Notes

This project transforms a traditional roguelike dungeon crawler into a wholesome garden simulation while preserving the strong ECS foundation. The architecture is solid - focus energy on gameplay feel, visual polish, and mobile optimization. 

**Development Philosophy:** Iterate quickly, test on real devices early, and prioritize player enjoyment over technical perfection. The cute cat and cozy aesthetic will carry initial player interest - retain them with satisfying core loop.

**Time Estimate:** 3-4 months solo development at 30 hours/week to MVP. Add 1 month for asset creation and polish if creating original art.
