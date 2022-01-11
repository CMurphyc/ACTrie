local Lplus = require "Lplus"
local TrieTree = Lplus.Class("TrieTree")

local def = TrieTree.define

def.field("table").trie = nil
def.field("table").idx = nil
def.field("table").depth = nil
def.field("number").tot = 0

def.static("=>", TrieTree).CreateTrieTree = function()
    local tree = TrieTree()
    tree:Init()
    return tree
end

def.method().Init = function(self)
    self.trie = {}
    self.idx = {}
    self.depth = {}
    self.tot = 0
end

def.method("string", "number").Insert = function(self, sourceStr, id)
    if self.trie then
        sourceStr = string.gsub(sourceStr, " ", "")
        local divideStr = GetDivideStringList(sourceStr)
        local len = #divideStr
        local u = 0
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

def.method("string", "=>", "boolean").IsContainBlockedWord = function(self, sourceStr)
    if sourceStr ~= nil and sourceStr ~= "" then
        sourceStr = string.gsub(sourceStr, " ", "")
        local divideStr = GetDivideStringList(sourceStr)
        if divideStr then
            local len = #divideStr
            for i = 1, len do
                divideStr[i] = string.lower(divideStr[i])
            end
            local nodeID = 0
            if self.trie then
                for i = 1, len do
                    nodeID = self.trie[0][divideStr[i]]
                    local matchCount = 0
                    while nodeID and nodeID ~= 0 do
                        matchCount = matchCount + 1
                        if self.idx and self.idx[nodeID] then
                            return true
                        end
                        if self.trie[nodeID] then
                            nodeID = self.trie[nodeID][divideStr[i + matchCount]] or 0
                        else
                            break
                        end
                    end
                end
            end
        end
    end
    return false
end

def.method("string", "=>", "string").FilterBlockedWords = function(self, sourceStr)
    local ans = ""
    if sourceStr ~= nil and sourceStr ~= "" then
        local matchStartPos = {}
        local matchEndPos = {}
        sourceStr = string.gsub(sourceStr, " ", "")
        local divideStr = GetDivideStringList(sourceStr)
        if divideStr then
            local len = #divideStr
            for i = 1, len do
                divideStr[i] = string.lower(divideStr[i])
            end
            local nodeID = 0
            local strMatchEndPos = 0
            if self.trie then
                for i = 1, len do
                    nodeID = self.trie[0][divideStr[i]] or 0
                    local matchCount = 0
                    while nodeID and nodeID ~= 0 do
                        matchCount = matchCount + 1
                        if self.idx and self.idx[nodeID] then
                            if not matchStartPos[i] then
                                matchStartPos[i] = 1
                            else
                                matchStartPos[i] = matchStartPos[i] + 1
                            end
                            strMatchEndPos = i + self.depth[nodeID] - 1
                            if not matchEndPos[strMatchEndPos] then
                                matchEndPos[strMatchEndPos] = 1
                            else
                                matchEndPos[strMatchEndPos] = matchEndPos[strMatchEndPos] + 1
                            end
                        end
                        if self.trie[nodeID] then
                            nodeID = self.trie[nodeID][divideStr[i + matchCount]] or 0
                        else
                            matchCount = 0
                            break
                        end
                    end
                end
            end
            local stackDepth = 0
            for i = 1, len do
                if matchStartPos[i] then
                    stackDepth = stackDepth + matchStartPos[i]
                end
                if stackDepth > 0 then
                    divideStr[i] = "*"
                end
                if matchEndPos[i] then
                    stackDepth = stackDepth - matchEndPos[i]
                end
            end
            ans = table.concat(divideStr)
        end
    end
    return ans
end

TrieTree.Commit()
_G.TrieTree = TrieTree
return TrieTree