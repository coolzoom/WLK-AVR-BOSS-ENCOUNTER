AVRE = LibStub("AceAddon-3.0"):NewAddon("AVRE", "AceConsole-3.0", "AceEvent-3.0", "LibShefkiTimer-1.0", "AceComm-3.0", "AceSerializer-3.0")
AVRE.MINOR_VERSION = tonumber(("$Revision: 103 $"):match("%d+"))
local L = LibStub("AceLocale-3.0"):GetLocale("AVRE")
local zones = LibStub("AceLocale-3.0"):GetLocale("AVRE Zones")
local AVRE = AVRE
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject("AVRE", { label = "AVRE", type = "launcher", icon = "Interface\\Icons\\Achievement_Boss_Algalon_01" })
--



--[[
      VARIABLES ----------------------------------------------------------------------------------------------------------------
  ]]

local POLLING_FREQUENCY = 1.0
local possibleWipe = false
local targetList = {}
local pullChecks = 0
local commPrefix = "AVRE-1.0"
local startingFight = false

AVRE.isEnabled = false
AVRE.inCombat = false
AVRE.ver = {}
AVRE.raid = {}
AVRE.enc = {}
AVRE.zones = {}
AVRE.scene = nil
AVRE.fight = nil
AVRE.testZone = nil
AVRE.forceHeroic = nil
AVRE.testing = false
AVRE.forcedTargetNpc = nil
AVRE.forcedTargetName = nil
AVRE.rangeScene = nil

AVRE.modules = {
	options = {
		loaded = false,
	},
	encounters = {
		ulduar = {
			zone = zones["Ulduar"],
			addon = "AVRE_Ulduar",
			expansion = "wotlk",
			loaded = false,
		},
		icecrown = {
			zone = zones["Icecrown Citadel"],
			addon = "AVRE_Icecrown",
			expansion = "wotlk",
			loaded = false,
		},
	},
}



--[[
      UPVALUES -----------------------------------------------------------------------------------------------------------------
  ]]
  
local _G = getfenv(0)
local pairs = _G.pairs
local strlower = _G.strlower
local strupper = _G.strupper
local format = _G.format

local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName
local UnitInRaid = _G.UnitInRaid
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost



--[[
      UTILITIES ----------------------------------------------------------------------------------------------------------------
  ]]

function AVRE:tcopy(to, from)
 for k, v in pairs(from) do
  if type(v) == "table" then
   to[k] = {}
   AVRE:tcopy(to[k], v)
  else
   to[k] = v
  end
 end
end


function AVRE:Colorize(s, color, highlight)
	if color and s then
		if highlight then
			return string.format("|cff%02x%02x%02x%s|r", (color.r or 1) * 128 + 127, (color.g or 1) * 128 + 127, (color.b or 1) * 128 + 127, s)
		else
			return string.format("|cff%02x%02x%02x%s|r", (color.r or 1) * 255, (color.g or 1) * 255, (color.b or 1) * 255, s)
		end
	else
		return s
	end
end



--[[
      INITIALIZATION -----------------------------------------------------------------------------------------------------------
  ]]

