@echo off
cls

set ServerTitle=787
set ServerPlayers=24
set ServerPort=27015
set ServerMap=zps_cinema
set ServerCfg=server.cfg


:: Steam Servers ID Token
:: If you have subscribed workshop addons on your account, and have set AccountTokenID, it will download the workshop content.
:: To setup a Token ID, head over to: https://steamcommunity.com/dev/managegameservers
:: set AccountTokenID= 1C125B84AC387F4C78EA6746520A5B6D

set SourceTV="+tv_enable 0;tv_autorecord 0;tv_maxclients 0;tv_transmitall 0;tv_relayvoice 0"


echo Protecting %ServerTitle% from crashes...
title %ServerTitle%
:srcds
echo (%time%) %ServerTitle% started.
start /wait srcds.exe -console -game zps -dedicated +map %ServerMap% -port %ServerPort% +maxplayers %ServerPlayers% -secure +sv_lan 0 %SourceTV% +servercfgfile %ServerCfg% +sv_hl2mp_item_respawn_time 0.1

echo (%time%) WARNING: %ServerTitle% closed and/or crashed, restarting.
goto srcds
