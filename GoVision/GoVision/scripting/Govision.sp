// example for the socket extension

#include <sourcemod>
#include <cstrike>
#include <socket>
#include <sdktools_gamerules>
#include <sdktools>

#pragma newdecls required
#pragma semicolon 1

#define CLASSNAME_LENGTH 64


Handle MasterSocket;

//Create lookup table for weapons maybe?

public Plugin myinfo = 
{
	name = "Go Vision",
	author = "Szymekmach1@gmail.com",
	description = "Sends player information to processing server + manages whitelist",
	version = "1.1.0",
	url = "N/a"
};

public void OnPluginStart()
{



	//Connect to the socket server
	AttemptConnect();

	//Register All event Handlers
	//NOTE: Most events should be post-hooked as there is no changing necessery

	//Generic sourcemod event
	HookEvent("player_team",Eventplayer_team,EventHookMode_Post);								//PTEM
	//HookEvent("player_shoot",Eventplayer_shoot,EventHookMode_Post);								//PFIR
	HookEvent("game_init",Eventgame_init,EventHookMode_Post);									//GINI
	HookEvent("game_start",Eventgame_start,EventHookMode_Post);									//GSTA
	HookEvent("game_end",Eventgame_end,EventHookMode_Post);										//GEND
	//Csgo specific events
	HookEvent("player_death",Eventplayer_death,EventHookMode_Post);								//PDTH
	HookEvent("player_hurt",Eventplayer_hurt,EventHookMode_Post);								//PHUR
	HookEvent("item_purchase",Eventitem_purchase,EventHookMode_Post);							//PBUY
	HookEvent("bomb_beginplant",Eventbomb_beginplant,EventHookMode_Post);						//BSPL
	HookEvent("bomb_abortplant",Eventbomb_abortplant,EventHookMode_Post);						//BABO
	HookEvent("bomb_planted",Eventbomb_planted,EventHookMode_Post);								//BPLA
	HookEvent("bomb_defused",Eventbomb_defused,EventHookMode_Post);								//BDEF
	HookEvent("bomb_exploded",Eventbomb_exploded,EventHookMode_Post);							//BEXP
	HookEvent("bomb_dropped",Eventbomb_dropped,EventHookMode_Post);								//BDRO
	HookEvent("bomb_pickup",Eventbomb_pickup,EventHookMode_Post);								//BPIC
	HookEvent("defuser_dropped",Eventdefuser_dropped,EventHookMode_Post);						//IDDR
	HookEvent("defuser_pickup",Eventdefuser_pickup,EventHookMode_Post);							//IDPI
	HookEvent("bomb_begindefuse",Eventbomb_begindefuse,EventHookMode_Post);						//BSDE
	HookEvent("bomb_abortdefuse",Eventbomb_abortdefuse, EventHookMode_Post);					//BADE
	HookEvent("silencer_off",Eventsilencer_off,EventHookMode_Post);								//PSON
	HookEvent("silencer_on",Eventsilencer_on,EventHookMode_Post);								//PSOF
	HookEvent("round_start",Eventround_start,EventHookMode_Post);								//RSTA
	HookEvent("round_end",Eventround_end,EventHookMode_Post);									//REND
	HookEvent("grenade_bounce",Eventgrenade_bounce,EventHookMode_Post);							//GBNC
	HookEvent("hegrenade_detonate",Eventhegrenade_detonate,EventHookMode_Post);					//GDET
	HookEvent("flashbang_detonate",Eventflashbang_detonate,EventHookMode_Post);					//GDET
	HookEvent("smokegrenade_detonate",Eventsmokegrenade_detonate,EventHookMode_Post);			//GDET
	HookEvent("smokegrenade_expired",Eventsmokegrenade_expired,EventHookMode_Post);				//GEXP
	HookEvent("molotov_detonate",Eventmolotov_detonate,EventHookMode_Post);						//GDET
	HookEvent("inferno_startburn",Eventinferno_startburn,EventHookMode_Post);					//FBUR
	HookEvent("inferno_expire",Eventinferno_expire,EventHookMode_Post);							//FSTO
	HookEvent("inferno_extinguish",Eventinferno_extinguish,EventHookMode_Post);					//FEXT
	HookEvent("bullet_impact",Eventbullet_impact,EventHookMode_Post);							//WBIM
	HookEvent("player_footstep",Eventplayer_footstep,EventHookMode_Post);						//PFST
	HookEvent("player_jump",Eventplayer_jump,EventHookMode_Post);								//PJUM
	HookEvent("player_blind",Eventplayer_blind,EventHookMode_Post);								//PBLI
	HookEvent("player_falldamage",Eventplayer_falldamage,EventHookMode_Post);					//PFDM
	HookEvent("start_halftime",Eventstart_halftime,EventHookMode_Post);							//RHLF
	HookEvent("weapon_fire",Eventweapon_fire,EventHookMode_Post);								//WFIR
	HookEvent("weapon_fire_on_empty",Eventweapon_fire_on_empty,EventHookMode_Post);				//WFEN
	HookEvent("grenade_thrown",Eventgrenade_thrown,EventHookMode_Post);							//GTHR
	HookEvent("weapon_outofammo",Eventweapon_outofammo,EventHookMode_Post);						//WOUT
	HookEvent("weapon_reload",Eventweapon_reload,EventHookMode_Post);							//WREL
	HookEvent("silencer_detach",Eventsilencer_detach,EventHookMode_Post);						//WSOF
	HookEvent("weapon_zoom_rifle",Eventweapon_zoom_rifle,EventHookMode_Post);					//WZRI
	HookEvent("item_pickup",Eventitem_pickup,EventHookMode_Post);								//PIPI
	HookEvent("item_pickup_failed",Eventitem_pickup_failed,EventHookMode_Post);					//PIPF
	HookEvent("item_remove",Eventitem_remove,EventHookMode_Post);								//PIRE
	HookEvent("item_equip",Eventitem_equip,EventHookMode_Post);									//PIEQ
}

