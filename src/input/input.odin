package input

import "simplex:input"
import "simplex:vmath"
import "vendor:glfw"

key_callback :: proc "c" (window: glfw.WindowHandle, glfw_key, scancode, glfw_action, mods: i32) {
	key := Key(glfw_key)
	key_state := KeyState(glfw_action)

	if key == .Unknown {
		return
	}

	input_state.keys[key] = key_state
}

mouse_callback :: proc "c" (window: glfw.WindowHandle, glfw_button, glfw_action, mods: i32) {
	mouse_button := MouseButton(glfw_button)
	button_state := KeyState(glfw_action)
	input_state.mouse_buttons[mouse_button] = button_state
}

scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	input_state.scroll_delta = f32(yoffset)
}

init :: proc(window: glfw.WindowHandle) {
	input_state.keys = make(map[Key]KeyState)
	glfw.SetMouseButtonCallback(window, mouse_callback)
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetScrollCallback(window, scroll_callback)
}


KeyState :: enum i32 {
	Release = glfw.RELEASE,
	Repeat  = glfw.REPEAT,
	Pressed = glfw.PRESS,
}

MouseButton :: enum i32 {
	Mouse1 = glfw.MOUSE_BUTTON_1,
	Mouse2 = glfw.MOUSE_BUTTON_2,
	Mouse3 = glfw.MOUSE_BUTTON_3,
	Mouse4 = glfw.MOUSE_BUTTON_4,
	Mouse5 = glfw.MOUSE_BUTTON_5,
	Mouse6 = glfw.MOUSE_BUTTON_6,
	Mouse7 = glfw.MOUSE_BUTTON_7,
	Mouse8 = glfw.MOUSE_BUTTON_8,
}

Key :: enum i32 {
	Unknown      = glfw.KEY_UNKNOWN,
	Space        = glfw.KEY_SPACE,
	Apostrophe   = glfw.KEY_APOSTROPHE,
	Comma        = glfw.KEY_COMMA,
	Minus        = glfw.KEY_MINUS,
	Period       = glfw.KEY_PERIOD,
	Slash        = glfw.KEY_SLASH,

	// Numbers
	Num0         = glfw.KEY_0,
	Num1         = glfw.KEY_1,
	Num2         = glfw.KEY_2,
	Num3         = glfw.KEY_3,
	Num4         = glfw.KEY_4,
	Num5         = glfw.KEY_5,
	Num6         = glfw.KEY_6,
	Num7         = glfw.KEY_7,
	Num8         = glfw.KEY_8,
	Num9         = glfw.KEY_9,
	Semicolon    = glfw.KEY_SEMICOLON,
	Equal        = glfw.KEY_EQUAL,

	// Letters
	A            = glfw.KEY_A,
	B            = glfw.KEY_B,
	C            = glfw.KEY_C,
	D            = glfw.KEY_D,
	E            = glfw.KEY_E,
	F            = glfw.KEY_F,
	G            = glfw.KEY_G,
	H            = glfw.KEY_H,
	I            = glfw.KEY_I,
	J            = glfw.KEY_J,
	K            = glfw.KEY_K,
	L            = glfw.KEY_L,
	M            = glfw.KEY_M,
	N            = glfw.KEY_N,
	O            = glfw.KEY_O,
	P            = glfw.KEY_P,
	Q            = glfw.KEY_Q,
	R            = glfw.KEY_R,
	S            = glfw.KEY_S,
	T            = glfw.KEY_T,
	U            = glfw.KEY_U,
	V            = glfw.KEY_V,
	W            = glfw.KEY_W,
	X            = glfw.KEY_X,
	Y            = glfw.KEY_Y,
	Z            = glfw.KEY_Z,
	LeftBracket  = glfw.KEY_LEFT_BRACKET,
	Backslash    = glfw.KEY_BACKSLASH,
	RightBracket = glfw.KEY_RIGHT_BRACKET,
	GraveAccent  = glfw.KEY_GRAVE_ACCENT,
	World1       = glfw.KEY_WORLD_1,
	World2       = glfw.KEY_WORLD_2,

	// Function keys
	Escape       = glfw.KEY_ESCAPE,
	Enter        = glfw.KEY_ENTER,
	Tab          = glfw.KEY_TAB,
	Backspace    = glfw.KEY_BACKSPACE,
	Insert       = glfw.KEY_INSERT,
	Delete       = glfw.KEY_DELETE,
	Right        = glfw.KEY_RIGHT,
	Left         = glfw.KEY_LEFT,
	Down         = glfw.KEY_DOWN,
	Up           = glfw.KEY_UP,
	PageUp       = glfw.KEY_PAGE_UP,
	PageDown     = glfw.KEY_PAGE_DOWN,
	Home         = glfw.KEY_HOME,
	End          = glfw.KEY_END,
	CapsLock     = glfw.KEY_CAPS_LOCK,
	ScrollLock   = glfw.KEY_SCROLL_LOCK,
	NumLock      = glfw.KEY_NUM_LOCK,
	PrintScreen  = glfw.KEY_PRINT_SCREEN,
	Pause        = glfw.KEY_PAUSE,
	F1           = glfw.KEY_F1,
	F2           = glfw.KEY_F2,
	F3           = glfw.KEY_F3,
	F4           = glfw.KEY_F4,
	F5           = glfw.KEY_F5,
	F6           = glfw.KEY_F6,
	F7           = glfw.KEY_F7,
	F8           = glfw.KEY_F8,
	F9           = glfw.KEY_F9,
	F10          = glfw.KEY_F10,
	F11          = glfw.KEY_F11,
	F12          = glfw.KEY_F12,

	// Keypad
	Kp0          = glfw.KEY_KP_0,
	Kp1          = glfw.KEY_KP_1,
	Kp2          = glfw.KEY_KP_2,
	Kp3          = glfw.KEY_KP_3,
	Kp4          = glfw.KEY_KP_4,
	Kp5          = glfw.KEY_KP_5,
	Kp6          = glfw.KEY_KP_6,
	Kp7          = glfw.KEY_KP_7,
	Kp8          = glfw.KEY_KP_8,
	Kp9          = glfw.KEY_KP_9,
	KpDecimal    = glfw.KEY_KP_DECIMAL,
	KpDivide     = glfw.KEY_KP_DIVIDE,
	KpMultiply   = glfw.KEY_KP_MULTIPLY,
	KpSubtract   = glfw.KEY_KP_SUBTRACT,
	KpAdd        = glfw.KEY_KP_ADD,
	KpEnter      = glfw.KEY_KP_ENTER,
	KpEqual      = glfw.KEY_KP_EQUAL,

	// Modifiers
	LeftShift    = glfw.KEY_LEFT_SHIFT,
	LeftControl  = glfw.KEY_LEFT_CONTROL,
	LeftAlt      = glfw.KEY_LEFT_ALT,
	LeftSuper    = glfw.KEY_LEFT_SUPER,
	RightShift   = glfw.KEY_RIGHT_SHIFT,
	RightControl = glfw.KEY_RIGHT_CONTROL,
	RightAlt     = glfw.KEY_RIGHT_ALT,
	RightSuper   = glfw.KEY_RIGHT_SUPER,
	Menu         = glfw.KEY_MENU,
}

