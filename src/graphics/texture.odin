package graphics

import "simplex:assets"
import "core:strings"
import gl "vendor:OpenGL"
import stb_image "vendor:stb/image"


Texture_Internal_Format :: enum i32 {
	RGB               = gl.RGB,
	RGBA              = gl.RGBA,
	RED               = gl.RED,
	RG                = gl.RG,
	SRGB              = gl.SRGB,
	SRGBA             = gl.SRGB_ALPHA,
	RGB8              = gl.RGB8,
	RGBA8             = gl.RGBA8,
	RGB16F            = gl.RGB16F,
	RGBA16F           = gl.RGBA16F,
	RGB32F            = gl.RGB32F,
	RGBA32F           = gl.RGBA32F,
	DEPTH_COMPONENT   = gl.DEPTH_COMPONENT,
	DEPTH_COMPONENT16 = gl.DEPTH_COMPONENT16,
	DEPTH_COMPONENT24 = gl.DEPTH_COMPONENT24,
	DEPTH_COMPONENT32 = gl.DEPTH_COMPONENT32,
	DEPTH_STENCIL     = gl.DEPTH_STENCIL,
}

Texture_Image_Format :: enum u32 {
	RGB             = gl.RGB,
	RGBA            = gl.RGBA,
	RED             = gl.RED,
	RG              = gl.RG,
	BGR             = gl.BGR,
	BGRA            = gl.BGRA,
	DEPTH_COMPONENT = gl.DEPTH_COMPONENT,
	DEPTH_STENCIL   = gl.DEPTH_STENCIL,
}

Texture_Wrap :: enum i32 {
	Repeat          = gl.REPEAT,
	Mirrored_Repeat = gl.MIRRORED_REPEAT,
	Clamp_To_Edge   = gl.CLAMP_TO_EDGE,
	Clamp_To_Border = gl.CLAMP_TO_BORDER,
}

Texture_Filter :: enum i32 {
	Nearest                = gl.NEAREST,
	Linear                 = gl.LINEAR,
	Nearest_Mipmap_Nearest = gl.NEAREST_MIPMAP_NEAREST,
	Linear_Mipmap_Nearest  = gl.LINEAR_MIPMAP_NEAREST,
	Nearest_Mipmap_Linear  = gl.NEAREST_MIPMAP_LINEAR,
	Linear_Mipmap_Linear   = gl.LINEAR_MIPMAP_LINEAR,
}

Texture :: struct {
	handle:          u32,
	width, height:   i32,
	internal_format: Texture_Internal_Format,
	image_format:    Texture_Image_Format,
	wrap_s:          Texture_Wrap,
	wrap_t:          Texture_Wrap,
	filter_min:      Texture_Filter,
	filter_max:      Texture_Filter,
}

Texture_Handle :: assets.Asset_Handle

Texture_Config :: struct {
	path: string,
}

load_texture :: proc(registry: ^assets.Asset_Registry, config: Texture_Config) -> Texture_Handle {

	assets.register_asset_list(registry, Texture)

	texture := Texture {
		width           = 0,
		height          = 0,
		internal_format = .RGBA,
		image_format    = .RGBA,
		wrap_s          = .Repeat,
		wrap_t          = .Repeat,
		filter_min      = .Nearest_Mipmap_Linear,
		filter_max      = .Nearest,
	}
	nrChannels: i32

	data := stb_image.load(
		strings.clone_to_cstring(config.path),
		&texture.width,
		&texture.height,
		&nrChannels,
		4,
	)

	if data == nil {
		panic("STB failed to load image")
	}

	generate_texture(&texture, data)

	stb_image.image_free(data)

	return assets.insert_asset(registry, texture)
}

generate_texture :: proc(texture: ^Texture, data: rawptr) {
	gl.GenTextures(1, &texture.handle)
	gl.BindTexture(gl.TEXTURE_2D, texture.handle)

	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		i32(texture.internal_format),
		texture.width,
		texture.height,
		0,
		u32(texture.image_format),
		gl.UNSIGNED_BYTE,
		data,
	)
	// set Texture wrap and filter modes
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, i32(texture.wrap_s))
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, i32(texture.wrap_t))
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, i32(texture.filter_min))
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, i32(texture.filter_max))
	gl.GenerateMipmap(gl.TEXTURE_2D)
	// unbind texture
	gl.BindTexture(gl.TEXTURE_2D, 0)
}


bind_texture :: proc(texture: ^Texture) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, texture.handle)
}
