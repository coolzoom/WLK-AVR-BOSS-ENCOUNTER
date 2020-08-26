local L = LibStub("AceLocale-3.0"):GetLocale("AVRE", false)
local AVRE = AVRE
if not AVRE or not AVR then return end
local mod = AVRE:NewModule("Ulduar")
local zone = LibStub("AceLocale-3.0"):GetLocale("AVRE Zones")["Ulduar"]
local chat = LibStub("AceLocale-3.0"):GetLocale("AVRE Ulduar")


function mod:OnInitialize()
	AVRE.modules.encounters.ulduar.loaded = true
end


function mod:OnEnable()
	DEFAULT_CHAT_FRAME:AddMessage(format(L["|cff4d4dffAVR Encounters (|r|cffffff20%s|r|cff4d4dff) loaded|r"], zone))
	
	AVRE:RegisterEncounters({
	
		
-- HODIR --------------------------------------------------------------------------------------------------------------

		hodir = {
			enable = {
				expansion = "wotlk",
				instance = "ulduar",
				fight = "hodir",
			},
			name = L["Hodir"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 32845 },
			},
			defeat = {
				type = "death",
				npcs = { 32845 }, -- This won't actually work, but we should detect a "wipe" anyway so it doesn't matter
			},
			
			onStart = function(self)
				self.storm = {}
			end,
			
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
				SPELL_AURA_REMOVED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				if eventType == "SPELL_AURA_APPLIED" then
					-- Storm Cloud applied
					if (spellId == 65123 or spellId == 65133) and self.o("storm") then
						if self.storm[dstName] then
							self.storm[dstName]:Remove()
							self.storm[dstName] = nil
						end
						local a = self.a("storm")
						self.storm[dstName] = AVR:AddCircleWarning(AVRE.scene, dstName, true, 3, 30, a.r, a.g, a.b, a.a, nil, true)
					end
					
				elseif eventType == "SPELL_AURA_REMOVED" then
					-- Storm Cloud removed
					if spellId == 65123 or spellId == 65133 then
						if self.storm[dstName] then
							self.storm[dstName]:Remove()
							self.storm[dstName] = nil
						end
					end

				end
			end,
		},


-- FREYA --------------------------------------------------------------------------------------------------------------

		freya = {
			enable = {
				expansion = "wotlk",
				instance = "ulduar",
				fight = "freya",
			},
			name = L["Freya"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 32906 },
			},
			defeat = {
				type = "death",
				npcs = { 32906 }, -- This won't actually work, but we should detect a "wipe" anyway so it doesn't matter
			},
			
			onStart = function(self)
				self.root = {}
			end,
			
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
				SPELL_AURA_REMOVED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				if eventType == "SPELL_AURA_APPLIED" then
					-- Iron Roots applied
					if (spellId == 62861 or spellId == 62438) and self.o("root") then
						if self.root[dstName] then
							self.root[dstName]:Remove()
							self.root[dstName] = nil
						end
						local a = self.a("root")
						self.root[dstName] = AVR:AddCircleWarning(AVRE.scene, dstName, true, 3, nil, a.r, a.g, a.b, a.a, nil, false)
					
					-- Nature's Fury
					elseif (spellId == 63571 or spellId == 62589) and self.o("fury") then
						local a = self.a("fury")
						AVR:AddCircleWarning(AVRE.scene, dstName, true, 8, 10, a.r, a.g, a.b, a.a, nil, true)
					
					end
					
				elseif eventType == "SPELL_AURA_REMOVED" then
					-- Iron Roots removed
					if spellId == 62861 or spellId == 62438 then
						if self.root[dstName] then
							self.root[dstName]:Remove()
							self.root[dstName] = nil
						end
					end

				end
			end,
		},


-- MIMIRON ------------------------------------------------------------------------------------------------------------

		mimiron = {
			enable = {
				expansion = "wotlk",
				instance = "ulduar",
				fight = "mimiron",
			},
			name = L["Mimiron"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 33432 },
			},
			defeat = {
				type = "death",
				npcs = { 33432 }, -- This won't actually work, but we should detect a "wipe" anyway so it doesn't matter
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				-- Napalm Shell
				if (spellId == 63666 or spellId == 65026) and self.o("napalm") then
					local a = self.a("napalm")
					AVR:AddCircleWarning(AVRE.scene, dstName, false, 5, 8, a.r, a.g, a.b, a.a, nil, true)
				end
			end,
		},


	-- GENERAL VEZAX ------------------------------------------------------------------------------------------------------

		generalvezax = {
			enable = {
				expansion = "wotlk",
				instance = "ulduar",
				fight = "generalvezax",
			},
			name = L["General Vezax"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 33271 },
			},
			defeat = {
				type = "death",
				npcs = { 33271 },
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_CAST_SUCCESS = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				
				-- Shadow Crash
				if spellId == 62660 and self.o("crash") then
					local a = self.a("crash")
					AVRE:ScheduleTimer(function()						
						local target = AVRE:GetBossTarget(33271)
						if not target then return end
						AVR:AddCircleWarning(AVRE.scene, target, false, 10, 7, a.r, a.g, a.b, a.a)
					end, 0.1)
					
				-- Mark of the Faceless
				elseif spellId == 63276 and self.o("mark") then
					local a = self.a("mark")
					AVR:AddCircleWarning(AVRE.scene, dstName, true, 15, 10, a.r, a.g, a.b, a.a, nil, true)
				end

			end,
		},


-- YOGG-SARON ---------------------------------------------------------------------------------------------------------

		yoggsaron = {
			enable = {
				expansion = "wotlk",
				instance = "ulduar",
				fight = "yoggsaron",
			},
			name = L["Yogg-Saron"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 33134 },
			},
			defeat = {
				type = "death",
				npcs = { 33288 },
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				-- Malady of the Mind
				if (spellId == 63830 or spellId == 63881) and self.o("malady") then
					local a = self.a("malady")
					AVR:AddCircleWarning(AVRE.scene, dstName, true, 10, 4, a.r, a.g, a.b, a.a, nil, true)
				end
			end,
		},



})
	
end
