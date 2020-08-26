local L = LibStub("AceLocale-3.0"):GetLocale("AVRE", false)
local AVRE = AVRE
if not AVRE or not AVR then return end
local mod = AVRE:NewModule("Icecrown")
local zone = LibStub("AceLocale-3.0"):GetLocale("AVRE Zones")["Icecrown Citadel"]
local chat = LibStub("AceLocale-3.0"):GetLocale("AVRE Icecrown")


function mod:OnInitialize()
	AVRE.modules.encounters.icecrown.loaded = true
end


function mod:OnEnable()
	DEFAULT_CHAT_FRAME:AddMessage(format(L["|cff4d4dffAVR Encounters (|r|cffffff20%s|r|cff4d4dff) loaded|r"], zone))
	
	AVRE:RegisterEncounters({
	
		
-- LORD MARROWGAR -----------------------------------------------------------------------------------------------------

		marrowgar = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "marrowgar",
			},
			name = L["Lord Marrowgar"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36612 },
			},
			defeat = {
				type = "death",
				npcs = { 36612 },
			},
			
			onStart = function(self)
				self.spikes = {}
				self.circles = {}
				self.markers = {}
			end,
			
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_SUMMON = true,
				UNIT_DIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				if eventType == "SPELL_SUMMON" then
				
					-- Bone Spike summoned
					if spellId == 69062 or spellId == 72669 or spellId == 72670 then
						if self.o("spike") then
							self.spikes[dstGuid] = srcGuid
							local a = self.a("spike")
							local m = AVR:AddCircleWarning(AVRE.scene, srcName, true, 2, nil, a.r, a.g, a.b, a.a, nil, true)
							if m then
								m:SetTimer(8)
								self.circles[dstGuid] = m
								
								m = AVRMarkerMesh:New()
								m:SetFollowUnit(srcName)
								m:SetLine(true)
								m:SetColor(1.0, 1.0, 1.0, 0.8)
								AVRE.scene:AddMesh(m)
								self.markers[dstGuid] = m
							end
						end
					end
					
				elseif eventType == "UNIT_DIED" then
					
					-- Bone Spike killed
					if self.spikes[dstGuid] then
						if self.circles[dstGuid] then
							self.circles[dstGuid]:Remove()
							self.circles[dstGuid] = nil
						end
						if self.markers[dstGuid] then
							self.markers[dstGuid]:Remove()
							self.markers[dstGuid] = nil
						end
						self.spikes[dstGuid] = nil
					end
					
					-- Spiked player killed
					for k, v in pairs(self.spikes) do
						if v == dstGuid then
							if self.circles[k] then
								self.circles[k]:Remove()
								self.circles[k] = nil
							end
							if self.markers[k] then
								self.markers[k]:Remove()
								self.markers[k] = nil
							end
							self.spikes[k] = nil
						end
					end
					
				end
			end,
		},


-- LADY DEATHWHISPER --------------------------------------------------------------------------------------------------

		deathwhisper = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "deathwhisper",
			},
			name = L["Lady Deathwhisper"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36855 },
			},
			defeat = {
				type = "death",
				npcs = { 36855 },
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SWING_DAMAGE = true,
				SWING_MISSED = true,
				SPELL_AURA_APPLIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
			
				if eventType == "SWING_DAMAGE" or eventType == "SWING_MISSED" then
				
					-- Vengeful Shade melee'd someone, they're probably about to get exploded on
					if AVRE:GetCIDFromGUID(srcGuid) == 38222 and self.o("spirit") then
						local a = self.a("spirit")
						AVR:AddCircleWarning(AVRE.scene, dstName, true, a.rad, 5, a.r, a.g, a.b, a.a, nil, false)
					end
					
				elseif eventType == "SPELL_AURA_APPLIED" then
				
					-- Dominate Mind
					if spellId == 71289 and self.o("dominate") then
						local a = self.a("dominate")
						AVR:AddCircleWarning(AVRE.scene, dstName, true, a.rad, 12, a.r, a.g, a.b, a.a, nil, true)
					end
					
				end
				
			end,
		},


-- FESTERGUT ----------------------------------------------------------------------------------------------------------

		festergut = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "festergut",
			},
			name = L["Festergut"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36626 },
			},
			defeat = {
				type = "death",
				npcs = { 36626 },
			},
			range = {
				normal = true,
				heroic = true,
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
			
				-- Gas Spore
				if spellId == 69279 and self.o("gasSpore") then
					local a = self.a("gasSpore")
					AVR:AddCircleWarning(AVRE.scene, dstName, true, 8, 12, a.r, a.g, a.b, a.a, nil, true)
					
				-- Vile Gas
				elseif spellId == 69240 or spellId == 71218 or spellId == 73019 or spellId == 73020 then
					if self.o("vile") then
						local a = self.a("vile")
						AVR:AddCircleWarning(AVRE.scene, dstName, true, 8, 6, a.r, a.g, a.b, a.a, nil, true)
					end
				end
				
			end,
		},


