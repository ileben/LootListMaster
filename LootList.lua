--[[

LootList
Author: Ivan Leben

--]]

LootList = {}

LootList.VERSION = "0.1";

LootList.PREFIX = "LootList";
LootList.WHISPER = "!lootlist";
LootList.PRINT_PREFIX = "<LootList>";

LootList.DEFAULT_SAVE =
{
	version = LootList.VERSION;
	
	lists =
	{
		Default =
		{
		},
	},
	
	activeList = "Default";
	filterEnabled = true;
};

--Output
--===================================================

function LootList.Print( msg )
  print( "|cffffff00"..LootList.PRINT_PREFIX.." |cffffffff"..msg );
end

function LootList.Error (msg)
  print( "|cffffff00"..LootList.PRINT_PREFIX.." |cffff2222"..msg );
end

--Slash handler
--===================================================


function LootList.SlashHandler( msg )

	if (msg == "") then

		--Empty command
		LootList.UpdateGui();
		LootList.ShowGui();
		
	else
	
		--Parametric commands
		local cmd, param = strsplit( " ", msg );
		if (cmd == "reset") then
		
			LootListSave = CopyTable( LootList.DEFAULT_SAVE );
			LootList.Print( "LootList settings reset." );
		end
	end
end


SLASH_LootList1 = "/lootlist";
SLASH_LootList2 = "/ll";
SlashCmdList["LootList"] = LootList.SlashHandler;


--Player list
--===================================================

function LootList.PlayerList_New( name )

	local f = PrimeGui.List_New( name );
	
	f.UpdateItem = LootList.PlayerList_UpdateItem;
	
	return f;
end

function LootList.PlayerList_UpdateItem( frame, item, value, selected  )

	PrimeGui.List_UpdateItem( frame, item, value, selected );
	
	if (value.color) then
	
		local c = value.color;
		item.label:SetTextColor( c.r, c.g, c.b, c.a );
	end
	
end

--Gui
--===================================================

function LootList.ShowGui()
	
	LootList.gui:Show();
end

function LootList.HideGui()

	LootList.gui:Hide();
end


