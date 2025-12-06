extends Node

const SAVE_PATH := "user://leaderboard.json"

var _entries: Array = []

func _ready() -> void:
	load_scores()

# Envia um resultado para o placar
func submit_score(player_name: String, points: int, sprite: String, extra: Dictionary = {}) -> void:
	var entry := {
		"name": player_name,
		"points": points,
		"sprite": sprite
	}

	# Campos extras opcionais
	for k in extra.keys():
		entry[k] = extra[k]

	_entries.append(entry)
	_sort_and_trim()
	save_scores()

# Retorna os top X
func get_top(limit: int = 10) -> Array:
	return _entries.slice(0, min(limit, _entries.size()))

# Limpa tudo
func clear_all() -> void:
	_entries.clear()
	save_scores()


func load_scores() -> void:
	_entries.clear()
	
	if FileAccess.file_exists(SAVE_PATH):
		var text := FileAccess.get_file_as_string(SAVE_PATH)
		var data: Variant = JSON.parse_string(text)
		
		if typeof(data) == TYPE_ARRAY:
			for d in data:
				if typeof(d) == TYPE_DICTIONARY and d.has("name") and d.has("points"):
					# Garante que existe sprite (se não, cria vazio)
					if not d.has("sprite"):
						d["sprite"] = ""
					_entries.append(d)
	
	_sort_and_trim()

func save_scores() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(_entries, "  "))
		f.flush()
		f.close()

func _sort_and_trim() -> void:
	# Ordena por:
	# 1. points DESC (maior primeiro)
	# 3. name ASC (estável)
	_entries.sort_custom(Callable(self, "_cmp_entry"))
	
	# Limita a 50 entradas
	if _entries.size() > 50:
		_entries = _entries.slice(0, 50)

func _cmp_entry(a: Dictionary, b: Dictionary) -> bool:
	var pa: int = int(a.get("points", 0))
	var pb: int = int(b.get("points", 0))

	if pa != pb:
		return pa > pb  # maior pontuação primeiro

	# desempate final por nome só para estabilidade
	return String(a.get("name", "")) < String(b.get("name", ""))