-- ROTFACE ------------------------------------------------------------------------------------------------------------

		rotface = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "rotface",
			},
			name = L["Rotface"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36627 },
			},
			defeat = {
				type = "death",
				npcs = { 36627 },
			},
			range = {
				normal = false,
				heroic = true,
			},
			
			onStart = function(self)
				if self.o("kiter") and self.o("kiter") ~= "" and self.o("kiter") ~= UnitName("player") then
					local a = self.a("kiter")
					AVR:AddCircleWarning(AVRE.scene, self.o("kiter"), true, a.rad, nil, a.r, a.g, a.b, a.a, nil, false)
				end
				self.exp_lastcast = {}
				self.exp_timers = {}
			end,
			
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_CAST_START = true,
				SPELL_AURA_APPLIED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
			
				if eventType == "SPELL_CAST_START" then
				
					-- Unstable Ooze Explosion
					if spellId == 69839 and self.o("explosion") then
						if (self.exp_lastcast[srcGuid] and GetTime() - self.exp_lastcast[srcGuid] < 4.0) or not self.exp_lastcast[srcGuid] then
							if self.exp_timers[srcGuid] then AVRE:CancelTimer(self.exp_timers[srcGuid], true) end
							self.exp_lastcast[srcGuid] = GetTime()
							local a = self.a("explosion")
							self.exp_timers[srcGuid] = AVRE:ScheduleTimer(function()
								AVR:AddCircleWarningEveryone(AVRE.scene, false, a.rad, 10, a.r, a.g, a.b, a.a, 10)
							end, 4.0)
						end
					end
					
				elseif eventType == "SPELL_AURA_APPLIED" then
				
						-- Mutated Infection
					if spellId == 69674 or spellId == 71224 or spellId == 73022 or spellId == 73023 then
					
						if dstName == UnitName("player") then
							if self.o("kiter") and self.o("kiter") ~= "" and self.o("kiter") ~= UnitName("player") then
								local m = AVRMarkerMesh:New()
								m:SetFollowUnit(self.o("kiter"))
								m:SetLine(true)
								m:SetColor(1.0, 1.0, 1.0, 0.4)
								AVRE.scene:AddMesh(m)
								AVRE:ScheduleTimer(function() if m then m:Remove() end end, 7)
							end
						end
						
						if self.o("infection") then
							local a = self.a("infection")
							AVR:AddCircleWarning(AVRE.scene, dstName, true, a.rad, 12, a.r, a.g, a.b, a.a, nil, true)
						end
					
					-- Vile Gas
					elseif spellId == 72272 or spellId == 72273 then
						if self.o("vile") then
							local a = self.a("vile")
							AVR:AddCircleWarning(AVRE.scene, dstName, false, 8, 6, a.r, a.g, a.b, a.a, nil, true)
						end						
					end
					
				end
				
			end,
		},


