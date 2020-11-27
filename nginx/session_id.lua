local resty_random = require "resty.random"
local resty_str = require "resty.string"

-- random_hash will attempt to generate a cryptographically strong hash of the
-- desired number of bytes. It will throw an exception if unable to generate a
-- cryptographically strong result.
local function random_hash(len)
    local attempt = 1
    local strong_random = resty_random.bytes(len, true)
    -- attempt to generate `len` bytes of
    -- cryptographically strong random data
    while not strong_random and attempt < 10 do
      strong_random = resty_random.bytes(len, true)
      attempt = attempt + 1
    end

    if not strong_random then
      -- we have run out of entropy for OpenSSL?
      error()
    end

    return resty_str.to_hex(strong_random)
end

-- Some variable declarations.
local cookie = ngx.var.cookie_SESSIONID

-- Only set the cookie if it doesn't exist
if not cookie then
  -- Get any existing cookies so we can preserve them
  local orig_cookies = ngx.req.get_headers()['Cookie']

  -- Now generate a Session-ID
  local session_id = random_hash(16)

  -- Set the Session-ID as a new cookie in the response
  -- and a cookie in the request
  local token = 'SESSIONID=' .. session_id
  ngx.header['Set-Cookie'] = token
  if orig_cookies then
    ngx.req.set_header('Cookie', token .. '; ' .. orig_cookies);
  else
    ngx.req.set_header('Cookie', token)
  end
end
