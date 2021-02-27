/*
admintoolssource.sp
AdminTools: Source
This plugin is coded by Alican "AlicanC" Çubukçuoðlu (alicancubukcuoglu@gmail.com)
Copyright (C) 2007 Alican Çubukçuoðlu
*/
/*
This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
*/

#pragma semicolon 1

//! Do not touch these.
//#define DEBUG
#define PLUGIN_VERSION "0.0.5"

#include "admintoolssource/ats.inc"
//Plugins
#include "admintoolssource/pluginsupport.inc"
#include "admintoolssource/plugins.inc"
//Tools
#include "admintoolssource/toolsupport.inc"
#include "admintoolssource/tools.inc"


//||||||CVar Handles
new Handle:admintoolssource_enabled;
//||||||Forward Handles
new Handle:Forward_OnToolStart;

public Plugin:myinfo=
	{
	name= "AdminTools: Source",
	author= "Alican 'AlicanC' Çubukçuoðlu",
	description= "Advanced server and player control.",
	version= PLUGIN_VERSION,
	url= "http://www.sourcemod.net/"
	}

public OnPluginStart()
	{
	//||||||||Checks
	//||||||Check compatibility
	CheckCompatibility();
	//||||||Check required files
	//||||Check translation files
	CheckRequiredFile("translations/admintoolssource/access.txt", "AdminTools: Source");
	CheckRequiredFile("translations/admintoolssource/base.txt", "AdminTools: Source");
	CheckRequiredFile("translations/admintoolssource/plugins.txt", "AdminTools: Source");
	CheckRequiredFile("translations/admintoolssource/templates.txt", "AdminTools: Source");
	CheckRequiredFile("translations/admintoolssource/tools.txt", "AdminTools: Source");
	//||||Check configuration files
	CheckRequiredFile("configs/admintoolssource/convars.txt", "AdminTools: Source");
	//||||Check data files
	if(CheckRequiredDirectory("data/admintoolssource", "AdminTools: Source"))
		{
		if(!CheckFile("data/admintoolssource/convarcache.txt"))
			{
			CacheConVars();
			}
		}
	
	//||||||||Load Translations
	LoadTranslations("admintoolssource/access");
	LoadTranslations("admintoolssource/base");
	LoadTranslations("admintoolssource/plugins");
	LoadTranslations("admintoolssource/templates");
	LoadTranslations("admintoolssource/tools");
	
	//||||||||Create Version CVar
	CreateConVar("admintoolssource_version", PLUGIN_VERSION, "AdminTools: Source Version", FCVAR_SPONLY|FCVAR_REPLICATED);
	
	//||||||||ATS CVars
	admintoolssource_enabled= CreateConVar("admintoolssource_enable", "1", "Enable/Disable AdminTools: Source.", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	
	//Commands
	RegAdminCmd("ats_menu", Command_Menu, ADMFLAG_CONVARS);
	RegAdminCmd("ats_recacheconvars", Command_ReCacheConVars, ADMFLAG_CONVARS);
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
	
	//Forwards
	Forward_OnToolStart= CreateGlobalForward("OnToolStart", ET_Ignore);
	
	//Initialize SDK Functions
	InitSDKFunctions();
	
	//Execute config
	AutoExecConfig();
	}

/*public OnConfigsExecuted()
	{
	}*/

public OnAllPluginsLoaded()
	{
	//Start Tools
	Call_StartForward(Forward_OnToolStart);
	Call_Finish();
	}

//||||COMMANDS||||

public Action:Command_Menu(client, args)//Secure
	{
	if(!GetConVarBool(admintoolssource_enabled))
		return Plugin_Handled;
	//
	ShowMenu(client, "MainMenu");
	//
	return Plugin_Handled;
	}

public Action:Command_ReCacheConVars(client, args)//Secure
	{
	if(!GetConVarBool(admintoolssource_enabled))
		return Plugin_Handled;
	//
	CacheConVars();
	//
	return Plugin_Handled;
	}

public Action:Command_Say(client, args)//Secure
	{
	if(!GetConVarBool(admintoolssource_enabled))
		return Plugin_Continue;
	new String:Arg1[32];
	new String:Chat[32];
	GetCmdArgString(Arg1, sizeof(Arg1));
	Arg1[strlen(Arg1)-1]= '\0';
	strcopy(Chat, sizeof(Chat), Arg1[1]);
	//Debug | 
	Debug("AdminTools: Source", "Command_Say", "Chat: '%s'", Chat);
	//
	if(StrEqual(Chat,"ats_menu") || StrEqual(Chat,"atsmenu"))
		{
		if(!HasClientFlagExt(client, Admin_Convars, Access_Effective, "AdminTools: Source", "%t: %t", "ATSAccess AccessDenied", "ATSAccess AdminFlagNeeded", "Admin_Convars"))
			return Plugin_Continue;
		ShowMenu(client, "MainMenu");
		return Plugin_Handled;
		}
		/*
		else 
		{
		new String:split[3][32];
		new String:command[32];
		new String:param1[32];
		new String:param2[32];
		//
		ExplodeString(Chat, " ", split, 3, 32);
		strcopy(command, sizeof(command), split[0]);
		strcopy(param1, sizeof(param1), split[1]);
		strcopy(param2, sizeof(param2), split[2]);
		//
		if(StrEqual(command,"..."))
			{
			new amount= StringToInt(param1);
			Bank_Withdraw(client, amount);
			return Plugin_Handled;
			}
		}
		*/
	//
	return Plugin_Continue;
	}

//||||FUNCTIONS||||

//||||MENUS||||

public Handle:Menu_MainMenu(client)
	{
	new Handle:menu= CreateMenu(MHandler_MainMenu);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT MainMenu");
	//
	decl String:text[128];
	//
	Format(text, sizeof(text), "%t", "ATSMenuI MainMenu ServerControl");
	AddMenuItem(menu, "ServerControl", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI MainMenu PluginControl");
	AddMenuItem(menu, "PluginControl", text);
	//
	if(CheckMod("cstrike"))
		{
		Format(text, sizeof(text), "%t", "ATSMenuI MainMenu BotControl");
		AddMenuItem(menu, "BotControl", text);
		}
	Format(text, sizeof(text), "%t", "ATSMenuI MainMenu Tools");
	AddMenuItem(menu, "Tools", text);
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_MainMenu(Handle:menu, MenuAction:action, param1, param2)
	{
	if(action==MenuAction_Select)
		{
		new client= param1;
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//
		ShowMenu(client, info);
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}

//||||

public Handle:Menu_BotControl(client)
	{
	new Handle:menu= CreateMenu(MHandler_BotControl);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT BotControl");
	//
	decl String:text[128];
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl AddBot");
	AddMenuItem(menu, "AddBot", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl AddBotT");
	AddMenuItem(menu, "AddBotT", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl AddBotCT");
	AddMenuItem(menu, "AddBotCT", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl KillBots");
	AddMenuItem(menu, "KillBots", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl BotWeaponModes");
	AddMenuItem(menu, "BotWeaponModes", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl BotRestrictWeapons");
	AddMenuItem(menu, "BotRestrictWeapons", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI BotControl RemoveBots");
	AddMenuItem(menu, "RemoveBots", text);
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_BotControl(Handle:menu, MenuAction:action, param1, param2)
	{
	if(action==MenuAction_Select)
		{
		new client= param1;
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//
		if(StrEqual(info, "AddBot"))
			{
			ServerCommand("bot_add");
			ShowMenu(client, "BotControl");
			}
			else if(StrEqual(info, "AddBotT"))
			{
			ServerCommand("bot_add_t");
			ShowMenu(client, "BotControl");
			}
			else if(StrEqual(info, "AddBotCT"))
			{
			ServerCommand("bot_add_ct");
			ShowMenu(client, "BotControl");
			}
			else if(StrEqual(info, "KillBots"))
			{
			ServerCommand("bot_kill");
			ShowMenu(client, "BotControl");
			}
			else if(StrEqual(info, "RemoveBots"))
			{
			ServerCommand("bot_kick");
			ShowMenu(client, "BotControl");
			}
			else if(StrEqual(info, "BotWeaponModes"))
			{
			ShowMenu(client, "BotWeaponModes");
			}
			else if(StrEqual(info, "BotRestrictWeapons"))
			{
			ShowMenu(client, "BotRestrictWeapons");
			}
		}
		else if(action==MenuAction_Cancel && param2==MenuCancel_Exit)
		{
		new client= param1;
		ShowMenu(client, "MainMenu");
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}

//||||

public Handle:Menu_ServerControl(client)
	{
	new Handle:menu= CreateMenu(MHandler_ServerControl);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT ServerControl");
	//
	decl String:text[128];
	//
	Format(text, sizeof(text), "%t", "ATSMenuI ServerControl RestartGame");
	AddMenuItem(menu, "RestartGame", text);
	//
	if(CheckMod("cstrike"))
		{
		Format(text, sizeof(text), "%t", "ATSMenuI ServerControl EndRound");
		AddMenuItem(menu, "EndRound", text);
		}
	//
	Format(text, sizeof(text), "%t", "ATSMenuI ServerControl ConVars");
	AddMenuItem(menu, "ConVars", text);
	//
	Format(text, sizeof(text), "%t", "ATSMenuI ServerControl RestartServer");
	AddMenuItem(menu, "RestartServer", text);
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_ServerControl(Handle:menu, MenuAction:action, param1, param2)
	{
	if(action==MenuAction_Select)
		{
		new client= param1;
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//
		if(StrEqual(info, "RestartGame"))
			{
			RestartGame();
			ShowMenu(client, "ServerControl");
			}
			else if(StrEqual(info, "EndRound"))
			{
			TerminateRound();
			ShowMenu(client, "ServerControl");
			}
			else if(StrEqual(info, "RestartServer"))
			{
			ServerCommand("restart");
			ShowMenu(client, "ServerControl");
			}
			else if(StrEqual(info, "ConVars"))
			{
			ShowMenu(client, "ConVars");
			}
		}
		else if(action==MenuAction_Cancel && param2==MenuCancel_Exit)
		{
		new client= param1;
		ShowMenu(client, "MainMenu");
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}

//||||

public Handle:Menu_ConVars(client)
	{
	new Handle:menu= CreateMenu(MHandler_ConVars);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT ConVars");
	//
	AddMenuConVars(menu, "data/admintoolssource/convarcache.txt");
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_ConVars(Handle:menu, MenuAction:action, param1, param2)
	{
	new client;
	if(action==MenuAction_Select)
		{
		client= param1;
		new String:s_param2[64];
		new String:split[2][32];
		new String:info[16];
		new String:cvname[32];
		GetMenuItem(menu, param2, s_param2, sizeof(s_param2));
		ExplodeString(s_param2, "|", split, 2, 32);
		strcopy(info, sizeof(info), split[0]);
		strcopy(cvname, sizeof(cvname), split[1]);
		Debug("AdminTools: Source", "MHandler_ConVars", "s_param2: '%s', info: '%s', cvname: '%s'", s_param2, info, cvname);
		new Handle:ConVar= FindConVar(cvname);
		//
		if(StrEqual(info, "TurnOn"))
			{
			SetConVarBool(FindConVar(cvname), true, false, true);
			ShowMenu(client, "ConVars");
			}
			else if(StrEqual(info, "TurnOff"))
			{
			SetConVarBool(FindConVar(cvname), false, false, true);
			ShowMenu(client, "ConVars");
			}
			else if(StrEqual(info, "ChangeInt"))
			{
			ShowChangeIntMenu(client, cvname, GetConVarInt(ConVar));
			}
			else if(StrEqual(info, "ChangeFloat"))
			{
			ShowChangeFloatMenu(client, cvname, GetConVarFloat(ConVar));
			}
		}
		else if(action==MenuAction_Cancel && param2==MenuCancel_Exit)
		{
		client= param1;
		ShowMenu(client, "ServerControl");
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}

//||||

public Handle:Menu_PluginControl(client)
	{
	new Handle:menu= CreateMenu(MHandler_PluginControl);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT PluginControl");
	//
	AddMenuPlugin(menu, "admintoolssource");
	AddMenuPlugin(menu, "atac");
	AddMenuPlugin(menu, "dmtb");
	AddMenuPlugin(menu, "cssdm");
	AddMenuPlugin(menu, "gungame");
	AddMenuPlugin(menu, "heroessource");
	AddMenuPlugin(menu, "radio");
	AddMenuPlugin(menu, "quakesounds");
	AddMenuPlugin(menu, "saysounds");
	AddMenuPlugin(menu, "sprintsource");
	AddMenuPlugin(menu, "whobangedmesource");
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_PluginControl(Handle:menu, MenuAction:action, param1, param2)
	{
	if(action==MenuAction_Select)
		{
		new client= param1;
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//
		ShowPluginControlMenu(client, info);
		}
		else if(action==MenuAction_Cancel && param2==MenuCancel_Exit)
		{
		new client= param1;
		ShowMenu(client, "MainMenu");
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}

//||||

public Handle:Menu_Tools(client)
	{
	new Handle:menu= CreateMenu(MHandler_Tools);
	//
	SetMenuTitle(menu, "[AdminTools: Source] %t\n ", "ATSMenuT Tools");
	//
	if(CheckMod("cstrike"))
		{
		AddMenuTool(menu, "afks");
		AddMenuTool(menu, "autobalance");
		AddMenuTool(menu, "fun");
		}
	//
	SetMenuExitButton(menu, true);
	//
	return menu;
	}

public MHandler_Tools(Handle:menu, MenuAction:action, param1, param2)
	{
	if(action==MenuAction_Select)
		{
		new client= param1;
		new String:info[32];
		GetMenuItem(menu, param2, info, sizeof(info));
		//
		ShowToolMenu(client, info);
		}
		else if(action==MenuAction_Cancel && param2==MenuCancel_Exit)
		{
		new client= param1;
		ShowMenu(client, "MainMenu");
		}
		else if(action==MenuAction_End)
		{
		CloseHandle(menu);
		}
	}