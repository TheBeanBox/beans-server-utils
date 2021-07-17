-- bsu_init.lua by Bonyoze
-- Makes all the shit work

DIR = "bsu/"
LIB_DIR = DIR .. "base/bsu_lib/"
CMDS_DIR = DIR .. "base/commands/"
SV_DIR = DIR .. "server/"
SH_DIR = DIR .. "shared/"
CL_DIR = DIR .. "client/"

local lib = file.Find(LIB_DIR .. "*.lua", "LUA") -- bsu library files
local cmds = file.Find(CMDS_DIR .. "*.lua", "LUA") -- commands files
local sv = file.Find(SV_DIR .. "*.lua", "LUA") -- server files
local sh = file.Find(SH_DIR .. "*.lua", "LUA") -- shared files
local cl = file.Find(CL_DIR .. "*.lua", "LUA") -- client files

BSU = BSU or {}

-- const values
BSU.DEFAULT_RANK = 101 -- Guest team index
BSU.BOT_RANK = 108 -- Bot team index
BSU.AFK_TIMEOUT = 900 -- 900 secs (15 mins)
BSU.CMD_PREFIX = "!"

-- some useful functions
function BSU:HexToColor(hex, alpha)
  local hex = hex:gsub("#","")
  return Color(tonumber("0x" .. hex:sub(1,2)), tonumber("0x" .. hex:sub(3,4)), tonumber("0x" .. hex:sub(5,6)), alpha or 255)
end

function BSU:ColorToHex(color)
  return string.format("%.2x%.2x%.2x", color.r, color.g, color.b)
end

-- SERVER/CLIENT SETUP
if SERVER then
  MsgN("[BSU SERVER] Started up")
  
  -- load/send library
  for _, file in  ipairs(lib) do
    include(LIB_DIR .. file)
    AddCSLuaFile(LIB_DIR .. file)
  end

  -- load/send base scripts
  include("bsu/base/database.lua") 

  include("bsu/base/teams.lua")
  AddCSLuaFile("bsu/base/teams.lua")

  include("bsu/base/player.lua")
  AddCSLuaFile("bsu/base/player.lua")

  -- load commands
  include("bsu/base/commands.lua")
  AddCSLuaFile("bsu/base/commands.lua")

  for _, file in ipairs(cmds) do
    include(CMDS_DIR .. file)
    AddCSLuaFile(CMDS_DIR .. file)
  end

  -- load assets
  resource.AddSingleFile("materials/bsu/scoreboard/windows.png")
  resource.AddSingleFile("materials/bsu/scoreboard/mac.png")
  resource.AddSingleFile("materials/bsu/stathud/stathudIcons16.png")

  include("bsu/developer.lua") -- REMOVE THIS WHEN PUBLIC
  AddCSLuaFile("bsu/developer.lua")

  -- SERVER MODULES
  for _, file in ipairs(sv) do
    include(SV_DIR .. file)
  end

  for _, file in ipairs(sh) do
    include(SH_DIR .. file)
    AddCSLuaFile(SH_DIR .. file)
  end

  for _, file in ipairs(cl) do
    AddCSLuaFile(CL_DIR .. file)
  end

  MsgN("[BSU SERVER] Finished loading modules")
else
  MsgN("[BSU CLIENT] Started up")

  -- load/send library
  for _, file in  ipairs(lib) do
    include(LIB_DIR .. file)
  end

  -- load base scripts
  include("bsu/base/teams.lua")

  include("bsu/base/player.lua")

  -- load commands
  include("bsu/base/commands.lua")

  for _, file in ipairs(cmds) do
    include(CMDS_DIR .. file)
    AddCSLuaFile(CMDS_DIR .. file)
  end

  include("bsu/developer.lua") -- REMOVE THIS WHEN PUBLIC

  -- CLIENT MODULES
  for _, file in ipairs(sh) do
    include(SH_DIR .. file)
  end

  for _, file in ipairs(cl) do
    include(CL_DIR .. file)
  end

  MsgN("[BSU CLIENT] Finished loading modules")
end

hook.Add("OnGamemodeLoaded", "BSU_GetTeamColorOverride", function()
  GAMEMODE.GetTeamColor = BSU.GetPlayerColor
end)