Config = {}

-- General Settings
Config.Debug = false

-- NPC Settings
Config.NPCSettings = {
    enabled = true,
    model = 'u_m_m_valgenstoreowner_01', -- Moonshiner NPC model (Valentine Store Owner)
    coords = vec4(1440.5, 308.5, 88.5, 270.0), -- Near Emerald Ranch barn (secluded, off road)
    scenario = 'WORLD_HUMAN_SMOKE_CIGAR',
    blip = {
        enabled = true,
        sprite = 'blip_shop_store',
        scale = 0.2,
        name = 'Moonshiner'
    }
}

-- Moonshine Props
Config.mashProp = "p_boxcar_barrel_09a" -- Mash barrel object
Config.brewProp = "mp001_p_mp_still02x" -- Moonshine still object

-- Mash Recipes
-- Define what mashes can be crafted and what items are needed
Config.mashes = {
    ['ginseng_mash'] = {
        label = "Ginseng Mash",
        items = {
            ['agarita'] = 2,
            ['alaskan_ginseng'] = 2,
            ['american_ginseng'] = 2,
            ['water'] = 1
        },
        mashTime = 0.3, -- time in minutes
        minXP = 2,
        maxXP = 5,
        output = 'ginseng_mash',
        outputAmount = 1
    },
    ['blackberry_mash'] = {
        label = "Black Berry Mash",
        items = {
            ['bay_bolete'] = 2,
            ['blackberry'] = 2,
            ['water'] = 1
        },
        mashTime = 1.3,
        minXP = 2,
        maxXP = 5,
        output = 'blackberry_mash',
        outputAmount = 1
    },
    ['alcohol'] = {
        label = "Alcohol Base",
        items = {
            ['yarrow'] = 4,
            ['water'] = 1
        },
        mashTime = 1.8,
        minXP = 2,
        maxXP = 5,
        output = 'alcohol',
        outputAmount = 1
    },
    ['minty_berry_mash'] = {
        label = "Minty Berry Mash",
        items = {
            ['black_currant'] = 2,
            ['evergreen_huckleberry'] = 2,
            ['wild_mint'] = 2
        },
        mashTime = 0.3,
        minXP = 2,
        maxXP = 5,
        output = 'minty_berry_mash',
        outputAmount = 1
    }
}

-- Moonshine Recipes
-- Define what moonshines can be crafted and what items are needed
Config.moonshine = {
    ['ginseng_moonshine'] = {
        label = "Ginseng Moonshine",
        items = {
            ['ginseng_mash'] = 2,
            ['alcohol'] = 1
        },
        brewTime = 2, -- time in minutes
        minXP = 2,
        maxXP = 5,
        output = 'ginseng_moonshine',
        outputAmount = 1
    },
    ['blackberry_moonshine'] = {
        label = "Black Berry Moonshine",
        items = {
            ['blackberry_mash'] = 2,
            ['alcohol'] = 2,
            ['water'] = 1
        },
        brewTime = 2,
        minXP = 2,
        maxXP = 5,
        output = 'blackberry_moonshine',
        outputAmount = 1
    },
    ['minty_berry_moonshine'] = {
        label = "Minty Berry Moonshine",
        items = {
            ['minty_berry_mash'] = 2,
            ['alcohol'] = 2
        },
        brewTime = 2,
        minXP = 2,
        maxXP = 5,
        output = 'minty_berry_moonshine',
        outputAmount = 1
    }
}

-- Shop Items
Config.ShopItems = {
    -- Equipment
    {
        name = 'mp001_p_mp_still02x',
        price = 2000,
        amount = 50,
        info = {},
        type = 'item',
        slot = 1,
    },
    {
        name = 'p_boxcar_barrel_09a',
        price = 500,
        amount = 50,
        info = {},
        type = 'item',
        slot = 2,
    },
    -- Basic Ingredients
    {
        name = 'water',
        price = 5,
        amount = 100,
        info = {},
        type = 'item',
        slot = 3,
    },
    {
        name = 'agarita',
        price = 10,
        amount = 50,
        info = {},
        type = 'item',
        slot = 4,
    },
    {
        name = 'alaskan_ginseng',
        price = 12,
        amount = 50,
        info = {},
        type = 'item',
        slot = 5,
    },
    {
        name = 'american_ginseng',
        price = 12,
        amount = 50,
        info = {},
        type = 'item',
        slot = 6,
    },
    {
        name = 'bay_bolete',
        price = 8,
        amount = 50,
        info = {},
        type = 'item',
        slot = 7,
    },
    {
        name = 'blackberry',
        price = 6,
        amount = 50,
        info = {},
        type = 'item',
        slot = 8,
    },
    {
        name = 'yarrow',
        price = 7,
        amount = 50,
        info = {},
        type = 'item',
        slot = 9,
    },
    {
        name = 'black_currant',
        price = 8,
        amount = 50,
        info = {},
        type = 'item',
        slot = 10,
    },
    {
        name = 'evergreen_huckleberry',
        price = 9,
        amount = 50,
        info = {},
        type = 'item',
        slot = 11,
    },
    {
        name = 'wild_mint',
        price = 7,
        amount = 50,
        info = {},
        type = 'item',
        slot = 12,
    },
}

