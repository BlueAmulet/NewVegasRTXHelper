#pragma once

static __declspec(naked) void SetRegionEditorNameHook() {

	__asm {
		push	ecx
		call	SetRegionEditorName
		add		esp, 8
		xor		esi, esi
		jmp		kSetRegionEditorNameReturn
	}

}



static __declspec(naked) void SetWeatherEditorNameHook() {

	__asm {
		push	ecx
		call	SetWeatherEditorName
		add		esp, 8
		jmp		kSetWeatherEditorNameReturn
	}

}