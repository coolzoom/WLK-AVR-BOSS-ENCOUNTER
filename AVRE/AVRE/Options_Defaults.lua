local L = LibStub("AceLocale-3.0"):GetLocale("AVRE")


--[[ CORE DEFAULTS ]]---------------------------------------------------------------------------------------------------------------

local defaultColor = { r = 1.0, g = 0.0, b = 0.0, a = 0.25 }

AVRE.defaults = {
 profile = {
		enabled = true,
		range = {
			classColor = true,
			line = true,
			circle = true,
			radius = 0.5,
			circleSelf = {
				enabled = true,
				r = 1.0,
				g = 1.0,
				b = 1.0,
				a = 0.08,
			},
		},
		enc = {
------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------- WRATH OF THE LICH KING --
------------------------------------------------------------------------------------------------------------------------------
			wotlk = {
				enabled = true,
--------------------- ULDUAR -------------------------------------------------------------------------------------------------
				ulduar = {
					enabled = true,
					hodir = {
						enabled = true,
						storm = true,
						advanced = {
							storm = { r = 1.0, g = 0.0, b = 0.0, a = 0.25 },
						},
					},
					freya = {
						enabled = true,
						root = true,
						fury = true,
						advanced = {
							root = { r = 1.0, g = 0.0, b = 0.0, a = 0.25 },
							fury = { r = 0.2, g = 0.2, b = 1.0, a = 0.25 },
						},
					},
					mimiron = {
						enabled = true,
						napalm = true,
						advanced = {
							napalm = { r = 0.2, g = 0.2, b = 1.0, a = 0.25 },
						},
					},
					generalvezax = {
						enabled = true,
						crash = true,
						mark = true,
						advanced = {
							crash = { r = 1.0, g = 0.0, b = 0.0, a = 0.25 },
							mark = { r = 0.2, g = 1.0, b = 0.2, a = 0.25 },
						},
					},
					yoggsaron = {
						enabled = true,
						malady = true,
						advanced = {
							malady = { r = 1.0, g = 0.0, b = 0.0, a = 0.25 },
						},
					},
				}, -- ulduar
--------------------- ICECROWN CITADEL ---------------------------------------------------------------------------------------
				icecrown = {
					enabled = true,
					marrowgar = {
						enabled = true,
						spike = true,
						advanced = {
							spike = { r = 1.0, g = 0.0, b = 0.0, a = 0.4 },
						},
					},
					deathwhisper = {
						enabled = true,
						dominate = true,
						spirit = true,
						advanced = {
							dominate = { r = 1.0, g = 0.0, b = 0.0, a = 0.3, rad = 3 },
							spirit = { r = 0.2, g = 0.2, b = 1.0, a = 0.4, rad = 3 },
						},
					},
					festergut = {
						enabled = true,
						gasSpore = true,
						vile = true,
						range = { enabled = false, range = 10 },
						advanced = {
							gasSpore = defaultColor,
							vile = { r = 1.0, g = 0.5, b = 0.0, a = 0.25 },
						},
					},
					rotface = {
						enabled = true,
						explosion = true,
						infection = true,
						vile = true,
						kiter = "",
						range = { enabled = false, range = 10 },
						advanced = {
							explosion = { r = 1.0, g = 0.0, b = 0.0, a = 0.25, rad = 6 },
							infection = { r = 0.2, g = 1.0, b = 0.2, a = 0.25, rad = 3 },
							vile = { r = 1.0, g = 0.5, b = 0.0, a = 0.25 },
							kiter = { r = 1.0, g = 1.0, b = 1.0, a = 0.7, rad = 2 },
						},
					},
					putricide = {
						enabled = true,
						malleable = true,
						malleableAll = true,
						plague = true,
						sick = true,
						advanced = {
							malleable = { r = 1.0, g = 0.0, b = 0.0, a = 0.25, rad = 7 },
							malleableAll = { r = 0.1, g = 0.1, b = 1.0, a = 0.15, rad = 7 },
							plague = { r = 1.0, g = 0.5, b = 0.0, a = 0.25 },
							sick = { r = 1.0, g = 1.0, b = 1.0, a = 0.5, rad = 0.6 },
						},
					},
					bloodprince = {
						enabled = true,
						flame = true,
						vortex = true,
						empvortex = true,
						advanced = {
							flame = { r = 1.0, g = 0.0, b = 0.0, rad = 10 },
							vortex = { r = 1.0, g = 1.0, b = 1.0, a = 0.3, rad = 11 },
							empvortex = { range = 12 },
						},
					},
					lanathel = {
						enabled = true,
						terror = true,
						advanced = {
							terror = { range = 6 },
						},
					},
					sindragosa = {
						enabled = true,
						beacon = true,
						instability = true,
						advanced = {
							beacon = { r = 1.0, g = 0.0, b = 0.0, a = 0.1, rad = 10 },
							instability = { r = 0.0, g = 0.0, b = 1.0, a = 0.1, rad = 20 },
						},
					},
					lichking = {
						enabled = true,
						defile = false,
						shadowtrap = true,
						plague = true,
						advanced = {
							defile = defaultColor,
							shadowtrap = defaultColor,
							plague = { r = 0.2, g = 1.0, b = 0.2, a = 0.4 },
						},
					},
				}, -- icecrown
------------------------------------------------------------------------------------------------------------------------------
			}, -- wotlk
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
		}, -- end
 }, -- profile
} -- defaults


