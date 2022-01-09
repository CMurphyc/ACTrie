# Lua实现的屏蔽字检测 & 过滤方案（Trie | AC Automaton）

[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)


## 内容列表

- [背景](#背景)
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
3.字典树，构造合并了前缀的Trie树，相当于用时间换空间了，构造出的Trie树所用的空间还是可以接受的。  

后者的解决方案中比较经典的就是AC自动机的，该方案显然也可以处理前者的需求。

## 使用说明

将项目中的文件解压至目标工程中即可使用。
需要注意的是使用`基于字典树的方案`时要求屏蔽字表结构如下所示
```lua
return {
    "我是屏蔽词",
    "我也是屏蔽词",
}
```

所有英文屏蔽词不区分大小写

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
被检查词条长度	32
AC自动机敏感词过滤消耗的时间: 	0.05
Trie 敏感词过滤消耗的时间: 	0.078
AC自动机过滤后的文本 	**的**叫*******叫*******叫外婆外婆也可以叫姥姥
Trie过滤后的文本 	**的**叫*******叫*******叫外婆外婆也可以叫姥姥
```

#### 最差情况之 - 被检查文本为所有敏感词相连所得的文本
```lua
-- 检测一次时间对比（敏感词有25k条，每个敏感词最大长度不超过120字符）
被检查词条长度	347075
AC自动机敏感词过滤消耗的时间: 	0.378
Trie 敏感词过滤消耗的时间: 	0.608
```

## 相关仓库

- [LuaKit](https://github.com/cooee/LuaKit) — 该项目提供的Lua工具集合包含了本项目测试使用的Lua性能检测工具profiler

## 维护者

[@MurphyCui](https://github.com/CMurphyc)。

## 如何贡献

欢迎对项目与代码提意见与反馈！[提一个 Issue](https://github.com/CMurphyc/ACTrie/issues/new) 或者提交一个 Pull Request。


## 使用许可

[MIT](LICENSE) © MurphyCui
