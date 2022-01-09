require "Lplus"
require "TrieTree"
require "Utility"

_G.block_word_list = {}

local blockWordsFileName = "block_words_data.lua"
local block_words_data = dofile(blockWordsFileName)
local reverseWords = dofile(blockWordsFileName)
for k, v in ipairs(reverseWords) do
    local s = GetDivideStringList(v)
    local len = #s
    local tmp = ""
    for i = 1, math.modf(len / 2) do
        tmp = s[i]
        s[i] = s[len - i + 1]
        s[len - i + 1] = tmp
    end
    table.insert(block_words_data, table.concat(s))
end


local testStr = table.concat(block_words_data)
testStr = "爸爸的爸爸叫爷爷爸爸的妈妈叫奶奶妈妈的妈妈叫外婆外婆也可以叫姥姥"

local profiler = require "profiler"
local newProfiler = profiler()


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

print("AC自动机 建树消耗时间 ", edTime)


newProfiler:start()
local acResult = ACTrie:FilterBlockedWords(testStr)
for i = 1, 1000 do
    ACTrie:FilterBlockedWords(testStr)
end
newProfiler:stop()

local tl, filterTime = newProfiler:report()

print("AC自动机敏感词过滤消耗的时间: ", filterTime)


newProfiler:start()
_G.BlockWordTrieTree = _G.TrieTree.CreateTrieTree()
_G.BlockWordTrieTree:UpdateTree(block_words_data)
newProfiler:stop()
local tl, edTime = newProfiler:report()
print("Trie 构建trie树消耗时间 ", edTime)

newProfiler:start()
local trieResult = _G.BlockWordTrieTree:FilterBlockedWords(testStr)
for i = 1, 1000 do
    _G.BlockWordTrieTree:FilterBlockedWords(testStr)
end
newProfiler:stop()

local tl, trieFilterTime = newProfiler:report()

print("Trie 敏感词过滤消耗的时间: ", trieFilterTime)
print("AC自动机过滤后的文本 ", acResult)
print("Trie过滤后的文本 ", trieResult)
-- print("B is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(acResult))
-- print("C is contain ", _G.BlockWordTrieTree:IsContainBlockedWord(trieResult))

