--[[

LootKingMaster
Author: Ivan Leben

--]]

local LKM = LootKingMaster;

--Configuration
--============================================================

function LKM.CreateConfigGui ()

	local f = CreateFrame( "Frame", "LKM.MainOptionsPanel", InterfaceOptionsFramePanelContainer );
	
	--Title
	local txtTitle =  f:CreateFontString( "txtTest" );
	txtTitle:SetFontObject( "GameFontNormal" );
	txtTitle:SetFont("Fonts\\FRIZQT__.TTF", 20);
	txtTitle:SetJustifyH( "LEFT" );
	txtTitle:SetPoint( "TOPLEFT", 10, -15 );
	txtTitle:SetText("LootKingMaster");
	
	
	--Dropdown
	local drop = PrimeGui.Drop_New( LKM.PREFIX.."Dropdown" );
	drop:Init();
	drop:SetParent( f );
	drop:SetPoint( "TOPLEFT", txtTitle, "BOTTOMLEFT", 0, -30 );
	drop:SetWidth( 200 );
	drop:SetLabelText( "List:" );
	drop.frame = f;
	f.drop = drop;
	
	local btnRenameList = PrimeGui.Button_New( LKM.PREFIX.."BtnRenameList" );
	btnRenameList:RegisterScript( "OnClick", LKM.RenameList_OnClick );
	btnRenameList:SetParent( f );
	btnRenameList:SetPoint( "TOPLEFT", drop, "BOTTOMLEFT", 0, -5 );
	btnRenameList:SetText( "Rename List" );
	btnRenameList:SetWidth( 200 );
	btnRenameList.frame = f;
	
	local btnNewList = PrimeGui.Button_New( LKM.PREFIX.."BtnNewList" );
	btnNewList:RegisterScript( "OnClick", LKM.NewList_OnClick );
	btnNewList:SetParent( f );
	btnNewList:SetPoint( "TOPLEFT", btnRenameList, "BOTTOMLEFT", 0, -5 );
	btnNewList:SetText( "New List" );
	btnNewList:SetWidth( 200 );
	btnNewList.frame = f;
	
	local btnDeleteList = PrimeGui.Button_New( LKM.PREFIX.."BtnDeleteList" );
	btnDeleteList:RegisterScript( "OnClick", LKM.DeleteList_OnClick );
	btnDeleteList:SetParent( f );
	btnDeleteList:SetPoint( "TOPLEFT", btnNewList, "BOTTOMLEFT", 0, -5 );
	btnDeleteList:SetText( "Delete List" );
	btnDeleteList:SetWidth( 200 );
	btnDeleteList.frame = f;
	
	
	--Filter checkbox
	local chkFilter = PrimeGui.Checkbox_New( LKM.PREFIX.."ChkFilter" );
	chkFilter:SetParent( f );
	chkFilter:SetText( "Enable chat filter" );
	chkFilter:SetPoint( "TOPLEFT", btnDeleteList, "BOTTOMLEFT", 0, -30 );
	chkFilter:SetWidth( 200 );
	chkFilter.OnValueChanged = LKM.ChkFilter_OnValueChanged;
	chkFilter.frame = f;
	f.chkFilter = chkFilter;
	
	--Silent checkbox
	local chkSilent = PrimeGui.Checkbox_New( LKM.PREFIX.."ChkSilent" );
	chkSilent:SetParent( f );
	chkSilent:SetText( "Enable silent mode" );
	chkSilent:SetPoint( "TOPLEFT", chkFilter, "BOTTOMLEFT", 0, -5 );
	chkSilent:SetWidth( 200 );
	chkSilent.OnValueChanged = LKM.ChkSilent_OnValueChanged;
	chkSilent.frame = f;
	f.chkSilent = chkSilent;
	
	--Add panel as an interface options category
	f.name = "LootKingMaster";
	f.refresh = LKM.UpdateConfigGui;
	InterfaceOptions_AddCategory( f );
	
	return f;
	
end

function LKM.UpdateConfigGui()
	
	--Fill dropdown with list names
	LKM.configGui.drop:RemoveAllItems();
	
	for name,list in pairs(LKM.GetSave().lists) do
		LKM.configGui.drop:AddItem( name, name );
	end
	
	LKM.configGui.drop:SelectIndex( 0 );
	
	--Update filter checkbox
	LKM.configGui.chkFilter:SetChecked( LKM.GetSave().filterEnabled );
	
	--Update silent checkbox
	LKM.configGui.chkSilent:SetChecked( LKM.GetSave().silentEnabled );
	
end

function LKM.ShowConfigGui()

	LKM.UpdateConfigGui();
	InterfaceOptionsFrame_OpenToCategory( "LootKingMaster" );
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
		
		LKM.UpdateConfigGui();
		LKM.configGui.drop:SelectValue(name);
	end
	
	LKM.UpdateGui();
end

function LKM.DeleteList_OnClick( button )

	local frame = button.frame;
	local name = frame.drop:GetSelectedText();
	
	--Confirm with user
	PrimeGui.ShowConfirmFrame( "Are you sure you want to delete list '"..name.."'?",
		LKM.DeleteList_Accept, nil, name );
end

function LKM.DeleteList_Accept( delName )

	--Get save table
	local save = LKM.GetSave();
	
	--Check if the last list
	if (PrimeUtil.CountTableKeys( save.lists ) <= 1) then
		LKM.Error( "Cannot delete your last list!" );
		return;
	end
	
	--Remove named list
	save.lists[ delName ] = nil;
	
	--Iterate remaining lists
	for name,list in pairs(save.lists) do
	
		--Switch to first remaining list	
		LKM.UpdateConfigGui();
		LKM.configGui.drop:SelectValue(name);
		
		--Switch active list too, if deleted
		if (LKM.GetActiveListName() == delName) then
			LKM.SetActiveList(name);
		end
		
		break;
	end
	
	LKM.UpdateGui();
end

function LKM.RenameList_OnClick( button )

	local frame = button.frame;
	local name = frame.drop:GetSelectedText();
	
	--Ask user for new name
	PrimeGui.ShowInputFrame( "New name for list '"..name.."':",
		LKM.RenameList_Accept, nil, name );
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
	
	LKM.UpdateConfigGui();
	LKM.configGui.drop:SelectValue( newName );
	
	--Switch active list too, if renamed
	if (LKM.GetActiveListName() == oldName) then
		LKM.SetActiveList( newName );
	end
	
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

function LKM.ChkSilent_OnValueChanged( check )

	if (check:GetChecked()) then
		LKM.GetSave().silentEnabled = true;
		LKM.Print( "Silent mode |cFF00FF00enabled." );
	else
		LKM.GetSave().silentEnabled = false;
		LKM.Print( "Silent mode |cFFFF0000disabled." );
	end
end
