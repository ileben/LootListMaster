--[[

LootListMaster
Author: Ivan Leben

--]]

LootListMaster = {}

LootListMaster.VERSION = "0.1";

LootListMaster.PREFIX = "LootListMaster";
LootListMaster.PRINT_PREFIX = "<LootListMaster>";
LootListMaster.WHISPER = "!lootlist";

LootListMaster.DEFAULT_SAVE =
{
	version = LootListMaster.VERSION;
	
	lists =
	{
		Default =
		{
		},
	},
	
	activeList = "Default";
	filterEnabled = true;
};

local LLM = LootListMaster;

--Output
--===================================================

function LLM.Print( msg )
  print( "|cffffff00" .. LLM.PRINT_PREFIX .. " |cffffffff"..msg );
end

function LLM.Error (msg)
  print( "|cffffff00" .. LLM.PRINT_PREFIX .. " |cffff2222"..msg );
end

--Save management
--===================================================

function LLM.ResetSave()

	LootListMasterSave = CopyTable( LLM.DEFAULT_SAVE );
end

function LLM.GetSave()

	return LootListMasterSave;
end

--Slash handler
--===================================================


function LLM.SlashHandler( msg )

	if (msg == "") then

		--Empty command
		LLM.UpdateGui();
		LLM.ShowGui();
		
	else
	
		--Parametric commands
		local cmd, param = strsplit( " ", msg );
		if (cmd == "reset") then
		
			LLM.ResetSave();
			LLM.Print( "LLM settings reset." );
		end
	end
end


SLASH_LootListMaster1 = "/lootlistmaster";
SLASH_LootListMaster2 = "/llm";
SlashCmdList["LootListMaster"] = LLM.SlashHandler;


--Player list
--===================================================

function LLM.PlayerList_New( name )

	local f = PrimeGui.List_New( name );
	
	f.UpdateItem = LLM.PlayerList_UpdateItem;
	
	return f;
end

function LLM.PlayerList_UpdateItem( frame, item, value, selected  )

	PrimeGui.List_UpdateItem( frame, item, value, selected );
	
	if (value.color) then
	
		local c = value.color;
		item.label:SetTextColor( c.r, c.g, c.b, c.a );
	end
	
end

--Gui
--===================================================

function LLM.ShowGui()
	
	LLM.gui:Show();
end

function LLM.HideGui()

	LLM.gui:Hide();
end


