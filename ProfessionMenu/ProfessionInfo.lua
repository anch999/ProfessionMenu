local PM = LibStub("AceAddon-3.0"):GetAddon("ProfessionMenu")

PM.profList = {
    {
        51304, -- Grand Master 450
        28596, -- Master 375
        11611, -- Artisan 300
        3464, -- Expert 225
        3101, -- Journeyman 150
        2259, -- Apprentice 75
    }, --ALCHEMY
    {
        51300, -- Grand Master 450
        29844, -- Master 375
        9785, -- Artisan 300
        3538, -- Expert 225
        3100, -- Journeyman 150
        2018, -- Apprentice 75
    }, --BLACKSMITHING
    {
        51313, -- Grand Master 450
        28029, -- Mater 375
        13920, -- Artisan 300
        7413, -- Expert 225
        7412, -- Journeyman 150
        7411, -- Apprentice 75
        rightClick = {_G["PROFESSIONMENU"]["Extractframe"], "Enchanting", "Left click to open Enchanting interface Right click to open the disenchanting interface"}
    }, --ENCHANTING
    {
        51306, -- Grand Master 450
        30350, -- Master 375
        12656, -- Artisan 300
        4038, -- Expert 225
        4037, -- Journeyman 150
        4036, -- Apprentice 75
    }, --ENGINEERING
    {
        45363, -- Grand Master 450
        45361, -- Master 375
        45360, -- Artisan 300
        45359, -- Expert 225
        45358, -- Journeyman 150
        45357, -- Apprentice 75
    }, --INSCRIPTION
    {
        51311, -- Grand Master 450
        28897, -- Master 375
        28895, -- Artisan 300
        28894, -- Expert 225
        25230, -- Journeyman 150
        25229, -- Apprentice 75
    }, --JEWELCRAFTING 
    {
        51302, -- Grand Master 450
        32549, -- Master 375
        10662, -- Artisan 300
        3811, -- Expert 225
        3104, -- Journeyman 150
        2108, -- Apprentice 75
    }, --LEATHERWORKING
    {
    2656,
    main = 50310 -- mining spellid for rank info
    }, --SMELTING
    {2383, Name = "Herbalism", Show = "showHerb" }, --Herbalism
    {
        51309, -- Grand Master 450
        26790, -- Master 375
        12180, -- Artisan 300
        3910, -- Expert 225
        3909, -- Journeyman 150
        3908, -- Apprentice 75
    }, --TAILORING
    {
        51296, -- Grand Master 450
        33359, -- Master 375
        18260, -- Artisan 300
        3413, -- Expert 225
        3102, -- Journeyman 150
        2550, -- Apprentice 75
    }, --COOKING
    {
        45542, -- Grand Master 450
        27028, -- Expert 375
        10846, -- Artisan 300
        7924, -- Expert 225
        3274, -- Journeyman 150
        3273, -- Apprentice 75
    }, --FIRSTAID
    {
        13977860,
        CraftingSpell = true
    }, --WOODCUTTING
}

local profCooldowns = {
    ["Enchanting"] = {
        28027, -- Prismatic Sphere 
        28028, -- Void Sphere 
        979343, -- Transmute: Forbidding Dread Dust 
        979341, -- Transmute: Forbidding Nether Shard 
        979342, -- Transmute: Forbidding Twisted Dust 
        979344, -- Transmute: Forbidding Void Dust 
    },
    ["Alchemy"] = {
        29688, -- Transmute: Primal Might 
        32765, -- Transmute: Earthstorm Diamond 
        32766, -- Transmute: Skyfire Diamond 
        28566, -- Transmute: Primal Air to Fire 
        28567, -- Transmute: Primal Earth to Water 
        28568, -- Transmute: Primal Fire to Earth 
        28569, -- Transmute: Primal Water to Air 
    },
    ["Jewelcrafting"] = {
        47280, -- Brilliant Glass 
        979840, -- Transmute: Pure Void Metal 
        979838, -- Transmute: Pure Twisted Metal 
        979837, -- Transmute: Pure Nether Metal 
        979839, -- Transmute: Pure Dread Metal 
    },
    ["Leatherworking"] = {
        979331, -- Transmute: Full Grain Dread Leather 
        979329, -- Transmute: Full Grain Nether Leather 
        979330, -- Transmute: Full Grain Twisted Leather 
        979332, -- Transmute: Full Grain Void Leather 
    },
    ["Tailoring"] = {
        26751, -- Primal Mooncloth 
        36686, -- Shadowcloth 
        31373, -- Spellcloth 
        979327, -- Transmute: Reinforced Dread Thread 
        979325, -- Transmute: Reinforced Nether Thread 
        979326, -- Transmute: Reinforced Void Thread 
        979328, -- Transmute: Reinforced Twisted Thread 
    },
    ["Engineering"] = {
        979835, -- Transmute: Pure Dread Metal 
        979833, -- Transmute: Pure Nether Metal 
        979836, -- Transmute: Pure Void Metal 
        979834, -- Transmute: Pure Twisted Metal 
    },
    ["Mining"] = {
        979337, -- Transmute: Pure Nether Metal 
    },
}

function PM:InitalizeProfessionCooldowns()
    self.ProfessionCooldowns = {}
    for profession, cooldowns in pairs(profCooldowns) do
        for _ , cdID in pairs (cooldowns) do
            local spellName = GetSpellInfo(cdID)
            self.ProfessionCooldowns[spellName] = {profession, cdID}
        end
    end
end

function PM:ScranProfessionCooldowns()

end