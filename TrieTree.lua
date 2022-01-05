local Lplus = require "Lplus"
local TrieTree = Lplus.Class("TrieTree")

local def = TrieTree.define

def.field("table").root = nil

def.static("=>", TrieTree).CreateTrieTree = function()
    local tree = TrieTree()
    tree.root = TrieTree.CreateNode("", false, nil)
    return tree
end

def.static("string", "boolean", "table", "=>", "table").CreateNode = function(char, isEnd, childs)
	local node = {}
	node.char = char or ""
	node.wordEnd = isEnd or false
	node.childs = childs or {}
	return node
end

def.method("table").UpdateTree = function(self, blockWordList)
    if blockWordList then
        for i, v in pairs(blockWordList) do
            local divideChars = TrieTree.GetDivideStringList(string.lower(v))
            if #divideChars > 0 then
                self:Insert(self.root, divideChars, 1)
            end
        end
    end
end

def.method("table", "table", "number").Insert = function(self, parent, chars, index)
	local node = self:FindNode(parent, chars[index])
	if not node then
		node = TrieTree.CreateNode(chars[index], false, nil)
        parent.childs[node.char] = node
	end
	local len = #chars
	if index == len then
		node.wordEnd = true
	else
		index = index + 1
		if index <= len then
			self:Insert(node, chars, index)
		end
	end
end

def.method("table", "string", "=>", "table").FindNode = function(self, node, char)
	local childs = node.childs
    if childs then
        if --[[not _G.EditorDataUtils.IsNilOrEmpty(char)]] true then
            local lowerChar = string.lower(char)
            return childs[lowerChar]
        end
    end
    return nil
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

def.method("string", "=>", "boolean").IsContainBlockedWord = function(self, sourceString)
    if --[[not _G.EditorDataUtils.IsNilOrEmpty(sourceString)]] true then
        local strWithoutSpace = string.gsub(sourceString, " ", "")
        local divideCharList = TrieTree.GetDivideStringList(strWithoutSpace)
        local matchPos = 1
        local len = #divideCharList
        local currentNode = self.root
        local matchedCharCount = 0
        while len >= matchPos do
            currentNode = self:FindNode(currentNode, divideCharList[matchPos])
            if not currentNode then
                matchPos = matchPos - matchedCharCount
                currentNode = self.root
                matchedCharCount = 0
            elseif currentNode.wordEnd then
                return true
            else
                matchedCharCount = matchedCharCount + 1
            end
            matchPos = matchPos + 1
        end
        
    end
	return false
end

--[[
    desc:将屏蔽字替换成'*'号
    param sourceString：含有屏蔽字的字符串
    return ：返回屏蔽字是 '*'的字符串
]]
def.method("string", "=>", "string").GetUnBlockedWord = function(self, sourceString)
    local currentTime = GetServerMillisecondsTime()
    if --[[not _G.EditorDataUtils.IsNilOrEmpty(sourceString)]] true then
        local strWithoutSpace = string.gsub(sourceString, " ", "")
        local divideCharList = TrieTree.GetDivideStringList(strWithoutSpace)
        local matchedArray = {} --匹配索引index，匹配字长度 {{index，length}，{index，length}}
        local matchPos = 1
        local len = #divideCharList
        local currentNode = self.root
        local matchedCharCount = 0
        while len >= matchPos do
            currentNode = self:FindNode(currentNode, divideCharList[matchPos])
            if not currentNode then
                matchPos = matchPos - matchedCharCount
                currentNode = self.root
                matchedCharCount = 0
            elseif currentNode.wordEnd then
                matchedCharCount = matchedCharCount + 1
                local matchItem = {index = matchPos - matchedCharCount,length = matchedCharCount}
                --print("------------->matchPArray.insert:"..(matchPos - matchedCharCount)..","..matchedCharCount)
                table.insert(matchedArray, matchItem)
                currentNode = self.root
                matchedCharCount = 0
            else
                matchedCharCount = matchedCharCount + 1
            end
            matchPos = matchPos + 1
        end

        if #matchedArray > 0 then
            local targetString = ""
            for k, matched in ipairs(matchedArray) do
                local pos = matched.index
                local length = matched.length
                --替换非法字符 
                for i = 1, length do
                    if pos + i <= #divideCharList then
                        divideCharList[pos + i] = "*"
                    end
                end
            end
            targetString = table.concat(divideCharList)
            --print("-------->final targetString:"..targetString)
            return targetString
        end
    else
        return sourceString
    end

    return ""
end

TrieTree.Commit()
_G.TrieTree = TrieTree
return TrieTree