// Game Version: v.3.0.70.55
#pragma once
constexpr long OFF_REGION = 0x140000000; //[Static]->Region
constexpr long OFF_LEVEL = 0x17c7160; //[Miscellaneous]->LevelName
constexpr long OFF_LOCAL_PLAYER = 0x225a8a8; //[Miscellaneous]->LocalPlayer
constexpr long OFF_ENTITY_LIST = 0x1eabd08; //[Miscellaneous]->cl_entitylist
constexpr long OFF_GLOBAL_VARS = 0x17c6c60; //[Miscellaneous]->GlobalVars
constexpr long OFF_NAMELIST = 0xc7912b0; //[Miscellaneous]->NameList

// Buttons
constexpr long OFF_IN_ATTACK = 0x074de2a0; //[Buttons]->in_attack
constexpr long OFF_IN_JUMP = 0x074de3a0; //[Buttons]->in_jump
constexpr long OFF_IN_DUCK = 0x074de4a0; //[Buttons]->in_duck
constexpr long OFFSET_IN_FORWARD = 0x074de1f0; //[Buttons]->in_forward
constexpr long OFFSET_TRAVERSAL_START_TIME = 0x2af0; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalStartTime
constexpr long OFFSET_TRAVERSAL_PROGRESS = 0x2aec; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalProgress
constexpr long OFFSET_TRAVERSAL_RELEASE_TIME = 0x2af8; //[RecvTable.DT_LocalPlayerExclusive]->m_traversalReleaseTime
constexpr long OFFSET_WALL_RUN_START_TIME = 0x3594; //[RecvTable.DT_LocalPlayerExclusive]->m_wallRunStartTime
constexpr long OFFSET_WALL_RUN_CLEAR_TIME = 0x3598; //RecvTable.DT_LocalPlayerExclusive]->m_wallRunClearTime

// Player
constexpr long OFF_VIEW_MATRIX = 0x11a350; //[RecvTable.DT_Player]->ViewMatrix
constexpr long OFF_VIEW_RENDER = 0x74dd028; //[RecvTable.DT_Player]->ViewRender
constexpr long OFF_VIEW_MODELS = 0x2d18; //[RecvTable.DT_Player]->m_hViewModels
constexpr long OFF_ZOOMING = 0x1bd1; //[RecvTable.DT_Player]->m_bZooming
constexpr long OFF_LOCAL_ORIGIN = 0x017c; //[DataMap.CBaseViewModel]->m_vecAbsOrigin
constexpr long OFF_ABSVELOCITY = 0x0170; //[DataMap.C_BaseEntity]->m_vecAbsVelocity
constexpr long OFF_TEAM_NUMBER = 0x0328; //[RecvTable.DT_BaseEntity]->m_iTeamNum
constexpr long OFF_CURRENT_HEALTH = 0x0318; //[RecvTable.DT_BaseEntity]->m_iHealth
constexpr long OFF_CURRENT_SHIELDS = 0x01a0; //[RecvTable.DT_BaseEntity]->m_shieldHealth
constexpr long OFF_NAME = 0x0471; //[RecvTable.DT_BaseEntity]->m_iName
constexpr long OFF_SIGNIFIER_NAME = 0x0468; //[RecvTable.DT_BaseEntity]->m_iSignifierName
constexpr long OFF_LIFE_STATE = 0x0680; //[RecvTable.DT_Player]->m_lifeState
constexpr long OFF_BLEEDOUT_STATE = 0x26e0; //[RecvTable.DT_Player]->m_bleedoutState
constexpr long OFF_LAST_VISIBLE_TIME = 0x1990; //[RecvTable.DT_BaseCombatCharacter]->CPlayer!lastVisibleTime // m_hudInfo_visibilityTestAlwaysPasses + 0x2
constexpr long OFF_LAST_AIMEDAT_TIME = 0x1990 + 0x8; //[RecvTable.DT_BaseCombatCharacter]->CPlayer!lastVisibleTime + 0x8 // m_hudInfo_visibilityTestAlwaysPasses + 0x2 + 0x8
constexpr long OFF_VIEW_ANGLES = 0x2534 - 0x14; //[DataMap.C_Player]->m_ammoPoolCapacity - 0x14
constexpr long OFF_PUNCH_ANGLES = 0x2438; //[DataMap.C_Player]->m_currentFrameLocalPlayer.m_vecPunchWeapon_Angle
constexpr long OFF_BREATH_ANGLES = (OFF_VIEW_ANGLES - 0x10);
constexpr long OFF_STUDIOHDR = 0xff0; //[Miscellaneous]->CBaseAnimating!m_pStudioHdr
constexpr long OFF_BONES = 0x0da0 + 0x48; //[RecvTable.DT_BaseAnimating]->m_nForceBone + 0x48
constexpr long OFF_CAMERAORIGIN = 0x1ed0; //[Miscellaneous]->CPlayer!camera_origin
constexpr long OFF_MODELNAME = 0x0030; //[DataMap.C_BaseEntity]->m_ModelName
constexpr long OFF_YAW = 0x223c - 0x8; //[DataMap.C_Player]=>m_currentFramePlayer.m_ammoPoolCount - 0x8
constexpr long OFF_NAMEINDEX = 0x38; //[RecvTable.DT_BaseEntity]
constexpr long OFF_XPLEVEL = 0x36a4; //m_xp
constexpr long OFF_SQUAD_ID = 0x0334; //m_squadID
constexpr long OFF_GAMEMODE = 0x022921b0; //mp_gamemode
constexpr long OFF_SPECTATOR_LIST = 0x1EADD28; //IDA signtature -> [48 8B 0D ? ? ? ? 48 85 C9 74 ? 48 8B 01 FF ? ? 48 85 C0 74 ? 48 63 4E 38]