-- PROFESSOR PUTRICIDE ------------------------------------------------------------------------------------------------

		putricide = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "putricide",
			},
			name = L["Professor Putricide"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36678, 37562, 37697 },
			},
			defeat = {
				type = "death",
				npcs = { 36678 },
			},
			
			onStart = function(self)
				self.unboundMeshes = {}
				self.unboundMeshes2 = {}
				self.sicknessMeshes = {}
				
				-- Initialize the Plague Sickness scene
				self.sickScene = AVR:GetTempScene("AVRE_PUTRICIDE_PLAGUESICKNESS")
				self.sickScene:ClearScene()
				self.sickScene.visible = false
				for k, v in pairs(AVRE.raid) do
					local a = self.a("sick")
					local m = AVR:AddCircleWarning(self.sickScene, k, true, a.rad, nil, a.r, a.g, a.b, a.a, 10, false)
					if m then self.sicknessMeshes[k] = m end
				end
			end,
			
			onEnd = function(self)
				self.sickScene:ClearScene()
				self.sickScene.visible = false
			end,
			
			combatEvents = {
				SPELL_CAST_SUCCESS = true,
				SPELL_AURA_APPLIED = true,
				SPELL_AURA_REMOVED = true,
				UNIT_DIED = true,
			},

			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				if eventType == "SPELL_CAST_SUCCESS" then

					-- Malleable Goo
					if spellId == 72615 or spellId == 72295 or spellId == 74280 or spellId == 74281 then
						if self.o("malleable") then
							local a = self.a("malleable")
							AVRE:GetBossTarget(36678, function(target)		
								AVR:AddCircleWarning(AVRE.scene, target, false, a.rad, 7, a.r, a.g, a.b, a.a)
							end)
						end
						if self.o("malleableAll") then
							local name, type, difficultyIndex, difficultyName, maxPlayers, dynamicDifficulty, isDynamic = GetInstanceInfo()
							if maxPlayers > 10 or AVRE.testing then
								local a = self.a("malleableAll")
								AVR:AddCircleWarningEveryone(AVRE.scene, false, a.rad, 7, a.r, a.g, a.b, a.a, 10)
							end
						end
					end
					
				elseif eventType == "SPELL_AURA_APPLIED" then

					-- Unbound Plague applied
					if spellId == 72855 or spellId == 72856 then
						if self.o("plague") then
							local a = self.a("plague")
							local m = self.unboundMeshes[dstName]
							if m then m:Remove() end
							m = self.unboundMeshes2[dstName]
							if m then m:Remove() end
							
							_, _, _, _, _, duration, expirationTime = UnitDebuff(dstName, spellName)
							if not duration or not expirationTime then
								if AVRE.testing then
									duration = 60
									expirationTime = GetTime() + 60
								else
									return
								end
							end
							
							m = AVR:AddCircleWarning(AVRE.scene, dstName, true, 2, nil, a.r, a.g, a.b, a.a, nil, true)
							if m then
								m:SetTimer(60, expirationTime)
								self.unboundMeshes[dstName] = m
							end
							
							m = AVR:AddCircleWarning(AVRE.scene, dstName, true, 4, nil, a.r, a.g, a.b, a.a, nil, true)
							if m then
								m:SetTimer(10)
								self.unboundMeshes2[dstName] = m
							end
						end
						
						if self.o("sick") and dstName == UnitName("player") then
							if self.sicknessMeshes[dstName] then
								self.sicknessMeshes[dstName]:Remove()
								self.sicknessMeshes[dstName] = nil
							end
							self.sickScene.visible = true
						end
						
					-- Plague Sickness applied
					elseif spellId == 70953 or spellId == 73117 then
						if self.sicknessMeshes[dstName] then
							self.sicknessMeshes[dstName]:Remove()
							self.sicknessMeshes[dstName] = nil
						end
					end
					
				elseif eventType == "SPELL_AURA_REMOVED" then
				
					-- Unbound Plague removed
					if spellId == 72855 or spellId == 72856 then
						local m = self.unboundMeshes[dstName]
						if m then 
							m:Remove()
							self.unboundMeshes[dstName] = nil
						end
						local m = self.unboundMeshes2[dstName]
						if m then 
							m:Remove()
							self.unboundMeshes2[dstName] = nil
						end
						if dstName == UnitName("player") then
							self.sickScene.visible = false
						end

					-- Plague Sickness removed
					elseif spellId == 70953 or spellId == 73117 then
						local a = self.a("sick")
						if self.sicknessMeshes[dstName] then self.sicknessMeshes[dstName]:Remove() end
						local m = AVR:AddCircleWarning(self.sickScene, dstName, true, a.rad, nil, a.r, a.g, a.b, a.a, 10, false)
						if m then self.sicknessMeshes[dstName] = m end
					end
					
				elseif eventType == "UNIT_DIED" then
				
					-- Someone died, remove their Plague Sickness circle
						if self.sicknessMeshes[dstName] then
							self.sicknessMeshes[dstName]:Remove()
							self.sicknessMeshes[dstName] = nil
						end

				end
			end,
			
		},


-- BLOOD PRINCE COUNCIL -----------------------------------------------------------------------------------------------

		bloodprince = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "bloodprince",
			},
			name = L["Blood Prince Council"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 37973, 37972, 37970 },
			},
			defeat = {
				type = "death",
				npcs = { 37973, 37972, 37970 },
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_CAST_START = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				-- Shock Vortex
				if spellId == 72037 and self.o("vortex") then
					local a = self.a("vortex")
					AVRE:GetBossTarget(37970, function(target)		
						AVR:AddCircleWarning(AVRE.scene, target, false, a.rad, 7, a.r, a.g, a.b, a.a)
					end)
					
				-- Empowered Shock Vortex
				elseif spellId == 72039 or spellId == 73037 or spellId == 73038 or spellId == 73039 then
					if self.o("empvortex") then
						local a = self.a("empvortex")
						AVRE:TemporaryRangeCheck(a.range, 5)
					end
					
				end
				
			end,
			
			onYell = function(self, event, message, sender, language, channelString, target)
				-- Empowered Flame
				if event == "CHAT_MSG_RAID_BOSS_EMOTE" and message:match(chat["EmpoweredFlameYell"]) and self.o("flame") then
					if target then
						local a = self.a("flame")
						AVR:AddCircleWarning(AVRE.scene, target, true, a.rad, 7, a.r, a.g, a.b, a.a, nil, false)
					end
				end
			end,
		},
		