function LootList.CreateGui()

	--Window
	local w = PrimeGui.Window_New("LootList", "LootList", true, true);
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
	local list = LootList.PlayerList_New( "LootList".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Dropdown
	local drop = PrimeGui.Drop_New( "LootList.Dropdown" );
	drop:Init();
	drop:SetParent( w.container );
	drop:SetPoint( "TOPRIGHT", 0, 0 );
	drop:SetWidth( 130 );
	drop:SetLabelText( "Active list:" );
	drop.OnValueChanged = LootList.Drop_OnValueChanged;
	drop.window = w;
	w.drop = drop;
	
	local btnNewList = PrimeGui.Button_New( "LootList.ButtonNewList" );
	btnNewList:RegisterScript( "OnClick", LootList.NewList_OnClick );
	btnNewList:SetParent( w.container );
	btnNewList:SetPoint( "TOPRIGHT", drop, "BOTTOMRIGHT", 0, -5 );
	btnNewList:SetText( "New List" );
	btnNewList:SetWidth( 130 );
	
	local btnDeleteList = PrimeGui.Button_New( "LootList.ButtonDeleteList" );
	btnDeleteList:RegisterScript( "OnClick", LootList.DeleteList_OnClick );
	btnDeleteList:SetParent( w.container );
	btnDeleteList:SetPoint( "TOPRIGHT", btnNewList, "BOTTOMRIGHT", 0, -5 );
	btnDeleteList:SetText( "Delete List" );
	btnDeleteList:SetWidth( 130 );
	
	local btnRenameList = PrimeGui.Button_New( "LootList.ButtonRenameList" );
	btnRenameList:RegisterScript( "OnClick", LootList.RenameList_OnClick );
	btnRenameList:SetParent( w.container );
	btnRenameList:SetPoint( "TOPRIGHT", btnDeleteList, "BOTTOMRIGHT", 0, -5 );
	btnRenameList:SetText( "Rename List" );
	btnRenameList:SetWidth( 130 );
	
	local btnSync = PrimeGui.Button_New( "LootList.ButtonSync" );
	btnSync:RegisterScript( "OnClick", LootList.Sync_OnClick );
	btnSync:SetParent( w.container );
	btnSync:SetPoint( "TOPRIGHT", btnRenameList, "BOTTOMRIGHT", 0, -5 );
	btnSync:SetText( "Sync" );
	btnSync:SetWidth( 130 );
	
	--Buttons
	local btnTop = PrimeGui.Button_New( "LootList.ButtonTop" );
	btnTop:RegisterScript( "OnClick", LootList.Top_OnClick );
	btnTop:SetParent( w.container );
	btnTop:SetPoint( "TOPRIGHT", btnSync, "BOTTOMRIGHT", 0, -20 );
	btnTop:SetText( "Top" );
	btnTop:SetWidth( 130 );
	
	local btnUp = PrimeGui.Button_New( "LootList.ButtonUp" );
	btnUp:RegisterScript( "OnClick", LootList.Up_OnClick );
	btnUp:SetParent( w.container );
	btnUp:SetPoint( "TOPRIGHT", btnTop, "BOTTOMRIGHT", 0, -5  );
	btnUp:SetText( "Up" );
	btnUp:SetWidth( 130 );
	
	local btnDown = PrimeGui.Button_New( "LootList.ButtonDown" );
	btnDown:RegisterScript( "OnClick", LootList.Down_OnClick );
	btnDown:SetParent( w.container );
	btnDown:SetPoint( "TOPRIGHT", btnUp, "BOTTOMRIGHT", 0, -5  );
	btnDown:SetText( "Down" );
	btnDown:SetWidth( 130 );
	
	local btnBottom = PrimeGui.Button_New( "LootList.ButtonBottom" );
	btnBottom:RegisterScript( "OnClick", LootList.Bottom_OnClick );
	btnBottom:SetParent( w.container );
	btnBottom:SetPoint( "TOPRIGHT", btnDown, "BOTTOMRIGHT", 0, -5  );
	btnBottom:SetText( "Bottom" );
	btnBottom:SetWidth( 130 );
	
	local btnInsert = PrimeGui.Button_New( "LootList.ButtonInsert" );
	btnInsert:RegisterScript( "OnClick", LootList.Insert_OnClick );
	btnInsert:SetParent( w.container );
	btnInsert:SetPoint( "TOPRIGHT", btnBottom, "BOTTOMRIGHT", 0, -30 );
	btnInsert:SetText( "Insert" );
	btnInsert:SetWidth( 130 );
	
	local btnRemove = PrimeGui.Button_New( "LootList.ButtonRemove" );
	btnRemove:RegisterScript( "OnClick", LootList.Remove_OnClick );
	btnRemove:SetParent( w.container );
	btnRemove:SetPoint( "TOPRIGHT", btnInsert, "BOTTOMRIGHT", 0, -5 );
	btnRemove:SetText( "Remove" );
	btnRemove:SetWidth( 130 );
	
	return w;
end

function LootList.UpdateGui()

	--Fill dropdown with list names
	LootList.gui.drop:RemoveAllItems();
	
	for name,list in pairs(LootListSave.lists) do
		LootList.gui.drop:AddItem( name, name );
	end
	
	LootList.gui.drop:SelectValue( LootListSave.activeList );
	
	--Store list state
	local index = LootList.gui.list:GetSelectedIndex();
	local offset = LootList.gui.list:GetScrollOffset();
	
	LootList.FillList( LootList.gui.list, LootList.GetActiveList() );
	
	--Restore list state
	LootList.gui.list:SelectIndex( index );
	LootList.gui.list:SetScrollOffset( offset );
	
end

function LootList.FillList( guiList, playerList )

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

function LootList.CreateSyncGui()

	--Window
	local w = PrimeGui.Window_New("LootListSync", "Sync", true, false);
	w:Init();
	w:SetParent( UIParent );
	w:SetWidth( 300 );
	w:SetHeight( 400 );
	
	--Label
    local txt = w:CreateFontString( "LootList.SyncGui.Text", "OVERLAY", "GameFontNormal" );
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
	local list = LootList.PlayerList_New( "LootList".."List" );
	list:Init();
	list:SetParent( bg );
	list:SetAllPoints( bg );
	list.window = w;
	w.list = list;
	
	--Cancel button
	local btnCancel = PrimeGui.Button_New( "LootList.SyncGui.Cancel" );
	btnCancel:Init();
	btnCancel:SetParent( w.container );
	btnCancel:SetText( "Cancel" );
	btnCancel:SetPoint( "BOTTOMRIGHT", 0,0 );
	btnCancel:RegisterScript( "OnClick", LootList.SyncGui_Cancel_OnClick );
	btnCancel.window = w;
	
	--Accept button
	local btnAccept = PrimeGui.Button_New( "LootList.SyncGui.Accept" );
	btnAccept:Init();
	btnAccept:SetParent( w.container );
	btnAccept:SetText( "Accept" );
	btnAccept:SetPoint( "BOTTOMRIGHT", btnCancel, "BOTTOMLEFT", -10,0 );
	btnAccept:RegisterScript( "OnClick", LootList.SyncGui_Accept_OnClick );
	btnAccept.window = w;
	
	return w;
	
end

function LootList.UpdateSyncGui()

	--Set message to match sync target
	LootList.syncGui.text:SetText( "Sync received from "..LootList.syncTarget );
	
	--Update sync list
	LootList.FillList( LootList.syncGui.list, LootList.syncList );
	
end

function LootList.SyncGui_Accept_OnClick( button )

	--Clear active list
	local list = LootList.GetActiveList();
	PrimeUtil.ClearTable( list );
	
	--Insert sync data into active list
	for i=1,table.getn( LootList.syncList ) do
		table.insert( list, LootList.syncList[i] );
	end
	
	LootList.UpdateGui();
	LootList.syncGui:Hide();
end

function LootList.SyncGui_Cancel_OnClick( button )

	LootList.syncGui:Hide();
end


--List manipulation
--====================================================================

function LootList.GetActiveList()

	--Return currently active list
	return LootListSave.lists[ LootListSave.activeList ];
end

function LootList.SetActiveList( name )

	--Check if valid name
	if (LootListSave.lists[ name ] == nil) then
		return;
	end
	
	--Switch to given list
	LootListSave.activeList = name;
	LootList.UpdateGui();
end

function LootList.Drop_OnValueChanged( drop )

	--Switch to selected list
	LootList.SetActiveList( drop:GetSelectedText() );
end

function LootList.NewList_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "New list name:", LootList.NewList_Accept);	
end

