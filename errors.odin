package main

import "core:fmt"
import "core:os"

Error :: union {
	GLFW_Error,
	Shader_Error
}

Shader_Error :: enum {
	None = 0,
	Compilation_Error
}

GLFW_Error :: enum {
	None = 0,
	Init_Error,
	Window_Error
}

fatal :: proc(err: Error) {
	error_type: string
	details: string
	switch e in err {
	case GLFW_Error:
		error_type = "GLFW Error"
		#partial switch e {
		case .Init_Error:
			details = "failed to init glfw"
		case .Window_Error:
			details = "failed to open window"
		}
	case Shader_Error:
		error_type = "Shader Error"
		#partial switch e {
		case .Compilation_Error:
			details = "compilation failed"
		}
	}
	fmt.eprintfln("%s: %s.", error_type, details)
	os.exit(1)
}

