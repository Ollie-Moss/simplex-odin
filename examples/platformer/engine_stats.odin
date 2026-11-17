package example_simplex

import "core:time"

Engine_Stats :: struct {
	fps:                        f64,
	frame_time:                 f32,
	frame_count:                i32,
	last_frame_start:           time.Time,
	accumulated_time:           f64,
	cpu_time_sim:               f32,
	cpu_time_render_sub:        f32,
	gl_draw_calls:              i32,
	gl_tris:                    i32,
	mem_heap:                   i32,
	mem_temp_peak:              f32,
	simulation_entity_count:    f32,
	simulation_component_count: f32,
	simulation_view_count:      f32,
}

make_engine_stats :: proc() -> Engine_Stats {
	return Engine_Stats{last_frame_start = time.now()}
}

calculate_fps :: proc(stats: ^Engine_Stats, update_delay: f64) {
	frame_start := time.now()
	delta := time.duration_seconds(time.diff(stats.last_frame_start, frame_start))
	stats.last_frame_start = time.now()

	stats.accumulated_time += delta
	stats.frame_count += 1

	if stats.accumulated_time > update_delay {
		stats.fps = f64(stats.frame_count) / stats.accumulated_time

		stats.accumulated_time = 0
		stats.frame_count = 0
	}
}
