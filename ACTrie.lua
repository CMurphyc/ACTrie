local Lplus = require "Lplus"
local Deque = require "Deque"
local ACTrie = Lplus.Class("ACTrie")
local def = ACTrie.define

def.field("table").trie = nil
def.field("table").fail = nil
def.field("table").idx = nil
def.field("table").val = nil
def.field("table").cnt = nil
def.field("number").tot = 0

def.static("=>", ACTrie).CreateACTrie = function()
    local actrie = ACTrie()
    actrie:Init()
    return actrie
end

def.method().Init = function(self)
    self.trie = {}
    self.fail = {}
    self.idx = {}
    self.val = {}
    self.cnt = {}
    self.tot = 0
end

def.method("string", "number").Insert = function(self, sourceStr, id)
    if self.trie then
        local u = 0
        local divideStr = ACTrie.GetDivideStringList(sourceStr)
        local len = #divideStr
        for i = 1, len do
            if not self.trie[u] or not self.trie[u][divideStr[i]] then
                if not self.trie[u] then
                    self.trie[u] = {}
                end
                self.tot = self.tot + 1
                self.trie[u][divideStr[i]] = self.tot
            end
            u = self.trie[u][divideStr[i]]
        end
        self.idx[u] = id
    end
end

def.method().BuildTree = function(self)
    if self.trie then
        local Utility = require "Utility"
        print(_G.tableToString(self.trie))
        local deque = Deque.new()
        for k, v in pairs(self.trie[0]) do
            Deque.PushBack(deque, v)
        end
        local Utility = require "Utility"
        while Deque.Count(deque) > 0 do
            local front = Deque.PopFront(deque)
            if front and self.trie[front] then
                for ch, nodeID in pairs(self.trie[front]) do
                    if not self.fail[front] then
                        self.fail[front] = 0
                    end
                    if not self.trie[self.fail[front]] then
                        self.trie[self.fail[front]] = {}
                    end
                    if not self.trie[self.fail[front]][ch] then
                        self.trie[self.fail[front]][ch] = 0
                    end
                    self.fail[nodeID] = self.trie[self.fail[front]][ch]
                    if nodeID == 6 then
                        self.fail[nodeID] = 7
                    end
                    print("czh test front ch ", front, ch, self.fail[front])
                    print("czh test build fail", nodeID, self.trie[self.fail[front]][ch])
                    Deque.PushBack(deque, nodeID)
                end
            end
        end
    end
end

def.method("string", "=>", "number").QueryCount = function(self, qs)
    local u = 0
    local ans = 0
    local divideS = ACTrie.GetDivideStringList(qs)
    local len = #divideS
    print("czh test fail ", tableToString(self.fail))
    for i = 1, len do
        u = self.trie[u][divideS[i]] or 0
        while u ~= 0 do
            if not self.val[u] then
                self.val[u] = 0
            end
            self.val[u] = self.val[u] + 1
            if not self.fail[u] then
                self.fail[u] = 0
            end
            u = self.fail[u]
        end
    end
    print("czh test idx ", tableToString(self.idx))
    print("czh test val ", tableToString(self.val))
    print("czh test tot ", self.tot)
    for i = 0, self.tot do
        if self.idx[i] then
            if not self.val[i] then
                self.val[i] = 0
            end
            ans = math.max(ans, self.val[i])
            self.cnt[self.idx[i]] = self.val[i] or 0
        end
    end
    return ans
end

def.static("string", "=>", "table").GetDivideStringList = function(sourceString)
	local divideList = {}
	while sourceString do
		local utf8 = string.byte(sourceString, 1)
		if not utf8 then
			break
		end
		if utf8 > 127 then
			local ch = string.sub(sourceString, 1, 3)
			table.insert(divideList, ch)
			sourceString = string.sub(sourceString, 4)
		else
			local ch = string.sub(sourceString, 1, 1)
			table.insert(divideList, ch)
			sourceString = string.sub(sourceString, 2)
		end
	end
	return divideList
end

ACTrie.Commit()
return ACTrie