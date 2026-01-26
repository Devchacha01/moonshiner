# Moonshiner System by devchacha

A comprehensive moonshiner script for RedM servers using RSG-Core framework. Craft mash, brew moonshine, and sell your products with a complete NPC shop system.

## Features

✅ **NPC Shop System** - Buy all ingredients and equipment from a dedicated moonshiner NPC  
✅ **Sell System** - Sell your moonshine and mash to the NPC or street buyers  
✅ **Placeable Props** - Place moonshine stills and mash barrels anywhere  
✅ **Mash Production** - Create different types of mash from gathered ingredients  
✅ **Moonshine Brewing** - Distill mash into premium moonshine  
✅ **"Fill the Mash" Mini-Game** - Interactive pouring mini-game (Hold Space to fill, hit the target zone!)  
✅ **Reward Tiers** - Performance-based brewing yields:
    - **Fail**: 2-3 bottles
    - **Success**: 4-7 bottles
    - **Perfect**: 10-12 bottles
✅ **Smoke Effects** - Dark smoke column rises from brewing stills (visible from far away)  
✅ **Destroy Still** - Blow up your still with a 10-second fuse if you need to destroy evidence  
✅ **Multiple Recipes** - Various mash and moonshine recipes (easily expandable)  
✅ **Street Selling** - Sell directly to NPCs for better prices with immersive animations  
✅ **Police Alerts** - Chance of alerting law enforcement during street sales  
✅ **Drunk Effects** - Buyers get visibly drunk and may pass out  
✅ **Progress Bars** - Custom Wild West themed UI during production  
✅ **Target System** - Interact with NPC using rsg-target  
✅ **Database Persistence** - Props are saved and restored  
✅ **Fully Configurable** - Easy to customize recipes, prices, and locations  
✅ **Authentic Props** - Uses verified moonshine jug checks to ensure drinking animations look great

## Dependencies

- [rsg-core](https://github.com/Rexshack-RedM/rsg-core)
- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [rsg-target](https://github.com/Rexshack-RedM/rsg-target)

## Installation
rename the folder as rsg-moonshiner
1. **Download and Extract**
   - Download the `rsg-moonshiner` folder
   - Place it in your server's `resources` folder

2. **Database Setup**
   - Import `moonshiner.sql` into your database

3. **Add Items**
   - Open `items.lua` and copy all items
   - Add them to your `rsg-core/shared/items.lua` file

4. **Configure the Script**
   - Edit `config.lua` to customize:
     - NPC location and model
     - Shop items and prices
     - Sell prices for moonshine and mash
     - Mash and moonshine recipes
     - Production times

5. **Add to server.cfg**
   ```
   ensure rsg-moonshiner
   ```

6. **Restart Server**

## Usage

### For Players

**Buying Equipment:**
1. Find the Moonshiner NPC (marked on map)
2. Use third-eye on the NPC
3. Select "Browse Moonshiner Shop"
4. Purchase a Moonshine Still and/or Mash Barrel

**Placing Equipment:**
1. Use the Still or Barrel from your inventory
2. Position it (ENTER to confirm, BACKSPACE to cancel)
3. Wait for placement animation

**Making Mash:**
1. Approach a placed Mash Barrel
2. Use third-eye (ALT) on the barrel
3. Select "Use Mash Barrel"
4. Select the mash type
5. Wait for production to complete

**Brewing Moonshine (Mini-Game):**
1. Approach a placed Moonshine Still
2. Use third-eye (ALT) on the still
3. Select "Use Moonshine Still"
4. Select the moonshine type
5. **Fill the Mash**: Hold **SPACE** to pour mash into the barrel.
   - **Target**: Release SPACE when the fill level is in the green zone (70-85%).
   - **Perfect**: Hit the small "Sweet Spot" (76-79%) for massive rewards!
   - **Fail**: Overfill or underfill and lose potential product.
6. The still will smoke while brewing.
7. **Cancel**: Press **BACKSPACE** or **ESC** during the brewing bar to abort the process.

**Drinking Moonshine:**
- Use the item in your inventory.
- Character drinks from a large moonshine jug (`p_jug01x`).
- **Effects**: Screen blur, wobble, passing out, and waking up in random locations (Rhodes) if you drink too much!

**Removing Equipment:**
1. Use third-eye on the equipment
2. Select "Remove Still" or "Remove Barrel"
3. Equipment returns to your inventory

**Destroying Still:**
1. Use third-eye on the still
2. Select "Destroy Still"
3. RUN! 10 seconds until explosion!

### Street Selling

**Commands:**
- `/sellmoonshine` - Start looking for buyers in a city
- `/stopsellingmoonshine` - Stop the selling session
- `/checkprops` - (Debug) Check which bottle/jug props are valid on the server

**How it works:**
1. Go to Valentine, Rhodes, Saint Denis, or Blackwater
2. Type `/sellmoonshine`
3. Wait for NPCs to approach you
4. Accept or decline their offer

**Features:**
- Better prices than shop ($110-$150 per bottle)
- Bulk sales (1, 5, or 10 bottles)
- Immersive animations
- Buyers get drunk and stumble away
- 20% chance buyer passes out
- 30% chance of police alert per sale

## Adding New Recipes

The UI automatically updates when you add new recipes. Simply edit `config.lua`:

```lua
Config.moonshine = {
    ['new_moonshine'] = {
        label = "New Moonshine",
        items = {
            ['new_mash'] = 1,
            ['alcohol'] = 1,
        },
        brewTime = 2.0,
        minXP = 5,
        maxXP = 10,
        output = 'new_moonshine',
        outputAmount = 1
    },
}
```

## Configuration

### NPC Settings
- **Model**: NPC character model
- **Coords**: Location and heading
- **Blip**: Map blip settings

### Selling Settings
- **Allowed Cities**: Define selling locations
- **Prices**: Min/max price per bottle
- **Police Chance**: Alert probability

### Recipes
- **Mash Recipes**: Ingredients and production time
- **Moonshine Recipes**: Mash requirements and brewing time

## Troubleshooting

**NPC doesn't spawn:**
- Check rsg-target is installed
- Verify NPC model name
- Check server console

**Can't interact with props:**
- Get closer (1.5 units)
- Restart the resource

**Street selling not working:**
- Must be in allowed city
- Need moonshine in inventory
- Wait for cooldown

**Items not showing:**
- Add items to rsg-core/shared/items.lua
- Restart rsg-core

## Credits

**Developed by devchacha**

Enjoy your moonshining business! 🥃
