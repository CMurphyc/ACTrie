function _G.tableToString (t)
	local address = {}
    if type(t) == "userdata" then
        return tableToString(getmetatable(t))
    end
    if type(t) ~= "table" then
        print(t)
        return
    end
    address[t]=0
    local ret = ""
    local space, deep = string.rep(' ', 4), 0
    local function _dump(t)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if type(v) == "table" and not address[v] then
                address[v] = 0
                deep = deep + 2
                ret = ret .. string.format("%s[%s] => Table\n%s(\n",string.rep(space, deep - 1),key,string.rep(space, deep))
                _dump(v)
                ret = ret ..string.format("%s)\n",string.rep(space, deep))
                deep = deep - 2
            else
                if type(v) ~= "string" then v = tostring(v) end
                ret = ret ..string.format("%s[%s] => %s\n",string.rep(space, deep + 1),key,v)
            end
        end
    end
    ret = ret ..(string.format("Table\n(\n"))
    _dump(t)
    ret = ret ..(string.format(")\n"))
    return ret
end