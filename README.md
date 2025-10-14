# discord_logger

A mod which brodcasts in-game logs to discord using webhook system totally free to use and easy to configure

# Configuration 

**Step 1-** Go to ``world.mt`` and add ``discord_logger = true``
**Step 2-** Go to ``minetest.conf`` at ``secure.http_mods`` add discord_logger if more then one mod is using http support use like ``secure.http_mods = xyz,zys,discord_logger`` dont add space between commas(,) or it wont work
**Step3-** Go to ``discord_logger`` in mods/worldmods
**Step 4-** go to ``config.lua`` inside ``discord_logger`` you'll see a structure like

``-- Discord webhook configuration
discord_logger = {}
discord_logger.webhook_url =``
After discord_logger.webhook_url = add ur webhook link, at last ur structure will look like 

``-- Discord webhook configuration
discord_logger = {}
discord_logger.webhook_url = "https://discord.com/api/webhooks/xyz"``

# Important note-

Never share ur webhook url, as it can give anyone access to ur webhook 

# Any problems?

Add ``jolethen`` on discord for any questions or bugs or just join the discord server below and open a ticket.

https://discord.gg/9PcS6BkdsU

Thanks for using my mod, make sure to join the server to support me :))