-- BLOOD-QUEEN LANA'THEL ----------------------------------------------------------------------------------------------

		lanathel = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "lanathel",
			},
			name = L["Blood-Queen Lana'thel"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 37955 },
			},
			defeat = {
				type = "death",
				npcs = { 37955 },
			},
			
			onStart = function(self) end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_CAST_SUCCESS = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
			
				-- Incite Terror
				if spellId == 73070 and self.o("terror") then
					local a = self.a("terror")
					AVRE:TemporaryRangeCheck(a.range, 10)
				end
				
			end,
		},


-- SINDRAGOSA ---------------------------------------------------------------------------------------------------------

		sindragosa = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "sindragosa",
			},
			name = L["Sindragosa"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36853, 37533, 37534 },
			},
			defeat = {
				type = "death",
				npcs = { 36853 },
			},
			
			onStart = function(self)
				self.unchained = {}
			end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_AURA_APPLIED = true,
				SPELL_AURA_REMOVED = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool)
				if eventType == "SPELL_AURA_APPLIED" then
					-- Frost Beacon
					if spellId == 70126 and self.o("beacon") then
						local a = self.a("beacon")
						AVR:AddCircleWarning(AVRE.scene, dstName, true, a.rad, 7, a.r, a.g, a.b, a.a, nil, true)
					-- Instability
					elseif spellId == 69766 and AVRE:IsHeroicRaid() and self.o("instability") then
						local a = self.a("instability")
						if self.unchained[dstName] then self.unchained[dstName]:Remove() end
						self.unchained[dstName] = nil
						local m = AVR:AddCircleWarning(AVRE.scene, dstName, true, a.rad, 5, a.r, a.g, a.b, a.a, nil, true)
						if m then self.unchained[dstName] = m end
					end
				elseif eventType == "SPELL_AURA_REMOVED" then
					-- Instability removed
					if spellId == 69766 and AVRE:IsHeroicRaid() then
						if self.unchained[dstName] then self.unchained[dstName]:Remove() end
						self.unchained[dstName] = nil
					end
				end
			end,
		},
		
		
	-- THE LICH KING ------------------------------------------------------------------------------------------------------

		lichking = {
			enable = {
				expansion = "wotlk",
				instance = "icecrown",
				fight = "lichking",
			},
			name = L["The Lich King"],
			zone = zone,
			pull = {
				type = "combat",
				npcs = { 36597 },
			},
			defeat = {
				type = "death",
				npcs = { 36597 },
			},
			
			onStart = function(self)
				self.wipeTime = nil
				self.plague = {}
			end,
			onEnd = function(self) end,
			
			combatEvents = {
				SPELL_CAST_START = true,
				SPELL_CAST_SUCCESS = true,
				SPELL_DISPEL = true,
			},
			
			onCombat = function(self, event, timestamp, eventType, srcGuid, srcName, srcFlags, dstGuid, dstName, dstFlags, spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool, auraType)

				if eventType == "SPELL_CAST_START" then
				
					-- Defile
					if spellId == 72762 and self.o("defile") then
						local a = self.a("defile")
						AVRE:GetBossTargetChange(36597, function(target)
							AVR:AddCircleWarning(AVRE.scene, target, true, 5, 2, a.r, a.g, a.b, a.a)
						end)
						
					-- Shadow Trap
					elseif spellId == 73539 and self.o("shadowtrap") then
						local a = self.a("shadowtrap")
						AVRE:GetBossTargetChange(36597, function(target)
							AVR:AddCircleWarning(AVRE.scene, target, false, 5, 4, a.r, a.g, a.b, a.a)
						end)
						
					-- Fury of the Frostmourne; extend the wipe check timer
					elseif spellId == 72350 then
						self.wipeTime = 160
						AVRE:CancelPossibleWipe()
					end
				
				elseif eventType == "SPELL_CAST_SUCCESS" then
						-- Necrotic Plague (initial cast)
					if spellId == 70337 or spellId == 73912 or spellId == 73913 or spellId == 73914 then
						if self.o("plague") then
							local a = self.a("plague")
							if self.plague[dstName] then self.plague[dstName]:Remove() end
							self.plague[dstName] = AVR:AddCircleWarning(AVRE.scene, dstName, true, 3, 5, a.r, a.g, a.b, a.a, nil, true)
						end
					end
					
				elseif eventType == "SPELL_DISPEL" then
						-- Necrotic Plague dispelled
					if extraSpellId == 70337 or extraSpellId == 73912 or extraSpellId == 73913 or extraSpellId == 73914 or extraSpellId == 70338 or extraSpellId == 73785 or extraSpellId == 73786 or extraSpellId == 73787 then
						if self.plague[dstName] then self.plague[dstName]:Remove() end
						self.plague[dstName] = nil
					end

				end
			end,
		},


})
	
end
