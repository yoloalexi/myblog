---
title: Node.js 版本切换
date: 2021-09-21 21:02:37
permalink: /pages/4e0a77/
tags: 
  - 
categories: 
  - 前端
  - 专业领域
  - 服务端
  - Node.js
---

切换 Node.js 版本的常用工具有 n、nvm、volta 

本文将简单描述下这些工具的安装和使用。
> PS: 个人目前用的是 nvm

<!-- more -->
# n
```sh
# 安装
$ sudo npm install -g n

# 版本切换

输入n，就会出现安装的node版本列表，列表项前面有个o的，说明就是你当前在使用的node版本，移动上下方向键来选择要使用的版本，最后按回车生效。

```sh
$ n
        5.10.1 
o      6.2.2 
        7.0.0

# 安装某个版本
$ n x.x.x

# 安装最新版本
$ n latest

# 安装稳定版本
$ n stable

# 删除某个版本
$ n rm x.x.x

# 指定某个版本来执行文件
n user x.x.x some.js
```
# nvm

https://github.com/nvm-sh/nvm/blob/master/README.md

```sh
# 安装方式有两种：
$ curl https://raw.github.com/creationix/nvm/v0.4.0/install.sh | sh
# 或者
$ wget -qO- https://raw.github.com/creationix/nvm/v0.4.0/install.sh | sh

# 以上脚本会把nvm库clone到~/.nvm，然后会在~/.bash_profile, ~/.zshrc或`~/.profile末尾添加source，安装完成之后，你可以用以下命令来安装node

# 对于较高版本的 macOS ，需要手动安装并将配置写入 ~/.zshrc 中；见 https://github.com/nvm-sh/nvm/blob/master/README.md#manual-install 

$ nvm install x.x.x

#  使用指定的版本
$ nvm use x.x.x

#  查看当前已经安装的版本
$ nvm ls
.nvm
->  vx.x.x

# 查看正在使用的版本
$ nvm current
vx.x.x

# 指定某个版本来执行文件
$ nvm run x.x.x some.js

# 卸载nvm
$ rm -rf ~/.nvm
```

# volta
> 尚未体验

一款与项目绑定的 node 版本管理工具。

- 官方文档：[https://volta.sh/](https://volta.sh/)
- 参考文档：[用Volta管理多个节点版本](https://juejin.cn/post/7084977608160444424)