function LootList.NewList_Accept( name )

	--Check for valid name
	if (name and name ~= "") then
	
		--Create new list and switch to it
		LootListSave.lists[ name ] = {};
		LootList.SetActiveList( name );
	end
end

function LootList.DeleteList_OnClick( button )

	--Confirm with user
	local activeList = LootListSave.activeList;
	PrimeGui.ShowConfirmFrame( "Are you sure you want to delete list '"..activeList.."'?",
		LootList.DeleteList_Accept, nil, activeList );
end

function LootList.DeleteList_Accept( name )

	--Check if the last list
	if (PrimeUtil.CountTableKeys( LootListSave.lists ) <= 1) then
		LootList.Error( "Cannot delete your last list!" );
		return;
	end
	
	--Remove named list
	LootListSave.lists[ name ] = nil;
	
	--Switch to first remaining list
	for name,list in pairs(LootListSave.lists) do
		LootList.SetActiveList(name);
		break;
	end
end

function LootList.RenameList_OnClick( button )

	--Ask user for new name
	local activeList = LootListSave.activeList;
	PrimeGui.ShowInputFrame( "New name for list '"..activeList.."':",
		LootList.RenameList_Accept, nil, activeList );
end

function LootList.RenameList_Accept( newName, oldName )

	--Check for valid name
	if (newName == nil or newName == "" or newName == oldName) then
		return;
	end
	
	--List must still exist
	if (LootListSave.lists[ oldName ] == nil) then
		LootList.Error( "List does not exist anymore!" );
		return;
	end
	
	--New name must not be taken
	if (LootListSave.lists[ newName ] ~= nil) then
		LootList.Error( "This list name is already taken!" );
		return;
	end
	
	--Change name of the list and switch to it
	LootListSave.lists[ newName ] = LootListSave.lists[ oldName ];
	LootListSave.lists[ oldName ] = nil;
	LootList.SetActiveList( newName );

