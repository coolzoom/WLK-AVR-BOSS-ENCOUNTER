Note: AVR will be broken in patch 3.3.5. See this
AVR (Augmented Virtual Reality) allows you to draw and add lines, circles and other markings on the 3D world itself. All markings may also be shared with others. Suitable for example to mark locations when explaining raid tactics. These marks can even be left visible for the fight itself.

Other things you can do with AVR:

Draw range circles around you or someone else at any range
Clearly mark players close to you
Mark any location relative to player position and rotation, for example mage blink landing spot
Measure distances
Boss encounter warnings (using a separate addon)
Boss encounters
AVR does not contain a built in boss encounters module anymore. They are now done by a separate addon. At the moment there are two options.

AVR Encounters adds AVR warnings for various boss abilities. It does not require any other boss encounter addon to work. It is not a replacement for traditional boss encounter addons as it does not do ability timers, sound warnings etc. It can be used with any traditional boss encounter addon such as BigWigs, DBM or DXE.
Raid Watch 2 is a full boss encounter addon much like BigWigs, DBM or DXE. It has built-in support for AVR and also does timer bars and other kinds of warnings.
Whichever you choose to use, you will also need to install AVR.

Important note: If you have installed a previous version of AVR which contained the AVR BigWigs module then you should delete that. Simply delete your Interface\Addons\AVR_BigWigs_Citadel folder.

Limitations and known issues
There are some fundamental limitations caused by what information is available to addons. These are mostly related to the exact position of camera and lack of unit Z coordinates. In particular you should note following:

Drawing works best on a flat surface (note that for example Dalaran has very uneven roads).
Camera getting stuck in a wall or ceiling will cause any markings to go out of sync with rest of the world.
Any kind of stairs/slopes and such cause troubles.
Jumping and other kinds of vertical movement causes the drawings to move with you.
Everything is drawn over the 3d world. This means that things that should be behind walls or units will appear in front of them.
Camera auto follow causes some problems. See also this
Some other known issues are:

All vehicles (like the ones at the start of Ulduar) are a bit problematic.
Lifts, moving platforms and in particular Gunships in Icercown Citadel raid have some problems.
Player map coordinates are unavailable in Icecrown Citadel raid on Lich King platform after the edges have collapsed. This means that any markings tied to zone coordinates or other players than yourself are unusable there. (Lana'Thel's room was fixed in 3.3.3 though the ramps leading there are still a bit odd.)
Player map coordinates are also not available in arenas or instances released before Wrath of the Lich King and so most things don't work in either of those.
How to use
See How to use.

Frequently asked questions
See FAQ.