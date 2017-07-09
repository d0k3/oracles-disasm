; Note: the tiles listed here may not apply for all areas.

; Tiles in normal areas

.define TILEINDEX_UNLIT_TORCH		$08
.define TILEINDEX_LIT_TORCH		$09
.define TILEINDEX_GASHA_TREE_TL		$4e
.define TILEINDEX_CONVEYOR_UP		$54
.define TILEINDEX_CONVEYOR_RIGHT	$55
.define TILEINDEX_CONVEYOR_DOWN		$56
.define TILEINDEX_CONVEYOR_LEFT		$57
.define TILEINDEX_TRACK_TL		$59
.define TILEINDEX_TRACK_BR		$5a
.define TILEINDEX_TRACK_BL		$5b
.define TILEINDEX_TRACK_TR		$5c
.define TILEINDEX_TRACK_HORIZONTAL	$5d
.define TILEINDEX_TRACK_VERTICAL	$5e
.define TILEINDEX_MINECART_PLATFORM	$5f
.define TILEINDEX_MYSTICAL_TREE_TL	$6e
.define TILEINDEX_MINECART_DOOR_UP	$7c
.define TILEINDEX_MINECART_DOOR_RIGHT	$7d
.define TILEINDEX_MINECART_DOOR_DOWN	$7e
.define TILEINDEX_MINECART_DOOR_LEFT	$7f
.define TILEINDEX_STANDARD_FLOOR	$a0 ; Keyblocks and such will turn into this tile
.define TILEINDEX_SOFT_SOIL		$d2
.define TILEINDEX_GRAVE_HIDING_DOOR	$d9
.define TILEINDEX_SOMARIA_BLOCK		$da
.define TILEINDEX_SWITCH_DIAMOND	$db
.define TILEINDEX_STAIRCASE		$dc
.define TILEINDEX_CURRENT_UP		$e0
.define TILEINDEX_CURRENT_DOWN		$e1
.define TILEINDEX_CURRENT_LEFT		$e2
.define TILEINDEX_CURRENT_RIGHT		$e3
.define TILEINDEX_WHIRLPOOL		$e9
.define TILEINDEX_CHEST_OPENED		$f0
.define TILEINDEX_CHEST			$f1
.define TILEINDEX_SIGN			$f2
.define TILEINDEX_HOLE			$f3
.define TILEINDEX_SOFT_SOIL_PLANTED	$f5
.define TILEINDEX_GRASS			$f8

.ifdef ROM_AGES
	.define TILEINDEX_PUDDLE	$f9
	.define TILEINDEX_WATER		$fa
.else ; ROM_SEASONS
	; For seasons, $f8-$f9 count as grass, $fa-$fc count as puddles
	.define TILEINDEX_PUDDLE	$fa
	.define TILEINDEX_WATER		$fd
.endif

.define TILEINDEX_DEEP_WATER		$fc

; Tiles in sidescrolling areas
.define TILEINDEX_SS_SPIKE		$02

