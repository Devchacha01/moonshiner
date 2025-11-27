# RSG-Moonshiner

A comprehensive moonshiner script for RedM servers using RSG-Core framework. This script allows players to craft mash and moonshine with a complete NPC shop system.

## Features

✅ **NPC Shop System** - Buy all ingredients and equipment from a dedicated moonshiner NPC
✅ **Sell System** - Sell your moonshine and mash back to the NPC for profit
✅ **Placeable Props** - Place moonshine stills and mash barrels anywhere
✅ **Mash Production** - Create different types of mash from gathered ingredients
✅ **Moonshine Brewing** - Distill mash into premium moonshine
✅ **Multiple Recipes** - Various mash and moonshine recipes to discover
✅ **Progress Bars** - Visual feedback during production using ox_lib
✅ **Target System** - Interact with NPC using rsg-target
✅ **Database Persistence** - Props are saved and restored on server restart
✅ **Fully Configurable** - Easy to customize recipes, prices, and locations

## Dependencies

- [rsg-core](https://github.com/Rexshack-RedM/rsg-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [rsg-target](https://github.com/Rexshack-RedM/rsg-target)

## Installation

1. **Download and Extract**
   - Download the `rsg-moonshiner` folder
   - Place it in your server's `resources` folder

2. **Database Setup**
   - Import `moonshiner.sql` into your database
   - This creates the table for storing placed props

3. **Add Items**
   - Open `items.lua` and copy all items
   - Add them to your `rsg-core/shared/items.lua` file

4. **Configure the Script**
   - Edit `config.lua` to customize:
     - NPC location and model
     - Shop items and prices
     - **Sell prices for moonshine and mash**
     - Mash and moonshine recipes
     - Production times
     - Collectable zones (optional)

5. **Add to server.cfg**
   ```
   ensure rsg-moonshiner
   ```

6. **Restart Server**
   - Restart your server or use `refresh` and `ensure rsg-moonshiner`

## Usage

### For Players

**Buying Equipment:**
1. Find the Moonshiner NPC (marked on map with blip)
2. Use third-eye (rsg-target) on the NPC
3. Select "Browse Moonshiner Shop"
4. Purchase a Moonshine Still and/or Mash Barrel

**Selling Products:**
1. Approach the Moonshiner NPC
2. Use third-eye (rsg-target) on the NPC
3. Select "Sell Moonshine & Mash"
4. Choose which products to sell
5. Receive cash payment instantly

**Placing Equipment:**
1. Use the Still or Barrel from your inventory
2. Position it where you want (use ENTER to confirm, BACKSPACE to cancel)
3. Wait for the placement animation to complete

**Making Mash:**
1. Approach a placed Mash Barrel
2. Use third-eye (ALT) on the barrel
3. Select "Use Mash Barrel"
4. Select the type of mash you want to make
5. Ensure you have the required ingredients
6. Wait for the production to complete

**Brewing Moonshine:**
1. Approach a placed Moonshine Still
2. Use third-eye (ALT) on the still
3. Select "Use Moonshine Still"
4. Select the type of moonshine you want to brew
5. Ensure you have the required mash and alcohol
6. Wait for the brewing time to complete
7. Return to collect your moonshine

**Removing Equipment:**
1. Approach the Still or Barrel
2. Use third-eye (ALT) on the equipment
3. Select "Use Moonshine Still" or "Use Mash Barrel"
4. Select "Remove Still" or "Remove Barrel" from the menu
5. The equipment will be returned to your inventory

### For Administrators

**Changing NPC Location:**
Edit `config.lua`:
```lua
Config.NPCSettings = {
    coords = vector4(x, y, z, heading),
    -- ... other settings
}
```

**Adding New Recipes:**
Edit `config.lua` and add to `Config.mashes` or `Config.moonshine`:
```lua
['new_mash'] = {
    label = "New Mash",
    items = {
        ['ingredient1'] = 2,
        ['ingredient2'] = 1,
    },
    mashTime = 1.0, -- minutes
    minXP = 2,
    maxXP = 5,
    output = 'new_mash',
    outputAmount = 1
},
```

**Adjusting Shop Prices:**
Edit `config.lua` in the `Config.ShopItems` section:
```lua
{
    name = 'item_name',
    price = 100, -- Change this
    amount = 50,
    -- ...
},
```

## Selling System

### **Street Selling** 🥃
Sell your moonshine directly to NPCs for higher profit than the shop!

**Commands:**
- `/sellmoonshine` - Start looking for buyers in a city
- `/stopsellingmoonshine` - Stop the selling session

**How it works:**
1. Go to **Valentine, Rhodes, Saint Denis, or Blackwater**
2. Type `/sellmoonshine`
3. Wait for NPCs to approach you (they are real pedestrians from the world)
4. Interact with them to see their offer
5. Accept or decline the deal

**Features:**
- **Better Prices**: Sell for $110-$150 per bottle (Shop pays ~$90-100)
- **Bulk Sales**: Buyers may want 1, 5, or 10 bottles at once
- **Immersive Animations**: 
  - Hand over the bottles
  - Watch the buyer drink it
  - Buyer gets **drunk** and stumbles away
  - 20% chance buyer **passes out** on the street!
- **Police Alerts** 🚨:
  - 30% chance of police being alerted per sale
  - Law enforcement gets a map blip and notification
  - "Suspicious activity" reported in your area

**Cooldowns:**
- 5 minutes between selling sessions
- 5-15 seconds between buyers
- Max 30 buyers per session

### **Shop Selling** 🏪
You can also sell bulk moonshine and mash to the Moonshiner NPC at the shop location for a safe, guaranteed (but lower) price.

## Configuration

### NPC Settings
- **Model**: NPC character model
- **Coords**: Location and heading
- **Scenario**: Animation/scenario for NPC
- **Blip**: Map blip settings

### Selling Settings
- **Allowed Cities**: Define which cities selling is allowed in
- **Prices**: Min/max price per bottle for street sales
- **Police Chance**: Probability of alerting law enforcement

### Recipes
- **Mash Recipes**: Define ingredients, production time, and output
- **Moonshine Recipes**: Define mash requirements and brewing time

### Shop Items
- **Equipment**: Stills and barrels
- **Ingredients**: All crafting materials
- **Prices**: Customizable for each item

## Troubleshooting

**NPC doesn't spawn:**
- Check that rsg-target is installed and started
- Verify the NPC model name is correct
- Check server console for errors

**Can't interact with props:**
- Make sure you're close enough (1.5 units)
- Check that the prop is properly placed
- Restart the resource

**Selling command not working:**
- Ensure you are inside one of the allowed cities
- Check if you have moonshine in your inventory
- Wait for the cooldown if you recently finished a session

**Items not showing in inventory:**
- Verify items are added to rsg-core/shared/items.lua
- Restart rsg-core after adding items
- Check item names match exactly (case-sensitive)

**Database errors:**
- Ensure moonshiner.sql is imported
- Check oxmysql is running
- Verify database connection in server.cfg

## Support

For issues, suggestions, or contributions:
- Create an issue on GitHub
- Join the RSG-Core Discord community

**Enjoy your moonshining business! 🥃**
