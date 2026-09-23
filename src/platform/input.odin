package platform

import "vendor:glfw"

Key :: enum i32 {
	Escape = glfw.KEY_ESCAPE,
	Enter = glfw.KEY_ENTER,
}

@(private)
Input :: struct {
	down: [glfw.KEY_LAST + 1]bool,
	pressed: [glfw.KEY_LAST + 1]bool,
}

@(private)
input: Input

@(private)
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
      if key < 0 do return
      switch action {
      case glfw.PRESS:
              input.down[key] = true
              input.pressed[key] = true
      case glfw.RELEASE:
              input.down[key] = false
      }
}

key_pressed :: proc(k: Key) -> bool {
	return input.pressed[i32(k)]
}

key_down :: proc(k: Key) -> bool {
	return input.down[i32(k)]
}
