--[[

LootKingMaster
Author: Ivan Leben

--]]

local LKM = LootKingMaster;

--Output
--===================================================

function LKM.Print( msg, force )

	if (LKM.GetSave().silentEnabled == false or force == true) then
	
		print( "|cffffff00" .. LKM.PRINT_PREFIX .. " |cffffffff"..msg );
		
	end
end

function LKM.Error (msg)

	print( "|cffffff00" .. LKM.PRINT_PREFIX .. " |cffff2222"..msg );
	
end


--Slash handler
--===================================================


function LKM.SlashHandler( msg )

	if (msg == "") then

		--Empty command
		LKM.UpdateGui();
		LKM.ShowGui();
		
	else
	
		--Parametric commands
		local cmd, param = strsplit( " ", msg );
		if (cmd == "reset") then
		
			LKM.ResetSave();
			LKM.Print( "Settings reset." );
		
		elseif (cmd == "config") then
		
			LKM.ShowConfigGui();
		end
	end
end


SLASH_LootKingMaster1 = "/lootkingmaster";
SLASH_LootKingMaster2 = "/lkm";
SlashCmdList["LootKingMaster"] = LKM.SlashHandler;


--Player list
--===================================================

function LKM.PlayerList_New( name )

	local f = PrimeGui.List_New( name );
	
	f.UpdateItem = LKM.PlayerList_UpdateItem;
	
	return f;
end

function LKM.PlayerList_UpdateItem( frame, item, value, selected  )

	PrimeGui.List_UpdateItem( frame, item, value, selected );
	
	if (value.color) then
	
		local c = value.color;
		item.label:SetTextColor( c.r, c.g, c.b, c.a );
	end
	
end

--Gui
--===================================================

function LKM.ShowGui()
	
	LKM.gui:Show();
end

function LKM.HideGui()

	LKM.gui:Hide();
end


