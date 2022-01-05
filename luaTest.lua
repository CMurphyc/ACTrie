require "Lplus"
require "TrieTree"

_G.block_word_list = {}

local blockWordsFileName = "block_words_data.lua"
local block_words_data = dofile(blockWordsFileName)

local testWords = dofile("TestWords.lua")

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
if testWords then
    for i = 1, #testWords do
        ACTrie:Insert(testWords[i], i)
    end
    print("czh test block word len ", #testWords)
end

ACTrie:BuildTree()

print("Test count ", ACTrie:QueryCount("she"))
