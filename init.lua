-- Discord Logger Mod (Crash-proof)
local modpath = minetest.get_modpath("discord_logger")
dofile(modpath .. "/config.lua")

local webhook_url = discord_logger.webhook_url

-- Helper: Safe POST request
local function send_to_discord(content)
    if not webhook_url or webhook_url == "" then
        minetest.log("warning", "[Discord Logger] Webhook URL not configured!")
        return
    end

    local request = minetest.request_http_api()
    if not request then
        minetest.log("error", "[Discord Logger] HTTP API not enabled in minetest.conf!")
        return
    end

    request.fetch({
        url = webhook_url,
        method = "POST",
        extra_headers = { "Content-Type: application/json" },
        data = minetest.write_json({ content = content })
    }, function() end)
end

-- Log command usage
minetest.register_on_chatcommand(function(name, command, params)
    local msg = ("🧑 %s used command: /%s %s"):format(name, command, params or "")
    send_to_discord(msg)
end)

-- Log joins and leaves
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    send_to_discord("✅ **" .. name .. "** joined the server.")
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local name = player:get_player_name()
    local reason = timed_out and " (timed out)" or ""
    send_to_discord("❌ **" .. name .. "** left the server" .. reason .. ".")
end)

-- Log deaths
minetest.register_on_dieplayer(function(player, reason)
    local name = player:get_player_name()
    local text = "💀 **" .. name .. "** died"
    if reason and reason.type then
        text = text .. " (" .. reason.type .. ")"
    end
    send_to_discord(text)
end)

-- Log item pickup and place
minetest.register_on_placenode(function(pos, newnode, placer)
    if not placer then return end
    local name = placer:get_player_name()
    local node = newnode.name
    send_to_discord(("🧱 %s placed %s at %s"):format(name, node, minetest.pos_to_string(pos)))
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger then return end
    local name = digger:get_player_name()
    send_to_discord(("⛏️ %s dug %s at %s"):format(name, oldnode.name, minetest.pos_to_string(pos)))
end)

-- Log item usage
minetest.register_on_punchnode(function(pos, node, puncher)
    if not puncher then return end
    local name = puncher:get_player_name()
    send_to_discord(("👊 %s punched %s at %s"):format(name, node.name, minetest.pos_to_string(pos)))
end)

-- Log privilege changes
minetest.register_on_priv_grant(function(name, granter, priv)
    send_to_discord(("⚙️ %s granted privilege '%s' to %s"):format(granter, priv, name))
end)

minetest.register_on_priv_revoke(function(name, revoker, priv)
    send_to_discord(("🚫 %s revoked privilege '%s' from %s"):format(revoker, priv, name))
end)
