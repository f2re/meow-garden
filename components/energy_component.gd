# components/energy_component.gd
class_name EnergyComponent
extends Resource

## Компонент для управления энергией существа.
## current_energy - текущее количество энергии.
## max_energy - максимальное количество энергии.

@export var current_energy: int = 100
@export var max_energy: int = 100

func _init(c_energy: int = 100, m_energy: int = 100):
	current_energy = c_energy
	max_energy = m_energy