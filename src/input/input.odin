package input

import "base:runtime"
import "vendor:glfw"

key_callback :: proc "c" (window: glfw.WindowHandle, glfw_key, scancode, glfw_action, mods: i32) {
	context = runtime.default_context()

	key := Key(glfw_key)
	key_state := KeyState(glfw_key)

	if key == .Unknown {
		return
	}

	if key_state == .Pressed || key_state == .Repeat {
		current_state := &keys[Key(key)]
		current_state^ =
			.Held if current_state^ == .Pressed || current_state^ == .Repeat else key_state
	} else if key_state == .Release {
		delete_key(&keys, Key(key))
	}
}

scroll_callback :: proc "c" (window: glfw.WindowHandle, xoffset: f64, yoffset: f64) {
	scroll_delta = f32(yoffset)
}

init :: proc(window: glfw.WindowHandle) {
	glfw.SetKeyCallback(window, key_callback)
	glfw.SetScrollCallback(window, scroll_callback)
}

KeyState :: enum {
	Release = glfw.RELEASE,
	Repeat = glfw.REPEAT,
	Pressed = glfw.PRESS,
	Held,
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


@(private)
keys: map[Key]KeyState

@(private)
scroll_delta: f32

update :: proc() {
	scroll_delta = 0
	glfw.PollEvents()
}

is_pressed :: proc(key: Key) -> bool {
	state := keys[key]
	return state == .Pressed || state == .Repeat
}

is_held :: proc(key: Key) -> bool {
	state := keys[key]
	return state == .Held
}

get_scroll_delta :: proc() -> f32 {
	return scroll_delta
}
