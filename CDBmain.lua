--Set things up
CDB = {};
CDB.panel = CreateFrame( "Frame" );
CDB.panel:RegisterEvent("PLAYER_ENTERING_WORLD");
if not CDBsettings then CDBsettings = {}; end
SLASH_CDB1="/cdb";
function SlashCmdList.CDB(msg, editbox)
	if not CDB.Initialzed then CDB.Initialize(); end;
	if (string.len(msg) == 0) then
		local function fluff()
			if CDBsettings.Enabled == true then return "enabled"
			else return "disabled"
			end
		end
		local fluff2 = " but a channel isn't set. Will try /rw if available.";
		if     type(CDBsettings.Channel) == "string" then fluff2 = " and set to channel: "..CDBsettings.Channel;
		elseif type(CDBsettings.Channel) == "table"  then fluff2 = " and set to report via "..CDBsettings.Channel[1].." to "..CDBsettings.Channel[2]; end
		print("Cooldown Barker is currently "..fluff()..fluff2)
		print("Usage: /cdb command")
		print(" Commands are: toggle, add, rem, channel, list, help, defaults")
		print(" If you want to learn more about a command use \"/cdb help command\"")
	else
		slashHandler(msg);
	end
end
--Meat and Potatoes
local defaultlist = {
	--Battle Rezs
	[20484] = true;		--Rebirth 
	[61999] = true;		--Raise Ally 
	[95750] = true;		--Soulstone Resurrection 
	--[20608] = true;		--Reincarnation [!]Doesn't show up in the combat log so we can't track it. Complain to Blizz
	--Healing CDs
	[633]   = true;		--Lay on Hands 
	[47788]	= true;		--Guardian Spirit
	[740] 	= true;		--Tranquility 
	[62618] = true;		--Power Word: Barrier 
	[98008]	= true;		--Spirit Link Totem 
	--Defensive CDs
	[86150]	= true;		--Guardian of Ancient Kings
	[31850]	= true;		--Ardent Defender
	[70940] = true;		--Divine Guardian
	--Bubbles
	[642]	= true;		--Divine Shield (Pally)
}
local tracklist = {};
CDB.panel:SetScript("OnEvent", function(self, event, ...)
	if (not CDB.Initialzed) then
		CDB.Enable();
	end
	if (CDBsettings.Enabled ~= true) then 
		CDB.Disable();
		return;
	end
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		local timestamp, linetype, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
		if (linetype == "SPELL_RESURRECT" or linetype == "SPELL_CAST_SUCCESS") then
			local spellId, spellName, spellSchool = select(12, ...)
			if tracklist == nil then CDB.Initialzed = false; CDB.Enable(); end
			if (tracklist[spellId] == true) then
				link = nil;
				grabage = nil;
				link, _ = GetSpellLink(spellId);
				if CDBsettings.Channel == nil then CDBsettings.Channel = "RAID_WARNING"; end
				if (type(CDBsettings.Channel) == "string") then
					if (CDBsettings.Channel == "RAID_WARNING") then
						if (IsRaidOfficer() == true) or (IsRealRaidLeader()  == true) then
						else return;
						end
					end
					if (destName) then
						SendChatMessage(sourceName.." cast "..link.." on "..destName..".", CDBsettings.Channel);
					else
						SendChatMessage(sourceName.." cast "..link, CDBsettings.Channel);
					end
				elseif type(CDBsettings.Channel) == "table" then
					if (CDBsettings.Channel[1] == "RAID_WARNING") then
						if (IsRaidOfficer() == true) or (IsRealRaidLeader()  == true) then
						else return;
						end
					end
					if CDBsettings.Channel[1] == "channel" then target = channelFinder(CDBsettings.Channel[2])
					else target = CDBsettings.Channel[2]; end;
					if (destName) then
						SendChatMessage(sourceName.." cast "..link.." on "..destName..".", CDBsettings.Channel[1], nil, target);
					else
						SendChatMessage(sourceName.." cast "..link, CDBsettings.Channel[1], nil, target);
					end
				end
			end
		end
	end
end);
function CDB.Initialize()
	tracklist = nil;
	tracklist = "DIE";
	tracklist = nil;
	tracklist = {};
	if (CDBsettings.badDefaults) then
		for _,spellId in ipairs(CDBsettings.badDefaults) do
			defaultlist[spellId] = false;
		end
	end
	for key,value in pairs(defaultlist) do
		if (value == true) then
			tracklist[key] = true;
		end
	end
	if (CDBsettings.CustomList) then
		for key,value in pairs(CDBsettings.CustomList) do
			tracklist[key] = true;
		end
	end
	CDB.Initialzed = true;
end
function CDB.Enable()
	CDB.panel:UnregisterEvent("PLAYER_ENTERING_WORLD");
	CDB.panel:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	if (CDB.Initialized ~= true) then
		CDB.Initialize();
	end
	CDBsettings.Enabled = true;
end
function CDB.Disable()
	CDB.panel:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	CDB.panel:RegisterEvent("PLAYER_ENTERING_WORLD");
	CDBsettings.Enabled = false;
end
function slashHandler(msg)
	local arguments = {};
	for i,v in ipairs({strsplit(" ", msg)}) do
		table.insert(arguments, v);
	end
	if 		arguments[1] == "toggle"	then slashHandler_togl();
	elseif	arguments[1] == "add"		then slashHandler_add(arguments[2]);
	elseif	arguments[1] == "rem"		then slashHandler_rem(arguments);
	elseif	arguments[1] == "channel"	then slashHandler_chan(arguments);
	elseif	arguments[1] == "list"		then slashHandler_list();
	elseif	arguments[1] == "defaults"	then slashHandler_defs();
	elseif	arguments[1] == "help"		then slashHandler_help(arguments[2]);
	end
