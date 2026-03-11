# Image to Starbound Converter

![Readme Icon](icon.png)

## Installing 

Download the fles and copy and paste the "imageBlock" folder to your mods folder (`/Starbound/mods/`).
When browsing your folder it should look like 

## Description

This mod contains the tools needed to convert images into placeable blocks ingame, the **.exe** converts into ingame format and the **item** allows you to place it ingame.

## **Disclaimer**

I **do not** take any responsibility for any problems caused from this mod, I recommend **making a backup** of any world files you intend to place converted builds inside of prior to pasting any builds.
During the testing phase of this item I very occasionally ran into an issue where certain pasted builds would break my game and i had to delete the world file and start over.
I did not encounter this bug at all on the current build of the problem, i am simply stating this for the sake of transparency, if you dont want to have problems, back up your stuff.

## Guide on how to use

### Spawning the item

Once you have downloaded the mod and put "imageBlock" in your mods folder, it should look like `/mods/imageBlock/imageBlock/...`.
If you are not sure if it's in the right directory check your `starbound.log` and you should see "Root: Detected asset source named 'Image to Starbound Converter' at '..\mods\imageBlock'".

Once the mod is successfully installed, you need to spawn the item.
To do this you need to load onto your character, make sure you are in admin mode by typing "/admin", open the crafting menu and search for "BLOCK PASTER" and spawn it in, once its spawned you no longer need admin.

### Using the converter

To use the Image to Starbound Converter, browse to `/mods/imageBlock/imageBlock/ImageToStarbound.exe` and launch the program.
From here you can drag and drop any `.png/.jpg/.jpeg` files you wish to convert.
Once you have selected the image you wish to convert, select your desired settings (*guide on settings below*) and click the "`[Generate]`" button.

The output will get saved to `/mods/imageBlock/imageBlock/imageData.lua`.
From here all you need to do is type "/reload" if you are ingame or launch the game if you are not.
From here you can simply hold the pasting tool, then an interface should appear with two buttons for either *foreground* paste or *background* paste.
Select the paste layer, and **left click** to paste.

Enjoy!

### Paint

### Block settings

## Future plans

  - The code is currently not perfect and optimisations are in the plan for the future, including simply better written code on the item itself, fast placing and faster generating.
  - It currently is only working for Windows x64 but with enough request I might make it work for Linux or maybe even Mac if I'm feeling generous.
  - Considering making an ingame previewer for the blocks to be pasted with an option tickbox on the ingame item interface.

