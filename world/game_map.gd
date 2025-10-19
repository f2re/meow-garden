# world/game_map.gd
extends Node2D

## Управляет отображением карты и проверкой проходимости.
## Должен быть прикреплен к Node2D с дочерним TileMap.

@onready var tilemap: TileMap = $TileMap

# Настройте ID источника тайлов в TileSet (см. world/garden_tileset.tres -> sources/3)
const TILESET_SOURCE_ID = 3
const TILE_LAYER = 0

# Координаты атласа для каждого типа тайла
const TILE_GRASS_COORD = Vector2i(0, 0)
const TILE_WATER_COORD = Vector2i(1, 0)
const TILE_STONE_PATH_COORD = Vector2i(2, 0)
const TILE_SOIL_COORD = Vector2i(3, 0)
const TILE_FENCE_COORD = Vector2i(4, 0)

var map_data: PackedInt32Array
var map_width: int
var map_height: int

# Словарь для сопоставления типа тайла с его атласными координатами
var tile_coords = {
	GardenGenerator.TileType.GRASS: TILE_GRASS_COORD,
	GardenGenerator.TileType.WATER: TILE_WATER_COORD,
	GardenGenerator.TileType.STONE_PATH: TILE_STONE_PATH_COORD,
	GardenGenerator.TileType.SOIL: TILE_SOIL_COORD,
	GardenGenerator.TileType.FENCE: TILE_FENCE_COORD,
}

# Отрисовывает карту на основе данных из GardenGenerator
func draw_map(data: PackedInt32Array, width: int, height: int):
	map_data = data
	map_width = width
	map_height = height
	
	tilemap.clear()
	for y in range(height):
		for x in range(width):
			var tile_type = map_data[y * width + x]
			var atlas_coord = tile_coords.get(tile_type, TILE_GRASS_COORD) # По умолчанию трава
			tilemap.set_cell(TILE_LAYER, Vector2i(x, y), TILESET_SOURCE_ID, atlas_coord)

# Проверяет, является ли тайл непроходимым
func is_impassable(x: int, y: int) -> bool:
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return true # Границы карты непроходимы
	
	var tile_type = map_data[y * map_width + x]
	return tile_type in [GardenGenerator.TileType.WATER, GardenGenerator.TileType.FENCE]

# Проверяет, можно ли сажать на данном тайле
func is_soil(x: int, y: int) -> bool:
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return false
	
	return map_data[y * map_width + x] == GardenGenerator.TileType.SOIL
