# core/garden_generator.gd
class_name GardenGenerator
extends RefCounted

## Утилитарный класс для генерации садовых карт.
## Создает простую сетку с различными типами почвы.

enum TileType {
	GRASS,      # Трава (проходимая)
	WATER,      # Вода (непроходимая)
	STONE_PATH, # Каменная дорожка (проходимая)
	SOIL,       # Почва (можно сажать)
	FENCE       # Забор (непроходимый)
}

var map_data: PackedInt32Array
var map_width: int
var map_height: int
var rng = RandomNumberGenerator.new()

func generate(width: int, height: int, seed_val: int = 0) -> PackedInt32Array:
	map_width = width
	map_height = height
	if seed_val != 0:
		rng.seed = seed_val
	
	map_data.resize(width * height)
	
	# Основное заполнение травой
	map_data.fill(TileType.GRASS)
	
	# Создание центральной области с почвой
	var soil_rect = Rect2i(3, 3, width - 6, height - 6)
	_carve_rect(soil_rect, TileType.SOIL)
	
	# Создание дорожки вокруг почвы
	var path_rect = soil_rect.grow(1)
	_carve_rect(path_rect, TileType.STONE_PATH)
	# Возвращаем почву, так как дорожка ее перезаписала
	_carve_rect(soil_rect, TileType.SOIL)

	# Добавление забора по периметру
	_create_fence()

	# Добавление небольшого пруда
	_create_pond(Vector2i(width - 5, height - 5), 3)
	
	return map_data

func _carve_rect(rect: Rect2i, tile: TileType):
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x >= 0 and x < map_width and y >= 0 and y < map_height:
				map_data[y * map_width + x] = tile

func _create_fence():
	for x in range(map_width):
		map_data[0 * map_width + x] = TileType.FENCE
		map_data[(map_height - 1) * map_width + x] = TileType.FENCE
	for y in range(map_height):
		map_data[y * map_width + 0] = TileType.FENCE
		map_data[y * map_width + map_width - 1] = TileType.FENCE

func _create_pond(center: Vector2i, radius: int):
	for y in range(center.y - radius, center.y + radius):
		for x in range(center.x - radius, center.x + radius):
			if Vector2(x, y).distance_to(center) < radius and rng.randf() > 0.2:
				if x > 0 and x < map_width -1 and y > 0 and y < map_height -1:
					map_data[y * map_width + x] = TileType.WATER

func get_random_soil_position() -> Vector2i:
	var soil_positions: Array[Vector2i] = []
	for y in range(map_height):
		for x in range(map_width):
			if map_data[y * map_width + x] == TileType.SOIL:
				soil_positions.append(Vector2i(x, y))
	
	if soil_positions.is_empty():
		return Vector2i.ZERO
	
	return soil_positions.pick_random()