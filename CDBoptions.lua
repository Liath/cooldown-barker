CDBoptions = {};
CDBoptionsPanel = CreateFrame( "Frame", "CDB_Panel", UIParent );
CDBoptionsPanel.name = GetAddOnMetadata("cooldown-barker", "Title");
InterfaceOptions_AddCategory(CDBoptionsPanel);

function CDBoptionsPanel.Initialize()
	if not CDBsettings then
		CDBsettings = {};
	end
	local CDBOptionsHeader = CDBoptionsPanel:CreateFontString(nil, "ARTWORK");
	CDBOptionsHeader:SetFontObject(GameFontNormalLarge);
	CDBOptionsHeader:SetPoint("TOPLEFT", 16, -16);
	CDBOptionsHeader:SetText(GetAddOnMetadata("cooldown-barker", "Title") .. " " .. GetAddOnMetadata("cooldown-barker", "Version"));
	
	local CDBOptionsCB_Enabled_label = CDBoptionsPanel:CreateFontString(nil, "ARTWORK");
	CDBOptionsCB_Enabled_label:SetFontObject(GameFontNormal);
	CDBOptionsCB_Enabled_label:SetPoint("TOPLEFT", 16, -40);
	CDBOptionsCB_Enabled_label:SetText("Enabled:");
	CDBOptionsCB_Enabled = CreateFrame("CheckButton", "CDBOptionsCB_Enabled", CDBoptionsPanel, "OptionsCheckButtonTemplate");
	CDBOptionsCB_Enabled:SetPoint("TOPLEFT", CDBOptionsHeader, "BOTTOMLEFT", 55, 0);
	CDBOptionsCB_Enabled:SetScript("OnClick", function(self)
		CDBsettings.Enabled = (not CDBsettings.Enabled);
		CDB.Enable();
		end);
	CDBOptionsCB_Enabled:SetChecked(CDBsettings.Enabled);
	CDBOptionsCB_EnabledText:SetText("");
	
	local CDBOptionsDD_Channel_label = CDBoptionsPanel:CreateFontString(nil, "ARTWORK");
	CDBOptionsDD_Channel_label:SetFontObject(GameFontNormal);
	CDBOptionsDD_Channel_label:SetPoint("TOPLEFT", 16, -62);
	CDBOptionsDD_Channel_label:SetText("Channel:");
	if not CDBOptionsDD_Channel then
		CreateFrame("Button", "CDBOptionsDD_Channel", CDBoptionsPanel, "UIDropDownMenuTemplate")
	end
	CDBOptionsDD_Channel:ClearAllPoints()
	CDBOptionsDD_Channel:SetPoint("TOPLEFT", 55, -55)
	CDBOptionsDD_Channel:Show()

	local items = {"Battleground", "Emote", "Guild", "Officer", "Party", "Raid", "Raid_Warning", "Say", "Whisper", "Yell", "Channel"}

	local function OnClick(self)
	   UIDropDownMenu_SetSelectedID(CDBOptionsDD_Channel, self:GetID())
	   CDBsettings.Channel = string.upper(items[self:GetID()]);
	end

	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo();
		for k,v in pairs(items) do
			if (type(CDBsettings.Channel) == "string") then
				if (string.upper(v) == CDBsettings.Channel) then
					UIDropDownMenu_SetSelectedName(CDBOptionsDD_Channel, v, v);
					UIDropDownMenu_SetText(CDBOptionsDD_Channel, v);
				end
			elseif (type(CDBsettings.Channel) == "table") then
				if (string.upper(v) == CDBsettings.Channel[1]) then
					UIDropDownMenu_SetSelectedName(CDBOptionsDD_Channel, v, v);
					UIDropDownMenu_SetText(CDBOptionsDD_Channel, v);
				end
			end
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			if (v == "Whisper" or v == "Channel") then
				if (CDBsettings.Channel) then 
					if (type(CDBsettings.Channel) == "table") then if (CDBsettings.Channel[2]) then 
						info.notClickable = true;
						UIDropDownMenu_SetText(CDBOptionsDD_Channel, CDBsettings.Channel[2]);
					end end
				else 
					if (v == "Whisper" or v == "Channel") then info.notClickable = true; end;
				end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_SetText(CDBOptionsDD_Channel, "");
	UIDropDownMenu_Initialize(CDBOptionsDD_Channel, initialize)
	UIDropDownMenu_SetWidth(CDBOptionsDD_Channel, 100);
	UIDropDownMenu_SetButtonWidth(CDBOptionsDD_Channel, 124)
	UIDropDownMenu_JustifyText(CDBOptionsDD_Channel, "LEFT")
end

function CDBoptions.Event(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		if (CDBoptionsPanel.Initialized ~= true) then
			CDBoptionsPanel.Initialize();
		end
	end
end

CDBoptions.EventFrame = CreateFrame("Frame", "CDBOptionsFrame");
CDBoptions.EventFrame:SetScript("OnEvent", CDBoptions.Event);
CDBoptions.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