end


function LootList.Sync_OnClick( button )

	--Ask user for list name
	PrimeGui.ShowInputFrame( "Name of the player to get the list from",
		LootList.Sync_Accept );
end

function LootList.Sync_Accept( value )

	--Initiate sync
	if (value and value ~= "") then
		LootList.Sync( value );
	end
end


function LootList.Top_OnClick( button )

	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	
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
	
	LootList.UpdateGui();
	LootList.gui.list:SelectIndex( 1 );
end

function LootList.Up_OnClick( button )

	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	
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
	
	LootList.UpdateGui();
	LootList.gui.list:SelectIndex( index-1 );
end

function LootList.Down_OnClick( button )

	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	
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
	
	LootList.UpdateGui();
	LootList.gui.list:SelectIndex( index+1 );
end

function LootList.Bottom_OnClick( button )

	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	
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
	
	LootList.UpdateGui();
	LootList.gui.list:SelectIndex( table.getn(list) );
end

function LootList.Insert_OnClick( button )

	--Ask user for name
	PrimeGui.ShowInputFrame( "Name of player to insert:",
		LootList.Insert_Accept );
end

function LootList.Insert_Accept( value )
	
	--Check valid value
	if ((value == nil) or (value == "")) then
		return;
	end
	
	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	
	--Check valid index
	if (index < 1 or index > table.getn(list)) then
		index = 1;
	end
	
	--Insert new player
	table.insert( list, index, value );
	
	LootList.UpdateGui();
end

function LootList.Remove_OnClick( button )
	
	--Check valid selection
	local value = LootList.gui.list:GetSelectedValue();
	if (value) then

		--Confirm with player
		PrimeGui.ShowConfirmFrame( "Are you sure you want to remove player '"..value.text.."'?",
			LootList.Remove_Accept, nil, value.text );
	end
end

function LootList.Remove_Accept( text )

	--Get active list and selected index
	local list = LootList.GetActiveList();
	local index = LootList.gui.list:GetSelectedIndex();
	local value = LootList.gui.list:GetSelectedValue();
	
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
	
	LootList.UpdateGui();
	
end


--Syncing
--===================================================

function LootList.Sync( target )
	
	--Notify user
	LootList.Print( "Sending sync request to "..target.."...");
	
	--Init sync data
	LootList.syncOn = true;
	LootList.syncTarget = target;
	LootList.syncId = LootList.syncId + 1;
	PrimeUtil.ClearTable( LootList.syncList );
	
	--Send sync request with our sync id
	SendAddonMessage( LootList.PREFIX, "SyncRequest_"..LootList.syncTarget..LootList.syncId,
		"WHISPER", target );
end

