extends Node

enum Language {ES, EN}

signal language_changed(new_value)

func get_key(value: int) -> String:
	match value:
		Language.ES:
			return 'es'
		Language.EN:
			return 'en'
	# El valor colchón
	return 'es'
