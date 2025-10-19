# ui/hud.gd
extends CanvasLayer

## Heads-Up Display для отображения основной игровой информации.
## Должен быть прикреплен к узлу CanvasLayer.

@onready var energy_label = $MarginContainer/VBoxContainer/EnergyLabel
@onready var day_label = $MarginContainer/VBoxContainer/DayLabel
@onready var turn_label = $MarginContainer/VBoxContainer/TurnLabel

var player_id: int = -1

func _ready():
	# Ищем ID игрока после инициализации мира
	var player_entities = EntityManager.get_entities_with_components([PlayerComponent])
	if not player_entities.is_empty():
		player_id = player_entities[0]
	
	# Подписываемся на конец хода, чтобы обновлять HUD
	GardenTurnManager.turn_ended.connect(_on_turn_ended)
	# Первоначальное обновление
	_on_turn_ended()

func _on_turn_ended():
	if player_id == -1:
		return

	# Обновление энергии
	var energy_comp: EnergyComponent = EntityManager.get_component(player_id, EnergyComponent)
	if energy_comp:
		energy_label.text = "Энергия: %d / %d" % [energy_comp.current_energy, energy_comp.max_energy]
	
	# Обновление дня и хода
	var turn = GardenTurnManager.turn_count
	var day = floor(turn / 10) + 1 # 10 ходов в дне
	day_label.text = "День: %d" % day
	turn_label.text = "Ход: %d" % turn
