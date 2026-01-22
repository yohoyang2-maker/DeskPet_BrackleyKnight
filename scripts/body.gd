extends Area2D
# 在 Inspector 里可直接配置对话时间线
@export var timelines: Array[String] = []
# 随机数范围（默认 7 → 生成 0 ~ 6）	#配合对话用
@export var random_range: int = 7
func _ready():
	# 连接点击事件
	input_event.connect(_on_input_event)
func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if State.is_sleeping:	# 唤醒睡眠模式
			Dialogic.start("wakeup")
		State.on_dialogue_triggered()	# reset睡眠时钟
		if timelines.is_empty():
			push_warning("Timelines 数组为空，请在 Inspector 中添加！")
			return
		var choice = timelines.pick_random()	# 随机抽取对话

		# 如果 random_range <= 0，避免报错
		var r = 0
		if random_range > 0:
			r = randi() % random_range
		Dialogic.VAR.set("random", r)	#将随机数传入Dialogic，作为Dialogic中的变量'random'

		State.start_dialogue(choice)
