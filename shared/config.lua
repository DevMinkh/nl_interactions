--[[ GlobalState settings ]]--
GlobalState = {}

GlobalState.Timer = 1 -- Minutes to autospawn after coma. Default is 12
GlobalState.RespawnCoords = vector3(-677.1683, 310.5062, 83.0840) -- where the player will spawn after timer is at 0
GlobalState.RespawnHeading = 1.0148 -- heading for respawncoords

--[[ basic settings ]]--
config = {}

config.useRenzuHud = true -- if u use renzu_hud and renzu_hygene (reset status at respawn)

config.jobName = 'ambulance'
config.bleedoutTimer = 30

config.reviveRewardPlayer = 700
config.reviveRewardSociety = 700
	
config.blipsHospital = {
    position = vector3(-676.3265, 320.2641, 83.0832),
    title = "Hospital",
    sprite = 61,
    colour = 1,
    scale = 0.8,
    display = 4,
    shortRange = true,
}

Config.BlipsPsy = {
    position = vector3(-1905.6453, -573.2115, 19.0972),
    title = "Psychologie",
    sprite = 362,
    colour = 1,
    scale = 0.7,
    display = 4,
    shortRange = true,
}
	
config.shopPharmacieCoords = vector4(-676.6450, 334.7412, 82.1, 175.4911)
config.pedModelPharma = 's_f_y_scrubs_01'
	
config.modelLitsBig = {'shmann_ehos_bed05'}
config.modelLits = {'shmann_ehos_couch01', 'shmann_ehos_couch02'}
config.modelLitsMorgue = {'v_med_cor_autopsytbl'}
config.modelLitsMorgueLittle = {'v_med_cor_emblmtable'}
config.modelWheelChair = {'prop_wheelchair_01'}

