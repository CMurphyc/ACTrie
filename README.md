# Lua实现的屏蔽字检测 & 过滤方案（AC Automaton | Trie）

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

基于Lua语言实现的屏蔽字检测 & 过滤方案，可用于对聊天、弹幕等功能内的文本内容做实时屏蔽字检测or过滤。

## 内容列表

- [背景](#背景)
- [安装](#安装)
- [使用说明](#使用说明)
- [示例](#示例)
- [相关仓库](#相关仓库)
- [维护者](#维护者)
- [如何贡献](#如何贡献)
- [使用许可](#使用许可)

## 背景

前段时间自己所在的游戏项目即将进行第一次内测，对公共频道聊天内容做敏感词检测的需求也是提了上来。

一开始策划的需求只是提示玩家当前输入的内容包含敏感词，但是后来一些玩家反馈不知道自己说话里哪个是敏感词聊天发不出去很难受（我们组之前的敏感词库里有"忍"以及其他的单个字，如果不是玩家反馈我也没想到忍是敏感词...），于是乎这个需求就进化成了把文本中的敏感词全部替换为星号。

从算法角度看，这个需求其实就是从简单的检测模式串中是否存在匹配串的子串 -> 字符串多模匹配替换

前者的解决方案很多  
1.字符串哈希暴力去做可以，假设屏蔽词库已经全部哈希预处理过了，考虑到文本的长度其实比较小，拆出所有子串的时间消耗也算可以接受（其实就算字符串长了点，用后缀自动机也可以在线性时间内处理所有不同的子串哈希，但是显然没必要...），不过有哈希冲突的风险  
2.KMP单次匹配的时间复杂度为O(被检测文本长度 + 模式串连在一起的长度), 考虑到我们项目使用的屏蔽字库足足有500kb+, 这个方案也被放弃  
3.字典树，构造合并了前缀的Trie树，相当于用时间换空间了，构造出的Trie树所用的空间还是可以接受的，单次查询最差时间复杂度为O(被检测文本长度 + Trie树最大深度)。  

后者的解决方案中比较经典的就是AC自动机的，该方案显然也可以处理前者的需求。

## 安装

将项目中的文件解压至目标工程放到你觉得合适的位置即可

## 使用说明

- 若是采用Trie方案，require被放入工程中的TireTree文件；若是采用AC自动机方案，require被放入工程的ACTrie文件。
- 所有英文敏感词不区分大小写。
- 词库内所有敏感词内的空格会被忽略掉。
- 做敏感词过滤时被检测文本内的空格不会被忽略。
- 做敏感词检测时被检测文本内的空格会被忽略。

## 示例
### 基于字典树的方案

```lua
-- Trie建树
_G.BlockWordTrieTree = _G.TrieTree.CreateTrieTree()
_G.BlockWordTrieTree:UpdateTree(block_words_data)
...
-- Trie文本过滤
local trieResult = _G.BlockWordTrieTree:FilterBlockedWords(testStr)
-- Trie敏感词检测
_G.BlockWordTrieTree:IsContainBlockedWord(trieResult)
```
### 基于AC自动机的方案

```lua
-- AC自动机建树
local ACTrie = require "ACTrie".CreateACTrie()
if block_words_data then
    local len = #block_words_data
    for i = 1, len do
        ACTrie:Insert(block_words_data[i], i)
    end
end
ACTrie:BuildTree()
...
-- AC自动机文本过滤
local acResult = ACTrie:FilterBlockedWords(testStr)
```

### 上述两个方案时间性能对比
#### 正常聊天文本长度（含敏感词）

```lua
-- 其中爸、妈、妈的、爸爸、妈妈、爷爷、奶、奶奶为敏感词
testStr = "爸爸的爸爸叫爷爷爸爸的妈妈叫奶奶妈妈的妈妈叫外婆外婆也可以叫姥姥"
-- 执行1000次所需的时间

屏蔽词库共有26772词条
被检查词条长度	32
AC自动机敏感词过滤消耗的时间: 	0.044
Trie 敏感词过滤消耗的时间: 	0.037
AC自动机过滤后的文本 	**的**叫*******叫*******叫外婆外婆也可以叫姥姥
Trie过滤后的文本 	**的**叫*******叫*******叫外婆外婆也可以叫姥姥
```

#### 正常聊天文本长度（不含敏感词）

```lua
testStr = "我爱吃饭的事情大概大家都知道，我爱摸鱼的事情我觉得大家也都清楚的"
-- 执行1000次所需的时间

屏蔽词库共有26772词条
被检查词条长度	32
AC自动机敏感词过滤消耗的时间: 	0.032
Trie 敏感词过滤消耗的时间: 	0.026
AC自动机过滤后的文本 	我爱吃饭的事情大概大家都知道，我爱摸鱼的事情我觉得大家也都清楚的
Trie过滤后的文本 	我爱吃饭的事情大概大家都知道，我爱摸鱼的事情我觉得大家也都清楚的
```

#### 极端情况之 - 被检查文本为所有敏感词相连所得的文本
```lua
屏蔽词库共有26772词条
被检查词条长度	347075
AC自动机敏感词过滤消耗的时间: 	0.398
Trie 敏感词过滤消耗的时间: 	0.456
```


#### 极端情况之 - 敏感词库中的敏感词之间存在大量相同的后缀 & 被检测的字符串的所有后缀都是敏感词
```lua
testStr = "我爱吃饭的事情大概大家都知道，我爱摸鱼的事情我觉得大家也都清楚的"

-- 屏蔽词之间存在大量重叠的后缀的情况
local divideStr = GetDivideStringList(testStr)
local dlen = #divideStr
for i = 1, dlen do
    local str = table.concat(divideStr, "", i, dlen)
    table.insert(block_words_data, str)
end

-- 执行1000次所需的时间

屏蔽词库共有26804词条
被检查词条长度	32
AC自动机敏感词过滤消耗的时间: 	0.138
Trie 敏感词过滤消耗的时间: 	0.223
```

#### 性能对比分析

- 如果屏蔽词之间存在大量相同的后缀且这些后缀本身就有不少是屏蔽词时，AC自动机方案的效率会明显高于Trie
- 如果屏蔽词之间存在大量相同的后缀但这些后缀本身只有极少数是屏蔽词时，因为AC自动机比起原始的Trie会多跳几次fail，且每次跳fail后跳到的结点大部分不是是一个词尾结点，故此时Trie的效率会稍稍稍稍高了一点点点点
- 如果屏蔽词之间几乎不存在相同的后缀，此时AC自动机退化成了原始的Trie，两者效率相当

## 相关仓库

- [LuaKit](https://github.com/cooee/LuaKit) — 该项目提供的Lua工具集合包含了本项目测试使用的Lua性能检测工具profiler

## 维护者

[@MurphyCui](https://github.com/CMurphyc)。

## 如何贡献

欢迎对项目与代码提意见与反馈！[提一个 Issue](https://github.com/CMurphyc/ACTrie/issues/new) 或者提交一个 Pull Request。


## 使用许可

[MIT](LICENSE) © MurphyCui
