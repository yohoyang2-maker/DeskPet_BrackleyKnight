extends Node

# --- 节点引用 ---
# 注意：请务必在编辑器 (Inspector) 中将人物的 AnimatedSprite2D 拖到这里
var player: AnimatedSprite2D 
@export var colorrect: ColorRect

# --- 对话与状态变量 ---
var in_dialogue: bool = false
@export var sleep_timeout: float = 300.0 # 默认 5 分钟进入睡眠
var sleep_timer: Timer
var is_sleeping: bool = false

func _ready() -> void:
	# 1. 初始化睡眠监控
	enable_sleep_monitor()
	
	# 2. 【关键】在全局初始化时连接信号，避免重复连接报错
	# 信号只需连接一次，游戏运行期间一直有效
	if Dialogic.has_signal("timeline_ended"):
		Dialogic.timeline_ended.connect(_on_dialogue_end)
	if Dialogic.has_signal("signal_event"):
		Dialogic.signal_event.connect(_on_dialogic_signal)

# --- 对话核心逻辑 ---

func start_dialogue(timeline):
	# 如果已经在对话中，直接返回 null 阻止重复触发
	if in_dialogue:
		return null
	
	in_dialogue = true
	
	# 启动并获取 Layout (用于后续 register_character 气泡定位)
	var layout = Dialogic.start(timeline)
	return layout

func _on_dialogue_end() -> void:
	in_dialogue = false
	set_player_state("idle") # 对话结束恢复默认动作
	reset_sleep_timer()     # 重点：对话完重新开始计算睡眠倒计时

func _on_dialogic_signal(signal_name: String) -> void:
	# 处理 Dialogic 里的自定义信号
	if signal_name == "change":
		_trigger_transition_effect()
	else:
		set_player_state(signal_name)

# --- 人物动作控制 ---

func set_player_state(state: String) -> void:
	if player == null: return
	
	match state:
		"idle", "roll", "hurt", "death":
			player.play(state)
		_:
			player.play(state) # 允许传递自定义动画名

func _trigger_transition_effect() -> void:
	if colorrect == null: return
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(colorrect, "size:y", 360, 0.25)
	tween.tween_property(colorrect, "size:y", 0, 0.25).set_delay(0.2)

# --- 睡眠模式逻辑 ---

func enable_sleep_monitor() -> void:
	sleep_timer = Timer.new()
	sleep_timer.one_shot = true
	add_child(sleep_timer)
	sleep_timer.timeout.connect(_on_sleep_timeout)
	reset_sleep_timer()

func reset_sleep_timer() -> void:
	if sleep_timer:
		sleep_timer.start(sleep_timeout)

func _on_sleep_timeout() -> void:
	enter_sleep_mode()

func enter_sleep_mode() -> void:
	if not is_sleeping and not in_dialogue:
		is_sleeping = true
		set_player_state("death") # 切换到睡眠/待机差分

func wake_up() -> void:
	if is_sleeping:
		is_sleeping = false
		set_player_state("idle")
	reset_sleep_timer()

func on_dialogue_triggered() -> void:
	# 当点击触发对话时调用
	wake_up()
	reset_sleep_timer()
