# main.gd
extends Node

## Главный скрипт игры.
## Отвечает за инициализацию игрового мира, сущностей и запуск игрового цикла.
#
# Сцена должна иметь следующую структуру:
# - Main (Node, этот скрипт)
#   - GameMap (Node2D, скрипт game_map.gd)
#     - TileMap (TileMap)
#   - Entities (Node2D) - для игрока и существ
#   - PlantRenderer (Node2D, скрипт plant_renderer.gd)
#   - UI (CanvasLayer)

const MAP_WIDTH = 50
const MAP_HEIGHT = 30

const PLAYER_SCENE = preload("res://player/garden_player.tscn")

@onready var game_map_node = $GameMap
@onready var entities_node = $Entities
@onready var plant_renderer_node = $PlantRenderer

var player_id: int

func _ready():
	# 1. Генерируем данные сада
	var garden_gen = GardenGenerator.new()
	var map_data = garden_gen.generate(MAP_WIDTH, MAP_HEIGHT)
	
	# 2. Отрисовываем карту
	game_map_node.draw_map(map_data, MAP_WIDTH, MAP_HEIGHT)
	
	# 3. Создаем сущность игрока
	var player_start_pos = garden_gen.get_random_soil_position()
	player_id = _create_player_entity(player_start_pos)
	
	# 4. Создаем несколько существ
	_create_creatures(5)

	# 5. Запускаем основной игровой цикл
	GardenTurnManager.start_game()
	
	# 6. Обновляем рендерер растений
	plant_renderer_node._redraw_all_plants()


# Синхронизирует визуальное положение узлов с данными в компонентах
func _process(_delta):
	var entities_with_pos = EntityManager.get_entities_with_components([PositionComponent])
	for entity_id in entities_with_pos:
		# Пропускаем растения, так как они отрисовываются через PlantRenderer
		if EntityManager.has_component(entity_id, PlantComponent):
			continue
			
		var entity_node = entities_node.get_node_or_null(str(entity_id))
		if entity_node:
			var pos_comp: PositionComponent = EntityManager.get_component(entity_id, PositionComponent)
			# Умножаем на размер тайла для преобразования координат сетки в мировые
			entity_node.position = Vector2(pos_comp.x, pos_comp.y) * 16 # Предполагаем размер тайла 16x16


func _create_player_entity(start_pos: Vector2i) -> int:
	var id = EntityManager.create_entity()
	
	# Добавляем компоненты
	EntityManager.add_component(id, PlayerComponent.new())
	EntityManager.add_component(id, PositionComponent.new(start_pos.x, start_pos.y))
	EntityManager.add_component(id, EnergyComponent.new(100, 100))
	EntityManager.add_component(id, InventoryComponent.new())
	
	# Добавляем стартовые семена
	var inv: InventoryComponent = EntityManager.get_component(id, InventoryComponent)
	inv.add_item("seed_basic", 5)

	# Создаем экземпляр сцены игрока
	var player_instance = PLAYER_SCENE.instantiate()
	player_instance.name = str(id)
	player_instance.entity_id = id
	entities_node.add_child(player_instance)
	
	return id

func _create_creatures(count: int):
	for i in range(count):
		var pos = Vector2i(randi_range(1, MAP_WIDTH - 2), randi_range(1, MAP_HEIGHT - 2))
		# Убедимся, что не ставим существо в стену
		if game_map_node.is_impassable(pos.x, pos.y):
			continue
		_create_creature_entity(pos, "Котик")

func _create_creature_entity(pos: Vector2i, name: String):
	var id = EntityManager.create_entity()
	
	EntityManager.add_component(id, PositionComponent.new(pos.x, pos.y))
	EntityManager.add_component(id, EnergyComponent.new(50, 50))
	
	var ai_comp = CreatureAIComponent.new()
	ai_comp.behavior = [CreatureAIComponent.Behavior.PASSIVE, CreatureAIComponent.Behavior.SHY].pick_random()
	EntityManager.add_component(id, ai_comp)

	# Временно создаем простой спрайт для существа
	var creature_sprite = Sprite2D.new()
	creature_sprite.texture = load("res://player/tile_0006.png") # Используем спрайт игрока как временный
	creature_sprite.modulate = Color.ORANGE
	creature_sprite.name = str(id)
	entities_node.add_child(creature_sprite)