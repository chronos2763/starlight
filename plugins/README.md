# how 2 starlight plugin
a starlight plugin takes the form of a lua module.

there are four types of functions that can be in a plugin:
* user - commands that can be run by everyone
* oper - commands that can be run by operators only
* feedback - functions that execute for every message
* tick - functions that run in the background

an empty plugin looks like this:
```lua
module = {user={}, oper={}, feedback={}, tick={}}

return module
```
the `module` keyword can be replaced with anything, as long as it still returns a table of your commands and functions.

when a message is processed, its contents are split by spaces (ignoring those between double quotes) and passed as the first argument to your function. functions in the `tick` table do not have this capability.

## variables and such
* author - a table with two elements: nickname, the author's nick; and hostmask, the author's host.
* last - a table that contains the last message from each nickname. will not update for users included in the `ignore` table defined in `conf.lua`.
* clock - returns how long in seconds the bot has been running for.

## persistent data values
you may want certain values to persist through bot restarts, and this bot supports that.

the `editsave(namespace, key, value)` function can be used to edit persistent data.
* the first parameter is the namespace your plugin uses, to prevent conflicts with other plugins.
* the second and third parameters are the key and the value of the data you want to store
* persistent save data can be accessed through the `savedata.(your namespace)` table.

there is also `touchsave(namespace)` which creates your namespace without putting anything in it if it does not yet exist, as well as `removesave(namespace, key)` to remove a key from your save data.

all of these can be seen in action in the provided plugins, as well as an example plugin `test.lua`.
