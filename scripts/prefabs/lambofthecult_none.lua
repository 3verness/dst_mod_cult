local assets =
{
	Asset( "ANIM", "anim/lambofthecult.zip" ),
	Asset( "ANIM", "anim/ghost_lambofthecult_build.zip" ),
}

local skins =
{
	normal_skin = "lambofthecult",
	ghost_skin = "ghost_lambofthecult_build",
}

return CreatePrefabSkin("lambofthecult_none",
{
	base_prefab = "lambofthecult",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"LAMBOFTHECULT", "CHARACTER", "BASE"},
	build_name_override = "lambofthecult",
	rarity = "Character",
})