-- Sell Prices (What the NPC will pay for your products)
-- NPC only buys finished moonshine, not mash or alcohol
Config.SellPrices = {
    -- Moonshine Products Only
    ['ginseng_moonshine'] = 100,
    ['blackberry_moonshine'] = 95,
    ['minty_berry_moonshine'] = 90,
}

-- Collectable Objects (optional - for harvesting in the world)
Config.collectableObjects = {
    ['goldencurrant_p'] = {
        label = "Currant Bush",
        items = {
            ['black_currant'] = 2
        }
    },
    ['blackcurrant_p'] = {
        label = "Currant Bush",
        items = {
            ['black_currant'] = 2
        }
    },
    ['s_inv_huckleberry01x'] = {
        label = "Blueberries Shrub",
        items = {
            ['blackberry'] = 2
        }
    },
    ['s_inv_raspberry01x'] = {
        label = "Raspberries Shrub",
        items = {
            ['blackberry'] = 2
        }
    }
}

-- Collectable Zones (optional - for harvesting in specific areas)
Config.collectableZones = {
    {
        point = vector3(-1983.08, 553.27, 116.05),
        radius = 15,
        items = {
            ['agarita'] = 1,
            ['alaskan_ginseng'] = 1
        }
    },
    {
        point = vector3(-2013.66, 529.29, 116.7),
        radius = 5,
        items = {
            ['american_ginseng'] = 1,
        }
    },
    {
        point = vector3(-2023.63, 534.62, 116.51),
        radius = 2.5,
        items = {
            ['blackberry'] = 2
        }
    },
    {
        point = vector3(-2010.58, 537.61, 116.43),
        radius = 3,
        items = {
            ['blackberry'] = 2,
            ['bay_bolete'] = 2
        }
    },
    {
        point = vector3(1304.39, 308.16, 88.19),
        radius = 7,
        items = {
            ['blackberry'] = 2,
            ['bay_bolete'] = 2
        }
    },
    {
        point = vector3(1306.49, 322.83, 88.0),
        radius = 10,
        items = {
            ['black_currant'] = 2,
            ['evergreen_huckleberry'] = 2
        }
    },
    {
        point = vector3(1287.65, 341.92, 90.15),
        radius = 15,
        items = {
            ['wild_mint'] = 2
        }
    }
}

-- Moonshine Selling System
Config.Selling = {
    enabled = true,
    command = 'sellmoonshine',
    
    -- Cities where selling is allowed
    allowedCities = {
        {name = "Valentine", coords = vector3(-281.0, 793.0, 118.0), radius = 150.0},
        {name = "Rhodes", coords = vector3(1225.0, -1305.0, 76.0), radius = 120.0},
        {name = "Saint Denis", coords = vector3(2632.0, -1312.0, 52.0), radius = 200.0},
        {name = "Blackwater", coords = vector3(-813.0, -1324.0, 43.0), radius = 130.0}
    },
    
    -- Buyer prices (higher than shop NPC)
    buyerPrices = {
        ['ginseng_moonshine'] = {min = 120, max = 150},      -- Shop: $100
        ['blackberry_moonshine'] = {min = 115, max = 145},   -- Shop: $95
        ['minty_berry_moonshine'] = {min = 110, max = 140}   -- Shop: $90
    },
    
    -- Purchase amounts (random)
    purchaseAmounts = {1, 5, 10},
    
    -- NPC settings
    npcModels = {
        'a_m_m_rhdcity_01',
        'a_m_m_valcity_01',
        'a_m_m_sdcity_01',
        'a_m_o_sdcity_01',
        'a_m_m_bwmworkers_01'
    },
    
    -- Timing
    timeBetweenBuyers = {min = 5000, max = 15000}, -- 5-15 seconds
    maxBuyersPerSession = 30,
    cooldownTime = 300000 -- 5 minutes between sessions
}