InputState :: struct {
	keys:              map[Key]KeyState,
	mouse_buttons:     map[MouseButton]KeyState,
	scroll_delta:      f32,
	current_mouse_pos: vmath.vec2,
	last_mouse_pos:    vmath.vec2,
}

@(private)
input_state := InputState {
	last_mouse_pos    = {0, 0},
	current_mouse_pos = {0, 0},
	scroll_delta      = 0,
}

update :: proc(window: glfw.WindowHandle) {
	input_state.scroll_delta = 0

	x, y := glfw.GetCursorPos(window)
	_, height := glfw.GetWindowSize(window)
	current_pos := vmath.vec2{f32(x), f32(height) - f32(y)}

	input_state.last_mouse_pos = input_state.current_mouse_pos
	input_state.current_mouse_pos = current_pos

	glfw.PollEvents()
}

is_pressed :: proc {
	is_pressed_key,
	is_pressed_mouse,
}

is_held :: proc {
	is_held_key,
	is_held_mouse,
}

is_pressed_key :: proc(key: Key) -> bool {
	state := input_state.keys[key]
	return state == .Pressed || state == .Repeat
}

is_held_key :: proc(key: Key) -> bool {
	state := input_state.keys[key]
	return state == .Pressed || state == .Repeat
}

is_pressed_mouse :: proc(mouseButton: MouseButton) -> bool {
	state := input_state.mouse_buttons[mouseButton]
	return state == .Pressed || state == .Repeat
}

is_held_mouse :: proc(mouseButton: MouseButton) -> bool {
	state := input_state.mouse_buttons[mouseButton]
	return state == .Pressed || state == .Repeat
}

get_scroll_delta :: proc() -> f32 {
	return input_state.scroll_delta
}

get_mouse_delta :: proc() -> vmath.vec2 {
	return input_state.last_mouse_pos - input_state.current_mouse_pos
}
