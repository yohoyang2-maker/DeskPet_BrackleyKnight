extends Node

#---拖拽---
var is_dragging = false
var click_start_pos = Vector2i.ZERO
var window_start_pos = Vector2i.ZERO
var target_window_pos = Vector2.ZERO
var smooth_speed : float = 15.0 

func _ready():
	# 初始化目标位置
	target_window_pos = Vector2(get_window().position)

func _process(delta: float) -> void:
	# --- 这里的 lerp 逻辑完全不用变 ---
	var current_pos = Vector2(get_window().position)
	var new_pos = current_pos.lerp(target_window_pos, smooth_speed * delta)
	get_window().position = Vector2i(new_pos.round())

func _input(event):
	# --- 鼠标移动更新目标逻辑 ---
	if is_dragging and event is InputEventMouseMotion:
		var mouse_pos = DisplayServer.mouse_get_position()
		var diff = mouse_pos - click_start_pos
		target_window_pos = Vector2(window_start_pos + diff)
	
	# 这样写比你原来在 Area2D 里写 else 更稳，防止鼠标甩飞
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false

# --- 【关键】这是留给 Node2D 调用的“接口” ---
func start_drag():
	is_dragging = true
	# 记录起始状态
	click_start_pos = DisplayServer.mouse_get_position()
	window_start_pos = get_window().position
