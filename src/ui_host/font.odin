package ui_host

import "core:fmt"
import "core:mem"
import "simplex:assets"
import "simplex:graphics"

Font_Provider :: struct {
	allocator:      mem.Allocator,
	store:          map[string]graphics.Font_Handle,
	// Borrowed
	asset_registry: ^assets.Asset_Registry,
}

// Does not own the Asset_Registry, only borrows
make_font_provider :: proc(
	asset_registry: ^assets.Asset_Registry,
	allocator := context.allocator,
) -> ^Font_Provider {
	font_provider := new(Font_Provider, allocator)
	if font_provider == nil do return nil

	font_provider.allocator = allocator
	font_provider.asset_registry = asset_registry
	font_provider.store = make(map[string]graphics.Font_Handle, allocator)
	return font_provider
}

delete_font_provider :: proc(font_provider: ^Font_Provider) {
	free_all(font_provider.allocator)
	free(font_provider)
}

// This will make a font accesible to styles via a name as a string
store_font :: proc(
	font_provider: ^Font_Provider,
	font_name: string,
	handle: graphics.Font_Handle,
) {
	if font_name in font_provider.store {
		panic(fmt.tprint("Font already in Font_Provider with name ", font_name))
	}

	font_provider.store[font_name] = handle
}

resolve_font :: proc(font_provider: ^Font_Provider, font_name: string) -> ^graphics.Font {
	font_handle, ok := font_provider.store[font_name]
	if !ok {
		panic(fmt.tprint("No font in Font_Provider with name ", font_name))
	}

	return assets.get_asset(font_provider.asset_registry, graphics.Font, font_handle)
}
