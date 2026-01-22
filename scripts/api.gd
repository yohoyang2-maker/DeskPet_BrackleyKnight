extends Node

# 获取子节点
@onready var http_request: HTTPRequest = $HTTPRequest
@onready var timer: Timer = $Timer

# 天气 API 地址 (format=%t 只返回温度，如 +20°C)
# 如果网络卡顿，可以将 https 改为 http 尝试
const WEATHER_URL = "https://wttr.in/Shanghai?format=%t"

func _ready() -> void:
	print("--- 天气系统启动 ---")
	
	# 1. 配置定时器：30分钟 = 1800秒 (测试时可改为 5.0 秒)
	timer.wait_time = 180.0 
	timer.one_shot = false
	timer.autostart = true
	
	# 2. 连接信号 (使用代码连接更稳健)
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)
		
	if not http_request.request_completed.is_connected(_on_request_completed):
		http_request.request_completed.connect(_on_request_completed)
	
	# 3. 游戏开始时立即查一次天气
	_on_timer_timeout()

func _on_timer_timeout() -> void:
	# 如果当前正在对话，就跳过这次，等下次定时器触发（或者延时重试）
	if State.in_dialogue:
		print("当前正在对话，跳过天气更新")
		return
		
	print("正在获取天气数据...")
	var error = http_request.request(WEATHER_URL)
	if error != OK:
		print("请求发起失败，错误码: ", error)

func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	# 检查网络请求是否成功 (200 = OK)
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var temp_text = body.get_string_from_utf8().strip_edges()
		print("获取成功，气温: ", temp_text)
		_show_weather_bubble(temp_text)
	else:
		print("获取失败，HTTP 状态码: ", response_code)

func _show_weather_bubble(temp_text: String) -> void:
	# 1. 唤醒人物（重置睡眠时钟等）
	State.on_dialogue_triggered()
	
	# 2. 【核心】将获取到的温度塞进 Dialogic 的变量里
	# 这里的 "WeatherTemp" 必须和你 Dialogic 变量页里设置的名字一模一样
	Dialogic.VAR.set_variable("WeatherTemp", temp_text)
	
	# 3. 启动你预设好的 timeline
	# 使用 State.start_dialogue 来统一管理状态
	var layout = State.start_dialogue("tapi")
	
	# 4. 气泡跟随逻辑 (复用你之前的代码)
	if layout and State.player:
		var marker = State.player.get_node_or_null("Marker2D")
		var knight_res = load("res://character/knight.dch")
		
		# 确保 layout 支持气泡功能再注册
		if marker and layout.has_method("register_character"):
			layout.register_character(knight_res, marker)
			print("气泡已定位到人物头顶")
