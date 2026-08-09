package example_simplex

import "core:math/linalg"
import "simplex:core"
import "simplex:ecs"
import "simplex:vmath"

calculate_projection :: proc(viewport_size: vmath.vec2) -> matrix[4, 4]f32 {
	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0

	halfWidth := f32(viewport_size.x)
	halfHeight := f32(viewport_size.y)
	return linalg.matrix_ortho3d(0, viewport_size.x, viewport_size.y, 0, nearZClip, farZClip)
}

calculate_camera_projection_right_side_up :: proc(
	transform: ^vmath.Transform,
	cam: ^Camera,
) -> matrix[4, 4]f32 {
	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0
	cam_position := transform.position

	halfWidth := f32(cam.viewport_size.x) / cam.zoom / 2.0
	halfHeight := f32(cam.viewport_size.y) / cam.zoom / 2.0
	return linalg.matrix_ortho3d(
		f32(cam_position.x) - halfWidth,
		f32(cam_position.x) + halfWidth,
		f32(cam_position.y) + halfHeight,
		f32(cam_position.y) - halfHeight,
		nearZClip,
		farZClip,
	)
}

calculate_camera_projection :: proc(transform: ^vmath.Transform, cam: ^Camera) -> matrix[4, 4]f32 {
	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0
	cam_position := transform.position

	halfWidth := f32(cam.viewport_size.x) / cam.zoom / 2.0
	halfHeight := f32(cam.viewport_size.y) / cam.zoom / 2.0
	return linalg.matrix_ortho3d(
		f32(cam_position.x) - halfWidth,
		f32(cam_position.x) + halfWidth,
		f32(cam_position.y) - halfHeight,
		f32(cam_position.y) + halfHeight,
		nearZClip,
		farZClip,
	)
}

cam_system :: proc(simplex: ^core.Simplex, entity: ecs.Entity) {
}

Camera :: struct {
	zoom:            f32,
	viewport_size:   vmath.ivec2,
	smoothing_speed: f32,
	deadzone:        [2]vmath.vec2,
}
