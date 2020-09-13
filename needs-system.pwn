#include <a_samp>
#include <playerprogress>
#include <zcmd>

new
	PlayerBar:needsBar[MAX_PLAYERS],
	pissingTimer[MAX_PLAYERS];

DestroyNeedsBar(playerid)
{
	if(needsBar[playerid] != INVALID_PLAYER_BAR_ID) 
	{
		HidePlayerProgressBar(playerid, needsBar[playerid]);
		DestroyPlayerProgressBar(playerid, needsBar[playerid]);
	}
}

bool:SkinIsFemale(skinid)
{
	switch(skinid)
	{
		case 9..13, 31, 38..41, 53..56, 63..65, 69, 75..77, 85, 87..93, 129, 131, 138..141, 145, 148, 150..152, 157, 169, 172, 178, 190..199, 201, 
		205, 207, 211, 214..216, 218..219, 224..226, 231..233, 237..238, 243..246, 251, 256..257, 263, 298, 306..309: return true;
	}
	return false;
}

SetPlayerPissing(playerid)
{
	GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~You are taking a piss.", 5509, 3);
	if(SkinIsFemale(GetPlayerSkin(playerid)))
	{
		ApplyAnimation(playerid, "PED", "SEAT_IDLE", 4.1, false, false, false, true, 0, false);
		SetPlayerAttachedObject(playerid, 0, 18705, 1, -0.25, 0.1, -1.60, 0.0, 0.0, 75.0);
	}
	else
	{
		ApplyAnimation(playerid, "PAULNMAC", "PISS_IN", 4.1, false, false, false, true, 0, false);
		SetPlayerAttachedObject(playerid, 0, 18705, 1, -0.36, 0.25, -1.65);
	}
	pissingTimer[playerid] = SetTimerEx("OnPlayerPissing", 150, true, "d", playerid);
}

public OnFilterScriptInit()
{
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
		if(i == INVALID_PLAYER_ID) continue;
		needsBar[i] = CreatePlayerProgressBar(i, 547.5, 150.0, 59.0, 5.0, 0xF1C40FFF, 100.0);
		SetPlayerProgressBarValue(i, needsBar[i], 50.0);
		UpdatePlayerProgressBar(i, needsBar[i]);
	}
	return 1;
}

public OnFilterScriptExit()
{
	for(new i; i <= GetPlayerPoolSize(); i++)
	{
		if(i == INVALID_PLAYER_ID) continue;
		DestroyNeedsBar(i);
		KillTimer(pissingTimer[i]);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	needsBar[playerid] = CreatePlayerProgressBar(playerid, 547.5, 150.0, 59.0, 5.0, 0xF1C40FFF, 100.0);
	SetPlayerProgressBarValue(playerid, needsBar[playerid], 50.0);
	UpdatePlayerProgressBar(playerid, needsBar[playerid]);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	DestroyNeedsBar(playerid);
	KillTimer(pissingTimer[playerid]);
	return 1;
}

forward OnPlayerPissing(playerid);
public OnPlayerPissing(playerid)
{
	new Float:pissingValue = GetPlayerProgressBarValue(playerid, needsBar[playerid]);
	if(pissingValue >= 0.1)
	{
		pissingValue = pissingValue - 0.5;
		SetPlayerProgressBarValue(playerid, needsBar[playerid], pissingValue);
		UpdatePlayerProgressBar(playerid, needsBar[playerid]);
	}
	else
	{
		KillTimer(pissingTimer[playerid]);
		if(IsPlayerAttachedObjectSlotUsed(playerid, 0)) RemovePlayerAttachedObject(playerid, 0);
		ApplyAnimation(playerid, (SkinIsFemale(GetPlayerSkin(playerid)) ? "PED" : "PAULNMAC"), (SkinIsFemale(GetPlayerSkin(playerid)) ? "SEAT_UP" : "PISS_OUT"), 4.1, false, false, false, false, 0, false);
	}
	return 1;
}

CMD:pee(playerid)
{
	if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "You must be on foot.");
	if(GetPlayerProgressBarValue(playerid, needsBar[playerid]) <= 0.0) return SendClientMessage(playerid, -1, "You don’t want to urinate.");

	SetPlayerPissing(playerid);
	return 1;
}