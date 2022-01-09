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

function _G.GetDivideStringList(sourceString)
	local divideList = {}
    local len  = string.len(sourceString)
    local stPos = 1
    local utf8Sign  = {0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while stPos <= len do
        local sign = string.byte(sourceString, stPos)
        local chLen = 1
        for i = 1, 6 do
            if sign < utf8Sign[i] then
                chLen = i
                break
            end
        end
        local ch = string.sub(sourceString, stPos, stPos + chLen - 1)
        stPos = stPos + chLen
        table.insert(divideList, ch)
    end
    return divideList
end