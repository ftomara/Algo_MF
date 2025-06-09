extends Control
#a709aa j
#ffa9fc i
#6212a386
var ANIMATION_DURATION = 0.4
var ANIMATION_DELAY = 0.01
@onready var label = $Background/MarginContainer/Rows/GameInfo/MarginContainer/Label
#@onready var settings = $settings
@onready var algo_option = $algo_option
@onready var info = $info
@onready var speed = $speed
@onready var speedMenu = $SpeedMenu
@onready var MenuOptions = $MenuOptions

var whoosh  = preload("res://sounds/whoosh-6316.mp3")
var sorted = preload("res://sounds/sorted.mp3")
var swaped = preload("res://sounds/swish.mp3")
var audio = AudioStreamPlayer.new()
#@onready var option_button = $OptionButton
var InputResponseCols = preload("res://scenes/input_response_cols.tscn")
#@onready var history = $Background/MarginContainer/Rows/GameInfo/MarginContainer/HBoxContainer
@onready var history = $Background/MarginContainer/Rows/GameInfo/CenterContainer/HBoxContainer
var style_box = StyleBoxFlat.new()
var style_box2 = StyleBoxFlat.new()
var style_box3= StyleBoxFlat.new()
var delay_timer
var sprites = []
var arr : Array 
var arr2 : Array 
# Called when the node enters the scene tree for the first time.
func _ready():
	style_box.set_bg_color(Color("#86fa8f86")) #green
	style_box.set_bg_color(Color("#86fa8f86")) #green
	style_box.set_corner_radius_all(8)
	style_box.set_border_width_all(3)
	style_box.set_border_color(Color("#ffffffff"))

	style_box2.set_bg_color(Color("#d7bbfe"))# purble  4d17b886
	style_box2.set_corner_radius_all(8)
	style_box2.set_border_width_all(3)
	style_box2.set_border_color(Color("#ffffffff"))
	
	style_box3.set_bg_color(Color("#96c8ff86"))#blue
	style_box3.set_corner_radius_all(8)
	style_box3.set_border_width_all(3)
	style_box3.set_border_color(Color("#ffffffff"))
	label.add_theme_color_override("font_color",Color("#a577f4"))			
	label.set("theme_override_font_sizes/font_size",50)	
	add_child(audio)
	drop_menu()
	#settings_menu()
func drop_menu():
	algo_option.add_item("  Bubble Sort")
	algo_option.add_item("  Insertion Sort")
	algo_option.add_item("  Selection Sort")	

func insertion_sort():
	var n = arr.size()
	sprites[0].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)	
	for i in range(1, n):
		label.text = "Current Pass  : " + str(i)
		var key = arr[i]
		var skey = sprites[i]
		var j = i - 1
		while j >= 0 and arr[j] > key:
			arr[j + 1] = arr[j]
			await animate_insertion(j)
			if audio.playing == false:
				audio.stream = swaped
				audio.play()
			#audio.stop()	
			j -= 1
		arr[j + 1] = key
		sprites[j + 1] = skey
		sprites[j + 1].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)
	if audio.playing == false:
		audio.stream = sorted
		audio.play()
		
func animate_insertion(key):
	var sprite1 = sprites[key+1].get_node("Sprite2D") 
	var sprite2 = sprites[key].get_node("Sprite2D") 
	sprite1.get_node("arrow_min").visible = true
	sprite1.get_node("min_label").text = "key"
	var delaytimer = create_delay_timer(0.2)
	await delaytimer.timeout		
	sprite1.get_node("min_label").text = ""
	sprite1.get_node("arrow_min").visible = false
	var tween1 = create_tween()
	var tween2 = create_tween()
	var original_position1 = sprite1.position
	var original_position2 = sprite2.position
	sprite1.get_node("d").set("theme_override_styles/normal", style_box3)
	await move(key,key+1)
	#await tween1.finished	
	var temp = sprites[key]
	sprites[key] = sprites[key+1]
	sprites[key+1]=temp
