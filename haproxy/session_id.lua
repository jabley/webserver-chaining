-- haproxy doesn't support ffi, so we need to use .so which wraps OpenSSL. See
-- the Dockerfile.
local rand = require "openssl.rand"

local function _string_to_hex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

-- Stores the session name and value in transaction context
local function _store_session(txn, value)
    local data = txn:get_priv()

    if not data then
        txn:set_priv({secure_session_id = value})
    else
        data["secure_session_id"] = value
        txn:set_priv(data)
    end
end

-- Returns the generated session name and value, or nil if there isn't one
local function _retrieve_session(txn)
    local data = txn:get_priv()

    if data and data["secure_session_id"] then
        return data["secure_session_id"]
    end

    return nil
end

local function ensure_session(txn)
    local token = _string_to_hex(rand.bytes(16))

    local value = "SESSIONID=" .. token

    _store_session(txn, value)

    txn.http:req_add_header("Cookie", value)
end

-- function to test if there was a session generated and set a response header if necessary
local function maybe_propagate_session(txn)
    local value = _retrieve_session(txn)
    if value then
        txn.http:res_add_header("Set-Cookie", value)
    end
end

core.register_action("ensure_session", { 'http-req' }, ensure_session, 0)
core.register_action("maybe_propagate_session", {'http-res'}, maybe_propagate_session, 0)
