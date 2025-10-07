-- ================================
-- Discord Logger Mod (Crash-proof)
-- ================================

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath .. "/config.lua")

local webhook_url = discord_logger and discord_logger.webhook_url or ""
local http = minetest.request_http_api()

-- ========== SAFETY CHECKS ==========
if not http then
    minetest.log("error", "[" .. modname .. "] HTTP API not available! Add this to minetest.conf:")
    minetest.log("error", "secure.trusted_mods = " .. modname)
end

if not webhook_url or webhook_url == "" then
    minetest.log("error", "[" .. modname .. "] Webhook URL missing in config.lua!")
end

-- ========== FUNCTION ==========
local function send_to_discord(content)
    if not http or webhook_url == "" then
        return
    end

    local ok, data = pcall(function()
        return minetest.write_json({ content = content })
    end)
    if not ok then
        minetest.log("error", "[" .. modname .. "] JSON encoding failed for message: " .. tostring(content))
        return
    end

    http.fetch({
        url = webhook_url,
        method = "POST",
        extra_headers = { "Content-Type: application/json" },
        data = data
    }, function(res)
        if res.succeeded then
            minetest.log("action", "[" .. modname .. "] Sent to Discord successfully.")
        else
            minetest.log("error", "[" .. modname .. "] Discord webhook failed! Code: " .. tostring(res.code))
        end
    end)
end

-- ========== EVENT LOGGING ==========
minetest.register_on_joinplayer(function(player)
    send_to_discord("✅ **" .. player:get_player_name() .. "** joined the server.")
end)

minetest.register_on_leaveplayer(function(player, timed_out)
    local reason = timed_out and " (timed out)" or ""
    send_to_discord("❌ **" .. player:get_player_name() .. "** left the server" .. reason)
end)

minetest.register_on_chatcommand(function(name, command, params)
    send_to_discord(("💬 **%s** used command: /%s %s"):format(name, command, params or ""))
end)

minetest.register_on_dieplayer(function(player, reason)
    local msg = "💀 **" .. player:get_player_name() .. "** died."
    if reason and reason.type then
        msg = msg .. " (" .. reason.type .. ")"
    end
    send_to_discord(msg)
end)

minetest.register_on_placenode(function(pos, newnode, placer)
    if not placer then return end
    send_to_discord(("🧱 **%s** placed %s at %s"):format(
        placer:get_player_name(), newnode.name, minetest.pos_to_string(pos)))
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
    if not digger then return end
    send_to_discord(("⛏️ **%s** dug %s at %s"):format(
        digger:get_player_name(), oldnode.name, minetest.pos_to_string(pos)))
end)

minetest.register_on_priv_grant(function(name, granter, priv)
    send_to_discord(("⚙️ %s granted '%s' to %s"):format(granter, priv, name))
end)

minetest.register_on_priv_revoke(function(name, revoker, priv)
    send_to_discord(("🚫 %s revoked '%s' from %s"):format(revoker, priv, name))
end)

-- ========== TEST MESSAGE ==========
minetest.after(5, function()
    if http and webhook_url ~= "" then
        send_to_discord("🛰️ **Discord Logger started successfully!**")
        minetest.log("action", "[" .. modname .. "] Test message sent to Discord.")
    end
end)
