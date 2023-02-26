-- CONSTS
local OFFSET = 0x56454E;
local BASE_RATIO = 16/9

-- MEMORY POINTERS
local p_effectsOverlayWidth = 0x89E9B0
local p_mainRenderWidth = 0x89EB04
local p_mainRenderHeight = 0x89E9B4
local p_viewPortHeightMult = 0x89E9C4
local p_viewPortWidthMult = 0x89E9C0
local p_uiWidth = 0x89E9E8

-- GLOBAL VARS
local g_canExecute = true;
local g_previousUIWidth = 640;

function prettyPrintModInfo()
	ConsolePrint("===================================")
    ConsolePrint("======== Ultrawide Support ========")
    ConsolePrint("======= JoplaSoft | v0.0.3a =======")
    ConsolePrint("===================================")
    print("")
end

function checkEngine()
	if ENGINE_VERSION < 4.1 then
        ConsolePrint("Wrong LuaEngine version. Please use at least version 4.1!", 3)
        g_canExecute = false
    end
end

function checkGame()
	if GAME_ID == 0x431219CC and ENGINE_TYPE == "BACKEND" then
		ConsolePrint("KH2 detected, running script")
		if ReadInt(0x2A5A056-OFFSET) > 0 and ReadInt(0x2A59056-OFFSET) == 0 then
			OFFSET = 0x56550E
			ConsolePrint("Detected JP version. If this is incorrect, try reloading at a different time")
		else
			ConsolePrint("Detected GLOBAL version. If this is incorrect, try reloading at a different time")
		end
	else
		g_canExecute = false
		ConsolePrint("KH2 not detected, not running script")
	end
end

function _OnInit()
    LUA_NAME = "ultrawide"
	
	prettyPrintModInfo()
	checkEngine()
	checkGame()
end

function _OnFrame()
	if g_canExecute then
		local renderWidth = ReadFloat(p_mainRenderWidth - OFFSET)
		local renderHeight = ReadFloat(p_mainRenderHeight - OFFSET)

		-- calculate expected width and height for a 16:9 ratio within the render bounds
		local expectedWidth = 0;
		local expectedHeight = math.floor(renderWidth / BASE_RATIO + 0.5)
		if expectedHeight > renderHeight then
			expectedHeight = renderHeight;
			-- expected width will always be smaller than renderWidth
			expectedWidth = math.floor(renderHeight * BASE_RATIO + 0.5)
		else
			expectedWidth = renderWidth
		end

		-- 2 scenario's
		-- either
		if expectedHeight < renderHeight then
			-- we need to change the viewport height mult
			-- not possible to fix the UI here (afaik)
			local newHeightRatio = renderHeight / expectedHeight
			WriteFloat(p_viewPortHeightMult - OFFSET, newHeightRatio)
		    WriteFloat(p_viewPortWidthMult - OFFSET, 1)
		elseif expectedWidth < renderWidth then
			-- we need to change viewport width mult
			local newWidthRatio = renderWidth / expectedWidth
			WriteFloat(p_viewPortWidthMult - OFFSET, newWidthRatio)
			WriteFloat(p_viewPortHeightMult - OFFSET, 1)

			-- and fix the UI
			local newUIWidth = g_previousUIWidth / newWidthRatio
			WriteFloat(p_uiWidth - OFFSET, newUIWidth)
		else
			-- otherwise render bounds exactly match 16:9 ratio and we change ratios back to 1
			WriteFloat(p_viewPortHeightMult - OFFSET, 1)
			WriteFloat(p_viewPortWidthMult - OFFSET, 1)
		end

		WriteFloat(p_effectsOverlayWidth - OFFSET, renderWidth)
	end
end
