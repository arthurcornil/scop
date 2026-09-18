package errors

import "core:fmt"
import "core:os"

Shader_Error :: enum {
	None = 0,
	Compilation_Error
}


Parsing_Error :: enum {
	None = 0,
	Not_A_Vertex,
	Vertex_Format,
	Wrong_Number_Of_Attributes
}

GLFW_Error :: enum {
	None = 0,
	Init_Error,
	Window_Error
}

Error :: union #shared_nil {
	os.Error,
	Parsing_Error,
	GLFW_Error,
	Shader_Error
}

fatal :: proc(err: Error) {
	if err == nil do return

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
	case Parsing_Error:
		error_type = "Parsing Error"
		#partial switch e {
		case .Vertex_Format:
			details = "Wrong format for vertex"
		case .Wrong_Number_Of_Attributes:
			details = "Too much or few attributes for vertex"
		}
	case Shader_Error:
		error_type = "Shader Error"
		#partial switch e {
		case .Compilation_Error:
			details = "compilation failed"
		}
	case os.Error:
		error_type = "OS Error"
		details = os.error_string(e)
	}
	fmt.eprintfln("%s: %s", error_type, details)
	os.exit(1)
}
