# ui/inventory_ui.gd
extends CanvasLayer

## Пользовательский интерфейс для отображения инвентаря игрока.
## Должен быть прикреплен к узлу CanvasLayer.

@onready var grid_container = $MarginContainer/GridContainer

# Префаб для одного слота инвентаря (например, Panel с Label внутри)
const INVENTORY_SLOT_SCENE = preload("res://ui/inventory_slot.tscn")

func _ready():
	# Скрываем инвентарь по умолчанию
	visible = false
	# Подписываемся на событие обновления инвентаря
	# (нужно будет создать этот сигнал в InventoryComponent)
	# InventoryComponent.inventory_changed.connect(update_ui)

func update_ui(inventory_comp: InventoryComponent):
	# Очищаем старые слоты
	for child in grid_container.get_children():
		child.queue_free()
	
	# Создаем новые слоты для каждого предмета
	for item_id in inventory_comp.items:
		var count = inventory_comp.get_item_count(item_id)
		
		var slot = INVENTORY_SLOT_SCENE.instantiate()
		slot.get_node("ItemName").text = item_id
		slot.get_node("ItemCount").text = "x%d" % count
		grid_container.add_child(slot)

func _unhandled_input(event):
	if event.is_action_just_pressed("toggle_inventory"):
		visible = not visible
