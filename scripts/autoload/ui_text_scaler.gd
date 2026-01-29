extends Node

@export var scale: float = 1.5
@export var batch_size: int = 40 # how many controls to scale per frame

var _queue: Array = []

func _ready() -> void:
	# Assure l'initialisation de la file (prévenir Nil si reload inattendu)
	if _queue == null:
		_queue = []

	# Collecte initiale des controls (mise en file) puis surveille les nouveaux nœuds
	get_tree().connect("node_added", Callable(self, "_on_node_added"))
	_collect_controls(get_tree().get_root())

func _process(delta: float) -> void:
	# Traite la file par petits lots pour éviter de bloquer la frame
	if _queue == null:
		_queue = []
		return

	var processed := 0
	while _queue.size() > 0 and processed < batch_size:
		# Check the head of the queue for validity before popping/assigning
		var maybe_node = _queue[0]
		if not is_instance_valid(maybe_node):
			# Remove invalid entries without counting them towards the batch
			_queue.pop_front()
			continue
		# Safe to pop now
		var control = _queue.pop_front()
		if control and control is Control:
			_scale_control(control)
		processed += 1

func _on_node_added(node: Node) -> void:
	if node is Control and is_instance_valid(node):
		if _queue == null:
			_queue = []
		_queue.append(node)

func _collect_controls(root: Node) -> void:
	for child in root.get_children():
		if child is Control and is_instance_valid(child):
			if _queue == null:
				_queue = []
			_queue.append(child)
		# recurse only if child is valid
		if is_instance_valid(child):
			_collect_controls(child)

func _scale_control(control: Control) -> void:
	if not is_instance_valid(control):
		return
	# Évite le double redimensionnement
	if control.has_meta("_ui_text_scaled"):
		return
	control.set_meta("_ui_text_scaled", true)

	# Tente de lire la taille de police définie dans le thème pour ce contrôle
	var cur_size := 0
	if control.has_method("get_theme_font_size"):
		cur_size = control.get_theme_font_size("font_size")
	if cur_size > 0:
		var new_size := int(max(8, round(cur_size * scale)))
		control.add_theme_font_size_override("font_size", new_size)
		return

	# Valeurs par défaut pour les types de contrôles courants
	var default_size := 14
	if control is Label:
		default_size = 16
	elif control is Button:
		default_size = 15
	elif control is LineEdit:
		default_size = 14
	elif control is RichTextLabel:
		default_size = 16

	control.add_theme_font_size_override("font_size", int(round(default_size * scale)))
