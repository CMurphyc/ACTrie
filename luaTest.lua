require "Lplus"
require "TrieTree"
require "Utility"

_G.block_word_list = {}

local blockWordsFileName = "block_words_data.lua"
local block_words_data = dofile(blockWordsFileName)
local testStr = table.concat(block_words_data, "", 20500, 20600)
-- testStr = "我妈妈妈的妈妈门叫我会叫不要玩妈妈们妈妈的爸爸了"

local LibStringSearch = require "string_search"

-- 性能测试
local LibProfiler = require "profiler"

local newProfiler = LibProfiler()

newProfiler:start()


local l_FindClass = LibStringSearch:new(block_words_data)
newProfiler:stop()

local tbLines, nTime = newProfiler:report()

print("A 构建trie树消耗时间 ", nTime)

newProfiler:start()

local matchStr = l_FindClass:find_all(testStr)
local result = l_FindClass:replace(matchStr, testStr)

newProfiler:stop()
local tbLines, nTime = newProfiler:report()
print("A 敏感词过滤消耗的时间: ", nTime)


newProfiler:start()
local ACTrie = require "ACTrie".CreateACTrie()
if block_words_data then
    local len = #block_words_data
    for i = 1, len do
        ACTrie:Insert(block_words_data[i], i)
    end
end
ACTrie:BuildTree()


newProfiler:stop()

local tl, edTime = newProfiler:report()

print("B 构建trie树消耗时间 ", edTime)


newProfiler:start()
local acResult = ACTrie:FilterBlockedWords(testStr)
newProfiler:stop()

local tl, filterTime = newProfiler:report()

print("B 敏感词过滤消耗的时间: ", filterTime)



newProfiler:start()
_G.BlockWordTrieTree = _G.TrieTree.CreateTrieTree()
_G.BlockWordTrieTree:UpdateTree(block_words_data)
newProfiler:stop()
local tl, edTime = newProfiler:report()
print("C 构建trie树消耗时间 ", edTime)

newProfiler:start()
local trieResult = _G.BlockWordTrieTree:GetUnBlockedWord(testStr)
newProfiler:stop()

local tl, trieFilterTime = newProfiler:report()

print("C 敏感词过滤消耗的时间: ", trieFilterTime)


require("init")

newProfiler:start()
local worldFilter = require("WordFilter").new("*")
worldFilter:init(block_words_data)

newProfiler:stop()
local tl, edTime = newProfiler:report()
print("D 构建trie树消耗时间 ", edTime)

newProfiler:start()
local lresult = worldFilter:doFilter(testStr)
newProfiler:stop()

local tl, trieFilterTime = newProfiler:report()

print("D 敏感词过滤消耗的时间: ", trieFilterTime)
if acResult == trieResult then
    print("B == C")
end
if acResult == lresult then
    print("B == D")
end
if trieResult == lresult then
    print("C == D")
end
print("A ", result)
print("B ", acResult)
print("C ", trieResult)
print("D ", lresult)
-- print("A is contain ", worldFilter:isFilter(result))
-- print("B is contain ", worldFilter:isFilter(acResult))
-- print("C is contain ", worldFilter:isFilter(trieResult))
-- print("D is contain ", worldFilter:isFilter(lresult))

print("A is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(result))
print("B is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(acResult))
print("C is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(trieResult))
print("D is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(lresult))

