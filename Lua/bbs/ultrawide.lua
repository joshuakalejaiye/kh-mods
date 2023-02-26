local OFFSET = 0x60E334
local BASE_RATIO = 16/9

local g_canExecute = true

local p_mainRenderWidth = 0x110B5988
local p_mainRenderHeight = 0x110B598C
local p_viewPortWidthMult = 0x110B5990
local p_viewPortHeightMult = 0x110B5994

function prettyPrintModInfo()
	ConsolePrint("===================================")
    ConsolePrint("======== Ultrawide Support ========")
    ConsolePrint("======= JoplaSoft | v0.0.2a =======")
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
    if GAME_ID == 0xBED4B944 and ENGINE_TYPE == "BACKEND" then
        InitializeRPC("839545395368820806")
    else
        ConsolePrint("Invalid Game. This script only works with KH:BBS FM PC (Global) version.", 3)
        g_canExecute = false
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
			local newHeightRatio = renderHeight / expectedHeight
			WriteFloat(p_viewPortHeightMult - OFFSET, newHeightRatio)
		    WriteFloat(p_viewPortWidthMult - OFFSET, 1)
		elseif expectedWidth < renderWidth then
			-- we need to change viewport width mult
			local newWidthRatio = renderWidth / expectedWidth
			WriteFloat(p_viewPortWidthMult - OFFSET, newWidthRatio)
			WriteFloat(p_viewPortHeightMult - OFFSET, 1)
		else
			-- otherwise render bounds exactly match 16:9 ratio and we change ratios back to 1
			WriteFloat(p_viewPortHeightMult - OFFSET, 1)
			WriteFloat(p_viewPortWidthMult - OFFSET, 1)
		end
	end
end