function LLM.CreateGui()

	--Window
	local w = PrimeGui.Window_New("LootListMaster", "LootListMaster", true, true);
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
	local list = LLM.PlayerList_New( "LootListMaster".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Dropdown
	local drop = PrimeGui.Drop_New( "LootListMaster.Dropdown" );
	drop:Init();
	drop:SetParent( w.container );
	drop:SetPoint( "TOPRIGHT", 0, 0 );
	drop:SetWidth( 130 );
	drop:SetLabelText( "Active list:" );
	drop.OnValueChanged = LLM.Drop_OnValueChanged;
	drop.window = w;
	w.drop = drop;
	
	local btnNewList = PrimeGui.Button_New( "LootListMaster.ButtonNewList" );
	btnNewList:RegisterScript( "OnClick", LLM.NewList_OnClick );
	btnNewList:SetParent( w.container );
	btnNewList:SetPoint( "TOPRIGHT", drop, "BOTTOMRIGHT", 0, -5 );
	btnNewList:SetText( "New List" );
	btnNewList:SetWidth( 130 );
	
	local btnDeleteList = PrimeGui.Button_New( "LootListMaster.ButtonDeleteList" );
	btnDeleteList:RegisterScript( "OnClick", LLM.DeleteList_OnClick );
	btnDeleteList:SetParent( w.container );
	btnDeleteList:SetPoint( "TOPRIGHT", btnNewList, "BOTTOMRIGHT", 0, -5 );
	btnDeleteList:SetText( "Delete List" );
	btnDeleteList:SetWidth( 130 );
	
	local btnRenameList = PrimeGui.Button_New( "LootListMaster.ButtonRenameList" );
	btnRenameList:RegisterScript( "OnClick", LLM.RenameList_OnClick );
	btnRenameList:SetParent( w.container );
	btnRenameList:SetPoint( "TOPRIGHT", btnDeleteList, "BOTTOMRIGHT", 0, -5 );
	btnRenameList:SetText( "Rename List" );
	btnRenameList:SetWidth( 130 );
	
	local btnSync = PrimeGui.Button_New( "LootListMaster.ButtonSync" );
	btnSync:RegisterScript( "OnClick", LLM.Sync_OnClick );
	btnSync:SetParent( w.container );
	btnSync:SetPoint( "TOPRIGHT", btnRenameList, "BOTTOMRIGHT", 0, -5 );
	btnSync:SetText( "Sync" );
	btnSync:SetWidth( 130 );
	
	--Buttons
	local btnTop = PrimeGui.Button_New( "LootListMaster.ButtonTop" );
	btnTop:RegisterScript( "OnClick", LLM.Top_OnClick );
	btnTop:SetParent( w.container );
	btnTop:SetPoint( "TOPRIGHT", btnSync, "BOTTOMRIGHT", 0, -20 );
	btnTop:SetText( "Top" );
	btnTop:SetWidth( 130 );
	
	local btnUp = PrimeGui.Button_New( "LootListMaster.ButtonUp" );
	btnUp:RegisterScript( "OnClick", LLM.Up_OnClick );
	btnUp:SetParent( w.container );
	btnUp:SetPoint( "TOPRIGHT", btnTop, "BOTTOMRIGHT", 0, -5  );
	btnUp:SetText( "Up" );
	btnUp:SetWidth( 130 );
	
	local btnDown = PrimeGui.Button_New( "LootListMaster.ButtonDown" );
	btnDown:RegisterScript( "OnClick", LLM.Down_OnClick );
	btnDown:SetParent( w.container );
	btnDown:SetPoint( "TOPRIGHT", btnUp, "BOTTOMRIGHT", 0, -5  );
	btnDown:SetText( "Down" );
	btnDown:SetWidth( 130 );
	
	local btnBottom = PrimeGui.Button_New( "LootListMaster.ButtonBottom" );
	btnBottom:RegisterScript( "OnClick", LLM.Bottom_OnClick );
	btnBottom:SetParent( w.container );
	btnBottom:SetPoint( "TOPRIGHT", btnDown, "BOTTOMRIGHT", 0, -5  );
	btnBottom:SetText( "Bottom" );
	btnBottom:SetWidth( 130 );
	
	local btnInsert = PrimeGui.Button_New( "LootListMaster.ButtonInsert" );
	btnInsert:RegisterScript( "OnClick", LLM.Insert_OnClick );
	btnInsert:SetParent( w.container );
	btnInsert:SetPoint( "TOPRIGHT", btnBottom, "BOTTOMRIGHT", 0, -30 );
	btnInsert:SetText( "Insert" );
	btnInsert:SetWidth( 130 );
	
	local btnRemove = PrimeGui.Button_New( "LootListMaster.ButtonRemove" );
	btnRemove:RegisterScript( "OnClick", LLM.Remove_OnClick );
	btnRemove:SetParent( w.container );
	btnRemove:SetPoint( "TOPRIGHT", btnInsert, "BOTTOMRIGHT", 0, -5 );
	btnRemove:SetText( "Remove" );
	btnRemove:SetWidth( 130 );
	
	return w;
end

function LLM.UpdateGui()

	--Fill dropdown with list names
	LLM.gui.drop:RemoveAllItems();
	
	for name,list in pairs(LLM.GetSave().lists) do
		LLM.gui.drop:AddItem( name, name );
	end
	
	LLM.gui.drop:SelectValue( LLM.GetSave().activeList );
	
	--Store list state
	local index = LLM.gui.list:GetSelectedIndex();
	local offset = LLM.gui.list:GetScrollOffset();
	
	LLM.FillList( LLM.gui.list, LLM.GetActiveList() );
	
	--Restore list state
	LLM.gui.list:SelectIndex( index );
	LLM.gui.list:SetScrollOffset( offset );
	
end

function LLM.FillList( guiList, playerList )

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

function LLM.CreateSyncGui()

	--Window
	local w = PrimeGui.Window_New("LootListSync", "Sync", true, false);
	w:Init();
	w:SetParent( UIParent );
	w:SetWidth( 300 );
	w:SetHeight( 400 );
	
	--Label
    local txt = w:CreateFontString( "LootListMaster.SyncGui.Text", "OVERLAY", "GameFontNormal" );
    txt:SetTextColor( 1, 1, 0, 1 );
    txt:SetPoint( "TOPLEFT", w.container, "TOPLEFT", 0, 0 );
    txt:SetPoint( "TOPRIGHT", w.container, "TOPRIGHT", 0, 0 );
	txt:SetJustifyH( "CENTER" );
	txt:SetJustifyV( "TOP" );
    txt:SetHeight( 40 );
    txt:SetWordWrap( true );
    txt:SetText( "Message" );
	w.text = txt;
	
	--List background
	local bg = CreateFrame( "Frame", nil, w.container );
	bg:SetPoint( "BOTTOMLEFT", 0,30 );
	bg:SetPoint( "TOPRIGHT", 0,-30 );
	
	bg:SetBackdrop(
	  {bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	   edgeFile = "Interface/DialogFrame/UI-Tooltip-Border",
	   tile = true, tileSize = 32, edgeSize = 32,
	   insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	 
	bg:SetBackdropColor(0,0,0,0.8);
	
	--List box
	local list = LLM.PlayerList_New( "LootListMaster".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Cancel button
	local btnCancel = PrimeGui.Button_New( "LootListMaster.SyncGui.Cancel" );
	btnCancel:Init();
	btnCancel:SetParent( w.container );
	btnCancel:SetText( "Cancel" );
	btnCancel:SetPoint( "BOTTOMRIGHT", 0,0 );
	btnCancel:RegisterScript( "OnClick", LLM.SyncGui_Cancel_OnClick );
	btnCancel.window = w;
	
	--Accept button
	local btnAccept = PrimeGui.Button_New( "LootListMaster.SyncGui.Accept" );
	btnAccept:Init();
	btnAccept:SetParent( w.container );
	btnAccept:SetText( "Accept" );
	btnAccept:SetPoint( "BOTTOMRIGHT", btnCancel, "BOTTOMLEFT", -10,0 );
	btnAccept:RegisterScript( "OnClick", LLM.SyncGui_Accept_OnClick );
	btnAccept.window = w;
	
	return w;
	
end

function LLM.UpdateSyncGui()

	--Set message to match sync target
	LLM.syncGui.text:SetText( "Sync received from "..LootListMaster.syncTarget );
	
	--Update sync list
	LLM.FillList( LLM.syncGui.list, LLM.syncList );
	
end

function LLM.SyncGui_Accept_OnClick( button )

	--Clear active list
	local list = LLM.GetActiveList();
	PrimeUtil.ClearTable( list );
	
	--Insert sync data into active list
	for i=1,table.getn( LLM.syncList ) do
		table.insert( list, LLM.syncList[i] );
	end
	
	LLM.UpdateGui();
	LLM.syncGui:Hide();
end

function LLM.SyncGui_Cancel_OnClick( button )

	LLM.syncGui:Hide();
end


--List manipulation
--====================================================================

function LLM.GetActiveList()

	--Return currently active list
	local save = LLM.GetSave();
	return save.lists[ save.activeList ];
end

function LLM.SetActiveList( name )

	--Check if valid name
	local save = LLM.GetSave();
	if (save.lists[ name ] == nil) then
		return;
	end
	
	--Switch to given list
	save.activeList = name;
	LLM.UpdateGui();
end

function LLM.Drop_OnValueChanged( drop )

	--Switch to selected list
	LLM.SetActiveList( drop:GetSelectedText() );
end

function LLM.NewList_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "New list name:", LLM.NewList_Accept);	
end

function LLM.NewList_Accept( name )

	--Check for valid name
	if (name and name ~= "") then
	
		--Create new list and switch to it
		local save = LLM.GetSave();
		save.lists[ name ] = {};
		LLM.SetActiveList( name );
	end
end

function LLM.DeleteList_OnClick( button )

	--Get save table
	local save = LLM.GetSave();
	
	--Confirm with user
	local activeListName = save.activeList;
	PrimeGui.ShowConfirmFrame( "Are you sure you want to delete list '"..activeListName.."'?",
		LLM.DeleteList_Accept, nil, activeListName );
end

function LLM.DeleteList_Accept( name )

	--Get save table
	local save = LLM.GetSave();
	
	--Check if the last list
	if (PrimeUtil.CountTableKeys( save.lists ) <= 1) then
		LLM.Error( "Cannot delete your last list!" );
		return;
	end
	
	--Remove named list
	save.lists[ name ] = nil;
	
	--Switch to first remaining list
	for name,list in pairs(save.lists) do
		LLM.SetActiveList(name);
		break;
	end
end

function LLM.RenameList_OnClick( button )

	--Get save table
	local save = LLM.GetSave();
	
	--Ask user for new name
	local activeListName = save.activeList;
	PrimeGui.ShowInputFrame( "New name for list '"..activeListName.."':",
		LLM.RenameList_Accept, nil, activeListName );
end

function LLM.RenameList_Accept( newName, oldName )

	--Get save table
	local save = LLM.GetSave();
	
	--Check for valid name
	if (newName == nil or newName == "" or newName == oldName) then
		return;
	end
	
	--List must still exist
	if (save.lists[ oldName ] == nil) then
		LLM.Error( "List does not exist anymore!" );
		return;
	end
	
	--New name must not be taken
	if (save.lists[ newName ] ~= nil) then
		LLM.Error( "This list name is already taken!" );
		return;
	end
	
	--Change name of the list and switch to it
	save.lists[ newName ] = save.lists[ oldName ];
	save.lists[ oldName ] = nil;
	LLM.SetActiveList( newName );

end


function LLM.Sync_OnClick( button )

	--Ask user for list name
	PrimeGui.ShowInputFrame( "Name of the player to get the list from",
		LLM.Sync_Accept );
end

function LLM.Sync_Accept( value )

	--Initiate sync
	if (value and value ~= "") then
		LLM.Sync( value );
	end
end


function LLM.Top_OnClick( button )

	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	
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
	
	LLM.UpdateGui();
	LLM.gui.list:SelectIndex( 1 );
end

function LLM.Up_OnClick( button )

	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	
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
	
	LLM.UpdateGui();
	LLM.gui.list:SelectIndex( index-1 );
end

function LLM.Down_OnClick( button )

	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	
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
	
	LLM.UpdateGui();
	LLM.gui.list:SelectIndex( index+1 );
end

function LLM.Bottom_OnClick( button )

	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	
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
	
	LLM.UpdateGui();
	LLM.gui.list:SelectIndex( table.getn(list) );
end

function LLM.Insert_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "Name of player to insert:",
		LLM.Insert_Accept );
end

function LLM.Insert_Accept( value )
	
	--Check valid value
	if ((value == nil) or (value == "")) then
		return;
	end
	
	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		index = 1;
	end
	
	--Insert new player
	table.insert( list, index, value );
	
	LLM.UpdateGui();
end

function LLM.Remove_OnClick( button )
	
	--Check valid selection
	local value = LLM.gui.list:GetSelectedValue();
	if (value) then

		--Confirm with player
		PrimeGui.ShowConfirmFrame( "Are you sure you want to remove player '"..value.text.."'?",
			LLM.Remove_Accept, nil, value.text );
	end
end

function LLM.Remove_Accept( text )

	--Get active list and selected index
	local list = LLM.GetActiveList();
	local index = LLM.gui.list:GetSelectedIndex();
	local value = LLM.gui.list:GetSelectedValue();
	
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
	
	LLM.UpdateGui();
	
end


--Syncing
--===================================================

function LLM.Sync( target )
	
	--Notify user
	LLM.Print( "Sending sync request to "..target.."...");
	
	--Init sync data
	LLM.syncOn = true;
	LLM.syncTarget = target;
	LLM.syncId = LLM.syncId + 1;
	PrimeUtil.ClearTable( LLM.syncList );
	
	--Send sync request with our sync id
	SendAddonMessage( LLM.PREFIX, "SyncRequest_"..LLM.syncTarget..LLM.syncId,
		"WHISPER", target );
end

function LLM.OnEvent_CHAT_MSG_ADDON( prefix, msg, channel, sender )

	if (prefix ~= LLM.PREFIX) then
		return;
	end
	
	--LLM.Print( "Addon prefix: "..tostring(prefix).." Message: "..tostring(msg) );
	
	local cmd, arg1, arg2 = strsplit( "_", msg );
	
	if (cmd == "SyncRequest") then
		
		--Notify user
		LLM.Print( "Received sync request by "..sender..".");
		
		--Iterate active list
		local list = LLM.GetActiveList();
		for i=1,table.getn(list) do
		
			--Return list item with a matching sync id
			SendAddonMessage( LLM.PREFIX, "Sync_"..arg1.."_"..tostring(list[i]),
				"WHISPER", sender );
		end
		
		--Finish sync with a matching end id
		SendAddonMessage( LLM.PREFIX, "SyncEnd_"..arg1,
			"WHISPER", sender );
	
	
	elseif (cmd == "Sync" and LLM.syncOn) then
		
		--Check if sync id matches
		if (arg1 == LLM.syncTarget..LLM.syncId) then
		
			--Add list item
			table.insert( LLM.syncList, arg2 );
		end
	
	
	elseif (cmd == "SyncEnd" and LLM.syncOn) then
	
		--Check if sync id matches
		if (arg1 == LLM.syncTarget..LLM.syncId) then
			
			--Sync finished
			LLM.syncOn = false;
			LLM.UpdateSyncGui();
			LLM.syncGui:Show();
		end
	end
end

function LLM.SyncReport()
	
	LLM.UpdateSyncGui();
	LLM.syncGui.text:SetText( "Sync received from '"..LLM.syncTarget.."'" );
	LLM.syncGui:Show();
end

--Whisper auto-report
--===================================================

function LLM.OnEvent_CHAT_MSG_WHISPER( msg, sender )

	--Get save table
	local save = LLM.GetSave();
	
	--Check if message matches list request
	if (msg == LLM.WHISPER) then
	
		--Notify user
		LLM.Print( "Whispering Loot List to "..sender.."...");
		
		--Reply with list header
		SendChatMessage( LLM.PRINT_PREFIX.." === "..save.activeList.." ===", "WHISPER", nil, sender );
		
		--Iterate active list
		local list = LLM.GetActiveList();
		for i=1,table.getn(list) do
		
			--Reply with our data
			SendChatMessage( LLM.PRINT_PREFIX.." "..tostring(i)..". "..tostring(list[i]), "WHISPER", nil, sender );
		end
	end
end

function LLM.ChatFilter( self, event, msg )

	--Length of the prefix string
	local prefixLen = strlen( LLM.PRINT_PREFIX );

	--Filter messages starting with prefix
	if (strsub( msg, 1, prefixLen ) == LLM.PRINT_PREFIX)
	then return true;
	else return false;
	end
end

function LLM.EnableChatFilter()
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LLM.ChatFilter );
end

function LLM.DisableChatFilter()
	ChatFrame_RemoveMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LLM.ChatFilter );
