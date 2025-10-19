# components/plant_component.gd
class_name PlantComponent
extends Resource

## Компонент для растений.
## Отвечает за стадии роста и состояние полива.

enum GrowthStage {
	SEED,     # Семя
	SPROUT,   # Росток
	GROWING,  # Растущее
	MATURE,   # Зрелое
	WITHERED  # Увядшее
}

@export var growth_stage: GrowthStage = GrowthStage.SEED
@export var is_watered: bool = false
@export var growth_progress: float = 0.0
@export var time_to_grow: float = 10.0 # Время для роста в ходах
