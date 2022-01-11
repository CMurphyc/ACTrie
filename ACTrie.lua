local Lplus = require "Lplus"
local Deque = require "Deque"
local Utility = require "Utility"
local ACTrie = Lplus.Class("ACTrie")
local def = ACTrie.define

def.field("table").trie = nil
def.field("table").fail = nil
def.field("table").idx = nil
def.field("table").depth = nil
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
    self.depth = {}
    self.tot = 0
end

def.method("string", "number").Insert = function(self, sourceStr, id)
    if self.trie then
        local u = 0
        sourceStr = string.gsub(sourceStr, " ", "")
        local divideStr = GetDivideStringList(sourceStr)
        local len = #divideStr
        self.depth[u] = 0
        for i = 1, len do
            divideStr[i] = string.lower(divideStr[i])
            if not self.trie[u] or not self.trie[u][divideStr[i]] then
                if not self.trie[u] then
                    self.trie[u] = {}
                end
                self.tot = self.tot + 1
                self.trie[u][divideStr[i]] = self.tot
            end
            u = self.trie[u][divideStr[i]]
            self.depth[u] = i
        end
        self.idx[u] = id
    end
end

def.method().BuildFail = function(self)
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
                        local failNodeChID = nil
                        -- 构造fail
                        while true do
                            currentFail = self.fail[currentFail]
                            if currentFail then
                                if self.trie[currentFail] then
                                    failNodeChID = self.trie[currentFail][ch]
                                    if failNodeChID then
                                        self.fail[nodeID] = failNodeChID
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

def.method("string", "=>", "string").FilterBlockedWords = function(self, sourceStr)
    local divideChars = GetDivideStringList(sourceStr)
    local ans = ""
    local len = #divideChars
    local nodeID = 0
    local matchStartPos = {}
    local matchEndPos = {}
    local currentCh = ""
    for i = 1, len do
        currentCh = string.lower(divideChars[i])
        while nodeID ~= 0 and (not self.trie[nodeID] or not self.trie[nodeID][currentCh]) do
            nodeID = self.fail[nodeID]
        end
        nodeID = self.trie[nodeID] and self.trie[nodeID][currentCh] or 0
        local checkNodeID = nodeID
        local startPos = 0
        while checkNodeID and checkNodeID ~= 0 do
            if self.idx[checkNodeID] then
                if not matchEndPos[i] then
                    matchEndPos[i] = 1
                else
                    matchEndPos[i] = matchEndPos[i] + 1
                end
                startPos = i - self.depth[checkNodeID] + 1
                if not matchStartPos[startPos] then
                    matchStartPos[startPos] = 1
                else
                    matchStartPos[startPos] = matchStartPos[startPos] + 1
                end
            end
            checkNodeID = self.fail[checkNodeID]
        end
    end
    local stackDepth = 0
    for i = 1, len do
        if matchStartPos[i] then
            stackDepth = stackDepth + matchStartPos[i]
        end
        if stackDepth > 0 then
            divideChars[i] = "*"
        end
        if matchEndPos[i] then
            stackDepth = stackDepth - matchEndPos[i]
        end
    end
    ans = table.concat(divideChars)
    return ans
end

ACTrie.Commit()
_G.ACTrie = ACTrie
return ACTrie