end
function slashHandler_help(topic)
	if topic == nil then return end
	local helplist = {
		["toggle"]	= {"Enables or disables Cooldown Barker:", "/cdb toggle on\off"},
		["add"]		= {"Adds a cooldown to the list of things we track:", "/cdb add SpellName or SpellId", "You have to look up the spells ID if it isn't a spell your class can cast.", "This is a limitiation in WoW, complain to Blizz.", "Your spells WoWHead page has the id at the end of the url.", "Rejuvenation is http://www.wowhead.com/spell=774 for example."},
		["rem"]		= {"Removes a cooldown from the list of things we track:", "/cdb rem SpellName or SpellId"},
		["channel"]	= {"Set the list of channel we announce to:", "/cdb channel [battleground, channel, emote, guild, officer, party, raid, raid_warning, say, whisper, yell]"},
		["list"]	= {"Lists all the cooldowns we watch:", "/cdb list"},
		["defaults"]= {"Clears everything and resets Cooldown Barker to default settings", "/cdb defaults yes"},
	}
	for i,v in ipairs(helplist[topic]) do
		print(v)
	end
end
function slashHandler_add(spellName)
	local spellLink,_ = GetSpellLink(spellName);
	if (spellLink) then
		local _, _, spellId = string.find(spellLink, "^|c%x+|Hspell:(.+)|h%[.*%]")
		spellId = tonumber(spellId);
		tracklist[spellId] = true;
		if (defaultlist[spellId] ~= nil) then 
			defaultlist[spellId] = true; 
		else
			if (CDBsettings.CustomList == nil) then CDBsettings.CustomList = {}; end
			CDBsettings.CustomList[spellId] = true;
		end
		print("Added "..spellLink.." to the list");
		return;
	end
	print("Invalid spell name or spell id. Try again!")
end
function slashHandler_list()
	print("We track:")
	for key,value in pairs(tracklist) do 
		if (value == true) then
			local derp,_ = GetSpellLink(key); 
			print(derp); 
		end
	end
end
function slashHandler_rem(args)
	table.remove(args, 1)
	local spellLink,_ = GetSpellLink(args[1]);
	if (spellLink) then
		_, _, spellId = string.find(spellLink, "^|c%x+|Hspell:(.+)|h%[.*%]");
	else
		spellName = args[1];
		table.remove(args, 1)
		for _,k in ipairs(args) do
			spellName = spellName.." "..k;
		end
		for i,_ in pairs(tracklist) do
			local info = {GetSpellInfo(i)};
			if (type(info) == "table") then
				if (tonumber(info[1]) == tonumber(spellName)) then
					spellId = i;
					break;
				end
			end
		end
	end
	spellId = tonumber(spellId);
	if tracklist[spellId] == nil then print("That doesn't appear to be in the list, check /cdb list or try again with a spellId."); return; end;
	tracklist[spellId] = nil;
	if spellLink == nil then spellLink = GetSpellLink(spellId); end
	if (defaultlist[spellId] ~= nil) then 
		if (CDBsettings.badDefaults == nil) then CDBsettings.badDefaults = {}; end;
		table.insert(CDBsettings.badDefaults, spellId)
		print("Blocked "..spellLink.." from the default list and removed it from the things we track.");
		return;
	else
		if (CDBsettings.CustomList == nil) then CDBsettings.CustomList = {}; end;
		CDBsettings.CustomList[spellId] = nil;
		print("Removed "..spellLink.." from the list");
		return;
	end
end
function slashHandler_chan(arguments)
	channel = arguments[2];
	local channels = {
		["battleground"] = true,
		["emote"] = true,
		["guild"] = true,
		["channel"] = true,
		["officer"] = true,
		["party"] = true,
		["raid"] = true,
		["raid_warning"] = true,
		["say"] = true,
		["whisper"] = true,
		["yell"] = true,
	}
	local specials = {
		["whisper"] = true,
		["channel"] = true,
	}
	if (specials[channel]) then  
		CDBsettings.Channel = {channel, arguments[3]}
		CDBoptionsPanel.Initialize()
		print("Reporting to "..arguments[3]..".");
	elseif channels[channel] then
		CDBsettings.Channel = string.upper(channel);
		CDBoptionsPanel.Initialize()
		print("Channel set to "..channel..".");
	else
    print("Channel isn't in the list, check /cdb help channel.");
  end
end
function channelFinder(channel)
	local chans		= {};
	local count = 1;
	for i,v in ipairs({GetChannelList()}) do
		if (tonumber(v) == nil) then
			chans[v] = count;
			count = 1 + count;
		end
	end
	if chans[channel] then return chans[channel]; end;
	return false;
end
function slashHandler_defs(channel)
	CDBsettings = nil;
	CDBsettings = "DIE";
	CDBsettings = nil;
	CDBsettings = {};
	CDB.Initialzed = nil;
	tracklist = nil;
	CDB.Enable()
	print("CDB set defaults done.");
end
function slashHandler_togl(channel)
	CDBsettings.Enabled = not CDBsettings.Enabled; 
	if  (CDBsettings.Enabled) then print("CDB Enabled!");
	else print("CDB Disabled!"); end
end