package perf

import "core:prof/spall"
import "core:sync"

@(private)
spall_ctx: spall.Context
@(private)
spall_buffer: spall.Buffer

init_profiling :: proc() {
	spall_ctx = spall.context_create("trace.spall")
	buffer_backing := make([]u8, spall.BUFFER_DEFAULT_SIZE)
	spall_buffer = spall.buffer_create(buffer_backing, u32(sync.current_thread_id()))
}

shutdown_profiling :: proc() {
	spall.buffer_destroy(&spall_ctx, &spall_buffer)
	spall.context_destroy(&spall_ctx)
}

benchmark :: proc {
	benchmark_named,
	benchmark_unnamed,
}

@(deferred_none = _benchmark_end)
benchmark_named :: proc(name: string, loc := #caller_location) {
	spall._buffer_begin(&spall_ctx, &spall_buffer, name, "", loc)
}

@(deferred_none = _benchmark_end)
benchmark_unnamed :: proc(loc := #caller_location) {
	spall._buffer_begin(&spall_ctx, &spall_buffer, loc.procedure, "", loc)
}

@(private)
_benchmark_end :: proc() {
	spall._buffer_end(&spall_ctx, &spall_buffer)
}
