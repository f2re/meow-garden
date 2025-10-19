# world/plant_renderer.gd
extends Node2D

## Оптимизированный рендерер для растений.
## Использует MultiMeshInstance2D для отрисовки всех растений за один вызов.

@export var plant_texture: Texture2D
@onready var multimesh_instance: MultiMeshInstance2D = $MultiMeshInstance2D

var plant_positions: PackedVector2Array = []

func _ready():
	# Настройка MultiMesh
	var multimesh = MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_2D
	multimesh.mesh = _create_quad_mesh()
	multimesh_instance.multimesh = multimesh
	
	# Подписываемся на изменения в мире
	EntityManager.entity_component_added.connect(_on_entity_changed)
	EntityManager.entity_component_removed.connect(_on_entity_changed)

func _create_quad_mesh() -> Mesh:
	var quad = QuadMesh.new()
	# Размер квадрата должен соответствовать размеру спрайта растения
	quad.size = Vector2(16, 16) 
	return quad

func _on_entity_changed(entity_id, component):
	# Обновляем, только если изменился компонент растения или позиции
	if not (component is PlantComponent or component is PositionComponent):
		return
	
	# Простое полное обновление. Можно оптимизировать.
	_redraw_all_plants()

func _redraw_all_plants():
	var plant_entities = EntityManager.get_entities_with_components([PlantComponent, PositionComponent])
	
	multimesh_instance.multimesh.instance_count = plant_entities.size()
	
	var i = 0
	for id in plant_entities:
		var pos_comp: PositionComponent = EntityManager.get_component(id, PositionComponent)
		var plant_comp: PlantComponent = EntityManager.get_component(id, PlantComponent)
		
		var transform = Transform2D()
		# Позиция в мире (предполагается, что размер тайла 16x16)
		transform.origin = Vector2(pos_comp.x * 16, pos_comp.y * 16)
		
		# Здесь можно добавить логику для выбора разных спрайтов
		# в зависимости от стадии роста (plant_comp.growth_stage)
		
		multimesh_instance.multimesh.set_instance_transform_2d(i, transform)
		i += 1
