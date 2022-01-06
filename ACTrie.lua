local Lplus = require "Lplus"
local Deque = require "Deque"
local Utility = require "Utility"
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
        -- 设置根节点的fail
        self.fail[0] = nil
        local deque = Deque.new()
        for k, v in pairs(self.trie[0]) do
            Deque.PushBack(deque, v)
            self.fail[v] = 0
        end
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
                        local currentFail = self.fail[front]
                        local currentID = nil
                        while true do
                            currentFail = self.fail[currentFail]
                            if currentFail then
                                if self.trie[currentFail] then
                                    currentID = self.trie[currentFail][ch]
                                    if currentID then
                                        self.fail[nodeID] = currentID
                                        break
                                    end
                                end
                            else
                                -- 指向根节点
                                self.fail[nodeID] = 0
                                break
                            end
                        end
                    else
                        self.fail[nodeID] = self.trie[self.fail[front]][ch]
                    end
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
    for i = 1, len do
        if not self.trie[u] or not self.trie[u][divideS[i]] then
            if not self.trie[u] then self.trie[u] = {} end
            self.trie[u][divideS[i]] = self.trie[self.fail[u]][divideS[i]]
        end
        u = self.trie[u][divideS[i]]
        local nodeID = u
        while nodeID and nodeID ~= 0 do
            if not self.val[nodeID] then
                self.val[nodeID] = 0
            end
            self.val[nodeID] = self.val[nodeID] + 1
            nodeID = self.fail[nodeID]
        end
    end
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

def.method("string", "=>", "table").QueryBlockedWordsIndexList = function(self, sourceStr)
    local divideChars = ACTrie.GetDivideStringList(sourceStr)
    local len = #divideChars
    local blockedIndexList = {}
    local oneMatchedStrIndexList = {}
    local u = 0
    for i = 1, len do
        while not self.trie[u][divideChars[i]] and self.fail[u] do
            u = self.fail[u]
            if not self.fail[u] then
                oneMatchedStrIndexList = {}
            end
        end
        u = self.trie[u][divideChars[i]]
        if not u or u == 0 then
            u = 0
        else
            table.insert(oneMatchedStrIndexList, i)
        end
        if self.idx[u] then
            for k, v in pairs(oneMatchedStrIndexList) do
                table.insert(blockedIndexList, v)
            end
            oneMatchedStrIndexList = {}
        end
    end
    return blockedIndexList
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