public void OnGameFrame()
{
	for (int i = 1; i <= MaxClients; i++)
	{
		//Player is real check
		if (IsClientInGame(i) && GetClientTeam(i) != 0)
		{
			float angles[3];
			char MasterBuffer [512];
			char TempBuffer [512];
			float ClientPos [3];
			GetClientEyeAngles(i, angles);
			//GetEntPropVector(i, Prop_Data, "m_vecVelocity", vel);
			GetClientAbsOrigin(i, ClientPos);
			float servertime = GetGameTime();
			Format(TempBuffer,sizeof(TempBuffer),"%07.2f%07.2f%010.3f%010.3f%010.3f%09.3f",angles[0],angles[1],ClientPos[0],ClientPos[1],ClientPos[2]+64,servertime);
			Format(MasterBuffer,sizeof(MasterBuffer),"PDAT%04d%02d%s",(strlen(TempBuffer)+2),2,TempBuffer);
			SendData(MasterBuffer);
		}
	}
}

public void AttemptConnect()
{
	MasterSocket = new Socket(SOCKET_TCP, OnSocketError);
	SocketSetOption(MasterSocket,SocketSendBuffer,0);
	SocketConnect(MasterSocket, OnSocketConnected, OnSocketReceive, OnSocketDisconnected, "192.168.1.13", 9090);
	SocketSetErrorCallback(MasterSocket,OnSocketError);
}
public void Eventweapon_fire(Handle event, const char[] name, bool dontBroadcast)
{
	float servertime = GetGameTime();

	char body[100];
	char packet[100];
	Format(body,sizeof(body),"%09.3f",servertime);	
	Format(packet,sizeof(packet),"PDAT%04d01%s",strlen(body)+2,body);
	SendData(packet);
}

public void Eventbullet_impact(Handle event, const char[] name, bool dontBroadcast)
{
	float x = GetEventFloat(event, "x");
	float y = GetEventFloat(event, "y");
	float z = GetEventFloat(event, "z");
	float servertime = GetGameTime();

	char body[100];
	char packet[100];
	Format(body,sizeof(body),"%010.3f%010.3f%010.3f%010.3f",x,y,z,servertime);	
	Format(packet,sizeof(packet),"PDAT%04d06%s",strlen(body)+2,body);
	SendData(packet);
}

public void OnSocketDisconnected(Socket socket, File hFile)
{
	MasterSocket = INVALID_HANDLE;
	CloseHandle(MasterSocket);
	AttemptConnect();
}

public void OnSocketError(Socket socket, const int errorType, const int errorNum, File hFile)
{
	MasterSocket = INVALID_HANDLE;
	CloseHandle(MasterSocket);
	AttemptConnect();
}

public void SendData(char[] BufferToSend)
{
	if(MasterSocket == INVALID_HANDLE)
	{
		AttemptConnect();
		return;
	}
	SocketSend(MasterSocket,BufferToSend);
}

public void Eventitem_remove(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventitem_equip(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventitem_pickup_failed(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventitem_pickup(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventweapon_zoom_rifle(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventsilencer_detach(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventweapon_reload(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventgrenade_thrown(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventweapon_outofammo(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventweapon_fire_on_empty(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventgame_end(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventgame_start(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventgame_init(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventstart_halftime(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_team(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_falldamage(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_blind(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_jump(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_footstep(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventinferno_extinguish(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventinferno_expire(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventinferno_startburn(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventmolotov_detonate(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventsmokegrenade_expired(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventsmokegrenade_detonate(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventflashbang_detonate(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventhegrenade_detonate(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventround_end(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventgrenade_bounce(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventround_start(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventsilencer_on(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventsilencer_off(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_abortdefuse(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventdefuser_pickup(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_begindefuse(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventdefuser_dropped(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_pickup(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_dropped(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_exploded(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_defused(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_abortplant(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_planted(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventbomb_beginplant(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventitem_purchase(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_hurt(Handle event, const char[] name, bool dontBroadcast)
{}
public void Eventplayer_death(Handle event, const char[] name, bool dontBroadcast)
{}
public void OnSocketConnected(Socket socket, any arg)
{}
public void OnSocketReceive(Socket socket, char[] receiveData, const int dataSize, File hFile)
{}