function AVRE:OnInitialize()
	-- Register database
 self.db = LibStub("AceDB-3.0"):New("AVREDB", self.defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileDeleted", "OnProfileChanged")
	
	-- Register for slash commands
	self:RegisterChatCommand("avre", "ChatCommand")
end


function AVRE:OnEnable()
	-- Register for events
	self:UnregisterAllEvents()
	self:RegisterEvent("RAID_ROSTER_UPDATE", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "OnEvent")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "OnEvent")
	self:RegisterEvent("CHAT_MSG_MONSTER_EMOTE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "OnEvent")
	self:RegisterEvent("CHAT_MSG_MONSTER_SAY", "OnEvent")

	-- Register communication
	self:UnregisterAllComm()
 self:RegisterComm(commPrefix, "OnCommReceived")

	-- Initialize
	self:LoadZone()
	self:UpdateRaid()
	
	-- Turn us on
	AVRE.isEnabled = self.db.profile.enabled
	
	-- Ask the raid if we should be in a fight right now
	if UnitInRaid("player") then
		self:SendCommMessage(commPrefix, self:Serialize({ c = "FIGHT_REQUEST" }), "RAID")
	end

	--[===[@debug@
	self:Print(L["Loaded"])
	--@end-debug@]===]
end


function AVRE:OnDisable()
	self:EndFight()

	-- Cancel all timers
	self:CancelAllTimers()

	-- Turn us off
	AVRE.isEnabled = false
	
	--[===[@debug@
	self:Print(L["Disabled"])
	--@end-debug@]===]
end


function AVRE:ChatCommand(input)
	if strlower(input) == "ver" then
		self:VersionCheck()
	else
		if self.modules.options.loaded then InterfaceOptionsFrame_OpenToCategory(self.optionsFrame) end
	end
end


function AVRE:OnProfileChanged(event, database, newProfileKey)
	--[===[@debug@
		self:Print(L["Profile modified, rebooting"])
	--@end-debug@]===]
 self:Disable()
 self:Enable() 
end


function AVRE:VersionCheck()
	if UnitInRaid("player") then
		ver = {}
		self:SendCommMessage(commPrefix, self:Serialize({ c = "VER_REQ" }), "RAID")
		self:ScheduleTimer("OnVersionCheckFinished", 5)
	end
end

function AVRE:OnVersionCheckFinished()
	if UnitInRaid("player") then
		for k, v in pairs(AVRE.raid) do
			if not ver[k] and UnitInRaid(k) and v.online then
				self:Print(format(L["%s is not using AVRE"], k))
			end
		end
		local count = 0
		for k, v in pairs(ver) do count = count + 1 end
		local numNot = GetNumRaidMembers() - count
		if numNot < 0 then numNot = 0 end
		self:Print(format(L["%d player(s) are running AVRE. %d player(s) are not."], count, numNot))
	end
end



--[[
      DATA BROKER OBJECT -------------------------------------------------------------------------------------------------------
  ]]
  
function dataobj.OnTooltipShow(tooltip)
	if not tooltip or not tooltip.AddLine then return end
	tooltip:AddLine("|cffffff20AVR Encounters|r", 0, 1, 0)
	tooltip:AddLine(L["Click to open options."], 0, 1, 0)
	tooltip:Show()
end

function dataobj:OnClick(button)
	if AVRE.modules.options.loaded then
		InterfaceOptionsFrame_OpenToCategory(AVRE.optionsFrame)
	else
		AVRE:Print(L["AVRE_Options module not enabled"])
	end
end



--[[
      EVENTS -------------------------------------------------------------------------------------------------------------------
  ]]

function AVRE:OnEvent(event, ...)

	if event == "RAID_ROSTER_UPDATE" then
		self:UpdateRaid()
		
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		self:LoadZone()
						
	elseif event == "PLAYER_REGEN_DISABLED" then
		if UnitInRaid("player") then
			self.inCombat = true
			self:CheckForPull()
		end
			
	elseif event == "PLAYER_REGEN_ENABLED" then
		self.inCombat = false
		self:UpdateRaid()
		
	elseif event == "CHAT_MSG_MONSTER_YELL" then
		local msg = select(1, ...)
		if AVRE.fight and AVRE.fight.onYell then AVRE.fight.onYell(AVRE.fight, event, ...) end
		self:OnMonsterMessage("yell", msg)
	
	elseif event == "CHAT_MSG_MONSTER_EMOTE" then
		local msg = select(1, ...)
		if AVRE.fight and AVRE.fight.onYell then AVRE.fight.onYell(AVRE.fight, event, ...) end
		self:OnMonsterMessage("emote", msg)
	
	elseif event == "CHAT_MSG_RAID_BOSS_EMOTE" then
		local msg = select(1, ...)
		if AVRE.fight and AVRE.fight.onYell then AVRE.fight.onYell(AVRE.fight, event, ...) end
		self:OnMonsterMessage("emote", msg)
	
	elseif event == "CHAT_MSG_MONSTER_SAY" then
		local msg = select(1, ...)
		if AVRE.fight and AVRE.fight.onYell then AVRE.fight.onYell(AVRE.fight, event, ...) end
		self:OnMonsterMessage("say", msg)
					
 end
end


function AVRE:OnCombatEvent(event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, ...)
	-- local a = select(1, ...)
	-- self:Print(format("%s %s %s %s", eventType, srcName or "nil", dstName or "nil", a or "nil"))
	if AVRE.fight and AVRE.isEnabled then

		if AVRE.fight.combatEvents and (AVRE.fight.combatEvents.ALL or AVRE.fight.combatEvents[eventType]) then
			if AVRE.fight.onCombat then
				AVRE.fight.onCombat(AVRE.fight, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, ...)
			end
		end
		
		if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
			if bit.band(dstGuid:sub(1, 5), 0x00F) == 3 or bit.band(dstGuid:sub(1, 5), 0x00F) == 5 then
				self:OnMobKill(tonumber(dstGuid:sub(9, 12), 16))
			end
		end

	end
end


function AVRE:OnCommReceived(prefix, message, distribution, sender)
 local success, o = self:Deserialize(message)
 if success == false then
		--[===[@debug@
  self:Print("[OnCommReceived] Failed to deserialize message")
		--@end-debug@]===]
  return
 else
		if o.c then
		
			if o.c == "VER" then
				if o.v then
					ver[sender] = o.v
					self:Print(format(L["%s is using AVRE r%s"], sender, o.v))
				end

			elseif o.c == "VER_REQ" then
				self:SendCommMessage(commPrefix, self:Serialize({ c = "VER", v = self.MINOR_VERSION }), "WHISPER", sender)

			elseif o.c == "FIGHT_REQUEST" and sender ~= UnitName("player") then
				if AVRE.fight then
					self:SendCommMessage(commPrefix, self:Serialize({ c = "FIGHT_RESPONSE", f = AVRE.fight.enable.fight }), "WHISPER", sender)
				else
				end
				
			elseif o.c == "FIGHT_RESPONSE" and sender ~= UnitName("player") then
				if not AVRE.fight and not startingFight then
					if AVRE.enc[o.f] then
						startingFight = true
						self:LoadZone(true)
						self:ScheduleTimer(function()
							self:StartFight(AVRE.enc[o.f])
							startingFight = false
						end, 3.0)
					end
				end
				
			elseif o.c == "ENC_ROTFACE" and sender ~= UnitName("player") then
				if o.v and o.v ~= "" then
					AVRE.db.profile.enc.wotlk.icecrown.rotface.kiter = o.v
					LibStub("AceConfigRegistry-3.0"):NotifyChange("AVRE")
				end
				
			end
			
		end
 end
end



--[[
      TARGET DETECTION ---------------------------------------------------------------------------------------------------------
  ]]
  
do

	--[[
	
		GetBossTargetChange (typically useful for SPELL_CAST_START events during
		really picky mechanics):
		
			If the boss is your target or focus, start watching for UNIT_TARGET
			events. If one is found, use the unit's target at that point. If one
			is not found within 0.3 seconds, use the target at 0.3 seconds.
			
			If the boss isn't your target or focus, scan the raid to find it.
			Save it's target's GUID. Scan every 0.05 seconds for 0.3 seconds and see if
			the boss changes targets during that time. If so, use the new target.
			If not, use the target at 0.3 seconds.
			
		GetBossTarget (typically useful for SPELL_CAST_COMPLETE events):
		
		 After a configurable delay, scans your target, focus, and the entire
		 raid to find the boss. Once found, uses the boss target.
			
	]]

	local isScanning = false
	local lastGuid
	local interested_unit
	local tries = 0
	local tryTimer, cancelTimer
	local FAILSAFE_TIME = 0.3
	local TRY_REPEAT_TIME = 0.05
	local MAX_TRIES = 6
	local fn, cid
	local inDoTarget = false
	
	
	local function deinit()
		if tryTimer then AVRE:CancelTimer(tryTimer, true) end
		if cancelTimer then AVRE:CancelTimer(cancelTimer, true) end
		isScanning = false
		lastGuid = nil
		interested_unit = nil
		fn = nil
		cid = nil
		tryTimer = nil
		cancelTimer = nil
	end
	
	local function doTarget(unit)
		if not inDoTarget then
			inDoTarget = true
			local u = unit.."target"
			if UnitExists(u) then
				if fn and type(fn) == "function" then
					local n = UnitName(u)
					if n then
						--[===[@debug@
						AVRE:Print(format("Using boss target for unit '%s': '%s'", u, n))
						--@end-debug@]===]
						fn(n)
					end
				end
			end
			deinit()
			inDoTarget = false
		end
	end


	function AVRE:OnTarget(event, unit) -- Fires for UNIT_TARGET events
		if isScanning and unit == interested_unit then
			--[===[@debug@
			AVRE:Print(format("UNIT_TARGET fired for unit: '%s'", unit))
			--@end-debug@]===]
			doTarget(unit)
		end
	end
	
	
	-- failsafe doesn't get scheduled for a normal repeated scan
	local function failsafe()
		--[===[@debug@
		AVRE:Print("FAILSAFE fired")
		--@end-debug@]===]
		if interested_unit then
			--[===[@debug@
			AVRE:Print(format("Failsafe is running doTarget on interested_unit: %s", interested_unit))
			--@end-debug@]===]
			doTarget(interested_unit)
		else
			local name, unit, guid = scan(cid)
			if unit then
				--[===[@debug@
				AVRE:Print(format("Failsafe is running doTarget on unit: %s", unit))
				--@end-debug@]===]
				doTarget(unit)
			else
				--[===[@debug@
				AVRE:Print("Failsafe fired, but did not have any unit to use")
				--@end-debug@]===]
				deinit()
			end
		end
	end
	
	
	local t = {"target", "targettarget", "focus", "focustarget", "mouseover", "mouseovertarget"}
	for i = 1, 4 do t[#t+1] = format("boss%d", i) end
	for i = 1, 4 do t[#t+1] = format("party%dtarget", i) end
	for i = 1, 40 do t[#t+1] = format("raid%dtarget", i) end
	local function findBoss(id)
		local idType = type(id)
		for i, unit in next, t do
			if UnitExists(unit) and not UnitIsPlayer(unit) then
				local unitId = UnitGUID(unit)
				if idType == "number" then unitId = tonumber(unitId:sub(-12, -7), 16) end
				if unitId == id then return unit end
			end
		end
	end
	

	local function scan(id)
		local unit = findBoss(id)
		if not unit then return end
		if UnitExists(unit.."target") then return UnitName(unit.."target"), unit, UnitGUID(unit.."target") end
	end
	
	
	local function try()
		if tries >= MAX_TRIES then return end
		tries = tries + 1
		local name, unit, guid = scan(cid)
		if unit and guid and guid ~= lastGuid then
			--[===[@debug@
			AVRE:Print(format("GUID change detected on try %d", tries))
			--@end-debug@]===]
			doTarget(unit)
			return
		end
		
		if tries == MAX_TRIES then
			--[===[@debug@
			AVRE:Print("MAX_TRIES reached")
			--@end-debug@]===]
			if unit then
				--[===[@debug@
				AVRE:Print(format("Trying to doTarget unit %s", unit))
				--@end-debug@]===]
				doTarget(unit)
			else
				--[===[@debug@
				AVRE:Print("Reached MAX_TRIES but didn't call doTarget")
				--@end-debug@]===]
				deinit()
			end
		end
	end


	function AVRE:GetBossTargetChange(_cid, _fn)
		deinit()
		inDoTarget = false
		
		fn = _fn
		cid = _cid

		--[===[@debug@
		if AVRE.forcedTargetNpc == cid and AVRE.forcedTargetName and fn then
			fn(AVRE.forcedTargetName)
			return
		end
		--@end-debug@]===]
		
		if self:GetUnitCreatureId("target") == cid then
			interested_unit = "target"
			isScanning = true
			cancelTimer = self:ScheduleTimer(failsafe, FAILSAFE_TIME)
		elseif self:GetUnitCreatureId("focus") == cid then
			interested_unit = "focus"
			isScanning = true
			cancelTimer = self:ScheduleTimer(failsafe, FAILSAFE_TIME)
		else
			interested_unit = nil
			local name, unit, guid = scan(cid)
			lastGuid = guid
			tries = 0
			self:ScheduleRepeatingTimer(try, TRY_REPEAT_TIME)
		end
	end
	
	function AVRE:GetBossTarget(_cid, _fn, _delay)
		--[===[@debug@
		if AVRE.forcedTargetNpc == _cid and AVRE.forcedTargetName and _fn then
			_fn(AVRE.forcedTargetName)
			return
		end
		--@end-debug@]===]
		self:ScheduleTimer(function()
			local name, unit, guid = scan(_cid)
			if name and type(_fn) == "function" then
				--[===[@debug@
				AVRE:Print(format("Normal scan is using unit: %s, target: %s", unit, name))
				--@end-debug@]===]
				_fn(name)
			end
		end, _delay or 0.1)
	end
	
end



--[[
      PLAYER TYPE DETECTION ----------------------------------------------------------------------------------------------------
  ]]
  
local function getTalentpointsSpent(spellID)
	local spellName = GetSpellInfo(spellID)
	for tabIndex=1, GetNumTalentTabs() do
		for talentID=1, GetNumTalents(tabIndex) do
			local name, _, _, _, spent = GetTalentInfo(tabIndex, talentID)
			if(name == spellName) then
				return spent
			end
		end
	end
	return 0
end

function AVRE:IsMelee()
	return select(2, UnitClass("player")) == "ROGUE"
		or select(2, UnitClass("player")) == "WARRIOR"
		or select(2, UnitClass("player")) == "DEATHKNIGHT"
		or (select(2, UnitClass("player")) == "PALADIN" and select(3, GetTalentTabInfo(1)) < 51)
		or (select(2, UnitClass("player")) == "SHAMAN" and select(3, GetTalentTabInfo(2)) >= 51)
		or (select(2, UnitClass("player")) == "DRUID" and select(3, GetTalentTabInfo(2)) >= 51)
end

function AVRE:IsRanged()
	return select(2, UnitClass("player")) == "MAGE"
		or select(2, UnitClass("player")) == "HUNTER"
		or select(2, UnitClass("player")) == "WARLOCK"
		or select(2, UnitClass("player")) == "PRIEST"
		or (select(2, UnitClass("player")) == "PALADIN" and select(3, GetTalentTabInfo(1)) >= 51)
		or (select(2, UnitClass("player")) == "SHAMAN" and select(3, GetTalentTabInfo(2)) < 51)
		or (select(2, UnitClass("player")) == "DRUID" and select(3, GetTalentTabInfo(2)) < 51)
end

function AVRE:IsPhysical()
	return self:IsMelee() or select(2, UnitClass("player")) == "HUNTER"
end

function AVRE:CanRemoveEnrage()
	return select(2, UnitClass("player")) == "HUNTER" or select(2, UnitClass("player")) == "ROGUE"
end

local function IsDeathKnightTank()
	local tankTalents = (getTalentpointsSpent(16271) >= 5 and 1 or 0) +		-- Anticipation
	                    (getTalentpointsSpent(49042) >= 5 and 1 or 0) +		-- Toughness
																					(getTalentpointsSpent(55225) >= 5 and 1 or 0)	  	-- Blade Barrier
	return tankTalents >= 2
end

local function IsDruidTank()
	local tankTalents = (getTalentpointsSpent(57881) >= 2 and 1 or 0) +		-- Natural Reaction
	                    (getTalentpointsSpent(16929) >= 3 and 1 or 0) +		-- Thick Hide
																					(getTalentpointsSpent(61336) >= 1 and 1 or 0) +		-- Survival Instincts
																					(getTalentpointsSpent(57877) >= 3 and 1 or 0)		  -- Protector of the Pack
	return tankTalents >= 3
end

function AVRE:IsTank()
	return (select(2, UnitClass("player")) == "WARRIOR" and select(3, GetTalentTabInfo(3)) >= 51)
		or (select(2, UnitClass("player")) == "DEATHKNIGHT" and IsDeathKnightTank())
		or (select(2, UnitClass("player")) == "PALADIN" and select(3, GetTalentTabInfo(2)) >= 51)
		or (select(2, UnitClass("player")) == "DRUID" and select(3, GetTalentTabInfo(2)) >= 51 and IsDruidTank())
end

function AVRE:IsHealer()
	return (select(2, UnitClass("player")) == "PALADIN" and select(3, GetTalentTabInfo(1)) >= 51)
		or (select(2, UnitClass("player")) == "SHAMAN" and select(3, GetTalentTabInfo(3)) >= 51)
		or (select(2, UnitClass("player")) == "DRUID" and select(3, GetTalentTabInfo(3)) >= 51)
		or (select(2, UnitClass("player")) == "PRIEST" and select(3, GetTalentTabInfo(3)) < 51)
end



--[[
      PULL DETECTION -----------------------------------------------------------------------------------------------------------
  ]]
  
-- Combat-based detection (some raid member is targeting the boss, and the boss is affecting combat)
function AVRE:BuildTargetList()
	local uId = "raid"
	for i = 0, GetNumRaidMembers() do
		local id = (i == 0 and "target") or uId..i.."target"
		local guid = UnitGUID(id)
		if guid and (bit.band(guid:sub(1, 5), 0x00F) == 3 or bit.band(guid:sub(1, 5), 0x00F) == 5) then
			local cId = tonumber(guid:sub(9, 12), 16)
			targetList[cId] = id
		end
	end
end

function AVRE:ClearTargetList()
	table.wipe(targetList)
end

function AVRE:DoDelayedCheckForPull(mob, fight)
	if not fight.inCombat then
		AVRE:BuildTargetList()
		pullChecks = pullChecks + 1
		if targetList[mob] and UnitAffectingCombat(targetList[mob]) then
			--[===[@debug@
			self:Print("Pull detected")
			--@end-debug@]===]
			AVRE:StartFight(fight, 3)
		elseif targetList[mob] and pullChecks < 10 then
			AVRE:ScheduleTimer(function() AVRE:DoDelayedCheckForPull(mob, fight) end, 3 * pullChecks)
		end
		AVRE:ClearTargetList()
	end
end

function AVRE:DoCheckForPull(mob, fight)
	local uId = targetList[mob]
	if uId and UnitAffectingCombat(uId) then
		--[===[@debug@
		self:Print("Pull detected")
		--@end-debug@]===]
		AVRE:StartFight(fight, 0)
		return true
	elseif uId then
		AVRE:ScheduleTimer(function() AVRE:DoDelayedCheckForPull(mob, fight) end, 3)
	end
end

function AVRE:CheckForPull()
	if zones and (zones[GetRealZoneText()] or (AVRE.testZone and zones[AVRE.testZone])) then
		pullChecks = 0
		AVRE:BuildTargetList()
		for k, v in pairs(AVRE.enc) do
			if v.pull and v.pull.type == "combat" and v.pull.npcs then
				for kk, vv in pairs(v.pull.npcs) do
					if AVRE:DoCheckForPull(vv, v) then break end
				end
			end
		end
		AVRE:ClearTargetList()
	end
end


-- Yell-based detection (used for some vehicle fights, etc.)
function AVRE:OnMonsterMessage(type, msg)

	-- Pull detection
	if zones and (zones[GetRealZoneText()] or (AVRE.testZone and zones[AVRE.testZone])) then
		for k, v in pairs(AVRE.enc) do
			if v.pull and v.pull.type == "yell" and v.pull.yells then
				for kk, vv in pairs(v.pull.yells) do
					if vv == msg then
						--[===[@debug@
						self:Print("Pull detected")
						--@end-debug@]===]
						AVRE:StartFight(v, 0)
					end
				end
			end
		end
	end

	-- Defeat detection
	if zones and (zones[GetRealZoneText()] or (AVRE.testZone and zones[AVRE.testZone])) then
		for k, v in pairs(AVRE.enc) do
			if v.defeat and v.defeat.type == "yell" and v.defeat.yells then
				for kk, vv in pairs(v.defeat.yells) do
					if vv == msg and v.inCombat then
						--[===[@debug@
						self:Print("Defeat detected")
						--@end-debug@]===]
						AVRE:EndFight()
					end
				end
			end
		end
	end

end
	


--[[
      WIPE DETECTION -----------------------------------------------------------------------------------------------------------
  ]]

function AVRE:CheckForWipe()
	local wipe = true
	local uId = ((GetNumRaidMembers() == 0) and "party") or "raid"
	for i = 0, math.max(GetNumRaidMembers(), GetNumPartyMembers()) do
		local id = (i == 0 and "player") or uId..i
		if UnitAffectingCombat(id) and not UnitIsDeadOrGhost(id) then
			wipe = false
			break
		end
	end
	return wipe
end



--[[
      DEFEAT DETECTION ---------------------------------------------------------------------------------------------------------
  ]]

function AVRE:OnMobKill(id)
	if AVRE.fight and AVRE.fight.defeat and AVRE.fight.defeat.type == "death" then
		if not AVRE.fight.dead then AVRE.fight.dead = {} end
		if AVRE.fight.defeat.npcs then
			for k, v in pairs(AVRE.fight.defeat.npcs) do
				if id == v then
					AVRE.fight.dead[v] = true
				end
			end
			local allDead = true
			for k, v in pairs(AVRE.fight.defeat.npcs) do
				if not AVRE.fight.dead[v] then
					allDead = false
					break
				end
			end
			if allDead then
				if AVRE.fight.onDefeat then AVRE.fight.onDefeat(AVRE.fight) end
				--[===[@debug@
				self:Print("Defeat detected")
				--@end-debug@]===]
				self:EndFight()
			end
		end
	end
end



--[[
      FIGHT LOGIC --------------------------------------------------------------------------------------------------------------
  ]]

function AVRE:OnTimer()
	self:UpdateRaid()
end


function AVRE:UpdateRaid()
	if UnitInRaid("player") then
	
		for k, v in pairs(AVRE.raid) do
			AVRE.raid[k].valid = nil
		end
	
		-- Gather data about the raid
		local numRaid = GetNumRaidMembers()
		for i = 1, numRaid do
			local playerName, rank, subgroup, level, class, fileName, zone, online, isDead, role, isML = GetRaidRosterInfo(i)
			if playerName then
				if not AVRE.raid[playerName] then AVRE.raid[playerName] = {} end
				AVRE.raid[playerName].rank = rank
				AVRE.raid[playerName].subgroup = subgroup
				AVRE.raid[playerName].level = level
				AVRE.raid[playerName].class = class
				AVRE.raid[playerName].zone = zone
				AVRE.raid[playerName].online = online
				AVRE.raid[playerName].isDead = isDead
				AVRE.raid[playerName].role = role
				AVRE.raid[playerName].isML = isML
				AVRE.raid[playerName].valid = true
			end -- valid player at that index
		end -- player loop
		
		-- Delete players no longer in the raid
		for k, v in pairs(AVRE.raid) do
			if not v.valid then
				AVRE.raid[k] = nil
			end
		end
		
		-- Check for a wipe
		if AVRE.isEnabled and AVRE.fight and self:CheckForWipe() and not possibleWipe then
			possibleWipe = true
			local time = 5
			if AVRE.fight.wipeTime then time = AVRE.fight.wipeTime end
			--[===[@debug@
			self:Print(format("Possible wipe detected. Checking again in %d seconds.", time))
			--@end-debug@]===]
			self:ScheduleTimer(function()
				if possibleWipe then
					if AVRE:CheckForWipe() then
						possibleWipe = false
						if AVRE.fight.onWipe then AVRE.fight.onWipe(AVRE.fight) end
						--[===[@debug@
						self:Print("Wipe detected")
						--@end-debug@]===]
						AVRE:EndFight()
					end
				end
			end, time)
		end
		
	else
		AVRE.raid = {}
	end -- we're in a raid
end


function AVRE:CancelPossibleWipe()
	possibleWipe = false
end


function AVRE:LoadZone(now)
	for k, v in pairs(self.modules.encounters) do
		if (GetRealZoneText() == v.zone or (AVRE.testZone and AVRE.testZone == v.zone)) and v.addon and not IsAddOnLoaded(v.addon) then
			local inInstance, instanceType = IsInInstance()
			if inInstance and instanceType == "raid" then
				if now then
					LoadAddOn(v.addon)
				else
					self:ScheduleTimer(function() LoadAddOn(v.addon) end, 3)
				end
			end
		end
	end
end


function AVRE:StartFight(fight, startDelay, silent)
	local enabled = false
	if fight and fight.enable then
		if fight.enable.expansion and self.db.profile.enc[fight.enable.expansion] and self.db.profile.enc[fight.enable.expansion].enabled then
			if fight.enable.instance and self.db.profile.enc[fight.enable.expansion][fight.enable.instance] and self.db.profile.enc[fight.enable.expansion][fight.enable.instance].enabled then
				if fight.enable.fight and self.db.profile.enc[fight.enable.expansion][fight.enable.instance][fight.enable.fight] and self.db.profile.enc[fight.enable.expansion][fight.enable.instance][fight.enable.fight].enabled then
					enabled = true
				end
			end
		end
	end
	
	if enabled and AVRE.isEnabled and AVR and AVR.sceneManager then
		-- Initialize AVR scene
		AVRE.scene = AVR:GetTempScene("AVR_ENCOUNTERS")
		AVRE.scene:ClearScene()
		AVRE.scene.visible = true
		
		-- Initialize range check scene (this scene can also be used for specific fight mechanics, it must always exist)
		if AVRE.rangeScene then AVR.sceneManager:RemoveScene(AVRE.rangeScene) end
		local s = AVRRangeWarningScene:New(AVR.threed)
		s.save = false -- don't save it in saved variables
		s.guiVisible = false -- don't show it in normal options dialogs
		s.visible = false -- initially make the scene invisible
		s:SetClassColor(AVRE.db.profile.range.classColor) -- if you want markers colored by class
		s:SetLine(AVRE.db.profile.range.line) -- if you want a line drawn as well
		s:SetCircle(AVRE.db.profile.range.circle) -- if you want a circle drawn at warning range
		s:SetRadius(AVRE.db.profile.range.radius) -- size of the markers
		s:SetUseTexture(true) -- draws meshes with a single texture instead of several polygons, makes things a bit faster
		AVR.sceneManager:AddScene(s)
		AVRE.rangeScene = s
		
		-- Turn on range check if fight definition asks for it
		if fight.range and ((self:IsHeroicRaid() and fight.range.heroic) or (not self:IsHeroicRaid() and fight.range.normal)) then
			if fight.o("range") and fight.o("range").enabled and fight.o("range").range then
				if AVRE.rangeScene then
					AVRE.rangeScene:SetRange(fight.o("range").range)
					AVRE.rangeScene.visible = true
				end
			end
		end
		
		-- Register for events
		self:RegisterEvent("UNIT_TARGET", "OnTarget")
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "OnCombatEvent")

		-- Initialize fight
		possibleWipe = false
		fight.inCombat = true
		fight.startDelay = startDelay
		fight.dead = {}
		AVRE.fight = fight
		if not AVRE.testing then
			self:CancelAllTimers()
			self:ScheduleRepeatingTimer("OnTimer", POLLING_FREQUENCY)
		end
		
		--[===[@debug@
		if not silent then
			local heroic = ""
			if AVRE:IsHeroicRaid() then heroic = " (heroic)" end
			self:Print(format("Initiating fight: %s"..heroic, fight.name))
		end
		--@end-debug@]===]
		
		if fight.onStart then fight.onStart(fight) end
		
		return true -- indicate success to callers
	end
end


function AVRE:EndFight(silent)
	self:CancelAllTimers()
	self:UnregisterEvent("UNIT_TARGET")
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	if AVRE.fight then
		if AVRE.scene then
			AVRE.scene:ClearScene()
			AVRE.scene.visible = false
		end
		if AVRE.rangeScene then AVRE.rangeScene.visible = false end
		AVRE.fight.inCombat = false
		--[===[@debug@
		if not silent then self:Print(format("Ending fight: %s", AVRE.fight.name)) end
		--@end-debug@]===]
		if AVRE.fight.onEnd then AVRE.fight.onEnd(AVRE.fight) end
		AVRE.fight = nil
	end
end



--[[
      API ----------------------------------------------------------------------------------------------------------------------
  ]]

function AVRE:RegisterEncounters(encounters)
	for k, v in pairs(encounters) do
		self:RegisterEncounter(k, v)
	end
end


function AVRE:RegisterEncounter(name, definition)
	do
		local o = definition
		
		local function option(name, default)
			if o.enable and o.enable.expansion and o.enable.instance and o.enable.fight then
				if self.db.profile.enc[o.enable.expansion] and self.db.profile.enc[o.enable.expansion][o.enable.instance] and self.db.profile.enc[o.enable.expansion][o.enable.instance][o.enable.fight] then
					return self.db.profile.enc[o.enable.expansion][o.enable.instance][o.enable.fight][name]
				end
			end
			if default ~= nil then return default else
				if AVRE.testing then return false else return true end
			end
		end
		definition.o = option
		
		local function advanced(name, default)
			if o.enable and o.enable.expansion and o.enable.instance and o.enable.fight then
				if self.db.profile.enc[o.enable.expansion] and self.db.profile.enc[o.enable.expansion][o.enable.instance] and self.db.profile.enc[o.enable.expansion][o.enable.instance][o.enable.fight] then
					if self.db.profile.enc[o.enable.expansion][o.enable.instance][o.enable.fight].advanced then
						return self.db.profile.enc[o.enable.expansion][o.enable.instance][o.enable.fight].advanced[name]
					end
				end
			end
			if default ~= nil then return default else
				if AVRE.testing then return nil else return { r = 1.0, g = 0.0, b = 0.0, a = 0.25 } end
			end
		end
		definition.a = advanced
	end
	AVRE.enc[name] = definition
	if definition.zone then zones[definition.zone] = true end
	AVRE.enc[name].inCombat = false
end


function AVRE:IsHeroicRaid()
	if AVRE.forceHeroic ~= nil then return AVRE.forceHeroic end
	local diff = GetInstanceDifficulty()
	local name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo()
	if isDynamic then
		if dynamicDifficulty == 1 then return true else return false end
	end
	if diff == 3 or diff == 4 then return true else return false end
end


function AVRE:TemporaryRangeCheck(range, duration)
	if AVRE.rangeScene then
		AVRE.rangeScene:SetRange(range)
		AVRE.rangeScene.visible = true
		AVRE:ScheduleTimer(function()
			if AVRE.rangeScene then AVRE.rangeScene.visible = false end
		end, duration)
		if AVRE.db.profile.range.circleSelf.enabled then
			AVR:AddCircleWarning(AVRE.scene, UnitName("player"), true, range, duration, AVRE.db.profile.range.circleSelf.r, AVRE.db.profile.range.circleSelf.g, AVRE.db.profile.range.circleSelf.b, AVRE.db.profile.range.circleSelf.a, nil, false)
		end
	end
end


function AVRE:Sync(o)
	self:SendCommMessage(commPrefix, self:Serialize(o), "RAID")
end


function AVRE:GetUnitCreatureId(unit)
	if unit then
		local guid = UnitGUID(unit)
		if guid then
			return (guid and tonumber(guid:sub(9, 12), 16)) or 0
		end
	end
end


function AVRE:GetCIDFromGUID(guid)
	if guid then
		return (guid and tonumber(guid:sub(9, 12), 16)) or 0
	end
end
