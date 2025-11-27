-- RSG-Moonshiner Items
-- Add these items to your rsg-core/shared/items.lua file
-- Format matches rsg-core single-line style

-- Equipment
mp001_p_mp_still02x   = { name = 'mp001_p_mp_still02x',   label = 'Moonshine Still',       weight = 5000, type = 'item', image = 'mp001_p_mp_still02x.png',     unique = false, useable = true,  shouldClose = true, combinable = nil, description = 'A portable moonshine distillery' },
p_boxcar_barrel_09a   = { name = 'p_boxcar_barrel_09a',   label = 'Mash Barrel',           weight = 3000, type = 'item', image = 'moonshine_barrel.png',        unique = false, useable = true,  shouldClose = true, combinable = nil, description = 'A barrel for making mash' },

-- Basic Ingredients (Note: water and blackberry already exist in rsg-core, don't duplicate)
agarita               = { name = 'agarita',               label = 'Agarita',               weight = 50,   type = 'item', image = 'agarita.png',                 unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Agarita berries' },
alaskan_ginseng       = { name = 'alaskan_ginseng',       label = 'Alaskan Ginseng',       weight = 50,   type = 'item', image = 'Alaskan_Ginseng.png',         unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Alaskan Ginseng root' },
american_ginseng      = { name = 'american_ginseng',      label = 'American Ginseng',      weight = 50,   type = 'item', image = 'American_Ginseng.png',        unique = false, useable = false, shouldClose = true, combinable = nil, description = 'American Ginseng root' },
bay_bolete            = { name = 'bay_bolete',            label = 'Bay Bolete',            weight = 50,   type = 'item', image = 'Bay_Bolete.png',              unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Bay Bolete mushroom' },
yarrow                = { name = 'yarrow',                label = 'Yarrow',                weight = 50,   type = 'item', image = 'Yarrow.png',                  unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Yarrow herb' },
black_currant         = { name = 'black_currant',         label = 'Black Currant',         weight = 50,   type = 'item', image = 'Black_Currant.png',           unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Black currant berries' },
evergreen_huckleberry = { name = 'evergreen_huckleberry', label = 'Evergreen Huckleberry', weight = 50,   type = 'item', image = 'Evergreen_Huckleberry.png',   unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Evergreen huckleberries' },
wild_mint             = { name = 'wild_mint',             label = 'Wild Mint',             weight = 50,   type = 'item', image = 'Wild_Mint.png',               unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Wild mint leaves' },

-- Mash Products
ginseng_mash          = { name = 'ginseng_mash',          label = 'Ginseng Mash',          weight = 500,  type = 'item', image = 'ginseng_mash.png',            unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Fermented ginseng mash' },
blackberry_mash       = { name = 'blackberry_mash',       label = 'Blackberry Mash',       weight = 500,  type = 'item', image = 'blackberry_mash.png',         unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Fermented blackberry mash' },
minty_berry_mash      = { name = 'minty_berry_mash',      label = 'Minty Berry Mash',      weight = 500,  type = 'item', image = 'minty_berry_mash.png',        unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Fermented minty berry mash' },
alcohol               = { name = 'alcohol',               label = 'Alcohol Base',          weight = 500,  type = 'item', image = 'alcohol.png',                 unique = false, useable = false, shouldClose = true, combinable = nil, description = 'Pure alcohol base' },

-- Moonshine Products (Useable - triggers drunk effects)
ginseng_moonshine     = { name = 'ginseng_moonshine',     label = 'Ginseng Moonshine',     weight = 500,  type = 'item', image = 'ginseng_moonshine.png',       unique = false, useable = true,  shouldClose = true, combinable = nil, description = 'Premium ginseng moonshine' },
blackberry_moonshine  = { name = 'blackberry_moonshine',  label = 'Blackberry Moonshine',  weight = 500,  type = 'item', image = 'blackberry_moonshine.png',    unique = false, useable = true,  shouldClose = true, combinable = nil, description = 'Sweet blackberry moonshine' },
minty_berry_moonshine = { name = 'minty_berry_moonshine', label = 'Minty Berry Moonshine', weight = 500,  type = 'item', image = 'minty_berry_moonshine.png',   unique = false, useable = true,  shouldClose = true, combinable = nil, description = 'Refreshing minty berry moonshine' },
