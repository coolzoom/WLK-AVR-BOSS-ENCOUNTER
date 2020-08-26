local L = LibStub("AceLocale-3.0"):GetLocale("AVRE", false)
local AVRE = AVRE
local mod = AVRE:NewModule("Options", "AceConsole-3.0")
local zones = LibStub("AceLocale-3.0"):GetLocale("AVRE Zones")



local newOrder
do
	local current = 0
	function newOrder()
		current = current + 1
		return current
	end
end

local function getRaidUnits(current)
	local t = { [""] = "" }
	
	if current and current ~= "" then t[current] = AVRE:Colorize(current, GRAY_FONT_COLOR) end
	
	if UnitInRaid("player") then
		local numRaid = GetNumRaidMembers()
		for i = 1, numRaid do
			local playerName = GetRaidRosterInfo(i)
			if playerName then
				t[playerName] = AVRE:Colorize(playerName, (RAID_CLASS_COLORS[({UnitClass(playerName)})[2]]))
			end
		end
	end
	
	return t
end

local newExpansion
local newInstance
local newFight
local a
local b
local c

local function newExpansion(n, s)
	a = s
	return n
end

local function newInstance(n, s)
	b = s
	return n
end

local function newFight(n, s)
	c = s
	return n
end

local function checkbox_spell(a, b, c, spellId, message, option)
	return {
		type = "toggle",
		name = GetSpellInfo(spellId),
		desc = format(message, GetSpellInfo(spellId)),
		get = function() return AVRE.db.profile.enc[a][b][c][option] end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c][option] = val end,
		order = newOrder(),
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function checkbox(a, b, c, name, option, desc)
	return {
		type = "toggle",
		name = name,
		desc = desc,
		get = function() return AVRE.db.profile.enc[a][b][c][option] end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c][option] = val end,
		order = newOrder(),
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled and option ~= "enabled" end,
	}
end

local function splitter()
	return {
		type = "header",
		name = "",
		order = newOrder(),
	}
end

local function spacer()
	return {
		type = "description",
		name = " ",
		order = newOrder(),
	}
end

local function header(name)
	return {
		type = "header",
		order = newOrder(),
		name = name,
	}
end

local function header_spell(spellId)
	return {
		type = "header",
		order = newOrder(),
		name = GetSpellInfo(spellId),
	}
end

local function desc_spell(spellId, msg)
	return {
		type = "description",
		order = newOrder(),
		name = msg:format(GetSpellInfo(spellId)),
	}
end

local function desc(msg)
	return {
		type = "description",
		order = newOrder(),
		name = msg,
	}
end

local function range1()
	return header(L["Range Check"])
end

