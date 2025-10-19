# components/creature_ai_component.gd
class_name CreatureAIComponent
extends Resource

## Компонент искусственного интеллекта для существ.
## Определяет поведение существа в игровом мире.

enum Behavior {
	PASSIVE,  # Пассивное поведение, существо неподвижно.
	SHY,      # Пугливое поведение, существо убегает от игрока.
	CURIOUS   # Любопытное поведение, существо следует за игроком на расстоянии.
}

@export var behavior: Behavior = Behavior.PASSIVE