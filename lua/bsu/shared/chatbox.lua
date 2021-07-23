-- chatbox.lua by Bonyoze
-- BSU custom chatbox

bsuChat = bsuChat or {}

if SERVER then
	-- send files to client-side
	AddCSLuaFile(MODULES_DIR .. "chatbox/messageManager.lua")
	AddCSLuaFile(MODULES_DIR .. "chatbox/frameManager.lua")
	AddCSLuaFile(MODULES_DIR .. "chatbox/chatManager.lua")

	-- setup hooks for player join/leave custom messages
	util.AddNetworkString("BSU_PlayerJoinLeaveMsg")

	hook.Add("PlayerInitialSpawn", "BSU_PlayerConnectMsg", function(ply)
		net.Start("BSU_PlayerJoinLeaveMsg")
			net.WriteString(ply:Nick())
			net.WriteTable(BSU:GetPlayerColor(ply))
			net.WriteBool(true)
			net.WriteBool(BSU:GetPlayerDBData(ply) == nil) -- is first time joining
			net.WriteBool(ply:IsBot()) -- player is a bot
		net.Send(player.GetAll())
	end)
	hook.Add("PlayerDisconnected", "BSU_PlayerDisconnectMsg", function(ply)
		net.Start("BSU_PlayerJoinLeaveMsg")
			net.WriteString(ply:Nick())
			net.WriteTable(BSU:GetPlayerColor(ply))
			net.WriteBool(false)
			-- these must be added but aren't used
			net.WriteBool(false)
			net.WriteBool(ply:IsBot())
		net.Send(player.GetAll())
	end)
else
	errorImage = "data:image/png;base64, iVBORw0KGgoAAAANSUhEUgAAAAgAAAAICAMAAADz0U65AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAGUExURf8A/gAAACcac5cAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAARSURBVBhXY2BgRIPkiDAyAAAEyAAhvFw1dgAAAABJRU5ErkJggg=="

	bsuChat.isOpen = false
	bsuChat.chatType = "global"
	bsuChat.chatTypes = {
		-- Main types (DO NOT REMOVE)
		global     = { icon = "world", toggleable = true },
		team       = { icon = "group", toggleable = true  },
		admin      = { icon = "shield"--[[, toggleable = user is admin]] },
		private    = { icon = "user_comment" },
		info     = { icon = "information" },
		-- Other types (cosmetic)
		connect    = { icon = "connect" }, -- player joined server
		disconnect = { icon = "disconnect" }, -- player left server
		namechange = { icon = "user_edit" } -- player changed name
	}

	-- include other files
	include(MODULES_DIR .. "chatbox/messageManager.lua")
	include(MODULES_DIR .. "chatbox/frameManager.lua")
	include(MODULES_DIR .. "chatbox/chatManager.lua")

	concommand.Add("bsu_chatbox_clear", function() -- clears all chat messages
		bsuChat.html:Call([[
			$("#chatbox > *").empty();
		]])
	end)

	hook.Add("PlayerBindPress", "BSU_OpenChatbox", function(ply, bind, pressed) -- opens the chatbox
		if bind == "messagemode" || bind == "messagemode2" then

			-- set current chatType
			if bind == "messagemode" then
				bsuChat.chatType = "global"
			elseif bind == "messagemode2" then
				bsuChat.chatType = "team"
			end

			-- show the chatbox
			if IsValid(bsuChat.frame) then
				bsuChat.show()
			else
				bsuChat.create()
				bsuChat.show()
			end

			-- update chat icon
			bsuChat.chatIcon:SetImage("icon16/" .. bsuChat.chatTypes[bsuChat.chatType].icon .. ".png")

			return true
		end
	end)

	hook.Add("HUDShouldDraw", "BSU_HideDefaultChatbox", function(name) -- hide the default chatbox
		if name == "CHudChat" then
			return false
		end
	end)

	hook.Add("OnGamemodeLoaded", "BSU_ChatboxInit", function()
		if not IsValid(bsuChat.frame) then
			bsuChat.create()
		end
	end)
end

-- some useful functions for formatting messages less painfully

function bsuChat._text(text)
	return {
		type = "text",
		value = text
	}
end

function bsuChat._hyperlink(url, text)
	return {
		type = "hyperlink",
		value = {
			url = url,
			text = text
		}
	}
end

function bsuChat._image(url)
	return {
		type = "image",
		value = url
	}	
end

function bsuChat._color(color)
	return {
		type = "color",
		value = color or color_white
	}
end

function bsuChat._italic(bool)
	return {
		type = "italic",
		value = bool == nil and true or bool
	}
end

function bsuChat._bold(bool)
	return {
		type = "bold",
		value = bool == nil and true or bool
	}
end

function bsuChat._strikethrough(bool)
	return {
		type = "strikethrough",
		value = bool == nil and true or bool
	}
end

function bsuChat._player(ply)
	return bsuChat._color(BSU:GetPlayerColor(ply)), bsuChat._bold(), bsuChat._text(ply and ply:IsValid() and ply:IsPlayer() and ply:Nick() or "Console"), bsuChat._bold(false)
end