local function range2(a, b, c, extraDesc)
	return {
		type = "toggle",
		name = L["Enable range check"],
		desc = L["Turns on an AVR range check when the fight starts."].." "..(extraDesc or ""),
		get = function() return AVRE.db.profile.enc[a][b][c].range.enabled end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c].range.enabled = val end,
		order = newOrder(),
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function range3(a, b, c)
	return {
		order = newOrder(),
		type = "range",
		name = L["Range"],
		desc = function()
			local def = AVRE.defaults.profile.enc[a][b][c].range.range
			return format(L["The distance in yards for the AVR range check."].." "..L["(Default is %d yards.)"], def)
		end,
		min = 1,
		max = 30,
		step = 1,
		get = function() return AVRE.db.profile.enc[a][b][c].range.range end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c].range.range = val end,
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function range_adv(a, b, c, option)
	return {
		order = newOrder(),
		type = "range",
		name = L["Range"],
		desc = function()
			local def = AVRE.defaults.profile.enc[a][b][c].advanced[option].range
			return format(L["The distance in yards for the AVR range check."].." "..L["(Default is %d yards.)"], def)
		end,
		min = 1,
		max = 30,
		step = 1,
		get = function() return AVRE.db.profile.enc[a][b][c].advanced[option].range end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c].advanced[option].range = val end,
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function character_picker(a, b, c, name, option, desc)
	return {
		order = newOrder(),
		type = "select",
		name = name,
		desc = desc,
		values = function() return getRaidUnits(AVRE.db.profile.enc[a][b][c][option]) end,
		get = function() return AVRE.db.profile.enc[a][b][c][option] end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c][option] = val end,
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function color(a, b, c, option)
	return {
		order = newOrder(),
		type = "color",
		name = L["Color and transparency"],
		hasAlpha = true,
		set = function(self, red, green, blue, alpha)
			AVRE.db.profile.enc[a][b][c].advanced[option].r = red
			AVRE.db.profile.enc[a][b][c].advanced[option].g = green
			AVRE.db.profile.enc[a][b][c].advanced[option].b = blue
			AVRE.db.profile.enc[a][b][c].advanced[option].a = alpha
		end,
		get = function()
			return AVRE.db.profile.enc[a][b][c].advanced[option].r, AVRE.db.profile.enc[a][b][c].advanced[option].g, AVRE.db.profile.enc[a][b][c].advanced[option].b, AVRE.db.profile.enc[a][b][c].advanced[option].a
		end,
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function radius(a, b, c, option)
	return {
		order = newOrder(),
		type = "range",
		name = L["Radius"],
		desc = function()
			local def = AVRE.defaults.profile.enc[a][b][c].advanced[option].rad
			return format(L["Determines the radius of the circle in yards."].." "..L["(Default is %.1f yards.)"], def)
		end,
		min = 0,
		max = 30,
		bigStep = 1,
		get = function() return AVRE.db.profile.enc[a][b][c].advanced[option].rad end,
		set = function(self, val) AVRE.db.profile.enc[a][b][c].advanced[option].rad = val end,
		disabled = function() return not AVRE.db.profile.enc[a][b][c].enabled end,
	}
end

local function broadcast(a, b, c, option, description)
	return {
		type = "execute",
		name = L["Broadcast to raid"],
		desc = description,
		func = function()
			AVRE:Sync({ c = strupper("ENC_"..c), v = AVRE.db.profile.enc[a][b][c][option] })
		end,
		order = newOrder(),
		disabled = function() return AVRE.db.profile.enc[a][b][c][option] == "" end,
	}
end



--[[
      OPTIONS ------------------------------------------------------------------------------------------------------------------
  ]]


AVRE.options = {
	name = function()
		local debugMsg = "    "
		--[===[@debug@
		debugMsg = debugMsg..L["(running in debug mode)"]
		--@end-debug@]===]
		return "AVR Encounters         r|cff20ff20"..AVRE.MINOR_VERSION.."|r"..debugMsg
	end,
	handler = VampArrow,
	type = "group",
	childGroups = "tab",
	args = {
	
		encounters = {
			type = "group",
			name = L["Encounters"],
			order = newOrder(),
			args = {
	
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
-- WRATH OF THE LICH KING ------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

				wotlk = {
					name = newExpansion(L["Wrath of the Lich King"], "wotlk"),
					type = "group",
					order = newOrder(),
					args = {
					
						enabled = {
							type = "toggle",
							name = L["Enable Expansion"],
							get = function() return AVRE.db.profile.enc.wotlk.enabled end,
							set = function(self, val) AVRE.db.profile.enc.wotlk.enabled = val end,
							order = newOrder(),
						},




--------------------------------------------------------------------------------------------------------------------
-- ULDUAR ----------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

						ulduar = {
							name = newInstance(zones["Ulduar"], "ulduar"),
							type = "group",
							order = newOrder(),
							args = {
								
								enabled = {
									type = "toggle",
									name = L["Enable Raid Instance"],
									get = function() return AVRE.db.profile.enc.wotlk.ulduar.enabled end,
									set = function(self, val) AVRE.db.profile.enc.wotlk.ulduar.enabled = val end,
									order = newOrder(),
								},
								
-- HODIR -----------------------------------------------------------------------------------------------------------

								hodir = {
									name = newFight(L["Hodir"], "hodir"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										storm1 = header_spell(65123),
										storm2 = desc_spell(65123, L["Places a circle under players with %s."]),
										storm3 = checkbox(a,b,c, L["Enabled"], "storm"),
										storm4 = color(a,b,c, "storm"),
									},
								},

-- FREYA -----------------------------------------------------------------------------------------------------------

								freya = {
									name = newFight(L["Freya"], "freya"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										root1 = header_spell(62861),
										root2 = desc_spell(62861, L["Places a circle under players with %s."]),
										root3 = checkbox(a,b,c, L["Enabled"], "root"),
										root4 = color(a,b,c, "root"),

										spacer2 = spacer(),
										fury1 = header_spell(63571),
										fury2 = desc_spell(63571, L["Places a circle under players with %s."]),
										fury3 = checkbox(a,b,c, L["Enabled"], "fury"),
										fury4 = color(a,b,c, "fury"),
									},
								},

-- MIMIRON ---------------------------------------------------------------------------------------------------------

								mimiron = {
									name = newFight(L["Mimiron"], "mimiron"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										napalm1 = header_spell(63666),
										napalm2 = desc_spell(63666, L["Places a circle under players with %s."]),
										napalm3 = checkbox(a,b,c, L["Enabled"], "napalm"),
										napalm4 = color(a,b,c, "napalm"),
									},
								},

-- GENERAL VEZAX ---------------------------------------------------------------------------------------------------

								generalvezax = {
									name = newFight(L["General Vezax"], "generalvezax"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										crash1 = header_spell(62660),
										crash2 = desc_spell(62660, L["Places a circle under players with %s."]),
										crash3 = checkbox(a,b,c, L["Enabled"], "crash"),
										crash4 = color(a,b,c, "crash"),

										spacer2 = spacer(),
										mark1 = header_spell(63276),
										mark2 = desc_spell(63276, L["Places a circle under players with %s."]),
										mark3 = checkbox(a,b,c, L["Enabled"], "mark"),
										mark4 = color(a,b,c, "mark"),
									},
								},
								
-- YOGG-SARON ------------------------------------------------------------------------------------------------------

								yoggsaron = {
									name = newFight(L["Yogg-Saron"], "yoggsaron"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										malady1 = header_spell(63830),
										malady2 = desc_spell(63830, L["Places a circle under players with %s."]),
										malady3 = checkbox(a,b,c, L["Enabled"], "malady"),
										malady4 = color(a,b,c, "malady"),
									},
								},



							},
						},

--------------------------------------------------------------------------------------------------------------------
-- ICECROWN CITADEL ------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

						icecrown = {
							name = newInstance(zones["Icecrown Citadel"], "icecrown"),
							type = "group",
							order = newOrder(),
							args = {
								
								enabled = {
									type = "toggle",
									name = L["Enable Raid Instance"],
									get = function() return AVRE.db.profile.enc.wotlk.icecrown.enabled end,
									set = function(self, val) AVRE.db.profile.enc.wotlk.icecrown.enabled = val end,
									order = newOrder(),
								},
								
-- LORD MARROWGAR --------------------------------------------------------------------------------------------------

								marrowgar = {
									name = newFight(L["Lord Marrowgar"], "marrowgar"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										spike1 = header_spell(69062),
										spike2 = desc_spell(69062, L["Places a circle under players with %s, along with a marker line toward them."]),
										spike3 = checkbox(a,b,c, L["Enabled"], "spike"),
										spike4 = color(a,b,c, "spike"),
									},
								},
								
-- LADY DEATHWHISPER -----------------------------------------------------------------------------------------------

								deathwhisper = {
									name = newFight(L["Lady Deathwhisper"], "deathwhisper"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										dominate1 = header_spell(71289),
										dominate2 = desc_spell(71289, L["Places a circle under players with %s."]),
										dominate3 = checkbox(a,b,c, L["Enabled"], "dominate"),
										dominate4 = color(a,b,c, "dominate"),
										dominate5 = radius(a,b,c, "dominate"),
										
										spacer2 = spacer(),
										spirit1 = header_spell(71426),
										spirit2 = desc_spell(71426, L["Places a circle under players with %s."].." "..L["Note: This only works when a ghost melees someone."]),
										spirit3 = checkbox(a,b,c, L["Enabled"], "spirit"),
										spirit4 = color(a,b,c, "spirit"),
										spirit5 = radius(a,b,c, "spirit"),
									},
								},
								
-- FESTERGUT -------------------------------------------------------------------------------------------------------

								festergut = {
									name = newFight(L["Festergut"], "festergut"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										gasSpore1 = header_spell(69279),
										gasSpore2 = desc_spell(69279, L["Places a circle under players with %s."]),
										gasSpore3 = checkbox(a,b,c, L["Enabled"], "gasSpore"),
										gasSpore4 = color(a,b,c, "gasSpore"),

										spacer2 = spacer(),
										vile1 = header_spell(69240),
										vile2 = desc_spell(69240, L["Places a circle under players with %s."]),
										vile3 = checkbox(a,b,c, L["Enabled"], "vile"),
										vile4 = color(a,b,c, "vile"),

										spacer3 = spacer(),
										range1 = range1(),
										range2 = range2(a,b,c),
										range3 = range3(a,b,c),
									},
								},
						
-- ROTFACE ---------------------------------------------------------------------------------------------------------

								rotface = {
									name = newFight(L["Rotface"], "rotface"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										explosion1 = header_spell(69839),
										explosion2 = desc_spell(69839, L["Places a circle under all players during %s."]),
										explosion3 = checkbox(a,b,c, L["Enabled"], "explosion"),
										explosion4 = color(a,b,c, "explosion"),
										explosion5 = radius(a,b,c, "explosion"),

										spacer2 = spacer(),
										gasSpore1 = header_spell(69674),
										gasSpore2 = desc_spell(69674, L["Places a circle under players with %s."]),
										infection3 = checkbox(a,b,c, L["Enabled"], "infection"),
										infection4 = color(a,b,c, "infection"),
										infection5 = radius(a,b,c, "infection"),

										spacer3 = spacer(),
										vile1 = header_spell(72272),
										vile2 = desc_spell(72272, L["Places a circle under players with %s."]),
										vile3 = checkbox(a,b,c, L["Enabled"], "vile"),
										vile4 = color(a,b,c, "vile"),

										spacer4 = spacer(),
										kiter1 = header(L["Big Ooze Kiter"]),
										kiter2 = desc(L["Choose a player in your raid who will be kiting the Big Oozes. They will have a small circle under them throughout the fight, and you'll get a marker toward that person when you get a Small Ooze."]),
										kiter3 = character_picker(a,b,c, L["Big Ooze Kiter"], "kiter"),
										kiter4 = color(a,b,c, "kiter"),
										kiter5 = radius(a,b,c, "kiter"),
										
										broadcast = broadcast(a,b,c, "kiter", L["Broadcasts your currently selected kiter to the raid."]),

										spacer5 = spacer(),
										range1 = range1(),
										range2 = range2(a,b,c, L["(Heroic mode only.)"]),
										range3 = range3(a,b,c),
									},
								},
						
-- PUTRICIDE -------------------------------------------------------------------------------------------------------

								putricide = {
									name = newFight(L["Professor Putricide"], "putricide"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										malleable1 = header_spell(72615),
										malleable2 = desc_spell(72615, L["Places a circle under players with %s."].." "..L["Only works for one of the players."]),
										malleable3 = checkbox(a,b,c, L["Enabled"], "malleable"),
										malleable4 = color(a,b,c, "malleable"),
										malleable5 = radius(a,b,c, "malleable"),

										spacer2 = spacer(),
										malleableAll1 = header(format(L["%s (All)"], GetSpellInfo(72615))),
										malleableAll2 = desc_spell(72615, L["Places a circle under all players during %s."].." "..L["Only occurs on 25-player mode."]),
										malleableAll3 = checkbox(a,b,c, L["Enabled"], "malleableAll"),
										malleableAll4 = color(a,b,c, "malleableAll"),
										malleableAll5 = radius(a,b,c, "malleableAll"),

										spacer3 = spacer(),
										plague1 = header_spell(72855),
										plague2 = desc_spell(72855, L["Places a circle under players with %s."]),
										plague3 = checkbox(a,b,c, L["Enabled"], "plague"),
										plague4 = color(a,b,c, "plague"),

										spacer4 = spacer(),
										sick1 = header_spell(70953),
										sick2 = desc(format(L["When you are afflicted with %s, you will see a circle under all players who do not have %s. These are valid players to pass %s to."], GetSpellInfo(72855), GetSpellInfo(70953), GetSpellInfo(72855))),
										sick3 = checkbox(a,b,c, L["Enabled"], "sick"),
										sick4 = color(a,b,c, "sick"),
										sick5 = radius(a,b,c, "sick"),
									},
								},
								
-- BLOOD PRINCE COUNCIL --------------------------------------------------------------------------------------------

								bloodprince = {
									name = newFight(L["Blood Prince Council"], "bloodprince"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										flame1 = header_spell(72040),
										flame2 = desc_spell(72040, L["Places a circle under players with %s."]),
										flame3 = checkbox(a,b,c, L["Enabled"], "flame"),
										flame4 = color(a,b,c, "flame"),
										flame5 = radius(a,b,c, "flame"),

										spacer2 = spacer(),
										vortex1 = header_spell(72037),
										vortex2 = desc_spell(72037, L["Places a circle under players with %s."]),
										vortex3 = checkbox(a,b,c, L["Enabled"], "vortex"),
										vortex4 = color(a,b,c, "vortex"),
										vortex5 = radius(a,b,c, "vortex"),

										spacer3 = spacer(),
										empvortex1 = header_spell(72039),
										empvortex2 = desc_spell(72039, L["Turns on the AVR range check during %s."]),
										empvortex3 = checkbox(a,b,c, L["Enabled"], "empvortex"),
										empvortex4 = range_adv(a, b, c, "empvortex"),
									},
								},

-- BLOOD-QUEEN LANA'THEL -------------------------------------------------------------------------------------------

								lanathel = {
									name = newFight(L["Blood-Queen Lana'thel"], "lanathel"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),

										spacer1 = spacer(),
										terror1 = header_spell(73070),
										terror2 = desc_spell(73070, L["Turns on the AVR range check during %s."]),
										terror3 = checkbox(a,b,c, L["Enabled"], "terror"),
										terror4 = range_adv(a, b, c, "terror"),
										note = desc(L["AVRE does not assist with bites. Please use another add-on such as Vamp and VampArrow to accomplish this."]),								
									},
								},
								
-- SINDRAGOSA ------------------------------------------------------------------------------------------------------

								sindragosa = {
									name = newFight(L["Sindragosa"], "sindragosa"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										beacon1 = header_spell(70126),
										beacon2 = desc_spell(70126, L["Places a circle under players with %s."]),
										beacon3 = checkbox(a,b,c, L["Enabled"], "beacon"),
										beacon4 = color(a,b,c, "beacon"),
										beacon5 = radius(a,b,c, "beacon"),

										spacer2 = spacer(),
										instability1 = header_spell(69766),
										instability2 = desc_spell(69766, L["Places a circle under players with %s."].." "..L["(Heroic mode only.)"]),
										instability3 = checkbox(a,b,c, L["Enabled"], "instability"),
										instability4 = color(a,b,c, "instability"),
										instability5 = radius(a,b,c, "instability"),
									},
								},
						
-- LICH KING -------------------------------------------------------------------------------------------------------

								lichking = {
									name = newFight(L["The Lich King"], "lichking"),
									type = "group",
									order = newOrder(),
									args = {
										enabled = checkbox(a,b,c, L["Enable Encounter"], "enabled"),
										
										spacer1 = spacer(),
										plague1 = header_spell(70337),
										plague2 = desc_spell(70337, L["Places a circle under players with %s."]),
										plague3 = checkbox(a,b,c, L["Enabled"], "plague"),
										plague4 = color(a,b,c, "plague"),

										spacer2 = spacer(),
										shadowtrap1 = header_spell(73539),
										shadowtrap2 = desc_spell(73539, L["Places a circle under players with %s."]),
										shadowtrap3 = checkbox(a,b,c, L["Enabled"], "shadowtrap"),
										shadowtrap4 = color(a,b,c, "shadowtrap"),

										spacer3 = spacer(),
										defile1 = header_spell(72762),
										defile2 = desc_spell(72762, L["Places a circle under players with %s."].." |cffffff20"..L["NOTE: This mechanic does not currently work due to a Blizzard bug."].."|r"),
										defile3 = checkbox(a,b,c, L["Enabled"], "defile"),
										defile4 = color(a,b,c, "defile"),
									},
								},
						
							},
						},
						
					},
				},
				
			},
		},





























		options = {
			type = "group",
			name = L["General Options"],
			order = newOrder(),
			args = {
			
				enabled = {
					type = "toggle",
					name = L["Enable AVR Encounters"],
					get = function() return AVRE.db.profile.enabled end,
					set = function(self, val)
						AVRE.db.profile.enabled = val
						if val then AVRE:Enable() else AVRE:Disable() end
					end,
					order = newOrder(),
				},
				
				range = {
					type = "group",
					name = L["Range Checks"],
					order = newOrder(),
					args = {
					
						header1 = header(L["General Range Checks"]),
						desc1 = desc(L["Certain fights offer the option to automatically turn on the AVR range check for the entire duration of the fight. The AVR range check is a special AVR scene that assists you in locating in-range players using the 3D game world instead of a list of names. It draws a circular marker under players in range, and can optionally draw a line to those players as well. Finally, a circle outline can optionally be drawn around you, assisting you in knowing when you're approaching range of other players.\n\nYou can see how AVR range checks work by creating a range check scene yourself using AVR. Play with the options to see what you like, then configure them here in AVR Encounters. |cffffff20Be aware that AVR range checks are very CPU intensive.|r"]),

						classColor = {
							type = "toggle",
							name = L["Color by class"],
							desc = L["When enabled, lines and markers to in-range players will be colored by that player's class."],
							get = function() return AVRE.db.profile.range.classColor end,
							set = function(self, val) AVRE.db.profile.range.classColor = val end,
							order = newOrder(),
						},
	
						line = {
							type = "toggle",
							name = L["Show lines to players"],
							desc = L["When enabled, a line will be drawn from you to any player within range of you."],
							get = function() return AVRE.db.profile.range.line end,
							set = function(self, val) AVRE.db.profile.range.line = val end,
							order = newOrder(),
						},
	
						circle = {
							type = "toggle",
							name = L["Show range circle outline"],
							desc = L["When enabled, a circle outline will be drawn around you, indicating the current range."],
							get = function() return AVRE.db.profile.range.circle end,
							set = function(self, val) AVRE.db.profile.range.circle = val end,
							order = newOrder(),
						},
	
						radius = {
							order = newOrder(),
							type = "range",
							name = L["Marker radius"],
							desc = format(L["Determines the radius of the markers drawn under players within range of you."].." "..L["(Default is %.1f yards.)"], 0.5),
							min = 0,
							max = 5,
							bigStep = 0.1,
							get = function() return AVRE.db.profile.range.radius end,
							set = function(self, val) AVRE.db.profile.range.radius = val end,
						},
						
						spacer2 = spacer(),
						header2 = header(L["Mechanic-Specific Range Checks"]),
						desc2 = desc(L["The following options control AVR range checks that appear during specific fight mechanics. These options do not affect general range checks that are used throughout an entire fight."]),
	
						circleSelfEnabled = {
							type = "toggle",
							name = L["Show circle around self"],
							desc = L["When enabled, a filled circle will be drawn around you, indicating the current range."],
							get = function() return AVRE.db.profile.range.circleSelf.enabled end,
							set = function(self, val) AVRE.db.profile.range.circleSelf.enabled = val end,
							order = newOrder(),
						},
						
						circleSelfColor = {
							order = newOrder(),
							type = "color",
							name = L["Self circle color"],
							desc = L["Determines the color and transparency of the filled circle drawn around you during mechanic-specific range checks."],
							hasAlpha = true,
							set = function(self, red, green, blue, alpha)
								AVRE.db.profile.range.circleSelf.r = red
								AVRE.db.profile.range.circleSelf.g = green
								AVRE.db.profile.range.circleSelf.b = blue
								AVRE.db.profile.range.circleSelf.a = alpha
							end,
							get = function()
								return AVRE.db.profile.range.circleSelf.r, AVRE.db.profile.range.circleSelf.g, AVRE.db.profile.range.circleSelf.b, AVRE.db.profile.range.circleSelf.a
							end,
							disabled = function() return not AVRE.db.profile.range.circleSelf.enabled end,
						},
	
					},
				},
				
			},
		},
					
	}
}