// Weapon
constexpr long OFF_WEAPON_HANDLE = 0x1934; //[RecvTable.DT_BaseCombatCharacter]->m_latestPrimaryWeapons
constexpr long OFF_WEAPON_INDEX = 0x1778; //[RecvTable.DT_WeaponX]->m_weaponNameIndex
constexpr long OFFSET_AMMO = 0x1580; //[DataMap.CWeaponX]->m_ammoInClip
constexpr long OFF_GRENADE_HANDLE = 0x1944; //[RecvTable.DT_Player]->m_latestNonOffhandWeapons
constexpr long OFF_SKIN = 0x0d58; //[RecvTable.DT_BaseAnimating]->m_nSkin
constexpr long OFF_WEAPON_DISCARDED = 0x1599; //[RecvTable.DT_WeaponX]->m_discarded
constexpr long OFFSET_TIME_BASE = 0x2088; //[RecvTable.DT_Player]->m_currentFramePlayer.timeBase
constexpr long OFF_PROJECTILESCALE = 0x1eac; //CWeaponX!m_flProjectileScale //[WeaponSettings]->projectile_gravity_scale + [WeaponSettingsMeta].base
constexpr long OFF_PROJECTILESPEED = 0x1ea4; //CWeaponX!m_flProjectileSpeed //[WeaponSettings]->projectile_launch_speed + [WeaponSettingsMeta].base

// Glow
constexpr long HIGHLIGHT_TYPE_SIZE = 0x34;
constexpr long OFF_GLOW_THROUGH_WALL = 0x26c; //[DT_HighlightSettings].?
constexpr long OFF_GLOW_FIX = 0x268;
constexpr long OFF_GLOW_HIGHLIGHT_ID = 0x28C; //[DT_HighlightSettings].m_highlightServerActiveStates
constexpr long OFF_GLOW_HIGHLIGHTS = 0xade5c40; //

// HUD
constexpr long OFF_VIEWRENDER = 0x74dd028; //[Miscellaneous]->ViewRenderer
constexpr long OFF_VIEWMATRIX = 0x11a350;  //[Miscellaneous]->ViewMatrix
