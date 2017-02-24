cmake_minimum_required(VERSION 3.0.0)

# MSVC: msbuild hlgme.sln /p:Configuration=Release
PROJECT(hlgme)

INCLUDE_DIRECTORIES(
	"G:/MyDoc/haxe/fork/hl/src"   # hashlink
	"../project/gme-master/gme"
)

FILE(GLOB SRC
	"../project/gme-master/gme/*.cpp"
	"./hlgme.c"
)

# 更改最终输目录在 CMakeLists 同层的 release/debug 下
SET(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR})

ADD_LIBRARY(gme MODULE ${SRC})

SET_TARGET_PROPERTIES(gme
	PROPERTIES
	OUTPUT_NAME hgme
	SUFFIX .hdll
)
