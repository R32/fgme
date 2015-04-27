flashgme
-----

整理以前旧的文件夹时,发现的很古老的东西 [Flash DEMO](http://r32.github.io) 

 * cygwin 32位

 * flash alchemy 0.4a

#### 配置alchemy

 * cygwin setup 需求包

  - All -> Devel -> gcc-g++: C++ compiler

  - All -> Archive -> zip: Info-ZIP compression utility

  - All -> Perl -> perl: Larry Wall’s Practical Extracting and Report Language

 * 一些配置

  - 修改 alchemy-setup 文件的一些文件路径

  - 在 `etc/bash.bashrc` 文件结尾后添加: `source /cygdrive/DRIVE/PATH/TO/alchemy/alchemy-setup`

 * [可选] 下载 alc-asc 脚本

	> 如需将 swc 用于 haxe,目前只能动态加载, 因此这个的脚本可以用来移除 debug 信息,以减小文件体积

	> 如遇错误, 找不到 jar 文件..., 复制下边几行到 alc-asc 文件头部

	```perl
	my $hacks = $0;
	$hacks =~ s/\/[^\/]+$/\/hacks.pl/;
	require $hacks; 
	```

 * [可选] cygwin 右键菜单

	> 在 setup 安装包中,选上 Shells/chere : Cygwin Prompt Here context menus

	> 安装完成之后. cygwin bash 下输入 chere -i. win7 需要以管理员模式运行
	
	> 右键就能找到 bash prompt here 的菜单.

	> chere -u 将移除右键菜单. 参看 chere --help