config.weaponList = {
	ammo9_1 = joaat("WEAPON_APPISTOL"),
	ammo9_2 = joaat("WEAPON_CERAMICPISTOL"),
	ammo9_3 = joaat("WEAPON_COMBATPDW"),
	ammo9_4 = joaat("WEAPON_COMBATPISTOL"),
	ammo9_5 = joaat("WEAPON_MACHINEPISTOL"),
	ammo9_6 = joaat("WEAPON_MINISMG"),
	ammo9_7 = joaat("WEAPON_GADGETPISTOL"),
	ammo9_8 = joaat("WEAPON_PISTOL"),
	ammo9_9 = joaat("WEAPON_PISTOL_MK2"),
	ammo9_10 = joaat("WEAPON_SMG"),
	ammo9_11 = joaat("WEAPON_SMG_MK2"),
	ammo9_12 = joaat("WEAPON_VINTAGEPISTOL"),
	ammorifle_1 = joaat("WEAPON_ADVANCEDRIFLE"),
	ammorifle_2 = joaat("WEAPON_ASSAULTSMG"),
	ammorifle_3 = joaat("WEAPON_BULLPUPRIFLE"),
	ammorifle_4 = joaat("WEAPON_BULLPUPRIFLE_MK2"),
	ammorifle_5 = joaat("WEAPON_CARBINERIFLE"),
	ammorifle_6 = joaat("WEAPON_CARBINERIFLE_MK2"),
	ammorifle_7 = joaat("WEAPON_COMBATMG"),
	ammorifle_8 = joaat("WEAPON_HEAVYRIFLE"),
	ammorifle_9 = joaat("WEAPON_MILITARYRIFLE"),
	ammorifle_10 = joaat("WEAPON_SPECIALCARBINE"),
	ammorifle_11 = joaat("WEAPON_SPECIALCARBINE_MK2"),
	ammorifle_12 = joaat("WEAPON_TACTICALRIFLE"),
	ammorifle2_1 = joaat("WEAPON_ASSAULTRIFLE"),
	ammorifle2_2 = joaat("WEAPON_ASSAULTRIFLE_MK2"),
	ammorifle2_3 = joaat("WEAPON_COMBATMG_MK2"),
	ammorifle2_4 = joaat("WEAPON_COMPACTRIFLE"),
	ammorifle2_5 = joaat("WEAPON_MG"),
	ammoshotgun_1 = joaat("WEAPON_ASSAULTSHOTGUN"),
	ammoshotgun_2 = joaat("WEAPON_BULLPUPSHOTGUN"),
	ammoshotgun_3 = joaat("WEAPON_COMBATSHOTGUN"),
	ammoshotgun_4 = joaat("WEAPON_DBSHOTGUN"),
	ammoshotgun_5 = joaat("WEAPON_HEAVYSHOTGUN"),
	ammoshotgun_6 = joaat("WEAPON_PUMPSHOTGUN"),
	ammoshotgun_7 = joaat("WEAPON_PUMPSHOTGUN_MK2"),
	ammoshotgun_8 = joaat("WEAPON_SAWNOFFSHOTGUN"),
	ammoshotgun_9 = joaat("WEAPON_AUTOSHOTGUN"),
	ammo22_1 = joaat("WEAPON_MARKSMANPISTOL"),
	ammo38_1 = joaat("WEAPON_DOUBLEACTION"),
	ammo44_1 = joaat("WEAPON_NAVYREVOLVER"),
	ammo44_2 = joaat("WEAPON_REVOLVER"),
	ammo44_3 = joaat("WEAPON_REVOLVER_MK2"),
	ammo45_1 = joaat("WEAPON_GUSENBERG"),
	ammo45_2 = joaat("WEAPON_HEAVYPISTOL"),
	ammo45_3 = joaat("WEAPON_MICROSMG"),
	ammo45_4 = joaat("WEAPON_SNSPISTOL"),
	ammo45_5 = joaat("WEAPON_SNSPISTOL_MK2"),
	ammo50_1 = joaat("WEAPON_PISTOL50"),
	ammomusket_1 = joaat("WEAPON_MUSKET"),
	ammosniper_1 = joaat("WEAPON_MARKSMANRIFLE"),
	ammosniper_2 = joaat("WEAPON_MARKSMANRIFLE_MK2"),
	ammosniper_3 = joaat("WEAPON_SNIPERRIFLE"),
	ammosniper_4 = joaat("WEAPON_PRECISIONRIFLE"),
	ammoheavysniper_1 = joaat("WEAPON_HEAVYSNIPER"),
	ammoheavysniper_2 = joaat("WEAPON_HEAVYSNIPER_MK2"),
	ammoemp_1 = joaat("WEAPON_EMPLAUNCHER"),
	melee_1 = joaat("WEAPON_BALL"),
	melee_2 = joaat("WEAPON_BAT"),
	melee_3 = joaat("WEAPON_BOTTLE"),
	melee_4 = joaat("WEAPON_CROWBAR"),
	melee_5 = joaat("WEAPON_FIREEXTINGUISHER"),
	melee_6 = joaat("WEAPON_FLASHLIGHT"),
	melee_7 = joaat("WEAPON_GOLFCLUB"),
	melee_8 = joaat("WEAPON_HAMMER"),
	melee_9 = joaat("WEAPON_HAZARDCAN"),
	melee_10 = joaat("WEAPON_METALDETECTOR"),
	melee_11 = joaat("WEAPON_FERTILIZERCAN"),
	melee_12 = joaat("WEAPON_KNUCKLE"),
	melee_13 = joaat("WEAPON_NIGHTSTICK"),
	melee_14 = joaat("WEAPON_PETROLCAN"),
	melee_15 = joaat("WEAPON_POOLCUE"),
	melee_16 = joaat("WEAPON_WRENCH"),
	knife_1 = joaat("WEAPON_BATTLEAXE"),
	knife_2 = joaat("WEAPON_DAGGER"),
	knife_3 = joaat("WEAPON_HATCHET"),
	knife_4 = joaat("WEAPON_KNIFE"),
	knife_5 = joaat("WEAPON_MACHETE"),
	knife_6 = joaat("WEAPON_STONE_HATCHET"),
	knife_7 = joaat("WEAPON_SWITCHBLADE"),
	gas_1 = joaat("WEAPON_BZGAS"),
	gas_2 = joaat("WEAPON_SMOKEGRENADE"),
	fire_1 = joaat("WEAPON_FIREWORK"),
	fire_2 = joaat("WEAPON_FLARE"),
	fire_3 = joaat("WEAPON_MOLOTOV"),
	ammoflare_1 = joaat("WEAPON_FLAREGUN"),
	grenade_1 = joaat("WEAPON_GRENADE"),
	grenade_2 = joaat("WEAPON_PIPEBOMB"),
	mine_1 = joaat("WEAPON_PROXMINE"),
	mine_2 = joaat("WEAPON_STICKYBOMB"),
	snow_1 = joaat("WEAPON_SNOWBALL"),
	stun_1 = joaat("WEAPON_STUNGUN"),
	barehand_1 = joaat("WEAPON_UNARMED")
}

config.weapKo = {
    poing = joaat('WEAPON_UNARMED'),
    tonfa = joaat('WEAPON_NIGHTSTICK')
}

config.illegalTaskBlacklist = {

}