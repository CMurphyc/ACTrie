require "Lplus"
require "TrieTree"

_G.block_word_list = {}

local blockWordsFileName = "block_words_data.lua"
local block_words_data = dofile(blockWordsFileName)

local testWords = dofile("TestWords.lua")

local map = {}
local cnt = 0
local maxnlen = 0
if block_words_data then
    for i = 1, #block_words_data do
        local s = _G.TrieTree.GetDivideStringList(block_words_data[i])
        local len = #s
        maxnlen = math.max(maxnlen, len)
        for j = 1, len do
            if not map[s[j]] then
                cnt = cnt + 1
                map[s[j]] = true 
            end
        end
    end
end

-- if block_words_data then
--     for i = 1, #block_words_data do
--         table.insert(_G.block_word_list, block_words_data[i])
--     end
-- end

-- _G.BlockWordTrieTree = _G.TrieTree.CreateTrieTree()

-- local startTime = os.clock()
-- _G.BlockWordTrieTree:UpdateTree(_G.block_word_list)
-- local endTime = os.clock()

-- print(endTime - startTime)


-- print(_G.BlockWordTrieTree:IsContainBlockedWord("test"))
-- print(_G.BlockWordTrieTree:IsContainBlockedWord("阮"))

local ACTrie = require "ACTrie".CreateACTrie()
if block_words_data then
    local len = #block_words_data
    for i = 1, len do
        ACTrie:Insert(block_words_data[i], i)
    end
end

ACTrie:BuildTree()

local indexList = ACTrie:QueryBlockedWordsIndexList("小泉波波小泉")

-- print("Test count ", ACTrie:QueryCount("小泉波波小泉"))