--[[
      INITIALIZATION -----------------------------------------------------------------------------------------------------------
  ]]

function mod:OnInitialize()
	-- Remove options for disabled modules
	--@non-debug@
	for k, v in pairs(AVRE.modules.encounters) do
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(v.addon)
		if not enabled then
			AVRE.options.args.encounters.args[v.expansion].args[k] = nil
			local count = 0
			for kk, vv in pairs(AVRE.options.args.encounters.args[v.expansion].args) do
				count = count + 1
			end
			if count <= 1 then
				AVRE.options.args.encounters.args[v.expansion] = nil
				count = 0
				for kkk, vvv in pairs(AVRE.options.args.encounters.args) do
					count = count + 1
				end
				if count <= 0 then
					AVRE.options.args.encounters.args.allDisabled = desc(L["All AVRE encounter modules have been disabled. Enable one or more of them from the add-on selection screen in order to configure them."])
				end
			end
		end
	end
	--@end-non-debug@
	
	-- Register options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AVRE", AVRE.options)
	AVRE.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AVRE", "AVR Encounters")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("AVRE-Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(AVRE.db))
	AVRE.profilesFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("AVRE-Profiles", "Profiles", "AVR Encounters")
	AVRE.modules.options.loaded = true
end


function mod:OnEnable()
--[===[@debug@
	self:Print(L["Loaded"])
--@end-debug@]===]
end