function LKM.CreateGui()

	--Window
	local w = PrimeGui.Window_New("LootKingMaster", "LootKingMaster", true, true);
	w:Init();
	w:SetParent( UIParent );
	w:SetWidth( 400 );
	w:SetHeight( 500 );
	
	--List background
	local bg = CreateFrame( "Frame", nil, w.container );
	bg:SetPoint( "BOTTOMLEFT", 0,0 );
	bg:SetPoint( "TOPRIGHT", -150,0 );
	
	bg:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-Tooltip-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	 
	bg:SetBackdropColor(0,0,0,0.8);
	
	--List box
	local list = LKM.PlayerList_New( "LootKingMaster".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Dropdown
	local drop = PrimeGui.Drop_New( "LootKingMaster.Dropdown" );
	drop:Init();
	drop:SetParent( w.container );
	drop:SetPoint( "TOPRIGHT", 0, 0 );
	drop:SetWidth( 130 );
	drop:SetLabelText( "Active list:" );
	drop.OnValueChanged = LKM.Drop_OnValueChanged;
	drop.window = w;
	w.drop = drop;
	
	--Buttons
	local btnTop = PrimeGui.Button_New( "LootKingMaster.ButtonTop" );
	btnTop:RegisterScript( "OnClick", LKM.Top_OnClick );
	btnTop:SetParent( w.container );
	btnTop:SetPoint( "TOPRIGHT", drop, "BOTTOMRIGHT", 0, -30 );
	btnTop:SetText( "Top" );
	btnTop:SetWidth( 130 );
	
	local btnUp = PrimeGui.Button_New( "LootKingMaster.ButtonUp" );
	btnUp:RegisterScript( "OnClick", LKM.Up_OnClick );
	btnUp:SetParent( w.container );
	btnUp:SetPoint( "TOPRIGHT", btnTop, "BOTTOMRIGHT", 0, -5  );
	btnUp:SetText( "Up" );
	btnUp:SetWidth( 130 );
	
	local btnDown = PrimeGui.Button_New( "LootKingMaster.ButtonDown" );
	btnDown:RegisterScript( "OnClick", LKM.Down_OnClick );
	btnDown:SetParent( w.container );
	btnDown:SetPoint( "TOPRIGHT", btnUp, "BOTTOMRIGHT", 0, -5  );
	btnDown:SetText( "Down" );
	btnDown:SetWidth( 130 );
	
	local btnBottom = PrimeGui.Button_New( "LootKingMaster.ButtonBottom" );
	btnBottom:RegisterScript( "OnClick", LKM.Bottom_OnClick );
	btnBottom:SetParent( w.container );
	btnBottom:SetPoint( "TOPRIGHT", btnDown, "BOTTOMRIGHT", 0, -5  );
	btnBottom:SetText( "Bottom" );
	btnBottom:SetWidth( 130 );
	
	local btnInsert = PrimeGui.Button_New( "LootKingMaster.ButtonInsert" );
	btnInsert:RegisterScript( "OnClick", LKM.Insert_OnClick );
	btnInsert:SetParent( w.container );
	btnInsert:SetPoint( "TOPRIGHT", btnBottom, "BOTTOMRIGHT", 0, -30 );
	btnInsert:SetText( "Insert" );
	btnInsert:SetWidth( 130 );
	
	local btnRemove = PrimeGui.Button_New( "LootKingMaster.ButtonRemove" );
	btnRemove:RegisterScript( "OnClick", LKM.Remove_OnClick );
	btnRemove:SetParent( w.container );
	btnRemove:SetPoint( "TOPRIGHT", btnInsert, "BOTTOMRIGHT", 0, -5 );
	btnRemove:SetText( "Remove" );
	btnRemove:SetWidth( 130 );
	
	
	local btnSave = PrimeGui.Button_New( LKM.PREFIX.."BtnSave");
	btnSave:RegisterScript( "OnClick", LKM.Save_OnClick );
	btnSave:SetParent( w.container );
	btnSave:SetPoint( "TOPRIGHT", btnRemove, "BOTTOMRIGHT", 0, -30 );
	btnSave:SetText( "Save" );
	btnSave:SetWidth( 130 );
	
	local btnSync = PrimeGui.Button_New( LKM.PREFIX.."BtnSync" );
	btnSync:RegisterScript( "OnClick", LKM.Sync_OnClick );
	btnSync:SetParent( w.container );
	btnSync:SetPoint( "TOPRIGHT", btnSave, "BOTTOMRIGHT", 0, -5 );
	btnSync:SetText( "Sync" );
	btnSync:SetWidth( 130 );
	
	local btnConfig = PrimeGui.Button_New( LKM.PREFIX.."BtnConfig");
	btnConfig:RegisterScript( "OnClick", LKM.Config_OnClick );
	btnConfig:SetParent( w.container );
	btnConfig:SetPoint( "TOPRIGHT", btnSync, "BOTTOMRIGHT", 0, -5 );
	btnConfig:SetText( "Config" );
	btnConfig:SetWidth( 130 );
	
	return w;
end

function LKM.UpdateGui()

	--Fill dropdown with list names
	LKM.gui.drop:RemoveAllItems();
	
	for name,list in pairs(LKM.GetSave().lists) do
		LKM.gui.drop:AddItem( name, name );
	end
	
	LKM.gui.drop:SelectValue( LKM.GetSave().activeList );
	
	--Store list state
	local index = LKM.gui.list:GetSelectedIndex();
	local offset = LKM.gui.list:GetScrollOffset();
	
	LKM.FillList( LKM.gui.list, LKM.GetActiveList() );
	
	--Restore list state
	LKM.gui.list:SelectIndex( index );
	LKM.gui.list:SetScrollOffset( offset );
	
end

function LKM.FillList( guiList, playerList )

	--Constants
	local white = {r=1, g=1, b=1, a=1};
	local gray = {r=0.5, g=0.5, b=0.5, a=1};
	
	--Get raid info
	local inRaid = UnitInRaid("player");
	local raidMembers = PrimeGroup.GetMembers();
	
	--Clear existing items
	guiList:RemoveAllItems();
	
	--Iterate player items
	for i=1,table.getn(playerList) do
	
		--White if not in raid
		local col = white;
		if (inRaid) then
		
			--Gray if item not in raid
			col = gray;
			
			--Find item among raid members
			for r=1,table.getn(raidMembers) do
				if (raidMembers[r] == playerList[i]) then
				
					--Class color if item in raid
					col = PrimeGroup.GetClassColor( playerList[i] );
					break;
				end
			end
		end
		
		--Insert player item with set color
		guiList:AddItem( { text = playerList[i], color = col } );
		
	end
end

--Sync gui
--============================================================================

function LKM.GetActiveSyncList()

	--Check that a sync list is selected
	if (LKM.syncActiveList == nil) then
		return nil;
	end
	
	--Return selected sync list
	return  LKM.syncLists[ LKM.syncActiveList ];

end

function LKM.SetActiveSyncList( name )

	--Check if valid name
	if (LKM.syncLists[ name ] == nil) then
		return;
	end
	
	--Switch to given list
	LKM.syncActiveList = name;
	LKM.UpdateSyncGui();
end

function LKM.CreateSyncGui()

	--Window
	local w = PrimeGui.Window_New("LootKingSync", "Sync", true, false);
	w:Init();
	w:SetParent( UIParent );
	w:SetWidth( 300 );
	w:SetHeight( 400 );
	
	--Label
    local txt = w:CreateFontString( LKM.PREFIX.."SyncGui.Text", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 0, 1 );
    txt:SetPoint( "TOPLEFT", w.container, "TOPLEFT", 0, 0 );
    txt:SetPoint( "TOPRIGHT", w.container, "TOPRIGHT", 0, 0 );
	txt:SetJustifyH( "CENTER" );
	txt:SetJustifyV( "TOP" );
    txt:SetHeight( 40 );
    txt:SetWordWrap( true );
    txt:SetText( "Message" );
	w.text = txt;
	
	--Dropdown
	local drop = PrimeGui.Drop_New( LKM.PREFIX.."SyncGui.Dropdown" );
	drop:Init();
	drop:SetParent( w.container );
	drop:SetPoint( "TOPLEFT", 0, -5 );
	drop:SetPoint( "TOPRIGHT", 0, -5 );
	drop:SetLabelText( "" );
	drop.OnValueChanged = LKM.SyncGui_Drop_OnValueChanged;
	drop.window = w;
	w.drop = drop;
	
	--List background
	local bg = CreateFrame( "Frame", nil, w.container );
	bg:SetPoint( "TOPRIGHT", drop, "BOTTOMRIGHT", 0,-5 );
	bg:SetPoint( "BOTTOMLEFT", 0,30 );
	
	bg:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-Tooltip-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	 
	bg:SetBackdropColor(0,0,0,0.8);
	
	--List box
	local list = LKM.PlayerList_New( "LootKingMaster".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Cancel button
	local btnClose = PrimeGui.Button_New( "LootKingMaster.SyncGui.Close" );
	btnClose:Init();
	btnClose:SetParent( w.container );
	btnClose:SetText( "Close" );
	btnClose:SetPoint( "BOTTOMRIGHT", 0,0 );
	btnClose:RegisterScript( "OnClick", LKM.SyncGui_Close_OnClick );
	btnClose.window = w;
	
	--Apply button
	local btnApply = PrimeGui.Button_New( "LootKingMaster.SyncGui.Accept" );
	btnApply:Init();
	btnApply:SetParent( w.container );
	btnApply:SetText( "Apply" );
	btnApply:SetPoint( "BOTTOMRIGHT", btnClose, "BOTTOMLEFT", -10,0 );
	btnApply:RegisterScript( "OnClick", LKM.SyncGui_Apply_OnClick );
	btnApply.window = w;
	
	return w;
	
end

function LKM.UpdateSyncGui()

	--Set message to match sync target
	LKM.syncGui.text:SetText( "Sync received from "..LootKingMaster.syncTarget );
	
	--Fill dropdown with list names
	LKM.syncGui.drop:RemoveAllItems();
	
	for name,list in pairs(LKM.syncLists) do
		LKM.syncGui.drop:AddItem( name, name );
	end
	
	LKM.syncGui.drop:SelectValue( LKM.syncActiveList );
	
	--Get active sync list
	local syncList = LKM.GetActiveSyncList();
	if (syncList ~= nil) then
	
		--Update sync list
		LKM.FillList( LKM.syncGui.list, syncList );
	end
	
end

function LKM.SyncGui_Drop_OnValueChanged( drop )

	--Switch to selected list
	LKM.SetActiveSyncList( drop:GetSelectedText() );
end

function LKM.SyncGui_Apply_OnClick( button )

	--Confirm with user	
	PrimeGui.ShowConfirmFrame( "This will copy all the synced lists and overwrite your own "..
		"lists with matching names. Are you sure?",
		LKM.SyncGui_ApplyList_Accept, nil );
	
end

function LKM.SyncGui_ApplyList_Accept()

	--Get save table
	local save = LKM.GetSave();
	
	--Iterate sync lists
	for name,syncList in pairs(LKM.syncLists) do
		
		--Insert/overwrite active list
		save.lists[ name ] = CopyTable(syncList);
	end
	
	LKM.UpdateGui();
	
end

function LKM.SyncGui_Close_OnClick( button )

	LKM.syncGui:Hide();
end


--List manipulation
--====================================================================

function LKM.GetActiveListName()

	--Return name of currently active list
	local save = LKM.GetSave();
	return save.activeList;
	
end

function LKM.GetActiveList()

	--Return currently active list
	local save = LKM.GetSave();
	return save.lists[ save.activeList ];
end

function LKM.SetActiveList( name )

	--Check if valid name
	local save = LKM.GetSave();
	if (save.lists[ name ] == nil) then
		return;
	end
	
	--Switch to given list
	save.activeList = name;
	LKM.UpdateGui();
end

function LKM.Drop_OnValueChanged( drop )

	--Switch to selected list
	LKM.SetActiveList( drop:GetSelectedText() );
end


function LKM.Top_OnClick( button )

	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		return;
	end
	
	--Must not be on top
	if (index == 1) then return end;
	
	--Move player up one spot
	local value = list[ index ];
	table.remove( list, index );
	table.insert( list, 1, value );
	
	LKM.UpdateGui();
	LKM.gui.list:SelectIndex( 1 );
end

function LKM.Up_OnClick( button )

	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		return;
	end
	
	--Must not be on top
	if (index == 1) then return end;
	
	--Move player up one spot
	local value = list[ index ];
	table.remove( list, index );
	table.insert( list, index-1, value );
	
	LKM.UpdateGui();
	LKM.gui.list:SelectIndex( index-1 );
end

function LKM.Down_OnClick( button )

	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		return;
	end
	
	--Must not be on the bottom
	if (index == table.getn(list)) then return end;
	
	--Move player down one spot
	local value = list[ index ];
	table.remove( list, index );
	table.insert( list, index+1, value );
	
	LKM.UpdateGui();
	LKM.gui.list:SelectIndex( index+1 );
end

function LKM.Bottom_OnClick( button )

	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		return;
	end
	
	--Must not be on the bottom
	if (index == table.getn(list)) then return end;
	
	--Move player down one spot
	local value = list[ index ];
	table.remove( list, index );
	table.insert( list, table.getn(list)+1, value );
	
	LKM.UpdateGui();
	LKM.gui.list:SelectIndex( table.getn(list) );
end

function LKM.Insert_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "Name of player to insert:",
		LKM.Insert_Accept );
end

function LKM.Insert_Accept( value )
	
	--Check valid value
	if ((value == nil) or (value == "")) then
		return;
	end
	
	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		index = 1;
	end
	
	--Insert new player
	table.insert( list, index, value );
	
	LKM.UpdateGui();
end

function LKM.Remove_OnClick( button )
	
	--Check valid selection
	local value = LKM.gui.list:GetSelectedValue();
	if (value) then

		--Confirm with player
		PrimeGui.ShowConfirmFrame( "Are you sure you want to remove player '"..value.text.."'?",
			LKM.Remove_Accept, nil, value.text );
	end
end

function LKM.Remove_Accept( text )

	--Get active list and selected index
	local list = LKM.GetActiveList();
	local index = LKM.gui.list:GetSelectedIndex();
	local value = LKM.gui.list:GetSelectedValue();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		return;
	end
	
	--Selection must still match remove request
	if ((value == nil) or (value.text ~= text)) then
		return;
	end
	
	--Remove player
	table.remove( list, index );
	
	LKM.UpdateGui();
	
end

function LKM.Save_OnClick( button )

	ReloadUI();
	
end

function LKM.Sync_OnClick( button )

	--Ask user for list name
	PrimeGui.ShowInputFrame( "Name of the player to get the list from",
		LKM.Sync_Accept );
end

function LKM.Sync_Accept( value )

	--Initiate sync
	if (value and value ~= "") then
		LKM.Sync( value );
	end
end

function LKM.Config_OnClick( button )

	LKM.ShowConfigGui();
end


--Syncing
--===================================================

function LKM.Sync( target )
	
	--Notify user
	LKM.Print( "Sending sync request to "..target.."...");
	
	--Init sync info
	LKM.syncOn = true;
	LKM.syncTarget = target;
	LKM.syncId = LKM.syncId + 1;
	
	--Init sync list
	LKM.syncActiveList = nil;
	PrimeUtil.ClearTableKeys( LKM.syncLists );
	
	--Send sync request with our sync id
	SendAddonMessage( LKM.SYNC_PREFIX, "SyncRequest_"..LKM.syncTarget..LKM.syncId,
		"WHISPER", target );
end

function LKM.OnEvent_CHAT_MSG_ADDON( prefix, msg, channel, sender )

	if (prefix ~= LKM.SYNC_PREFIX) then
		return;
	end
	
	--LKM.Print( "Addon prefix: "..tostring(prefix).." Message: "..tostring(msg) );
	
	local cmd, arg1, arg2 = strsplit( "_", msg );
	
	if (cmd == "SyncRequest") then
		
		--Notify user
		LKM.Print( "Received sync request by "..sender..".");
		
		--Iterate all lists
		for name,list in pairs(LKM.GetSave().lists) do
		
			--Return list header with matching sync id
			SendAddonMessage( LKM.SYNC_PREFIX, "SyncList_"..arg1.."_"..tostring(name),
				"WHISPER", sender );
			
			--Iterate active list
			for i=1,table.getn(list) do
			
				--Return list item with a matching sync id
				SendAddonMessage( LKM.SYNC_PREFIX, "Sync_"..arg1.."_"..tostring(list[i]),
					"WHISPER", sender );
			end
		end
		
		--Finish sync with a matching end id
		SendAddonMessage( LKM.SYNC_PREFIX, "SyncEnd_"..arg1,
			"WHISPER", sender );
	
	elseif (cmd == "SyncList" and LKM.syncOn) then
	
		--Check if sync id matches
		if (arg1 == LKM.syncTarget..LKM.syncId) then
		
			--Create new list and make active
			LKM.syncLists[ arg2 ] = {};
			LKM.syncActiveList = arg2;
			
		end
	
	elseif (cmd == "Sync" and LKM.syncOn) then
		
		--Check if sync id matches
		if (arg1 == LKM.syncTarget..LKM.syncId) then
		
			--Check that active list exists
			local syncList = LKM.GetActiveSyncList();
			if (syncList ~= nil) then
				
				--Add list item
				table.insert( syncList, arg2 );
			end
		end
	
	
	elseif (cmd == "SyncEnd" and LKM.syncOn) then
	
		--Check if sync id matches
		if (arg1 == LKM.syncTarget..LKM.syncId) then
			
			--Sync finished
			LKM.syncOn = false;
			LKM.UpdateSyncGui();
			LKM.syncGui:Show();
		end
	end
end


--Whisper auto-report
--===================================================

function LKM.OnEvent_CHAT_MSG_WHISPER( msg, sender )

	--Get save table
	local save = LKM.GetSave();
	
	--Check if message matches list request
	if (msg == LKM.WHISPER) then
	
		--Notify user
		LKM.Print( "Whispering Loot List to "..sender.."...");
		
		--Reply with list header
		SendChatMessage( LKM.PRINT_PREFIX.." === "..save.activeList.." ===", "WHISPER", nil, sender );
		
		--Iterate active list
		local list = LKM.GetActiveList();
		for i=1,table.getn(list) do
		
			--Reply with our data
			SendChatMessage( LKM.PRINT_PREFIX.." "..tostring(i)..". "..tostring(list[i]), "WHISPER", nil, sender );
		end
	end
end

function LKM.InChatFilter( self, event, msg )

	--Filter sync request whispers
	if (msg == LKM.WHISPER)
	then return true;
	else return false;
	end
end

function LKM.OutChatFilter( self, event, msg )

	--Length of the prefix string
	local prefixLen = strlen( LKM.PRINT_PREFIX );

	--Filter messages starting with prefix
	if (strsub( msg, 1, prefixLen ) == LKM.PRINT_PREFIX)
	then return true;
	else return false;
	end
end

function LKM.EnableChatFilter()
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER",			LKM.InChatFilter );
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER_INFORM",		LKM.OutChatFilter );
end

function LKM.DisableChatFilter()
	ChatFrame_RemoveMessageEventFilter( "CHAT_MSG_WHISPER",			LKM.InChatFilter );
	ChatFrame_RemoveMessageEventFilter( "CHAT_MSG_WHISPER_INFORM",	LKM.OutChatFilter );
end


--Entry point
--===================================================

function LKM.OnEvent( frame, event, ... )
  
  local funcName = "OnEvent_" .. event;
  local func = LKM[ funcName ];
  if (func) then func(...) end
  
end

function LKM.OnEvent_PLAYER_LOGIN()

	--Init variables
	LKM.syncOn = false;
	LKM.syncTarget = "Target";
	LKM.syncId = 0;
	LKM.syncLists = {};
	LKM.syncActiveList = nil;
	
	--Start with default save if missing
	if (LKM.GetSave() == nil) then
		LKM.ResetSave();
	end
	
	--Upgrade save from old version
	LKM.Upgrade();
	
	--Create new minimap button if missing
	if (LKM.button == nil) then
		LKM.button = PrimeGui.MinimapButton_New( LKM.PREFIX.."MinimapButton" );
	end
	
	--Create new gui if missing
	if (LKM.gui == nil) then
		LKM.gui = LKM.CreateGui();
		LKM.gui:SetPoint( "CENTER", 0,0 );
		LKM.gui:Hide();
	end
	
	--Create new sync gui if missing
	if (LKM.syncGui == nil) then
		LKM.syncGui = LKM.CreateSyncGui();
		LKM.syncGui:SetPoint( "CENTER", 0,0 );
		LKM.syncGui:Hide();
	end
	
	--Create new config gui if missing
	if (LKM.configGui == nil) then
		LKM.configGui = LKM.CreateConfigGui();
	end
	
	--Register communication events
	LKM.frame:RegisterEvent( "CHAT_MSG_WHISPER" );
	LKM.frame:RegisterEvent( "CHAT_MSG_ADDON" );
	
	--Filter addon whispers
	if (LKM.GetSave().filterEnabled) then
		LKM.EnableChatFilter();
	end
	
	--First update
	LKM.UpdateGui();
	
end

function LKM.Init()

	--Register event for initialization (save isn't loaded until PLAYER_LOGIN!!!)
	LKM.frame = CreateFrame( "Frame", LKM.PREFIX.."EventFrame" );
	LKM.frame:SetScript( "OnEvent", LKM.OnEvent );
	LKM.frame:RegisterEvent( "PLAYER_LOGIN" );
	
end

LKM.Init();
