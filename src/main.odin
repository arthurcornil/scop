package main

import "core:fmt"
import "core:os"
import "core:mem"

import "./errors"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer mem.tracking_allocator_destroy(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
		}
	}

	if len(os.args) != 2 {
		fmt.eprintln("Usage: scop [PATH TO .obj FILE]")
		os.exit(1)
	}
	if err := run(os.args[1]); err != nil {
		errors.report(err)
		when ODIN_DEBUG {
			return
		} else {
			os.exit(1)
		}
	}
}
