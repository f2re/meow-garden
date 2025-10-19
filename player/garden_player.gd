# player/garden_player.gd
extends Node2D

## Управляет вводом игрока и выполнением действий.

var entity_id: int
var is_my_turn: bool = false

# Стоимость действий в энергии
const MOVE_COST = 5
const PLANT_COST = 10
const WATER_COST = 5
const HARVEST_COST = 8
const REMOVE_WEED_COST = 7

func _ready():
	# Подписываемся на сигнал о начале хода игрока
	GardenTurnManager.player_turn_started.connect(_on_player_turn_started)

func _on_player_turn_started():
	is_my_turn = true
	print("Ход игрока. Энергия: %d" % _get_energy().current_energy)

func _unhandled_input(event):
	if not is_my_turn:
		return

	var move_dir = Vector2i.ZERO
	if event.is_action_pressed("ui_up"): move_dir.y = -1
	elif event.is_action_pressed("ui_down"): move_dir.y = 1
	elif event.is_action_pressed("ui_left"): move_dir.x = -1
	elif event.is_action_pressed("ui_right"): move_dir.x = 1
	
	if move_dir != Vector2i.ZERO:
		get_viewport().set_input_as_handled()
		_try_action("MOVE", {"direction": move_dir})
	elif event.is_action_pressed("action_plant"):
		get_viewport().set_input_as_handled()
		_try_action("PLANT")
	elif event.is_action_pressed("action_water"):
		get_viewport().set_input_as_handled()
		_try_action("WATER")
	elif event.is_action_pressed("action_harvest"):
		get_viewport().set_input_as_handled()
		_try_action("HARVEST")
	elif event.is_action_pressed("action_remove"):
		get_viewport().set_input_as_handled()
		_try_action("REMOVE_WEED")
	elif event.is_action_pressed("action_interact"):
		get_viewport().set_input_as_handled()
		_try_action("INTERACT")

func _try_action(action_type: String, payload: Dictionary = {}):
	var energy_comp = _get_energy()
	var cost = 0
	
	match action_type:
		"MOVE": cost = MOVE_COST
		"PLANT": cost = PLANT_COST
		"WATER": cost = WATER_COST
		"HARVEST": cost = HARVEST_COST
		"REMOVE_WEED": cost = REMOVE_WEED_COST
		"INTERACT": cost = 0

	if energy_comp.current_energy < cost:
		print("Недостаточно энергии для действия '%s'!" % action_type)
		return

	var success = false
	match action_type:
		"MOVE": success = _execute_move(payload.get("direction", Vector2i.ZERO))
		"PLANT": success = _execute_plant()
		# ... Другие действия будут здесь ...
	
	if success:
		energy_comp.current_energy -= cost
		_end_turn()
	else:
		print("Действие '%s' не удалось." % action_type)
		# Если действие не удалось, ход не заканчивается

func _execute_move(direction: Vector2i) -> bool:
	var pos_comp = _get_position()
	var target_pos = Vector2i(pos_comp.x + direction.x, pos_comp.y + direction.y)
	
	var game_map = get_tree().root.get_node("Main/GameMap") # Путь может потребовать корректировки
	if not game_map.is_impassable(target_pos.x, target_pos.y):
		pos_comp.x = target_pos.x
		pos_comp.y = target_pos.y
		return true
	return false

func _execute_plant() -> bool:
	var pos_comp = _get_position()
	var inv_comp = _get_inventory()
	var game_map = get_tree().root.get_node("Main/GameMap")

	if game_map.is_soil(pos_comp.x, pos_comp.y) and inv_comp.has_item("seed_basic"):
		# Проверяем, нет ли уже растения на этом месте
		var entities_at_pos = EntityManager.get_entities_at_position(pos_comp.x, pos_comp.y)
		for id in entities_at_pos:
			if EntityManager.has_component(id, PlantComponent):
				print("Здесь уже что-то растет.")
				return false

		inv_comp.remove_item("seed_basic")
		var new_plant_id = EntityManager.create_entity()
		EntityManager.add_component(new_plant_id, PositionComponent.new(pos_comp.x, pos_comp.y))
		EntityManager.add_component(new_plant_id, PlantComponent.new())
		print("Посажено базовое семя.")
		return true
	
	print("Нельзя сажать здесь или нет семян.")
	return false

# --- Вспомогательные функции для получения компонентов ---
func _get_position() -> PositionComponent:
	return EntityManager.get_component(entity_id, PositionComponent)

func _get_energy() -> EnergyComponent:
	return EntityManager.get_component(entity_id, EnergyComponent)

func _get_inventory() -> InventoryComponent:
	return EntityManager.get_component(entity_id, InventoryComponent)

func _end_turn():
	is_my_turn = false
	GardenTurnManager.end_player_turn()