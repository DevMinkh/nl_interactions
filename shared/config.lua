globalState = {}

globalState.timer = 1 -- Minutes to autospawn after coma. Default is 12
globalState.respawnCoords = vector3(-677.1683, 310.5062, 83.0840) -- where the player will spawn after timer is at 0
globalState.respawnHeading = 1.0148 -- heading for respawncoords

config = {}

--[[ basic settings ]]--
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
	
config.shopPharmacieCoords = vector4(-676.6450, 334.7412, 82.1, 175.4911)
config.pedModelPharma = 's_f_y_scrubs_01'
	
config.modelLitsBig = {'shmann_ehos_bed05'}
config.modelLits = {'shmann_ehos_couch01', 'shmann_ehos_couch02'}
config.modelLitsMorgue = {'v_med_cor_autopsytbl'}
config.modelLitsMorgueLittle = {'v_med_cor_emblmtable'}
config.modelWheelChair = {'prop_wheelchair_01'}

config.weaponList = {
    balle9mm0 = joaat("weapon_pistol"),
    balle9mm2 = joaat("weapon_combatpistol"),
    balle9mm3 = joaat("weapon_smg"),
    balle9mm4 = joaat("weapon_pistol_mk2"),
    balle9mm5 = joaat("weapon_minismg"),
    balle9mm6 = joaat("weapon_machinepistol"),
    balle9mm7 = joaat("weapon_ceramicpistol"),
    balle50acp = joaat("weapon_pistol50"),
    balle44 = joaat("WEAPON_REVOLVER"),
    balle45acp = joaat("weapon_snspistol"),
    balle45acp0 = joaat("weapon_heavypistol"),
    balle45acp2 = joaat("WEAPON_GUSENBERG"),
    balle45acp3 = joaat("weapon_microsmg"),
    balle556 = joaat("weapon_carbinerifle_mk2"),
    balle5562 = joaat("WEAPON_SPECIALCARBINE"),
    balle12G = joaat("weapon_pumpshotgun_mk2"),
    balle12G2 = joaat("weapon_dbshotgun"),
    balleplomb = joaat("weapon_musket"),
    griffe = joaat("weapon_knuckle"),
    coupure = joaat("weapon_knife"),
    coupure2 = joaat("weapon_switchblade"),
    bleu = joaat("weapon_golfclub"),
    bleu2 = joaat("weapon_bat"),
    bleu3 = joaat("weapon_nightstick"),
    bleu4 = joaat("weapon_flashlight"),
    brulure = joaat("WEAPON_MOLOTOV"),
    balle762 = joaat("WEAPON_ASSAULTRIFLE"),
    balle762NATO = joaat("WEAPON_SNIPERRIFLE"),
    poing = joaat("WEAPON_UNARMED"),
}

config.weapKo = {
    poing = joaat('WEAPON_UNARMED'),
    tonfa = joaat('WEAPON_NIGHTSTICK')
}

config.illegalTaskBlacklist = {

}