fgme
-----

Experimental! 实验性, 尝试 hxcpp/cpp 混合编程

#### 记录

仅在 winXP 中做过测试. 目前感觉CPU占用 53%, 反而是 flash 生成的同样库却根本不占CPU.

 0. 需要将目录添加到库, `haxelib dev fgme path/to/fgme`
 
 1. 双击 `tools/gen.hxml` 将在 `project/` 目录下生成 build.xml 和 静态链接库(gme.lib)
 
 2. 打开 test/bin.hxml, 得到 test/bin/Test.exe, 运行

感觉实在太复杂了, 没有相应的智能提示, 还不如直接用 C++ 来写, 或许写成 extern 的形式将没这么复杂.

#### 依赖

 * https://github.com/ncannasse/hxsdl

 * [game-music-emu](http://www.slack.net/~ant/libs/audio.html#Game_Music_Emu)
 
	```bash
	# git submodule

	git submodule init
	git submodule update
	```

#### 其它

[Flash DEMO](http://r32.github.io)

以前旧的版本 选择 [Original 分支](https://github.com/R32/fgme/tree/Original)