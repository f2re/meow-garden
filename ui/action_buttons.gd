# ui/action_buttons.gd
extends CanvasLayer

## Пользовательский интерфейс для кнопок действий на мобильных устройствах.
## Должен быть прикреплен к узлу CanvasLayer.

signal action_pressed(action_name)

func _ready():
	# Подключаем сигналы от всех кнопок в сцене
	$MoveButtons/Up.pressed.connect(_on_button_pressed.bind("ui_up"))
	$MoveButtons/Down.pressed.connect(_on_button_pressed.bind("ui_down"))
	$MoveButtons/Left.pressed.connect(_on_button_pressed.bind("ui_left"))
	$MoveButtons/Right.pressed.connect(_on_button_pressed.bind("ui_right"))
	
	$ActionButtons/Plant.pressed.connect(_on_button_pressed.bind("action_plant"))
	$ActionButtons/Water.pressed.connect(_on_button_pressed.bind("action_water"))
	$ActionButtons/Harvest.pressed.connect(_on_button_pressed.bind("action_harvest"))
	# ... и так далее для остальных кнопок

func _on_button_pressed(action_name: String):
	# Создаем искусственное событие ввода
	var event = InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)
	
	# Короткая задержка, чтобы симулировать отпускание клавиши
	await get_tree().create_timer(0.1).timeout
	event.pressed = false
	Input.parse_input_event(event)
