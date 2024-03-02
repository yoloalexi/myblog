#!/bin/bash
set -e

# 构建文档
yarn run docs:build

# 清空站点dist目录
rm -rf /www/wwwroot/www.zhuyanlin.com/dist/*

# 复制构建好的文件到站点目录
cp -r /www/wwwroot/www.zhuyanlin.com/blog/docs/.vuepress/dist/* /www/wwwroot/www.zhuyanlin.com/dist/