func selection_sort() -> void:
	var n = arr.size()

	for i in range(n):
		# Assume the current element is the minimum
		var min_index = i
		label.text = "Current Pass  : " + str(i)
	

		# Find the index of the minimum element in the remaining unsorted part
		for j in range(i + 1, n):
			if arr[j] < arr[min_index]:
				#animate_swap(j , min_index , false)
				min_index = j
		# Swap the found minimum element with the current element
		sprites[min_index].get_node("Sprite2D/arrow_min").visible = true
		sprites[min_index].get_node("Sprite2D/min_label").text = "min"
		var delaytimer = create_delay_timer(0.2)
		await delaytimer.timeout		
		sprites[min_index].get_node("Sprite2D/min_label").text = ""
		sprites[min_index].get_node("Sprite2D/arrow_min").visible = false
		await animate_swap(i , min_index , false)		
		if min_index != i:
			await animate_swap(i , min_index , true)
			var temp = arr[i]
			arr[i] = arr[min_index]
			arr[min_index] = temp	
			#var temp2 = sprites[i]
			#sprites[i]= sprites[min_index]
			#sprites[min_index]=temp2
			delay_timer = create_delay_timer(ANIMATION_DURATION + ANIMATION_DELAY)
			await delay_timer.timeout
		delay_timer = create_delay_timer(0.00001)
		sprites[i].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)
		await delay_timer.timeout
	label.text = "Current Pass  : " + str(arr.size() - 1)			
	if audio.playing == false:
		audio.stream = sorted
		audio.play()
func bubble_sort():
	for i in range(arr.size() - 1 ):
		label.text = "Current Pass  : " + str(i)
		for j in range(arr.size() - 1 - i):
			var flag = false
			if arr[j] > arr[j + 1]:
				# Swap values in the array manually
				flag = true				
				var temp = arr[j]
				arr[j] = arr[j + 1]
				arr[j + 1] = temp
				#print(arr)
				# Animate swapping nodes
				await animate_swap(j, j + 1 , flag)
			await animate_swap(j, j + 1 , false)
			delay_timer = create_delay_timer(0.6 + ANIMATION_DELAY)
			await delay_timer.timeout
		#delay_timer = create_delay_timer(0.0001)
		#await delay_timer.timeout    
		sprites[arr.size() - 1 - i].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)
	delay_timer = create_delay_timer(0.00001)
	await delay_timer.timeout    
	sprites[0].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)
	label.text = "Current Pass  : " + str(arr.size() - 1)		
	if audio.playing == false:
		audio.stream = sorted
		audio.play()
	print(arr)
func create_delay_timer(duration: float):
	
	var timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.start()
	return timer	
func animate_swap(index1 , index2 , flag: bool):
	
	var sprite1 = sprites[index1].get_node("Sprite2D")
	var sprite2 = sprites[index2].get_node("Sprite2D")
	var original_position1 = sprite1.position
	var original_position2 = sprite2.position
	var tween1 = create_tween()
	
	# Initial position of sprite1
	var initial_position1 = sprite1.position
	
	# Move up a little bit and then right to sprite2's position
	var up_position1 = initial_position1 + Vector2(0, -80)
	var move_to_x1 = sprite2.position.x
	tween1.tween_property(sprite1, "position", up_position1, ANIMATION_DURATION / 3)
	#tween1.tween_property(sprite1, "position:x", move_to_x1, ANIMATION_DURATION / 3)
	#tween1.connect("finished", on_tween_finished)	
	var move_down_x = original_position2.y
	var move_up_y = original_position1.y	
	tween1.tween_property(sprite1, "position:y",move_up_y, ANIMATION_DURATION / 3)
	#await wait_for_tween(tween1)
	# Tween for sprite2
	var tween2 = create_tween()
	
	# Initial position of sprite2
	var initial_position2 = sprite2.position
	
	# Move down a little bit and then left to sprite1's original position
	var down_position2 = initial_position2 + Vector2(0, 80)
	var move_to_x2 = sprite1.position.x
	#tween2.tween_property(sprite2, "modulate", Color.DARK_ORANGE, ANIMATION_DURATION / 3)
	tween2.tween_property(sprite2, "position", down_position2, ANIMATION_DURATION / 3)
	#tween2.tween_property(sprite2, "position:x", move_to_x2, ANIMATION_DURATION / 3)
	tween2.tween_property(sprite2, "position:y", move_up_y, ANIMATION_DURATION / 3)
	#await wait_for_tween(tween2)
	if flag:
		var temp = sprites[index1].get_node("Sprite2D/d").text
		sprites[index1].get_node("Sprite2D/d").text = sprites[index2].get_node("Sprite2D/d").text
		sprites[index2].get_node("Sprite2D/d").text = temp
		if audio.playing == false:
			audio.stream = swaped
			audio.play()
func animate_enterance(sprite : Sprite2D):
	var pos = sprite.position
	var initail_pos = get_viewport_rect().size.x + pos.x
	sprite.position = Vector2(initail_pos, pos.y)  
	var tween = create_tween()
	tween.tween_property(sprite, "position:x", pos.x, 0.02).set_ease(Tween.EASE_IN)
	if audio.playing == false:
		audio.stream = whoosh
		audio.play()
