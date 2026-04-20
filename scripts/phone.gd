extends Node3D

@onready var full_size: Node3D = $"../fullPos"
@onready var min_size: Node3D = $"../minPos"
# @onready var helper_text: Label = $HelperText

@onready var camera_3d: Camera3D = %Camera3D

@export var switch_curve : Curve
const TIME : float = .2
@onready var phone_screen: SubViewport = %PhoneScreen
const PHONE_SCREEN = preload("uid://dwslou3wpdsev")
@export_flags_2d_physics var phone_physics_layer

var show_phone : bool = false
var current_time : float
var need_click : bool

var enable

signal change_focus

const RAY_LENGTH = 100

func _ready():
	set_mesh($Phone)
	
	process_phone_size(0)
	
	var vp_texture: ViewportTexture = phone_screen.get_texture()
	
	PHONE_SCREEN.set_texture(BaseMaterial3D.TextureParam.TEXTURE_ALBEDO, vp_texture)

func _input(event: InputEvent) -> void:
	if !enable:
		return
	
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		need_click = true
		
	if need_click and !show_phone and event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		need_click = false
	
	if event.is_action_pressed("phone"):
#		if helper_text.visible:
#			helper_text.visible = false
		show_phone = !show_phone
		change_focus.emit()
		if show_phone:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
				need_click = true
		
	if show_phone and current_time == TIME:
		if event is InputEventMouseButton:
			var space_state = get_world_3d().direct_space_state
			var mousepos = get_viewport().get_mouse_position()
			
			var origin = camera_3d.project_ray_origin(mousepos)
			var end = origin + camera_3d.project_ray_normal(mousepos) * RAY_LENGTH
			var query = PhysicsRayQueryParameters3D.create(origin, end, phone_physics_layer)
			var result = space_state.intersect_ray(query)
			# If is on the screen
			if result.get("face_index", 2) <= 1:
				var uv = get_uv_coords(result.get("position"),result.get("normal"))
				uv.x *= phone_screen.size.x
				uv.y *= phone_screen.size.y
				event.position = uv
				phone_screen.push_input(event)

func _process(delta: float) -> void:
	if !enable:
		return
	
	process_phone_size(delta)
	
func process_phone_size(delta: float) -> void:
	if current_time != TIME and show_phone:
		current_time = min(TIME,current_time+delta)
	
	if current_time != 0 and !show_phone:
		current_time = max(0,current_time-delta)
	
	var weight = current_time/TIME
	
	global_position = lerp(min_size.global_position, full_size.global_position, weight)
	global_rotation = lerp(min_size.global_rotation, full_size.global_rotation, weight)
	scale = lerp(min_size.scale, full_size.scale, weight)

func _on_awake_awake() -> void:
	enable = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		need_click = true

func _on_end() -> void:
	enable = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# Code from https://tmptesting.godotforums.randommomentania.com/d/30491-how-to-translate-a-world-coordinate-to-uv-coordinate/11
var meshtool
var mesh
var mesh_instance

var transform_vertex_to_global = true

func set_mesh(_mesh_instance):
	mesh_instance = _mesh_instance
	mesh = _mesh_instance.mesh
	
	meshtool = MeshDataTool.new()
	meshtool.create_from_surface(mesh, 0)

# Extracts position data for this triangle
func _get_triangle_data(datatool, p1i, p2i, p3i):	
	var p1 = datatool.get_vertex(p1i)
	var p2 = datatool.get_vertex(p2i)
	var p3 = datatool.get_vertex(p3i)
	
	return [p1, p2, p3]

func equals_with_epsilon(v1, v2, epsilon):
	if (v1.distance_to(v2) < epsilon):
		return true
	return false

func get_face(point, normal, epsilon = 0.2):
	for idx in range(meshtool.get_face_count()):
		var world_normal = mesh_instance.global_transform.basis * meshtool.get_face_normal(idx)
		
		if !equals_with_epsilon(world_normal, normal, epsilon):
			continue
		# Normal is the same-ish, so we need to check if the point is on this face
		var v1 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 0))
		var v2 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 1))
		var v3 = meshtool.get_vertex(meshtool.get_face_vertex(idx, 2))
		
		if transform_vertex_to_global:
			v1 = mesh_instance.global_transform * v1
			v2 = mesh_instance.global_transform * v2
			v3 = mesh_instance.global_transform * v3

		if is_point_in_triangle(point, v1, v2, v3):
			return idx	
	return null

func barycentric(P, A, B, C):
	# Returns barycentric co-ordinates of point P in triangle ABC
	var mat1 = Basis(A, B, C)
	var det = mat1.determinant()
	var mat2 = Basis(P, B, C)
	var factor_alpha = mat2.determinant()
	var mat3 = Basis(P, C, A)
	var factor_beta = mat3.determinant()
	var alpha = factor_alpha / det;
	var beta = factor_beta / det;
	var gamma = 1.0 - alpha - beta;
	return Vector3(alpha, beta, gamma)
	
func cart2bary(p : Vector3, a : Vector3, b : Vector3, c: Vector3) -> Vector3:
	var v0 := b - a
	var v1 := c - a
	var v2 := p - a
	var d00 := v0.dot(v0)
	var d01 := v0.dot(v1)
	var d11 := v1.dot(v1)
	var d20 := v2.dot(v0)
	var d21 := v2.dot(v1)
	var denom := d00 * d11 - d01 * d01
	var v = (d11 * d20 - d01 * d21) / denom
	var w = (d00 * d21 - d01 * d20) / denom
	var u = 1.0 - v - w
	return Vector3(u, v, w)

func transfer_point(from : Basis, to : Basis, point : Vector3) -> Vector3:
	return (to * from.inverse()) * point
	
func bary2cart(a : Vector3, b : Vector3, c: Vector3, barycentric_v3: Vector3) -> Vector3:
	return barycentric_v3.x * a + barycentric_v3.y * b + barycentric_v3.z * c
	
func is_point_in_triangle(point, v1, v2, v3):
	#bc = barycentric(point, v1, v2, v3)
	var bc = barycentric(point, v1, v2, v3)	
	
	if bc.x < 0 or bc.x > 1:
		return false
	if bc.y < 0 or bc.y > 1:
		return false
	if bc.z < 0 or bc.z > 1:
		return false
	return true

func get_uv_coords(point, normal):
	# Gets the uv coordinates on the mesh given a point on the mesh and normal
	# these values can be obtained from a raycast
	transform_vertex_to_global = transform
	
	var face = get_face(point, normal)
	if face == null:
		return null
	var v1 = meshtool.get_vertex(meshtool.get_face_vertex(face, 0))
	var v2 = meshtool.get_vertex(meshtool.get_face_vertex(face, 1))
	var v3 = meshtool.get_vertex(meshtool.get_face_vertex(face, 2))
		
	if transform_vertex_to_global:
		v1 = mesh_instance.global_transform * v1
		v2 = mesh_instance.global_transform * v2
		v3 = mesh_instance.global_transform * v3
		
	var bc = barycentric(point, v1, v2, v3)
	var uv1 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 0))
	var uv2 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 1))
	var uv3 = meshtool.get_vertex_uv(meshtool.get_face_vertex(face, 2))
	return (uv1 * bc.x) + (uv2 * bc.y) + (uv3 * bc.z)
