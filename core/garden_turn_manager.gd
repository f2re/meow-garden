# core/garden_turn_manager.gd
# Этот скрипт должен быть добавлен как Autoload (синглтон) с именем "GardenTurnManager"
extends Node

signal player_turn_started
signal creature_turn_started
signal turn_ended

var turn_count: int = 0
var player_entity_id: int = -1
var creature_entity_ids: Array[int] = []

func _ready():
	# Предполагается, что EntityManager уже готов
	# В реальной игре стоит убедиться в порядке инициализации
	pass

func start_game():
	player_entity_id = EntityManager.get_entities_with_components([PlayerComponent])[0]
	creature_entity_ids = EntityManager.get_entities_with_components([CreatureAIComponent])
	_start_player_turn()

func end_player_turn():
	_process_plant_growth()
	_start_creature_turn()

func _start_player_turn():
	turn_count += 1
	print("--- Новый ход: %d ---" % turn_count)
	emit_signal("player_turn_started")

func _process_plant_growth():
	# --- Фаза Роста Растений ---
	var plant_entities = EntityManager.get_entities_with_components([PlantComponent])
	for plant_id in plant_entities:
		var plant: PlantComponent = EntityManager.get_component(plant_id, PlantComponent)
		
		if plant.growth_stage == PlantComponent.GrowthStage.WITHERED:
			continue

		if plant.is_watered:
			plant.growth_progress += 1
			plant.is_watered = false # Растение использует воду для роста
			print("Растение %d растет. Прогресс: %d/%d" % [plant_id, plant.growth_progress, plant.time_to_grow])
		
		if plant.growth_progress >= plant.time_to_grow:
			plant.growth_progress = 0
			var next_stage_index = plant.growth_stage + 1
			if next_stage_index < PlantComponent.GrowthStage.size():
				plant.growth_stage = next_stage_index
				print("Растение %d перешло в новую стадию роста!" % plant_id)
			else:
				plant.growth_stage = PlantComponent.GrowthStage.MATURE


func _start_creature_turn():
	# --- Фаза Существ ---
	# В будущем здесь будет логика для каждого существа
	print("Ход существ. На данный момент они ничего не делают.")
	emit_signal("creature_turn_started")
	_end_turn()

func _end_turn():
	emit_signal("turn_ended")
	# Начинаем следующий ход игрока
	_start_player_turn()