func _on_line_edit_text_submitted(new_text):
	reset_scene()
	arr2 = new_text.split_floats(" ")
	for i in range(arr2.size()):
		arr.append(arr2[i])
		var input_response = InputResponseCols.instantiate()
		input_response.get_node("Sprite2D/d").text = str(arr2[i])
		var sp = input_response.get_node("Sprite2D")
		sp.position = Vector2(sp.position.x+(i*7) , sp.position.y)
		input_response.get_node("Sprite2D/arrow_min").visible = false
		sprites.append(input_response)
		history.add_child(input_response)
		#print(history.get_child(i).get_node("Sprite2D").position)
		#print(sp.texture.get_width())
		#print(sp.position.x)
		######################################
		await animate_enterance(sp)
		await get_tree().create_timer(1).timeout	
		##########################################	
		#var delay_timer = create_delay_timer(ANIMATION_DURATION + ANIMATION_DELAY)
		#await delay_timer.timeout
		
	#await move(2,4)
	#await move(1,3)
	#insertion_sort()
	#bubble_sort()
	#selection_sort()
	#start_sorting()
func reset_scene():
	
	for sprite in sprites:
		history.remove_child(sprite)
		sprite.queue_free()
	arr.clear()
	sprites.clear()	
func reset_sprite_colors():
	label.text=" "
	info.get_node("Button").reset()
	for i in range(sprites.size()):
		sprites[i].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box2)		

func _on_option_button_item_selected(index):
	$AudioStreamPlayer.play()	
	if index == 0:
		bubble_sort()
		info.get_node("Button").text_rect(0)
	if index == 1:
		insertion_sort()
		info.get_node("Button").text_rect(1)
	if index ==2:
		selection_sort()
		info.get_node("Button").text_rect(2)
		
		
func _on_button_pressed():
	$AudioStreamPlayer.play()
	reset_sprite_colors()
	for i in range(arr2.size()):
		sprites[i].get_node("Sprite2D/d").text = str(arr2[i])
		arr[i]=arr2[i]	
func move(i,j):
	var sp1 = sprites[j].get_node("Sprite2D")		
	var sp2 = sprites[i].get_node("Sprite2D")
	var tween = create_tween()
	var op1 =sp1.position
	var op2 =sp2.position
	print("op1 : ",op1," op2: ",op2)
	if(j-i > 1):
		tween.tween_property(sp1,"position:y" ,op1.y-120, ANIMATION_DURATION / 3)	
		tween.tween_property(sp2,"position:y" ,op2.y+120, ANIMATION_DURATION / 3)
		tween.tween_property(sp1,"position:x" ,op1.x-115.3*(j-i), ANIMATION_DURATION / 3)	
		tween.tween_property(sp2,"position:x" ,op2.x+115.3*(j-i), ANIMATION_DURATION / 3)	
		tween.tween_property(sp1,"position:y" ,op1.y, ANIMATION_DURATION / 3)		
		tween.tween_property(sp2,"position:y" ,op2.y, ANIMATION_DURATION / 3)	
	elif (j-i ==1):
		tween.tween_property(sp1 , "position:y" ,op1.y-120, ANIMATION_DURATION / 3)	
		tween.tween_property(sp2 , "position:x" ,op2.x+116 , ANIMATION_DURATION / 3)
		tween.tween_property(sp1 , "position:x" ,op1.x-116, ANIMATION_DURATION / 3)
		tween.tween_property(sp1 , "position:y" ,op1.y, ANIMATION_DURATION / 3)
	elif (j-i==0):
		tween.tween_property(sp1 , "position:y" ,op1.y-120, ANIMATION_DURATION / 3)
		tween.tween_property(sp1 , "position:y" ,op1.y, ANIMATION_DURATION / 3)			
				
	await tween.finished
	print("new1 : ",sp1.position," new2: ",sp2.position)
	
	
func quick_sort(arr: Array, low: int, high: int) -> int:
	if(low == high):
		sprites[low].get_node("Sprite2D/d").set("theme_override_styles/normal", style_box)	
	if low < high:
		# pi is the partitioning index, arr[pi] is now at the right place
		var pi: int = await partition(arr, low, high)
		await get_tree().create_timer(3).timeout					
		# Recursively sort elements before partition and after partition
		await quick_sort(arr, low, pi - 1)
		#await get_tree().create_timer(5).timeout							
		await quick_sort(arr, pi + 1, high)	
	return 1
	print(arr)
	
	