end


--Entry point
--===================================================

function LLM.OnEvent( frame, event, ... )
  
  local funcName = "OnEvent_" .. event;
  local func = LLM[ funcName ];
  if (func) then func(...) end
  
end

function LLM.Init()
	
	--Init variables
	LLM.syncOn = false;
	LLM.syncTarget = "Target";
	LLM.syncId = 0;
	LLM.syncList = {};
	
	--Start with default save if missing
	if (LLM.GetSave() == nil) then
		LLM.ResetSave();
	end
	
	--Create new gui if missing
	if (LLM.gui == nil) then
		LLM.gui = LLM.CreateGui();
		LLM.gui:SetPoint( "CENTER", 0,0 );
		LLM.gui:Hide();
	end
	
	--Create new sync gui if missing
	if (LLM.syncGui == nil) then
		LLM.syncGui = LLM.CreateSyncGui();
		LLM.syncGui:SetPoint( "CENTER", 0,0 );
		LLM.syncGui:Hide();
	end
	
	--Register whisper event
	LLM.gui:SetScript( "OnEvent", LLM.OnEvent );
	LLM.gui:RegisterEvent( "CHAT_MSG_WHISPER" );
	LLM.gui:RegisterEvent( "CHAT_MSG_ADDON" );
	
	--Filter addon whispers
	if (LLM.GetSave().filterEnabled) then
		LLM.EnableChatFilter();
	end
	
	--First update
	LLM.UpdateGui();
	
end

LLM.Init();
