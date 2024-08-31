#! /usr/bin/bash

me=$(basename "$0")
target="${me%.sh}"

GameVersion=$(sed -nr "/^\[Miscellaneous\]/ { :l /^GameVersion[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
cl_entitylist=$(sed -nr "/^\[Miscellaneous\]/ { :l /^cl_entitylist[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
LocalPlayer=$(sed -nr "/^\[Miscellaneous\]/ { :l /^LocalPlayer[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
GlobalVars=$(sed -nr "/^\[Miscellaneous\]/ { :l /^GlobalVars[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
NameList=$(sed -nr "/^\[Miscellaneous\]/ { :l /^NameList[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
ViewRender=$(sed -nr "/^\[Miscellaneous\]/ { :l /^ViewRender[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
ViewMatrix=$(sed -nr "/^\[Miscellaneous\]/ { :l /^ViewMatrix[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
LevelName=$(sed -nr "/^\[Miscellaneous\]/ { :l /^LevelName[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
projectile_launch_speed=$(sed -nr "/^\[WeaponSettings\]/ { :l /^projectile_launch_speed[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
base=$(sed -nr "/^\[WeaponSettingsMeta\]/ { :l /^base[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
camera_origin=$(sed -nr "/^\[Miscellaneous\]/ { :l /^CPlayer!camera_origin[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_pStudioHdr=$(sed -nr "/^\[Miscellaneous\]/ { :l /^CBaseAnimating!m_pStudioHdr[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
in_attack=$(sed -nr "/^\[Buttons\]/ { :l /^in_attack[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_nForceBone=$(sed -nr "/^\[RecvTable.DT_BaseAnimating\]/ { :l /^m_nForceBone[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_latestPrimaryWeapons=$(sed -nr "/^\[RecvTable.DT_BaseCombatCharacter\]/ { :l /^m_latestPrimaryWeapons[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_latestNonOffhandWeapons=$(sed -nr "/^\[RecvTable.DT_BaseCombatCharacter\]/ { :l /^m_latestNonOffhandWeapons[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
lastVisibleTime=$(sed -nr "/^\[Miscellaneous\]/ { :l /^CPlayer!lastVisibleTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
lastCrosshairTargetTime=$(sed -nr "/^\[Miscellaneous\]/ { :l /^CWeaponX!lastCrosshairTargetTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_shieldHealth=$(sed -nr "/^\[RecvTable.DT_BaseEntity\]/ { :l /^m_shieldHealth[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_iTeamNum=$(sed -nr "/^\[RecvTable.DT_BaseEntity\]/ { :l /^m_iTeamNum[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_squadID=$(sed -nr "/^\[RecvTable.DT_BaseEntity\]/ { :l /^m_squadID[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_iName=$(sed -nr "/^\[RecvTable.DT_BaseEntity\]/ { :l /^m_iName[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_traversalProgress=$(sed -nr "/^\[RecvTable.DT_LocalPlayerExclusive\]/ { :l /^m_traversalProgress[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_traversalStartTime=$(sed -nr "/^\[RecvTable.DT_LocalPlayerExclusive\]/ { :l /^m_traversalStartTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_traversalReleaseTime=$(sed -nr "/^\[RecvTable.DT_LocalPlayerExclusive\]/ { :l /^m_traversalReleaseTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_iHealth=$(sed -nr "/^\[RecvTable.DT_Player\]/ { :l /^m_iHealth[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_lifeState=$(sed -nr "/^\[RecvTable.DT_Player\]/ { :l /^m_lifeState[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_bleedoutState=$(sed -nr "/^\[RecvTable.DT_Player\]/ { :l /^m_bleedoutState[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_xp=$(sed -nr "/^\[RecvTable.DT_Player\]/ { :l /^m_xp[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_weaponNameIndex=$(sed -nr "/^\[RecvTable.DT_WeaponX\]/ { :l /^m_weaponNameIndex[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_vecAbsVelocity=$(sed -nr "/^\[DataMap.C_BaseEntity\]/ { :l /^m_vecAbsVelocity[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_vecAbsOrigin=$(sed -nr "/^\[DataMap.C_BaseEntity\]/ { :l /^m_vecAbsOrigin[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_bZooming=$(sed -nr "/^\[DataMap.C_Player\]/ { :l /^m_bZooming[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
timeBase=$(sed -nr "/^\[DataMap.C_Player\]/ { :l /^m_currentFramePlayer.timeBase[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_ammoPoolCount=$(sed -nr "/^\[DataMap.C_Player\]/ { :l /^m_currentFramePlayer.m_ammoPoolCount[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_ammoPoolCapacity=$(sed -nr "/^\[DataMap.C_Player\]/ { :l /^m_ammoPoolCapacity[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_playerData=$(sed -nr "/^\[RecvTable.DT_WeaponX\]/ { :l /^m_playerData[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_targetZoomFOV=$(sed -nr "/^\[DataMap.WeaponPlayerData\]/ { :l /^m_targetZoomFOV[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
mp_gamemode=$(sed -nr "/^\[DataMap.C_Player\]/ { :l /^mp_gamemode[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)

parse_hpp () {
func_in=$(eval echo \$$1)
if [[ "$func_in" == "" ]]; then
  func_out=$(sed -n -e "s/$2\s*=\s*//p" Offsets.hpp)
  func_out=${func_out%%;*}
  echo ${func_out//\"}
else
  func_out=$(eval echo \$$1)
  echo ${func_out%%[[:cntrl:]]}
fi
}

GameVersion=$(parse_hpp GameVersion "constexpr char OFF_GAME_VERSION\[\]")
cl_entitylist=$(parse_hpp cl_entitylist "constexpr long OFF_ENTITY_LIST")
LocalPlayer=$(parse_hpp LocalPlayer "constexpr long OFF_LOCAL_PLAYER")
GlobalVars=$(parse_hpp GlobalVars "constexpr long OFF_GLOBAL_VARS")
NameList=$(parse_hpp NameList "constexpr long OFF_NAMELIST")
ViewRender=$(parse_hpp ViewRender "constexpr long OFF_VIEW_RENDER")
ViewMatrix=$(parse_hpp ViewMatrix "constexpr long OFF_VIEW_MATRIX")
LevelName=$(parse_hpp LevelName "constexpr long OFF_LEVEL")
camera_origin=$(parse_hpp camera_origin "constexpr long OFF_CAMERAORIGIN")
m_pStudioHdr=$(parse_hpp m_pStudioHdr "constexpr long OFF_STUDIOHDR")
in_attack=$(parse_hpp in_attack "constexpr long OFF_IN_ATTACK")
m_latestPrimaryWeapons=$(parse_hpp m_latestPrimaryWeapons "constexpr long OFF_WEAPON_HANDLE")
m_latestNonOffhandWeapons=$(parse_hpp m_latestNonOffhandWeapons "constexpr long OFF_GRENADE_HANDLE")
lastVisibleTime=$(parse_hpp lastVisibleTime "constexpr long OFF_LAST_VISIBLE_TIME")
lastCrosshairTargetTime=$(parse_hpp lastCrosshairTargetTime "constexpr long OFF_LAST_AIMEDAT_TIME")
m_shieldHealth=$(parse_hpp m_shieldHealth "constexpr long OFF_CURRENT_SHIELDS")
m_iTeamNum=$(parse_hpp m_iTeamNum "constexpr long OFF_TEAM_NUMBER")
m_squadID=$(parse_hpp m_squadID "constexpr long OFF_SQUAD_ID")
m_iName=$(parse_hpp m_iName "constexpr long OFF_NAME")
m_traversalProgress=$(parse_hpp m_traversalProgress "constexpr long OFFSET_TRAVERSAL_PROGRESS")
m_traversalStartTime=$(parse_hpp m_traversalStartTime "constexpr long OFFSET_TRAVERSAL_START_TIME")
m_traversalReleaseTime=$(parse_hpp m_traversalReleaseTime "constexpr long OFFSET_TRAVERSAL_RELEASE_TIME")
m_iHealth=$(parse_hpp m_iHealth "constexpr long OFF_CURRENT_HEALTH")
m_lifeState=$(parse_hpp m_lifeState "constexpr long OFF_LIFE_STATE")
m_bleedoutState=$(parse_hpp m_bleedoutState "constexpr long OFF_BLEEDOUT_STATE")
m_xp=$(parse_hpp m_xp "constexpr long OFF_XPLEVEL")
m_weaponNameIndex=$(parse_hpp m_weaponNameIndex "constexpr long OFF_WEAPON_INDEX")
m_vecAbsVelocity=$(parse_hpp m_vecAbsVelocity "constexpr long OFF_ABSVELOCITY")
m_vecAbsOrigin=$(parse_hpp m_vecAbsOrigin "constexpr long OFF_LOCAL_ORIGIN")
m_bZooming=$(parse_hpp m_bZooming "constexpr long OFF_ZOOMING")
timeBase=$(parse_hpp timeBase "constexpr long OFF_TIME_BASE")
mp_gamemode=$(parse_hpp mp_gamemode "constexpr long OFF_GAMEMODE")

echo "#pragma once"
echo "// generated by ${target}"
echo "// [Miscellaneous]"
echo "constexpr char OFF_GAME_VERSION[] = \"${GameVersion}\"; //[Miscellaneous]->GameVersion"
echo "constexpr long OFF_ENTITY_LIST = ${cl_entitylist}; //[Miscellaneous]->cl_entitylist"
echo "constexpr long OFF_LOCAL_PLAYER = ${LocalPlayer}; //[Miscellaneous]->LocalPlayer"
echo "constexpr long OFF_GLOBAL_VARS = ${GlobalVars}; //[Miscellaneous]->GlobalVars"
echo "constexpr long OFF_NAMELIST = ${NameList}; //[Miscellaneous]->NameList"
echo "constexpr long OFF_VIEW_RENDER = ${ViewRender}; //[Miscellaneous]->ViewRender"
echo "constexpr long OFF_VIEW_MATRIX = ${ViewMatrix}; //[Miscellaneous]->ViewMatrix"
echo "constexpr long OFF_LEVEL = ${LevelName}; //[Miscellaneous]->LevelName"
if [[ "$projectile_launch_speed" == "" ]]; then
  m_flProjectileSpeed=$(sed -n -e "s/constexpr long OFF_PROJECTILESPEED\s*=\s*//p" Offsets.hpp)
  m_flProjectileSpeed=${m_flProjectileSpeed%%;*}
  echo "constexpr long OFF_PROJECTILESPEED = $m_flProjectileSpeed; //[Miscellaneous]->CWeaponX!m_flProjectileSpeed //[WeaponSettings]->projectile_launch_speed + [WeaponSettingsMeta]->base"
else
  echo "constexpr long OFF_PROJECTILESPEED = ${projectile_launch_speed%%[[:cntrl:]]} + ${base%%[[:cntrl:]]}; //[Miscellaneous]->CWeaponX!m_flProjectileSpeed //[WeaponSettings]->projectile_launch_speed + [WeaponSettingsMeta]->base"
fi
echo "constexpr long OFF_PROJECTILESCALE = OFF_PROJECTILESPEED + 0x8; //[Miscellaneous]->CWeaponX!m_flProjectileScale //[WeaponSettings]->projectile_gravity_scale + [WeaponSettingsMeta]->base"
echo "constexpr long OFF_CAMERAORIGIN = ${camera_origin}; //[Miscellaneous]->CPlayer!camera_origin"
echo "constexpr long OFF_STUDIOHDR = ${m_pStudioHdr}; //[Miscellaneous]->CBaseAnimating!m_pStudioHdr"
echo "// [Buttons]"
echo "constexpr long OFF_IN_ATTACK = ${in_attack}; //[Buttons]->in_attack"
echo "// [RecvTable.DT_BaseAnimating]"
if [[ "$m_nForceBone" == "" ]]; then
  m_nForceBone=$(sed -n -e "s/constexpr long OFF_BONES\s*=\s*//p" Offsets.hpp)
  m_nForceBone=${m_nForceBone%%;*}
  echo "constexpr long OFF_BONES = $m_nForceBone; //[RecvTable.DT_BaseAnimating]->m_nForceBone + 0x48"
else
  echo "constexpr long OFF_BONES = ${m_nForceBone%%[[:cntrl:]]} + 0x48; //[RecvTable.DT_BaseAnimating]->m_nForceBone + 0x48"
fi
echo "// [RecvTable.DT_BaseCombatCharacter]"
echo "constexpr long OFF_WEAPON_HANDLE = ${m_latestPrimaryWeapons}; //[RecvTable.DT_BaseCombatCharacter]->m_latestPrimaryWeapons"
echo "constexpr long OFF_GRENADE_HANDLE = ${m_latestNonOffhandWeapons}; //[RecvTable.DT_BaseCombatCharacter]->m_latestNonOffhandWeapons"
echo "constexpr long OFF_LAST_VISIBLE_TIME = ${lastVisibleTime}; //[Miscellaneous]->CPlayer!lastVisibleTime //[RecvTable.DT_BaseCombatCharacter]->m_hudInfo_visibilityTestAlwaysPasses + 0x2"
echo "constexpr long OFF_LAST_AIMEDAT_TIME = ${lastCrosshairTargetTime}; //[Miscellaneous]->CWeaponX!lastCrosshairTargetTime //[RecvTable.DT_BaseCombatCharacter]->m_hudInfo_visibilityTestAlwaysPasses + 0x2 + 0x8"
echo "// [RecvTable.DT_BaseEntity]"
echo "constexpr long OFF_CURRENT_SHIELDS = ${m_shieldHealth}; //[RecvTable.DT_BaseEntity]->m_shieldHealth"
echo "constexpr long OFF_TEAM_NUMBER = ${m_iTeamNum}; //[RecvTable.DT_BaseEntity]->m_iTeamNum"
echo "constexpr long OFF_SQUAD_ID = ${m_squadID}; //[RecvTable.DT_BaseEntity]->m_squadID"
echo "constexpr long OFF_NAME = ${m_iName}; //[RecvTable.DT_BaseEntity]->m_iName"
echo "constexpr long OFF_NAMEINDEX = 0x38; //[RecvTable.DT_BaseEntity]"
echo "// [RecvTable.DT_LocalPlayerExclusive]"
echo "constexpr long OFFSET_TRAVERSAL_PROGRESS = ${m_traversalProgress}; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalProgress"
echo "constexpr long OFFSET_TRAVERSAL_START_TIME = ${m_traversalStartTime}; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalStartTime"
echo "constexpr long OFFSET_TRAVERSAL_RELEASE_TIME = ${m_traversalReleaseTime}; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalReleaseTime"
echo "// [RecvTable.DT_Player]"
echo "constexpr long OFF_CURRENT_HEALTH = ${m_iHealth}; //[RecvTable.DT_Player]->m_iHealth"
echo "constexpr long OFF_LIFE_STATE = ${m_lifeState}; //[RecvTable.DT_Player]->m_lifeState"
echo "constexpr long OFF_BLEEDOUT_STATE = ${m_bleedoutState}; //[RecvTable.DT_Player]->m_bleedoutState"
echo "constexpr long OFF_XPLEVEL = ${m_xp}; //[RecvTable.DT_Player]->m_xp"
echo "// [RecvTable.DT_WeaponX]"
echo "constexpr long OFF_WEAPON_INDEX = ${m_weaponNameIndex}; //[RecvTable.DT_WeaponX]->m_weaponNameIndex"
echo "// [DataMap.C_BaseEntity]"
echo "constexpr long OFF_ABSVELOCITY = ${m_vecAbsVelocity}; //[DataMap.C_BaseEntity]->m_vecAbsVelocity"
echo "constexpr long OFF_LOCAL_ORIGIN = ${m_vecAbsOrigin}; //[DataMap.C_BaseEntity]->m_vecAbsOrigin"
echo "// [DataMap.C_Player]"
echo "constexpr long OFF_ZOOMING = ${m_bZooming}; //[DataMap.C_Player]->m_bZooming"
echo "constexpr long OFF_TIME_BASE = ${timeBase}; //[DataMap.C_Player]->m_currentFramePlayer.timeBase"
if [[ "$m_ammoPoolCount" == "" ]]; then
  m_ammoPoolCount=$(sed -n -e "s/constexpr long OFF_YAW\s*=\s*//p" Offsets.hpp)
  m_ammoPoolCount=${m_ammoPoolCount%%;*}
  echo "constexpr long OFF_YAW = $m_ammoPoolCount; //[DataMap.C_Player]->m_currentFramePlayer.m_ammoPoolCount - 0x8"
else
  echo "constexpr long OFF_YAW = ${m_ammoPoolCount%%[[:cntrl:]]} - 0x8; //[DataMap.C_Player]->m_currentFramePlayer.m_ammoPoolCount - 0x8"
fi
if [[ "$m_ammoPoolCapacity" == "" ]]; then
  m_ammoPoolCapacity=$(sed -n -e "s/constexpr long OFF_VIEW_ANGLES\s*=\s*//p" Offsets.hpp)
  m_ammoPoolCapacity=${m_ammoPoolCapacity%%;*}
  echo "constexpr long OFF_VIEW_ANGLES = $m_ammoPoolCapacity; //[DataMap.C_Player]->m_ammoPoolCapacity - 0x14"
else
  echo "constexpr long OFF_VIEW_ANGLES = ${m_ammoPoolCapacity%%[[:cntrl:]]} - 0x14; //[DataMap.C_Player]->m_ammoPoolCapacity - 0x14"
fi
echo "// [DataMap.WeaponPlayerData]"
if [[ "$m_playerData" == "" ]]; then
  m_playerData=$(sed -n -e "s/constexpr long OFF_ZOOM_FOV\s*=\s*//p" Offsets.hpp)
  m_playerData=${m_playerData%%;*}
  echo "constexpr long OFF_ZOOM_FOV = $m_playerData; //[RecvTable.DT_WeaponX]->m_playerData + [DataMap.WeaponPlayerData]->m_targetZoomFOV"
else
  echo "constexpr long OFF_ZOOM_FOV = ${m_playerData%%[[:cntrl:]]} + ${m_targetZoomFOV%%[[:cntrl:]]}; //[RecvTable.DT_WeaponX]->m_playerData + [DataMap.WeaponPlayerData]->m_targetZoomFOV"
fi
echo "// [ConVars]"
echo "constexpr long OFF_GAMEMODE = ${mp_gamemode}; //[ConVars]->mp_gamemode"
echo "// [Static]"
echo "constexpr long OFF_REGION = 0x140000000; //[Static]->Region"
echo "// [IDA]"
echo "constexpr long OFF_OBSERVER_LIST = 0x1f17fa8; //IDA signature >> [48 8B 0D ? ? ? ? 48 85 C9 74 ? 48 8B 01 FF ? ? 48 85 C0 74 ? 48 63 4E 38]"
echo "constexpr long OFF_OBSERVER_ARRAY = 0x964;// + 0x10;"
