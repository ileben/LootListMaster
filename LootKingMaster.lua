--[[

LootKingMaster
Author: Ivan Leben

--]]

LootKingMaster = {}

LootKingMaster.VERSION = "0.1";

LootKingMaster.PREFIX = "LootKingMaster";
LootKingMaster.PRINT_PREFIX = "<LootKingMaster>";
LootKingMaster.SYNC_PREFIX = "LootKingSync";
LootKingMaster.WHISPER = "!lootking";

LootKingMaster.DEFAULT_SAVE =
{
	version = LootKingMaster.VERSION;
	
	lists =
	{
		Default =
		{
		},
	},
	
	activeList = "Default";
	filterEnabled = true;
};

local LKM = LootKingMaster;

--Output
--===================================================

function LKM.Print( msg )
  print( "|cffffff00" .. LKM.PRINT_PREFIX .. " |cffffffff"..msg );
end

function LKM.Error (msg)
  print( "|cffffff00" .. LKM.PRINT_PREFIX .. " |cffff2222"..msg );
end

--Save management
--===================================================

function LKM.ResetSave()

	LootKingMasterSave = CopyTable( LKM.DEFAULT_SAVE );
end

function LKM.GetSave()

	return LootKingMasterSave;
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
	
	local btnNewList = PrimeGui.Button_New( "LootKingMaster.ButtonNewList" );
	btnNewList:RegisterScript( "OnClick", LKM.NewList_OnClick );
	btnNewList:SetParent( w.container );
	btnNewList:SetPoint( "TOPRIGHT", drop, "BOTTOMRIGHT", 0, -5 );
	btnNewList:SetText( "New List" );
	btnNewList:SetWidth( 130 );
	
	local btnDeleteList = PrimeGui.Button_New( "LootKingMaster.ButtonDeleteList" );
	btnDeleteList:RegisterScript( "OnClick", LKM.DeleteList_OnClick );
	btnDeleteList:SetParent( w.container );
	btnDeleteList:SetPoint( "TOPRIGHT", btnNewList, "BOTTOMRIGHT", 0, -5 );
	btnDeleteList:SetText( "Delete List" );
	btnDeleteList:SetWidth( 130 );
	
	local btnRenameList = PrimeGui.Button_New( "LootKingMaster.ButtonRenameList" );
	btnRenameList:RegisterScript( "OnClick", LKM.RenameList_OnClick );
	btnRenameList:SetParent( w.container );
	btnRenameList:SetPoint( "TOPRIGHT", btnDeleteList, "BOTTOMRIGHT", 0, -5 );
	btnRenameList:SetText( "Rename List" );
	btnRenameList:SetWidth( 130 );
	
	local btnSync = PrimeGui.Button_New( "LootKingMaster.ButtonSync" );
	btnSync:RegisterScript( "OnClick", LKM.Sync_OnClick );
	btnSync:SetParent( w.container );
	btnSync:SetPoint( "TOPRIGHT", btnRenameList, "BOTTOMRIGHT", 0, -5 );
	btnSync:SetText( "Sync" );
	btnSync:SetWidth( 130 );
	
	--Buttons
	local btnTop = PrimeGui.Button_New( "LootKingMaster.ButtonTop" );
	btnTop:RegisterScript( "OnClick", LKM.Top_OnClick );
	btnTop:SetParent( w.container );
	btnTop:SetPoint( "TOPRIGHT", btnSync, "BOTTOMRIGHT", 0, -20 );
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
	
	--Filter checkbox
	local chkFilter = PrimeGui.Checkbox_New( LKM.PREFIX.."ChkFilter" );
	chkFilter:SetParent( w.container );
	chkFilter:SetText( "Enable chat filter" );
	chkFilter:SetPoint( "BOTTOMRIGHT", 0, 0 );
	chkFilter:SetWidth( 130 );
	chkFilter.OnValueChanged = LKM.ChkFilter_OnValueChanged;
	chkFilter.window = w;
	w.chkFilter = chkFilter;
	
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
	
	--Update filter checkbox
	LKM.gui.chkFilter:SetChecked( LKM.GetSave().filterEnabled );
	
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

