# Wadsprint [![Version](/util/version.png)] [minetest_wadsprint] 

Minetest mod for sprinting/running with W, A and D buttons.

![Wadsprint](/screenshots/wadsprint_screenshots.png?raw=true "Wadsprint mod screenshots")

**How to use**

1. Press A and D simultaneously to trigger the `ready_to_sprint` state. 
2. Then press W to start sprinting.
3. Release A and D (keep W pressed) and continue sprinting until the stamina runs out.
4. Drink a coffee to faster regenerate the stamina.

**How to download**

https://github.com/aa6/minetest_wadsprint/archive/master.zip

**How to install**

http://wiki.minetest.com/wiki/Installing_mods

**How to configure**

Edit `config.lua` at the mod directory.

Copy `config.lua` to `worlds/<worldname>/mod_minetest_wadsprint_config.lua` to create a per-world config.

**Dependencies**

All mod dependencies are optional.

- [hud?](https://github.com/BlockMen/hud_hunger)
- [hudbars?](http://repo.or.cz/minetest_hudbars.git)
- [player_monoids?](https://github.com/minetest-mods/player_monoids)
- [farming?](https://notabug.org/tenplus1/farming)

**Dependents**

- [minetest_wadsprint_dyspnea](https://github.com/aa6/minetest_wadsprint_dyspnea)

**Development**

- Run `git clone https://github.com/aa6/minetest_wadsprint.git; cd minetest_wadsprint` to clone the repository.
- Run `bash util/git_hook_pre_commit.bash install` after repository cloning. `./VERSION` and `./util/version.png` then will be updated automatically on every commit. To increment minor version append " 2" to `./VERSION` file contents.
- Use `print(dump( ... ))` to print tables to console when debugging.
- Use `error(123)` to stop execution when debugging.
- Remember that array numeration in Lua starts not from `0` but from `1`: `arr = { 123 }; -- arr[0] == nil; arr[1] == 123`.
- Use manual http://dev.minetest.net/Category:Methods

**Changelog**

https://github.com/aa6/minetest_wadsprint/commits/master

**Links**

[Minetest forums topic](https://forum.minetest.net/viewtopic.php?f=11&t=14296)

**Credits**

Thanks to [GunshipPenguin](https://github.com/GunshipPenguin) and his [sprint mod](https://github.com/GunshipPenguin/sprint) for showing a good example of how sprint mod for minetest can be done.
