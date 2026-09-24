package platform

import "vendor:glfw"

Key :: enum i32 {
	Escape = glfw.KEY_ESCAPE,
	Enter = glfw.KEY_ENTER,
}

@private
Input :: struct {
	key_down: [glfw.KEY_LAST + 1]bool,
	key_pressed: [glfw.KEY_LAST + 1]bool,
	mouse_down: bool,
	cursor_pos: [2]f64,
	cursor_delta: [2]f64,
	last_cursor: [2]f64
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

key_pressed :: proc(k: Key) -> bool { return input.key_pressed[i32(k)] }
key_down :: proc(k: Key) -> bool { return input.key_down[i32(k)] }

mouse_drag_delta :: proc() -> Maybe([2]f64) {
	if input.mouse_down {
		return input.cursor_delta
	}
	return nil
}

update_input :: proc() {
	input.key_pressed = {}
	input.cursor_delta = {}
}
