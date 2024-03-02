---
title: React之低版本chrome setState loading2次状态出现的bug
date: 2019-07-18 21:06:09
permalink: /pages/a4da30/
categories: 
  - 前端
  - 应用框架
  - UI 框架
  - React
tags: 
  - 
titleTag: 草稿
---
## 前言
需求是这样的， RadioGroup 每次切换，要去请求数据并填充 Table

然后 Table 加了 loding 状态，切换时 设置 true,拿到数据时设置 false

```js
this.setState({loading:true})
let data = await getList()
this.setState({
  loading:false,
  data:data
})
```
结果快速切换 RadioGroup 时 多个 RadioButton 都变成 check 样式

控件用的 antd

chrome 59 出现，高版本不会出现

## 原因分析

Promise.prototype.finally chrome63 才支持 不知道会不会有关系，试一下。。

目前没有找到原因

## 解决方案

```js
this.setState({loading:true})
let data = await getList()
this.setState({
  data:data
})
setTimeout(()=>{
  this.setState({
    loading:false,
  })
},0)
```