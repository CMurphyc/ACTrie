require "Lplus"
require "TrieTree"
require "Utility"

_G.block_word_list = {}

local blockWordsFileName = "block_words_data.lua"
local block_words_data = dofile(blockWordsFileName)
local len = #block_words_data
print(string.format("屏蔽词库共有%d词条", len))

-- 屏蔽词库加入原屏蔽词的翻转串
-- local reverseWords = dofile(blockWordsFileName)
-- for k, v in ipairs(reverseWords) do
--     local s = GetDivideStringList(v)
--     local len = #s
--     local tmp = ""
--     for i = 1, math.modf(len / 2) do
--         tmp = s[i]
--         s[i] = s[len - i + 1]
--         s[len - i + 1] = tmp
--     end
--     table.insert(block_words_data, table.concat(s))
-- end

-- 全部屏蔽词相连
local testStr = table.concat(block_words_data)
-- 普通长度文本含屏蔽字
-- testStr = "爸爸的爸爸叫爷爷爸爸的妈妈叫奶奶妈妈的妈妈叫外婆外婆也可以叫姥姥"
-- 普通长度文本不含屏蔽字
-- testStr = "我爱吃饭的事情大概大家都知道，我爱摸鱼的事情我觉得大家也都清楚的"

-- 屏蔽词之间存在大量重叠的后缀的情况
-- local divideStr = GetDivideStringList(testStr)
-- local dlen = #divideStr
-- for i = 1, dlen do
--     local str = table.concat(divideStr, "", i, dlen)
--     table.insert(block_words_data, str)
-- end

print("被检查词条长度", #GetDivideStringList(testStr))

local profiler = require "profiler"
local newProfiler = profiler()


-------------开始AC自动机建树测试------------
newProfiler:start()

local ACTrie = require "ACTrie".CreateACTrie()
if block_words_data then
    local len = #block_words_data
    for i = 1, len do
        ACTrie:Insert(block_words_data[i], i)
    end
end
ACTrie:BuildFail()

newProfiler:stop()

local tl, edTime = newProfiler:report()

print("AC自动机 建树消耗时间 ", edTime)
----------AC自动机建树测试结束-----------------


----------开始AC自动机屏蔽字过滤测试-----------
newProfiler:start()
local acResult = ACTrie:FilterBlockedWords(testStr)
-- for i = 1, 1000 do
--     ACTrie:FilterBlockedWords(testStr)
-- end
newProfiler:stop()

local tl, filterTime = newProfiler:report()

print("AC自动机敏感词过滤消耗的时间: ", filterTime)
---------AC自动机屏蔽字过滤测试结束--------------


-------------开始Trie建树测试------------
newProfiler:start()
_G.BlockWordTrieTree = _G.TrieTree.CreateTrieTree()
if block_words_data then
    local len = #block_words_data
    for i = 1, len do
        _G.BlockWordTrieTree:Insert(block_words_data[i], i)
    end
end
newProfiler:stop()
local tl, edTime = newProfiler:report()
print("Trie 构建trie树消耗时间 ", edTime)
----------Trie建树测试结束-----------------


----------开始Trie屏蔽字过滤测试-----------
newProfiler:start()
local trieResult = _G.BlockWordTrieTree:FilterBlockedWords(testStr)
-- for i = 1, 1000 do
--     _G.BlockWordTrieTree:FilterBlockedWords(testStr)
-- end
newProfiler:stop()

local tl, trieFilterTime = newProfiler:report()

print("Trie 敏感词过滤消耗的时间: ", trieFilterTime)

----------Trie屏蔽字过滤测试结束-----------


-------------打印部分测试结果-------------------


-- print("AC自动机过滤后的文本 ", string.gsub(acResult, "*", ""))
-- print("Trie过滤后的文本 ", string.gsub(trieResult, "*", ""))
-- print("AC自动机过滤后的文本 ", acResult)
-- print("Trie过滤后的文本 ", trieResult)


print("AC自动机过滤后是否存在屏蔽字 ", _G.BlockWordTrieTree:IsContainBlockedWord(acResult))
print("Trie过滤后是否存在屏蔽字 ", _G.BlockWordTrieTree:IsContainBlockedWord(trieResult))

