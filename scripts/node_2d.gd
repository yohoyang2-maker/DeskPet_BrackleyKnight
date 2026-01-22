extends Node2D

@onready var knight = preload("res://character/knight.dch")
@export var timelines: Array[String] = ["body1","body2","body3","body4","body5"]

# 不要在这里 pick_random，否则永远是同一个

func _ready() -> void:
	State.player = $AnimatedSprite2D 
	pass


func _on_area_2d_input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# 1. 触发拖拽逻辑
			Global.start_drag() 
			
			# 2. 只有在没有对话时，才随机启动新对话（防止点一下出一堆气泡）
			if not State.in_dialogue:
				# 每次点击时重新随机选择一个 timeline
				var _random_name = timelines.pick_random()
				
				# 调用你全局脚本里的启动函数（确保你用了之前那个带 return 的版本）
				var layout = Dialogic.start(_random_name)
				
				# 3. 定位气泡
				if layout:
					layout.register_character(knight, $AnimatedSprite2D)
					
		#var layout = Dialogic.start(random_timeline)#定位气泡
		#layout.register_character(knight,$AnimatedSprite2D/Marker2D)				
				# 4. 通知全局脚本：现在有对话了，重置睡眠时钟
				State.on_dialogue_triggered()


func _on_button_pressed() -> void:
	State.set_player_state("death")
	$ColorRect.play_close_effect()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
