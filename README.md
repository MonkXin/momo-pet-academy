# 小白的学堂时光

一款原生 macOS 单机桌宠原型：白色凤眼兔、小屋式学堂、五项长期能力与本地存档。

## 当前功能

- 幼儿园成长路线与三门课程：识字小课、跳跳训练、小小舞台。
- 智力、武力、魅力、创造力、勇气五项长期能力。
- 饱食、心情、清洁、精力四项日常状态。
- 课程、摸摸、喂食、休息即时改变状态并保存到本机。
- 再次打开应用会按离线整天数结算日常状态，最多一次结算七天。
- 接星星小游戏：成功后心情 +8、幼儿园成长经验 +5。
- JSON 本地存档位于应用支持目录，关闭重开后仍会保留成长数据。

## 在 Cursor 终端运行

Xcode 当前位于下载目录时，使用：

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache \
swift run --disable-sandbox
```

测试：

```bash
DEVELOPER_DIR=/Users/monkxin/Downloads/Xcode.app/Contents/Developer \
SWIFTPM_MODULECACHE_OVERRIDE=/private/tmp/momo-swiftpm-cache \
CLANG_MODULE_CACHE_PATH=/private/tmp/momo-clang-module-cache \
swift test --disable-sandbox
```
