--[[

LootKingMaster
Author: Ivan Leben

--]]


--Main table
--========================================================

LootKingMaster = {};

local LKM = LootKingMaster;


--Default values
--========================================================

LKM.VERSION = "0.1";
LKM.UPGRADE_LIST = { "1.1" };

LKM.PREFIX = "LootKingMaster";
LKM.PRINT_PREFIX = "<LootKingMaster>";
LKM.SYNC_PREFIX = "LootKingSync";
LKM.WHISPER = "!lootking";

LKM.DEFAULT_SAVE =
{
	version = LKM.VERSION;
	
	lists =
	{
		Default =
		{
		},
	},
	
	activeList = "Default",
	filterEnabled = true,
	silentEnabled = true,
	minimapButtonPos = 225;
};

--Save management
--===================================================

function LKM.ResetSave()

	_G["LootKingMasterSave"] = CopyTable( LKM.DEFAULT_SAVE );
end

function LKM.GetSave()

	return _G["LootKingMasterSave"];
end

--Save upgrades
--====================================================

function LKM.Upgrade_1_1()

	local save = LKM.GetSave();
	
	if (save.silentEnabled == nil) then
		save.silentEnabled = LKM.DEFAULT_SAVE.silentEnabled;
	end
	
	if (save.minimapButtonPos == nil) then
		save.minimapButtonPos = LKM.DEFAULT_SAVE.minimapButtonPos;
	end

end

function LKM.Upgrade()

	local save = LKM.GetSave();
	local curVersion = save.version;
	
	for i=1,table.getn( LKM.UPGRADE_LIST ) do

		local nextVersion = LKM.UPGRADE_LIST[i];
		if (PrimeUtil.CompareVersions( curVersion, nextVersion )) then
			
			LKM.Print( "Upgrading settings from version "..curVersion.." to "..nextVersion, true );
			
			local verString = string.gsub( nextVersion, "[.]", "_" );
			local funcName = "Upgrade_"..verString;
			local func = LKM[ funcName ];
			
			if (func) then func() else
				LKM.Error( "Missing upgrade function!" );
			end
			
			curVersion = nextVersion;
		end
	end
	
	save.version = LKM.VERSION;
end
