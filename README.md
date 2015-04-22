## Cooldown Barker
Very lightweight mod that will call out in Raid Warning when a big cooldown like Lay on Hands or a battle rez is used.
Often times multiple people will try to brez the same target and this helps clarify things. 
It also tracks a host of other CDs by default and others can be added.

##Usage
####Adding Spells
/cdb add spellId

You can use the spells name too but in a limited way due to flaws in the API. http://www.wowwiki.com/API_GetSpellLink
Names will only work if the name of the spell is in your spell book. 
You can use WoWHead to look up a spells ID. For example Rejuventation's WoWHead page is at :
http://www.wowhead.com/spell=774
So Rejuvenation's ID is 774. On any spell page the number at the end will be the spells ID.

####Removing Spell
/cdb rem spell

You can use the spells name here just fine since we can just check it against the list.
If the spell you removed is in the default list it will be disabled.

####Listing Spells
/cdb list

####Toggling the barker on/off
/cdb toggle

####Changing where/who Cooldown Barker reports to
```
/cdb channel battleground | Report to the BG if you're in one, otherwise nothing will happen.
/cdb channel guild | Report to guild chat.
/cdb channel emote | Like using /me.
/cdb channel channel Trade | Will tell trade chat you just Lay on Hands yourself like a boss. You can set the third part to any channel you are currently in.
/cdb channel officer | Guild Officer chat.
/cdb channel party | Party chat .
/cdb channel raid | /ra if you feel like alerting the raid but your raid leader isn't cool enough to set assist on you :P
/cdb channel raid_warning | The most logical place to tell the raid who didn't call out in Vent when they were gonna burn a Brez
/cdb channel say | Actually not a bad place to put them if you want to unobtrusive in a raid.
/cdb channel whisper Derp | Will alert Derp via whisper of all the fun cooldowns your popping.
/cdb channel yell | Another fun place to send alerts to.
```

####Return all settings to Defaults
/cdb defaults

Clears the spell list back to defaults.

##Current Default Spells:
----
####Battle Rezs
Rebirth,
Raise Ally,
Soulstone Resurrection,
####Healing CDs
Lay on Hands,
Guardian Spirit,
Tranquility,
Power Word: Barrier,
Spirit Link Totem,
Holy Radiance,
####Defensive CDs
Guardian of Ancient Kings,
Ardent Defender,
Divine Guardian,
####Bubbles
Divine Shield