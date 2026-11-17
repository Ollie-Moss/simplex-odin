package graphics

import "core:math/linalg"
import "simplex:vmath"

calculate_projection :: proc(viewport_size: vmath.vec2) -> matrix[4, 4]f32 {
	nearZClip: f32 = -100.0
	farZClip: f32 = 100.0

	halfWidth := f32(viewport_size.x)
	halfHeight := f32(viewport_size.y)
	return linalg.matrix_ortho3d(0, viewport_size.x, viewport_size.y, 0, nearZClip, farZClip)
}
