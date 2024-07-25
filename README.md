# Modded Craftbot Recipes
 This custom game allows you to play Survival mode with mods, while also being able to craft the modded parts in the craftbot! It will take care of loading all available crafting recipes from compatible mods into the craftbot!

 ![Steam Downloads](https://img.shields.io/steam/downloads/2816900681)

# How to make your mod compatible
### Step 1: Create a folder named `CraftingRecipes` in the root directory of your mod.
![Guide1](https://github.com/QuestionableM/Modded-Craftbot-Recipes/blob/main/GuideImages/guide_image1.png)
### Step 2: Create a file named `craftbot.json`, `hideout.json` or `workbench.json` in the `CraftingRecipes` directory.
![Guide2](https://github.com/QuestionableM/Modded-Craftbot-Recipes/blob/main/GuideImages/guide_image2.png)

## Here's what each file corresponds to:
```
craftbot.json  -> adds your crafting recipes to the craftbot
hideout.json   -> adds your crafting recipes to the hideout trader
workbench.json -> adds your crafting recipes to the craftbot in the crashed ship
```

### Step 3: Add your own crafting recipes into the created file(s).
##### The following code block is an example of how your json file with crafting recipes should look like
```jsonc
[
	{
		//this is the uuid of your part
		"itemId": "00000000-0000-0000-0000-000000000000",
		"quantity": 1,
		"craftTime": 32,
		"ingredientList": [
			//this is where you define ingredients for your crafting recipe
			{
				"quantity": 10,
				"itemId": "00000000-0000-0000-0000-000000000000"
			},
			{
				"quantity": 2,
				"itemId": "00000000-0000-0000-0000-000000000000"
			}
		]
	}
]
```

# My crafting recipes are not showing up, what should i do?
If you've just created a new mod, you should contact `TechnologicNick#4045` first before doing any testing, as the mod database used by the custom game updates once per 12 hours and it might not contain the information about your mod.

If you have any other questions, feel free to join our [Modding Server](https://discord.gg/SVEFyus)

# Other Info
The mod preview image was made by [Dart Frog](https://steamcommunity.com/profiles/76561198318189561)
