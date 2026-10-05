package renderer

import gl "vendor:OpenGL"
import "core:image/bmp"
import "core:image"

load_texture :: proc(path: string) -> (texture: u32, err: image.Error){
	gl.GenTextures(1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);	
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

	img := bmp.load_from_file(path) or_return
	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RGB,
		i32(img.width),
		i32(img.height),
		0,
		gl.RGB,
		gl.UNSIGNED_BYTE,
		raw_data(img.pixels.buf)
	)
	gl.GenerateMipmap(gl.TEXTURE_2D)
	return
}
