package main

import "core:fmt"
import "core:os"
import "./parser"
import "./obj"

main :: proc() {
	if len(os.args) != 2 {
		fmt.eprintln("Usage: scop [PATH TO .obj FILE]")
		os.exit(1)
	}

	obj := obj.Obj{}
	defer delete(obj.vertices)
	err := parser.parse(os.args[1], &obj)
	if err != nil {
		fmt.eprintln("Error")
		os.exit(1)
	}
	fmt.println(obj.vertices)
}