func partition(arr: Array, low: int, high: int) -> int:
	var pivot: int = arr[high]  # pivot
	var i: int = (low - 1)  
	var sprite1 = sprites[high].get_node("Sprite2D") 
	var originalpos = sprite1.position
	var tween = create_tween()
	sprite1.get_node("d").set("theme_override_styles/normal", style_box3)
	sprite1.get_node("pivot").visible = true
	#tween.tween_property(sprite1 , "position:y" ,-125, 0.5)
	#tween.tween_property(sprite1 , "position:y" ,originalpos.y, 0.5)	
	#await tween.finished
	if(!label.visible):
		label.visible =true
	for j in range(low, high):
		#sprites[j].get_node("Sprite2D/j").visible = true
		# If the current element is smaller than or equal to pivot
		if arr[j] <= pivot:
			label.text = str(arr[j]) + " <= " + str(pivot)
			sprites[j].get_node("Sprite2D/jlabel").visible =true
			sprites[j].get_node("Sprite2D/min_label").visible =true
			sprites[j].get_node("Sprite2D/min_label").text = "j = "+str(j)
			i += 1
			sprites[j].get_node("Sprite2D/min_label").visible =true			
			sprites[i].get_node("Sprite2D/min_label").text = "i = "+str(i)
			sprites[i].get_node("Sprite2D/ilabel").visible =true			
			# Swap arr[i] with arr[j] using a temporary variable
			await move(i,j)
			if audio.playing == false:
				audio.stream = swaped
				audio.play()
			await get_tree().create_timer(1).timeout			
			sprites[i].get_node("Sprite2D/ilabel").visible =false						
			sprites[j].get_node("Sprite2D/jlabel").visible =false	
			sprites[j].get_node("Sprite2D/min_label").visible =false					
			sprites[i].get_node("Sprite2D/min_label").visible =false					
			var temp: int = arr[i]
			arr[i] = arr[j]
			arr[j] = temp
			var temp2 = sprites[i]
			sprites[i] = sprites[j]
			sprites[j]=temp2
			
	label.visible = false
	
		#sprites[j].get_node("Sprite2D/j").visible = false		

	# Swap arr[i + 1] with arr[high] (or pivot) using a temporary variable
	var temp: int = arr[i + 1]
	arr[i + 1] = arr[high]
	arr[high] = temp
	await get_tree().create_timer(1).timeout
	# animation pivot in right place	
	await move(i+1,high)
	sprite1.get_node("d").set("theme_override_styles/normal", style_box)
	sprite1.get_node("pivot").visible = false
	var temp2 = sprites[i+1]
	sprites[i+1] = sprites[high]
	sprites[high]=temp2
	#var temp2 = sprites[i+1].get_node("Sprites2D/d").text
	#sprites[i+1].get_node("Sprites2D/d").text = sprites[high].get_node("Sprites2D/d").text
	#sprites[high].get_node("Sprites2D/d").text=temp2
	return (i + 1)
func start_sorting():
	var  ad : int = 0
	ad = await quick_sort(arr, 0, arr.size() - 1)
	if ad:
		if audio.playing == false:
			audio.stream = sorted
			audio.play()
		

func _on_algo_option_pressed():
	$AudioStreamPlayer.play()


func _on_speed_pressed():
	speedMenu.visible = !speedMenu.visible
	
func _on_x_25_pressed():
	ANIMATION_DURATION = 2.0
	print ("0.25")

func _on_x_1_pressed():
	ANIMATION_DURATION = 1.0

func _on_x_1_5_pressed():
	ANIMATION_DURATION = 0.5

func _on_x_2_pressed():
	ANIMATION_DURATION = 0.25
	
func _on_algo_icon_pressed():
	MenuOptions.visible = !MenuOptions.visible

func _on_selection_sort_pressed():
	MenuOptions.visible = false
	_on_button_pressed()
	await get_tree().create_timer(0.5).timeout
	selection_sort()


func _on_bubble_sort_pressed():
	MenuOptions.visible = false
	_on_button_pressed()
	await get_tree().create_timer(0.5).timeout
	bubble_sort()


func _on_insertion_sort_pressed():
	MenuOptions.visible = false
	_on_button_pressed()
	await get_tree().create_timer(0.5).timeout
	insertion_sort()


func _on_quick_sort_pressed():
	MenuOptions.visible = false
	_on_button_pressed()
	await get_tree().create_timer(0.5).timeout
	start_sorting()


func _on_arrow_pressed():
	get_tree().change_scene_to_file("res://scenes/home_page.tscn")