function LootList.OnEvent_CHAT_MSG_ADDON( prefix, msg, channel, sender )

	if (prefix ~= LootList.PREFIX) then
		return;
	end
	
	--LootList.Print( "Addon prefix: "..tostring(prefix).." Message: "..tostring(msg) );
	
	local cmd, arg1, arg2 = strsplit( "_", msg );
	
	if (cmd == "SyncRequest") then
		
		--Notify user
		LootList.Print( "Received sync request by "..sender..".");
		
		--Iterate active list
		local list = LootList.GetActiveList();
		for i=1,table.getn(list) do
		
			--Return list item with a matching sync id
			SendAddonMessage( LootList.PREFIX, "Sync_"..arg1.."_"..tostring(list[i]),
				"WHISPER", sender );
		end
		
		--Finish sync with a matching end id
		SendAddonMessage( LootList.PREFIX, "SyncEnd_"..arg1,
			"WHISPER", sender );
	
	
	elseif (cmd == "Sync" and LootList.syncOn) then
		
		--Check if sync id matches
		if (arg1 == LootList.syncTarget..LootList.syncId) then
		
			--Add list item
			table.insert( LootList.syncList, arg2 );
		end
	
	
	elseif (cmd == "SyncEnd" and LootList.syncOn) then
	
		--Check if sync id matches
		if (arg1 == LootList.syncTarget..LootList.syncId) then
			
			--Sync finished
			LootList.syncOn = false;
			LootList.UpdateSyncGui();
			LootList.syncGui:Show();
		end
	end
end

function LootList.SyncReport()
	
	LootList.UpdateSyncGui();
	LootList.syncGui.text:SetText( "Sync received from '"..LootList.syncTarget.."'" );
	LootList.syncGui:Show();
end

--Whisper auto-report
--===================================================

function LootList.OnEvent_CHAT_MSG_WHISPER( msg, sender )

	--Check if message matches list request
	if (msg == LootList.WHISPER) then
	
		--Notify user
		LootList.Print( "Whispering Loot List to "..sender.."...");
		
		--Reply with list header
		SendChatMessage( LootList.PRINT_PREFIX.." === "..LootListSave.activeList.." ===", "WHISPER", nil, sender );
		
		--Iterate active list
		local list = LootList.GetActiveList();
		for i=1,table.getn(list) do
		
			--Reply with our data
			SendChatMessage( LootList.PRINT_PREFIX.." "..tostring(i)..". "..tostring(list[i]), "WHISPER", nil, sender );
		end
	end
end

function LootList.ChatFilter( self, event, msg )

	--Length of the prefix string
	local prefixLen = strlen( LootList.PRINT_PREFIX );

	--Filter messages starting with prefix
	if (strsub( msg, 1, prefixLen ) == LootList.PRINT_PREFIX)
	then return true;
	else return false;
	end
end

function LootList.EnableChatFilter()
	ChatFrame_AddMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LootList.ChatFilter );
end

function LootList.DisableChatFilter()
	ChatFrame_RemoveMessageEventFilter( "CHAT_MSG_WHISPER_INFORM", LootList.ChatFilter );
end


--Entry point
--===================================================

function LootList.OnEvent( frame, event, ... )
  
  local funcName = "OnEvent_" .. event;
  local func = LootList[ funcName ];
  if (func) then func(...) end
  
end

function LootList.Init()
	
	--Init variables
	LootList.syncOn = false;
	LootList.syncTarget = "Target";
	LootList.syncId = 0;
	LootList.syncList = {};
	
	--Start with default save if missing
	if (LootListSave == nil) then
		LootListSave = CopyTable( LootList.DEFAULT_SAVE );
	end
	
	--Create new gui if missing
	if (LootList.gui == nil) then
		LootList.gui = LootList.CreateGui();
		LootList.gui:SetPoint( "CENTER", 0,0 );
		LootList.gui:Hide();
	end
	
	--Create new sync gui if missing
	if (LootList.syncGui == nil) then
		LootList.syncGui = LootList.CreateSyncGui();
		LootList.syncGui:SetPoint( "CENTER", 0,0 );
		LootList.syncGui:Hide();
	end
	
	--Register whisper event
	LootList.gui:SetScript( "OnEvent", LootList.OnEvent );
	LootList.gui:RegisterEvent( "CHAT_MSG_WHISPER" );
	LootList.gui:RegisterEvent( "CHAT_MSG_ADDON" );
	
	--Filter addon whispers
	if (LootListSave.filterEnabled) then
		LootList.EnableChatFilter();
	end
	
	--First update
	LootList.UpdateGui();
	
end

LootList.Init();
