#! /usr/bin/bash

me=$(basename "$0")
target="${me%.sh}"

GameVersion=$(sed -nr ":l /^GameVersion[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
cl_entitylist=$(sed -nr ":l /^cl_entitylist[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
LocalEntityHandle=$(sed -nr ":l /^LocalEntityHandle[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
LocalPlayer=$(sed -nr ":l /^LocalPlayer[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
GlobalVars=$(sed -nr ":l /^GlobalVars[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
NameList=$(sed -nr ":l /^NameList[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
ViewRender=$(sed -nr ":l /^ViewRender[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
ViewMatrix=$(sed -nr ":l /^ViewMatrix[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
LevelName=$(sed -nr ":l /^LevelName[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
projectile_launch_speed=$(sed -nr ":l /^projectile_launch_speed[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
base=$(sed -nr ":l /^base[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
camera_origin=$(sed -nr ":l /^CPlayer!camera_origin[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_pStudioHdr=$(sed -nr ":l /^CBaseAnimating!m_pStudioHdr[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_nForceBone=$(sed -nr ":l /^m_nForceBone[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_latestPrimaryWeapons=$(sed -nr ":l /^m_latestPrimaryWeapons[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_latestNonOffhandWeapons=$(sed -nr ":l /^m_latestNonOffhandWeapons[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
lastVisibleTime=$(sed -nr ":l /^CPlayer!lastVisibleTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
lastCrosshairTargetTime=$(sed -nr ":l /^CWeaponX!lastCrosshairTargetTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_shieldHealth=$(sed -nr ":l /^m_shieldHealth[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_iTeamNum=$(sed -nr ":l /^m_iTeamNum[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_squadID=$(sed -nr ":l /^m_squadID[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_iName=$(sed -nr ":l /^m_iName[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_traversalProgress=$(sed -nr ":l /^m_traversalProgress[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_traversalStartTime=$(sed -nr ":l /^m_traversalStartTime[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_iHealth=$(sed -nr ":l /^m_iHealth[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_lifeState=$(sed -nr ":l /^m_lifeState[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_bleedoutState=$(sed -nr ":l /^m_bleedoutState[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_xp=$(sed -nr ":l /^m_xp[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_iSignifierName=$(sed -nr "/^\[RecvTable.DT_PropSurvival\]/ { :l /^m_iSignifierName[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_customScriptInt=$(sed -nr ":l /^m_customScriptInt[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_weaponNameIndex=$(sed -nr "/^\[RecvTable.DT_WeaponX\]/ { :l /^m_weaponNameIndex[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_vecAbsOrigin=$(sed -nr "/^\[DataMap.C_BaseEntity\]/ { :l /^m_vecAbsOrigin[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;}" ./$target.txt)
m_bZooming=$(sed -nr ":l /^m_bZooming[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
timeBase=$(sed -nr ":l /^m_currentFramePlayer.timeBase[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_ammoPoolCount=$(sed -nr ":l /^m_currentFramePlayer.m_ammoPoolCount[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_ammoPoolCapacity=$(sed -nr ":l /^m_ammoPoolCapacity[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_playerData=$(sed -nr ":l /^m_playerData[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_targetZoomFOV=$(sed -nr ":l /^m_targetZoomFOV[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
mp_gamemode=$(sed -nr ":l /^mp_gamemode[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
gamepad_aim_assist_melee=$(sed -nr ":l /^gamepad_aim_assist_melee[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)
m_gameTimescale=$(sed -nr ":l /^m_gameTimescale[ ]*=/ { s/[^=]*=[ ]*//; p; q;}; n; b l;" ./$target.txt)

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
LocalEntityHandle=$(parse_hpp LocalEntityHandle "constexpr long OFF_LOCAL_ENTITY_HANDLE")
LocalPlayer=$(parse_hpp LocalPlayer "constexpr long OFF_LOCAL_PLAYER")
GlobalVars=$(parse_hpp GlobalVars "constexpr long OFF_GLOBAL_VARS")
NameList=$(parse_hpp NameList "constexpr long OFF_NAME_LIST")
ViewRender=$(parse_hpp ViewRender "constexpr long OFF_VIEW_RENDER")
ViewMatrix=$(parse_hpp ViewMatrix "constexpr long OFF_VIEW_MATRIX")
LevelName=$(parse_hpp LevelName "constexpr long OFF_LEVEL_NAME")
camera_origin=$(parse_hpp camera_origin "constexpr long OFF_CAMERA_ORIGIN")
m_pStudioHdr=$(parse_hpp m_pStudioHdr "constexpr long OFF_STUDIO_HDR")
m_latestPrimaryWeapons=$(parse_hpp m_latestPrimaryWeapons "constexpr long OFF_WEAPON_HANDLE")
m_latestNonOffhandWeapons=$(parse_hpp m_latestNonOffhandWeapons "constexpr long OFF_GRENADE_HANDLE")
lastVisibleTime=$(parse_hpp lastVisibleTime "constexpr long OFF_LAST_VISIBLE_TIME")
lastCrosshairTargetTime=$(parse_hpp lastCrosshairTargetTime "constexpr long OFF_LAST_AIMEDAT_TIME")
m_shieldHealth=$(parse_hpp m_shieldHealth "constexpr long OFF_SHIELD")
m_iTeamNum=$(parse_hpp m_iTeamNum "constexpr long OFF_TEAM_NUMBER")
m_squadID=$(parse_hpp m_squadID "constexpr long OFF_SQUAD_ID")
m_iName=$(parse_hpp m_iName "constexpr long OFF_NAME")
m_traversalProgress=$(parse_hpp m_traversalProgress "constexpr long OFF_TRAVERSAL_PROGRESS")
m_traversalStartTime=$(parse_hpp m_traversalStartTime "constexpr long OFF_TRAVERSAL_START_TIME")
m_iHealth=$(parse_hpp m_iHealth "constexpr long OFF_HEALTH")
m_lifeState=$(parse_hpp m_lifeState "constexpr long OFF_LIFE_STATE")
m_bleedoutState=$(parse_hpp m_bleedoutState "constexpr long OFF_BLEEDOUT_STATE")
m_xp=$(parse_hpp m_xp "constexpr long OFF_XP_LEVEL")
m_iSignifierName=$(parse_hpp m_iSignifierName "constexpr long OFF_SIGNIFIER_NAME")
m_customScriptInt=$(parse_hpp m_customScriptInt "constexpr long OFF_ITEM_HANDLE")
m_weaponNameIndex=$(parse_hpp m_weaponNameIndex "constexpr long OFF_WEAPON_INDEX")
m_vecAbsOrigin=$(parse_hpp m_vecAbsOrigin "constexpr long OFF_LOCAL_ORIGIN")
m_bZooming=$(parse_hpp m_bZooming "constexpr long OFF_ZOOMING")
timeBase=$(parse_hpp timeBase "constexpr long OFF_TIME_BASE")
mp_gamemode=$(parse_hpp mp_gamemode "constexpr long OFF_GAME_MODE")
gamepad_aim_assist_melee=$(parse_hpp gamepad_aim_assist_melee "constexpr long OFF_OBSERVER_LIST")
m_gameTimescale=$(parse_hpp m_gameTimescale "constexpr long OFF_OBSERVER_ARRAY")

cp Offsets.hpp Offsets.tmp
echo "#pragma once" > Offsets.hpp
echo "// generated by ${target}" >> Offsets.hpp
echo "// [Miscellaneous]" >> Offsets.hpp
echo "constexpr char OFF_GAME_VERSION[] = \"${GameVersion}\"; //[Miscellaneous]->GameVersion" >> Offsets.hpp
echo "constexpr long OFF_ENTITY_LIST = ${cl_entitylist}; //[Miscellaneous]->cl_entitylist" >> Offsets.hpp
echo "constexpr long OFF_LOCAL_ENTITY_HANDLE = ${LocalEntityHandle}; //[Miscellaneous]->LocalEntityHandle" >> Offsets.hpp
echo "constexpr long OFF_LOCAL_PLAYER = ${LocalPlayer}; //[Miscellaneous]->LocalPlayer" >> Offsets.hpp
echo "constexpr long OFF_GLOBAL_VARS = ${GlobalVars}; //[Miscellaneous]->GlobalVars" >> Offsets.hpp
echo "constexpr long OFF_NAME_LIST = ${NameList}; //[Miscellaneous]->NameList" >> Offsets.hpp
echo "constexpr long OFF_VIEW_RENDER = ${ViewRender}; //[Miscellaneous]->ViewRender" >> Offsets.hpp
echo "constexpr long OFF_VIEW_MATRIX = ${ViewMatrix}; //[Miscellaneous]->ViewMatrix" >> Offsets.hpp
echo "constexpr long OFF_LEVEL_NAME = ${LevelName}; //[Miscellaneous]->LevelName" >> Offsets.hpp
if [[ "$projectile_launch_speed" == "" ]] || [[ "$base" == "" ]] || [[ ${base%%[[:cntrl:]]} == 0x0000 ]]; then
  m_flProjectileSpeed=$(sed -n -e "s/constexpr long OFF_PROJECTILE_SPEED\s*=\s*//p" Offsets.tmp)
  m_flProjectileSpeed=${m_flProjectileSpeed%%;*}
  echo "constexpr long OFF_PROJECTILE_SPEED = $m_flProjectileSpeed; //[Miscellaneous]->CWeaponX!m_flProjectileSpeed //[WeaponSettings]->projectile_launch_speed + [WeaponSettingsMeta]->base" >> Offsets.hpp
else
  echo "constexpr long OFF_PROJECTILE_SPEED = ${projectile_launch_speed%%[[:cntrl:]]} + ${base%%[[:cntrl:]]}; //[Miscellaneous]->CWeaponX!m_flProjectileSpeed //[WeaponSettings]->projectile_launch_speed + [WeaponSettingsMeta]->base" >> Offsets.hpp
fi
echo "constexpr long OFF_PROJECTILE_SCALE = OFF_PROJECTILE_SPEED + 0x8; //[Miscellaneous]->CWeaponX!m_flProjectileScale //[WeaponSettings]->projectile_gravity_scale + [WeaponSettingsMeta]->base" >> Offsets.hpp
echo "constexpr long OFF_CAMERA_ORIGIN = ${camera_origin}; //[Miscellaneous]->CPlayer!camera_origin" >> Offsets.hpp
echo "constexpr long OFF_STUDIO_HDR = ${m_pStudioHdr}; //[Miscellaneous]->CBaseAnimating!m_pStudioHdr" >> Offsets.hpp
echo "// [RecvTable.DT_BaseAnimating]" >> Offsets.hpp
if [[ "$m_nForceBone" == "" ]]; then
  m_nForceBone=$(sed -n -e "s/constexpr long OFF_BONE\s*=\s*//p" Offsets.tmp)
  m_nForceBone=${m_nForceBone%%;*}
  echo "constexpr long OFF_BONE = $m_nForceBone; //[RecvTable.DT_BaseAnimating]->m_nForceBone + 0x48" >> Offsets.hpp
else
  echo "constexpr long OFF_BONE = ${m_nForceBone%%[[:cntrl:]]} + 0x48; //[RecvTable.DT_BaseAnimating]->m_nForceBone + 0x48" >> Offsets.hpp
fi
echo "// [RecvTable.DT_BaseCombatCharacter]" >> Offsets.hpp
echo "constexpr long OFF_WEAPON_HANDLE = ${m_latestPrimaryWeapons}; //[RecvTable.DT_BaseCombatCharacter]->m_latestPrimaryWeapons" >> Offsets.hpp
echo "constexpr long OFF_GRENADE_HANDLE = ${m_latestNonOffhandWeapons}; //[RecvTable.DT_BaseCombatCharacter]->m_latestNonOffhandWeapons" >> Offsets.hpp
echo "constexpr long OFF_LAST_VISIBLE_TIME = ${lastVisibleTime}; //[Miscellaneous]->CPlayer!lastVisibleTime //[RecvTable.DT_BaseCombatCharacter]->m_hudInfo_visibilityTestAlwaysPasses + 0x2" >> Offsets.hpp
echo "constexpr long OFF_LAST_AIMEDAT_TIME = ${lastCrosshairTargetTime}; //[Miscellaneous]->CWeaponX!lastCrosshairTargetTime //[RecvTable.DT_BaseCombatCharacter]->m_hudInfo_visibilityTestAlwaysPasses + 0x2 + 0x8" >> Offsets.hpp
echo "// [RecvTable.DT_BaseEntity]" >> Offsets.hpp
echo "constexpr long OFF_SHIELD = ${m_shieldHealth}; //[RecvTable.DT_BaseEntity]->m_shieldHealth" >> Offsets.hpp
echo "constexpr long OFF_TEAM_NUMBER = ${m_iTeamNum}; //[RecvTable.DT_BaseEntity]->m_iTeamNum" >> Offsets.hpp
echo "constexpr long OFF_SQUAD_ID = ${m_squadID}; //[RecvTable.DT_BaseEntity]->m_squadID" >> Offsets.hpp
echo "constexpr long OFF_NAME = ${m_iName}; //[RecvTable.DT_BaseEntity]->m_iName" >> Offsets.hpp
echo "constexpr long OFF_NAME_INDEX = 0x38; //[RecvTable.DT_BaseEntity]" >> Offsets.hpp
echo "// [RecvTable.DT_LocalPlayerExclusive]" >> Offsets.hpp
echo "constexpr long OFF_TRAVERSAL_PROGRESS = ${m_traversalProgress}; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalProgress" >> Offsets.hpp
echo "constexpr long OFF_TRAVERSAL_START_TIME = ${m_traversalStartTime}; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalStartTime" >> Offsets.hpp
echo "// [RecvTable.DT_Player]" >> Offsets.hpp
echo "constexpr long OFF_HEALTH = ${m_iHealth}; //[RecvTable.DT_Player]->m_iHealth" >> Offsets.hpp
echo "constexpr long OFF_LIFE_STATE = ${m_lifeState}; //[RecvTable.DT_Player]->m_lifeState" >> Offsets.hpp
echo "constexpr long OFF_BLEEDOUT_STATE = ${m_bleedoutState}; //[RecvTable.DT_Player]->m_bleedoutState" >> Offsets.hpp
echo "constexpr long OFF_XP_LEVEL = ${m_xp}; //[RecvTable.DT_Player]->m_xp" >> Offsets.hpp
echo "// [RecvTable.DT_PropSurvival]" >> Offsets.hpp
echo "constexpr long OFF_SIGNIFIER_NAME = ${m_iSignifierName}; //[RecvTable.DT_PropSurvival]->m_iSignifierName" >> Offsets.hpp
echo "constexpr long OFF_ITEM_HANDLE = ${m_customScriptInt}; //[RecvTable.DT_PropSurvival]->m_customScriptInt" >> Offsets.hpp
echo "// [RecvTable.DT_WeaponX]" >> Offsets.hpp
echo "constexpr long OFF_WEAPON_INDEX = ${m_weaponNameIndex}; //[RecvTable.DT_WeaponX]->m_weaponNameIndex" >> Offsets.hpp
echo "// [DataMap.C_BaseEntity]" >> Offsets.hpp
echo "constexpr long OFF_LOCAL_ORIGIN = ${m_vecAbsOrigin}; //[DataMap.C_BaseEntity]->m_vecAbsOrigin" >> Offsets.hpp
echo "// [DataMap.C_Player]" >> Offsets.hpp
echo "constexpr long OFF_ZOOMING = ${m_bZooming}; //[DataMap.C_Player]->m_bZooming" >> Offsets.hpp
echo "constexpr long OFF_TIME_BASE = ${timeBase}; //[DataMap.C_Player]->m_currentFramePlayer.timeBase" >> Offsets.hpp
if [[ "$m_ammoPoolCount" == "" ]]; then
  m_ammoPoolCount=$(sed -n -e "s/constexpr long OFF_YAW\s*=\s*//p" Offsets.tmp)
  m_ammoPoolCount=${m_ammoPoolCount%%;*}
  echo "constexpr long OFF_YAW = $m_ammoPoolCount; //[DataMap.C_Player]->m_currentFramePlayer.m_ammoPoolCount - 0x8" >> Offsets.hpp
else
  echo "constexpr long OFF_YAW = ${m_ammoPoolCount%%[[:cntrl:]]} - 0x8; //[DataMap.C_Player]->m_currentFramePlayer.m_ammoPoolCount - 0x8" >> Offsets.hpp
fi
if [[ "$m_ammoPoolCapacity" == "" ]]; then
  m_ammoPoolCapacity=$(sed -n -e "s/constexpr long OFF_VIEW_ANGLES\s*=\s*//p" Offsets.tmp)
  m_ammoPoolCapacity=${m_ammoPoolCapacity%%;*}
  echo "constexpr long OFF_VIEW_ANGLES = $m_ammoPoolCapacity; //[DataMap.C_Player]->m_ammoPoolCapacity - 0x14" >> Offsets.hpp
else
  echo "constexpr long OFF_VIEW_ANGLES = ${m_ammoPoolCapacity%%[[:cntrl:]]} - 0x14; //[DataMap.C_Player]->m_ammoPoolCapacity - 0x14" >> Offsets.hpp
fi
echo "// [DataMap.WeaponPlayerData]" >> Offsets.hpp
if [[ "$m_playerData" == "" ]]; then
  m_playerData=$(sed -n -e "s/constexpr long OFF_ZOOM_FOV\s*=\s*//p" Offsets.tmp)
  m_playerData=${m_playerData%%;*}
  echo "constexpr long OFF_ZOOM_FOV = $m_playerData; //[RecvTable.DT_WeaponX]->m_playerData + [DataMap.WeaponPlayerData]->m_targetZoomFOV" >> Offsets.hpp
else
  echo "constexpr long OFF_ZOOM_FOV = ${m_playerData%%[[:cntrl:]]} + ${m_targetZoomFOV%%[[:cntrl:]]}; //[RecvTable.DT_WeaponX]->m_playerData + [DataMap.WeaponPlayerData]->m_targetZoomFOV" >> Offsets.hpp
fi
echo "// [ConVars]" >> Offsets.hpp
echo "constexpr long OFF_GAME_MODE = ${mp_gamemode}; //[ConVars]->mp_gamemode" >> Offsets.hpp
echo "// [Static]" >> Offsets.hpp
echo "constexpr long OFF_REGION = 0x140000000; //[Static]->Region" >> Offsets.hpp
echo "// [IDA]" >> Offsets.hpp
if [[ "$gamepad_aim_assist_melee" == "" ]]; then
  gamepad_aim_assist_melee=$(sed -n -e "s/constexpr long OFF_OBSERVER_LIST\s*=\s*//p" Offsets.tmp)
  gamepad_aim_assist_melee=${gamepad_aim_assist_melee%%;*}
  echo "constexpr long OFF_OBSERVER_LIST = $gamepad_aim_assist_melee; //[ConVars]->gamepad_aim_assist_melee + 0x20c8 //IDA signature >> [48 8B 0D ? ? ? ? 48 85 C9 74 ? 48 8B 01 FF ? ? 48 85 C0 74 ? 48 63 4E 38]" >> Offsets.hpp
else
  echo "constexpr long OFF_OBSERVER_LIST = ${gamepad_aim_assist_melee%%[[:cntrl:]]} + 0x20c8; //[ConVars]->gamepad_aim_assist_melee + 0x20c8 //IDA signature >> [48 8B 0D ? ? ? ? 48 85 C9 74 ? 48 8B 01 FF ? ? 48 85 C0 74 ? 48 63 4E 38]" >> Offsets.hpp
fi
echo "constexpr long OFF_OBSERVER_ARRAY = ${m_gameTimescale}; //[RecvTable.DT_GlobalNonRewinding]->m_gameTimescale //IDA signature >> [8B 84 C8 ? ? ? ? 83 F8]" >> Offsets.hpp
