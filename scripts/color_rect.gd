extends ColorRect

func _ready() -> void:
	State.colorrect = self
	# 初始状态：确保颜色是黑色，且高度为 0（不遮挡屏幕）
	color = Color.BLACK
	size.y = 0
	size.x = 360 # 确保宽度覆盖屏幕

# 核心：关闭程序的动画效果
func play_close_effect() -> void:
	# 确保它在最上层显示（可选）
	z_index = 100 
	
	var tween = create_tween()
	# 设置动画曲线：向外减速，看起来更平滑
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# 在 0.8 秒内，高度从 0 变到 360
	tween.tween_property(self, "size:y", 360, 0.8)
