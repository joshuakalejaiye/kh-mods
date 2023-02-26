local offset = 0x3A0606;

local canExecute = true
local mainRenderWidth = 0x22B7290;
local mainRenderHeight = 0x22B7294;
local mode = 0x3B1534;

local previousRenderWidth = 1920;
local previousRenderHeight = 1080;

function prettyPrintModInfo()
	ConsolePrint("===================================")
    ConsolePrint("======== Ultrawide Support ========")
    ConsolePrint("======= JoplaSoft | v0.0.1a =======")
    ConsolePrint("===================================")
    print("")
end

function checkEngine()
	if ENGINE_VERSION < 4.1 then
        ConsolePrint("Wrong LuaEngine version. Please use at least version 4.1!", 3)
        canExecute = false
    end
end

function checkGame()
    if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
        ConsolePrint("Game Validated!")
    else
        ConsolePrint("Invalid Game. This script only works with KH1 PC (Global) version.", 3)
        canExecute = false
    end
end

function _OnInit()
    LUA_NAME = "ultrawide"

	prettyPrintModInfo()
	checkEngine()
	checkGame()
end

function _OnFrame()
	if canExecute then
		local previousWidthHeightRatio = previousRenderWidth / previousRenderHeight
		local renderWidth = ReadFloat(mainRenderWidth - offset)
		local renderHeight = ReadFloat(mainRenderHeight - offset)
		local currentWidthHeightRatio = renderWidth / renderHeight

		if math.abs(currentWidthHeightRatio - previousWidthHeightRatio) > 0.01 then
			local oldMode = ReadFloat(mode - offset)
			local newMode = oldMode * (previousWidthHeightRatio / currentWidthHeightRatio)
			WriteFloat(mode - offset, newMode)
		end
		
		previousRenderWidth = ReadFloat(mainRenderWidth - offset)
		previousRenderHeight = ReadFloat(mainRenderHeight - offset)
	end
end
