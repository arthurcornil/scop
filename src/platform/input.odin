package platform

import "vendor:glfw"

Key :: enum i32 {
	Escape = glfw.KEY_ESCAPE,
	Enter = glfw.KEY_ENTER,
	X = glfw.KEY_X,
	Y = glfw.KEY_Y,
	Z = glfw.KEY_Z,
}

@private
Input :: struct {
	key_down: [glfw.KEY_LAST + 1]bool,
	key_pressed: [glfw.KEY_LAST + 1]bool,
	mouse_down: bool,
	cursor_pos: [2]f64,
	cursor_delta: [2]f64,
	last_cursor: [2]f64,
	scroll_offset: f64,
	shift_down: bool,
	alt_down: bool
}

@private
input: Input

@private
key_callback :: proc "c" (window: Window, key, scancode, action, mods: i32) {
	if key < 0 do return
	switch action {
	case glfw.PRESS:
		input.key_down[key] = true
		input.key_pressed[key] = true
	case glfw.RELEASE:
		input.key_down[key] = false
	}	
	input.shift_down = bool(mods & glfw.MOD_SHIFT)
	input.alt_down = bool(mods & glfw.MOD_ALT)
}

@private
cursor_callback :: proc "c" (window: Window, x, y: f64) {
	pos: [2]f64 = {x, y}
	input.cursor_pos = pos
	if input.mouse_down {
		input.cursor_delta += input.cursor_pos - input.last_cursor
	}
	input.last_cursor = input.cursor_pos
}

@private
mouse_button_callback :: proc "c" (window: Window, button, action, mods: i32) {
	if button != glfw.MOUSE_BUTTON_LEFT do return
	switch action {
	case glfw.PRESS:
		input.mouse_down = true
	case glfw.RELEASE:
		input.mouse_down = false
	}
}

@private
scroll_callback :: proc "c" (window: Window, _, yoffset: f64) {
	input.scroll_offset += yoffset
}

key_pressed :: proc(k: Key) -> bool { return input.key_pressed[i32(k)] }
key_down :: proc(k: Key) -> bool { return input.key_down[i32(k)] }
scroll_delta :: proc() -> f64 { return input.scroll_offset }
shift_down :: proc() -> bool { return input.shift_down }
alt_down :: proc() -> bool { return input.alt_down }

mouse_drag_delta :: proc() -> Maybe([2]f64) {
	if input.mouse_down {
		return input.cursor_delta
	}
	return nil
}

update_input :: proc() {
	input.key_pressed = {}
	input.cursor_delta = {}
	input.scroll_offset = 0
}