function LKM.NewList_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "New list name:", LKM.NewList_Accept);	
end

function LKM.NewList_Accept( name )

	--Check for valid name
	if (name and name ~= "") then
	
		--Create new list and switch to it
		local save = LKM.GetSave();
		save.lists[ name ] = {};
		LKM.SetActiveList( name );
	end
end

function LKM.DeleteList_OnClick( button )

	--Get save table
	local save = LKM.GetSave();
	
	--Confirm with user
	local activeListName = save.activeList;
	PrimeGui.ShowConfirmFrame( "Are you sure you want to delete list '"..activeListName.."'?",
		LKM.DeleteList_Accept, nil, activeListName );
end

function LKM.DeleteList_Accept( name )

	--Get save table
	local save = LKM.GetSave();
	
	--Check if the last list
	if (PrimeUtil.CountTableKeys( save.lists ) <= 1) then
		LKM.Error( "Cannot delete your last list!" );
		return;
	end
	
	--Remove named list
	save.lists[ name ] = nil;
	
	--Switch to first remaining list
	for name,list in pairs(save.lists) do
		LKM.SetActiveList(name);
		break;
	end
end

function LKM.RenameList_OnClick( button )

	--Get save table
	local save = LKM.GetSave();
	
	--Ask user for new name
	local activeListName = save.activeList;
	PrimeGui.ShowInputFrame( "New name for list '"..activeListName.."':",
		LKM.RenameList_Accept, nil, activeListName );
end

function LKM.RenameList_Accept( newName, oldName )

	--Get save table
	local save = LKM.GetSave();
	
	--Check for valid name
	if (newName == nil or newName == "" or newName == oldName) then
		return;
	end
	
	--List must still exist
	if (save.lists[ oldName ] == nil) then
		LKM.Error( "List does not exist anymore!" );
		return;
	end
	
	--New name must not be taken
	if (save.lists[ newName ] ~= nil) then
		LKM.Error( "This list name is already taken!" );
		return;
	end
	
	--Change name of the list and switch to it
	save.lists[ newName ] = save.lists[ oldName ];
	save.lists[ oldName ] = nil;
	LKM.SetActiveList( newName );

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

function LKM.ChkFilter_OnValueChanged( check )

	if (check:GetChecked()) then
		LKM.EnableChatFilter();
		LKM.GetSave().filterEnabled = true;
		LKM.Print( "Chat filter |cFF00FF00enabled." );
	else
		LKM.DisableChatFilter();
		LKM.GetSave().filterEnabled = false;
		LKM.Print( "Chat filter |cFFFF0000disabled." );
	end
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

function LKM.ChatFilter( self, event, msg )

	--Length of the prefix string
	local prefixLen = strlen( LKM.PRINT_PREFIX );

	--Filter messages starting with prefix
	if (strsub( msg, 1, prefixLen ) == LKM.PRINT_PREFIX)
	then return true;
	else return false;
	end
end

function LKM.EnableChatFilter()
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LKM.ChatFilter );
end

function LKM.DisableChatFilter()
	ChatFrame_RemoveMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LKM.ChatFilter );
end


--Entry point
--===================================================

function LKM.OnEvent( frame, event, ... )
  
  local funcName = "OnEvent_" .. event;
  local func = LKM[ funcName ];
  if (func) then func(...) end
  
end

function LKM.Init()
	
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
	
	--Register whisper event
	LKM.gui:SetScript( "OnEvent", LKM.OnEvent );
	LKM.gui:RegisterEvent( "CHAT_MSG_WHISPER" );
	LKM.gui:RegisterEvent( "CHAT_MSG_ADDON" );
	
	--Filter addon whispers
	if (LKM.GetSave().filterEnabled) then
		LKM.EnableChatFilter();
	end
	
	--First update
	LKM.UpdateGui();
	
end

LKM.Init();
