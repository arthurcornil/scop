package errors

import "core:fmt"
import "core:os"

Shader_Error :: enum {
	None = 0,
	Compilation_Error
}


Parsing_Error :: enum {
	None = 0,
	Wrong_Tag,
	Wrong_Format,
	Wrong_Number_Of_Attributes,
	Not_A_Face,
	Zero_Face_Index,
	Out_Of_Bounds
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

report :: proc(err: Error) {
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
		case .Wrong_Tag:
			details = "Wrong tag"
		case .Wrong_Format:
			details = "Format Error"
		case .Wrong_Number_Of_Attributes:
			details = "Too many or few attributes"
		case .Zero_Face_Index:
			details = "Index '0' found in face"
		case .Out_Of_Bounds:
			details = "Out of bounds index found in face"
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
}
