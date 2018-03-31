; This is a list of all interactions in the game. (Well, it's not finished yet.)
;
; COMMENT FORMAT:
;   LynnaLab parses the comments to glean information about interactions. When a line
;   starts with ";;", every subsequent line that starts with ";" is considered
;   documentation until the next uncommented line. Within here, the description can be
;   typed, or fields can be entered with "@field{value}".
;
;   Field list (case-insensitive):
;   * postype:
;       "normal" = X and Y positions are treated normally (default)
;       "short" = both Y and X positions are stored in Y variable.
;
; USING THIS WITH ZOLE:
;   To use this with ZOLE, first find the main ID of the object you want (on the .define
;   line), then check the comments to see if you want a particular subID.
;
;   Then, in ZOLE, create a "no-value interaction" or a "2-value interaction" with ID
;   XXYY, where XX is the main ID, and YY is the subid. (Use $00 if no subids are
;   specified.)
;
;   Example: INTERACID_DUNGEON_STUFF has subid $01, which drops a small key when all
;   enemies are killed. You would create an interaction with ID 1201.
;
;   If you also need to set var03, create a "Quadruple-value object" instead.  Set "Type"
;   to 0 (means "interaction"), and set "Unknown" to the value you need for var03.


;;
; Interactions $00-$0c consist of various animations.
; @subid{
;  [Bit 0| Flicker to create transparency]
;  [Bit 7| Disable sound effect]
; }
.define INTERACID_GRASSDEBRIS		$00
.define INTERACID_REDGRASSDEBRIS	$01
.define INTERACID_GREENPOOF		$02
.define INTERACID_SPLASH		$03
.define INTERACID_LAVASPLASH		$04
.define INTERACID_PUFF			$05
.define INTERACID_ROCKDEBRIS		$06
.define INTERACID_CLINK			$07
.define INTERACID_KILLENEMYPUFF		$08
.define INTERACID_SNOWDEBRIS		$09
.define INTERACID_SHOVELDEBRIS		$0a
.define INTERACID_0b			$0b
.define INTERACID_ROCKDEBRIS2		$0c

.define INTERACID_0d			$0d ; stub
.define INTERACID_0e			$0e ; stub

; SubID:
;  0: fall down hole effect
;  1: pegasus seed "dust" effect?
; Var03:
;  Bit 7 - disable sound effect
.define INTERACID_FALLDOWNHOLE		$0f

;;
; Farore.
.define INTERACID_FARORE		$10

;; Objects related to the mini-cutscenes where Farore spawns a chest.
; SubID: xy
;  y=0: "Parent" interaction
;  y=1: "Children" sparkles
;  x: for y=1, this sets the sparkle's initial angle
.define INTERACID_FARORE_MAKECHEST	$11

;;
; Various generic events used in dungeons.
; @positiontype{normal}
; @subid{
;  [$00|Show text on entering dungeon; also initializes toggle blocks, switches, and loads
;       static objects.]
;  [$01|Small key falls here when [wNumEnemies] == 0]
;  [$02|A chest appears here when [wNumEnemies] == 0]
;  [$03|Set room flag $80 when [wNumEnemies] == 0]
;  [$04|Create a staircase when [wNumEnemies] == 0 (and set room flag $80).
;       This will search the room for tiles with indices between $40-$43, and create
;       staircase tiles at those positions.]
; }
.define INTERACID_DUNGEON_STUFF		$12

;;
; When [wNumEnemies] == [subid], the block at this position can be pushed, and wNumEnemies
; will set to 0 (which may trigger a door opening). This increments wNumEnemies when it
; spawns.
.define INTERACID_PUSHBLOCK_TRIGGER	$13

;;
; This interaction is created at $d140 (w1ReservedInteraction1) when a block/pot/etc is
; pushed.
.define INTERACID_PUSHBLOCK		$14

;;
; Controls the red/yellow/blue floor tiles that toggle when jumped over.
; @subid{
;   [$00|"Parent" interaction; constantly checks Link's position and spawns subid1 when
;        appropriate.]
;   [$01|Toggles tile at position [var03] when Link lands, then deletes itself.]
; }
.define INTERACID_TOGGLE_FLOOR		$15

;;
; A minecart you can mount (gets replaced with SPECIALOBJECTID_MINECART once you start
; riding)
.define INTERACID_MINECART		$16

;;
; This shows a key or boss key sprite when opening a door.
; SubID is the tile index of the door being opened.
.define INTERACID_DUNGEON_KEY_SPRITE	$17

;;
; This is used when opening keyholes in the overworld.
; SubID is the treasure index of the key being used, minus $42 (TREASURE_GRAVEYARD_KEY,
; the first one).
.define INTERACID_OVERWORLD_KEY_SPRITE	$18

;;
; For torch puzzles.
; Subid: initial orientation of cube (0-5)
.define INTERACID_COLORED_CUBE		$19

; A flame that appears when the colored cube is put in the right place.
.define INTERACID_COLORED_CUBE_FLAME	$1a

; Subid:
;   bits 0-2: bit in wSwitchState which controls the gate
;   bits 4-7: 0: barrier extends left
;             2: barrier extends right
.define INTERACID_MINECART_GATE		$1b

; The book on farore's desk
.define INTERACID_FARORES_MEMORY	$1c

.define INTERACID_1d			$1d ; stub

;;
; This works as both a door opener and closer.
;
; angle: $00,$02,$04,$06 for small keys in respective directions;
;        $08,$0a,$0c,$0e for boss doors;
;        $10,$12,$14,$16 for shutters;
;        $18,$1a,$1c,$1e for minecart shutters.
;
; @Y{Used for Y/X position}
; @X{Value from 0-7 corresponding to a bit in wActiveTriggers (for subids $04-$07)}
;
; @subid{
;  [$00|open based on angle (see above)]
;  [$04-$07|door controlled by wActiveTriggers (switches, buttons)]
;  [$08-$0b|door shuts until [wNumEnemies] == 0]
;  [$0c-$0f|minecart doors]
;  [$10-$13|door closes and stays shut once Link moves away from it]
;  [$14|door opens when 2 torches are lit (up)]
;  [$15|door opens when 2 torches are lit (left)]
;  [$16|door opens when 1 torch is lit (down)]
;  [$17|door opens when 1 torch is lit (left)]
; }
; @postype{short}
.define INTERACID_DOOR_CONTROLLER	$1e

;;
; @subid{
;  [$00|Trigger a warp when Link dives here. (X should be 0 or 1, indicating where
;       to warp to, while Y is the short-form position.)]
;  [$01|Trigger a warp at the top of a waterfall (only if riding dimitri)]
;  [$02|Trigger a warp in a cave in a waterfall (only if riding Dimitri)]
; }
.define INTERACID_SPECIAL_WARP		$1f

;;
; Runs a dungeon-specific script. Subid is the script index.
.define INTERACID_DUNGEON_SCRIPT	$20

;;
; Runs assembly code for specific dungeon events.
; @subid{
;   [$00|Nothing]
;   [$01|d2: verify a 2x2 floor pattern, drop a key.]
;   [$02|d2: verify that a floor tile is red to open a door.]
;   [$03|Light torches when a colored cube rolls into this position.]
;   [$04|d2: Set torch color based on the color of the tile at this position.]
;   [$05|d2: Drop a small key here when a colored block puzzle has been solved.]
;   [$06|d2: Set trigger 0 when the colored flames are lit red.]
;   [$07|Toggle a bit in wSwitchState based on whether a toggleable floor tile at
;        position Y is blue. The bitmask to use is X.]
;   [$08|Toggle a bit in wSwitchState based on whether blue flames are lit. The bitmask
;        to use is X.]
;   [$09|d3: Drop a small key when 3 blocks have been pushed.]
;   [$0a|d3: When an orb is hit, spawn an armos, as well as interaction which will spawn
;            a chest when it's killed.]
;   [$0b|Unused? A chest appears when 4 torches in a diamond formation are lit?]
;   [$0c|d3: 4 armos spawn when trigger 0 is activated.]
;   [$0d|d3: Crystal breakage handler]
;   [$0e|d3: Small key falls when a block is pushed into place]
;   [$0f|d4: A door opens when a certain floor pattern is achieved]
;   [$10|d4: A small key falls when a certain froor pattern is achieved]
;   [$11|Tile-filling puzzle: when all the blue turns red, a chest will spawn here.]
;   [$12|d4: A chest spawns here when the torches light up with the color blue.]
;   [$13|d5: A chest spawns here when all the spaces around the owl statue are filled.]
;   [$14|d5: A chest spawns here when two blocks are pushed to the right places]
;   [$15|d5: Cane of Somaria chest spawns here when blocks are pushed into a pattern]
;   [$16|d5: Sets floor tiles to show a pattern when a switch is held down.]
;   [$17|Create a chest at position Y which appears when [wActiveTriggers] == X, but which
;        also disappears when the trigger is released.]
;   [$18|d3: Calculate the value for [wSwitchState] based on which crystals are broken.]
;   [$19|d1: Set trigger 0 when the colored flames are lit blue.]
;  }
.define INTERACID_DUNGEON_EVENTS	$21

; When a tile at this position is jumped over, all colored floor tiles in the room change
; colors.
; Subid:
;  0: The "controller".
;  1: Instance that's spawned by the controller to perform the replacement.
.define INTERACID_FLOOR_COLOR_CHANGER	$22

; Extends or retracts a bridge when a bit in wSwitchState changes.
; Subid: bits 0-2: bit in wSwitchState to watch
; Y: YX position
; X: Index of bridge data
.define INTERACID_EXTENDABLE_BRIDGE	$23

; Controls a bit in wActiveTriggers based on various things.
; Subid:
;   bits 0-3: 0: Control a bit in wActiveTriggers based on wToggleBlocksState.
;             1: Control a bit in wActiveTriggers based on wSwitchState.
;             2: Control a bit in wActiveTriggers based on if [wNumLitTorches] == Y.
;   bits 4-6: A bit to check in wToggleBlocksState or wSwitchState (subids 0 and 1 only)
; Y: Number of torches to be lit (subid 2 only).
; X: a bitmask for wActiveTriggers (subid 2 only).
.define INTERACID_TRIGGER_TRANSLATOR	$24

; Keeps track of the yellow tile in the tile-filling puzzles and updates the floor color.
; Starting position is determined by Y and X.
; To complete the tile-filling puzzle, an interaction with id $2111 should also exist;
; that will spawn the chest.
.define INTERACID_TILE_FILLER		$25

.define INTERACID_26			$26 ; stub
.define INTERACID_27			$27 ; stub

; Valid subids: $00-$0a
.define INTERACID_BIPIN			$28

; subid does nothing.
.define INTERACID_ADLAR			$29

; Librarian at eyeglasses library.
; subid does nothing.
.define INTERACID_LIBRARIAN		$2a

; Valid subids: $00-$09
.define INTERACID_BLOSSOM		$2b

; The wallmaster used in black tower escape cutscene?
.define INTERACID_VERAN_CUTSCENE_WALLMASTER	$2c

; Veran's face used in cutscene just before final battle
.define INTERACID_VERAN_CUTSCENE_FACE	$2d

; Old man who gives or takes money. His position is hardcoded. Uses room flag $40.
; Subid: 0 gives 200 rupees, 1 takes 100 rupees.
.define INTERACID_OLD_MAN_WITH_RUPEES	$2e

; Plays MUS_NAYRU and lowers volume if GLOBALFLAG_INTRO_DONE is not set.
.define INTERACID_PLAY_NAYRU_MUSIC	$2f

; Subid:
;   0: human npc
;   1: goron npc
;   2: elder npc (biggoron's sword minigame)
;   3: controls the game itself
.define INTERACID_SHOOTING_GALLERY	$30

; Subid:
;   0: First meet at the start of the game
;   1: Talking after nayru is kidnapped
;   2: Credits cutscene
;   3: Saved Zelda cutscene?
;   4: Cutscene at black tower entrance where Impa warns about Ralph's heritage
;   5: Like subid 4, but for linked game
;   6: ?
;   7: Tells you that Zelda's been kidnapped by vire
;   8: ?
;   9: Tells you that Zelda's been kidnapped by twinrova
;   a: ? (doesn't have a script)
.define INTERACID_IMPA_IN_CUTSCENE			$31

; A fake octorok.
; Subid:
;   0: Octorok attacking impa. (var03 is a value from 0-2 for the index.)
;   2: Great fairy turned into an octorok.
.define INTERACID_FAKE_OCTOROK		$32

; Not really the boss itself, but this basically "runs" the fight?
; Subid: this should be $ff; it's incremented each time an enemy is spawned to keep track
;        of the enemy index to spawn next.
.define INTERACID_SMOG_BOSS		$33

; The stone that's pushed at the start of the game. After it's moved, this stone is
; handled by PARTID_TRIFOCE_STONE instead.
.define INTERACID_TRIFORCE_STONE	$34

; The child that you name.
; subid: determines graphic.
;        0: hyperactive
;        1: shy
;        2: curious
;        3: slacker
;        4: warrior
;        5: arborist
;        6: singer
; var03: script index.
;        01-03: stage 4 (hyperactive/shy/curious)
;        04-06: stage 5
;        07-09: stage 6
;        0a-0d: stage 7 (slacker/warrior/arborist/singer)
;        0e-11: stage 8
;        12-15: stage 9
;        16-1c: unused?
.define INTERACID_CHILD			$35

; Subid:
;   00: Cutscene at the beginning of game (talking to Link, then gets posessed)
;   01: Cutscene in Ambi's palace after getting bombs
;   02: Cutscene on maku tree screen after being saved
;   03: Cutscene with Nayru and Ralph when Link exits the black tower
;   04: Cutscene at end of game with Ambi and her guards
;   05: ?
;   06: ?
;   07: Cutscene with the vision of Nayru teaching you Tune of Echoes
;   08: Cutscene after saving Zelda?
;   09: Cutscene where Ralph's heritage is revealed (unlinked?)
;   0a: Cutscene where Ralph's heritage is revealed (linked?)
;   0b: NPC after being saved
;   0c: NPC between being told about Ralph's heritage and beating Veran (linked?)
;   0d: NPC after Veran is beaten (linked)
;   0e: ?
;   0f: NPC after getting maku seed, but before being told about Ralph's heritage
;   10: Cutscene in black tower where Nayru/Ralph meet you to try to escape
;   11: Cutscene on white background with Din just before facing Twinrova
;   12: ?
;   13: NPC after completing game (singing to animals)
.define INTERACID_NAYRU			$36

; Subid:
;   00: Cutscene where Nayru gets posessed
;   01: Cutscene outside Ambi's palace before getting mystery seeds
;   02: Cutscene after Nayru is posessed
;   03: Cutscene after talking to Rafton
;   04: Cutscene on maku tree screen after saving Nayru
;   05: Cutscene in black tower where Nayru/Ralph meet you to try to escape
;   06: Cutscene at end of game with Ambi and her guards "confronting" Link
;   07: Cutscene postgame where they warp to the maku tree, Ralph notices the statue
;   08: Cutscene in credits where Ralph is training with his sword
;   09: Cutscene where Ralph charges in to Ambi's palace
;   0a: Cutscene where Ralph's about to charge into the black tower
;   0b: Cutscene where Ralph tells you about getting Tune of Currents
;   0c: Cutscene where Ralph confronts Ambi in black tower
;   0d: Cutscene where Ralph goes back in time
;   0e: Cutscene with Nayru and Ralph when Link exits the black tower
;   0f: Does nothing but stand there, facing right
;   10: Cutscene after talking to Cheval
;   11: NPC after finishing the game
;   12: NPC after beating Veran, before beating Twinrova in a linked game
.define INTERACID_RALPH			$37

; Subid: only $00 is valid
.define INTERACID_PAST_GIRL		$38

; Subid:
;   0: Listening to Nayru sing at beginning of game
;   1: Monkey disappearance cutscene (spawns multiple monkeys; var03 is monkey index)
;   2: Monkey that only exists before intro
;   3: Monkey that only exists before intro
;   4:
;   5: Spawns more monkeys
;   6:
;   7: A monkey npc depending on var03:
;      0: Appears between saving Nayru and beating game
;      1: Listening to Nayru after beating game
;      2: Appears between saving Maku tree and beating game
.define INTERACID_MONKEY		$39

; This guy's appearance changes based on his subid. Has "present" and "past" versions, and
; can also be a "construction worker" in the black tower?
;
; Subid:
;   00: Cutscene where guy is struck by lightning in intro
;   01: Past villager?
;   02: Guard blocking entrance to black tower
;   03: Guy in front of present maku tree screen
;   04: "Sidekick" to the comedian guy
;   05: Guy in front of shop
;   06: Villager in front of past maku tree screen
;   07: Villager in past near Ambi's palace
;   08: Villager outside house hear black tower
;   09: Villager who turns to stone in a cutscene?
;   0a: Villager turned to stone?
;   0b: Villager being restored from stone, resumes playing catch
;   0c: Villager playing catch with son
;   0d: Cutscene when you first enter the past
;   0e: Stone villager?
.define INTERACID_VILLAGER		$3a

; Like male villager, this person's appearance changes based on subid, with present and
; past versions.
; Subid:
;   00: Cutscene where guy is struck by lightning in intro
;   01: Present NPC near black tower
;   02: Present NPC outside shop
;   03: Past NPC south of shooting gallery screen
;   04: Past NPC just outside black tower
;   05: Past villager
;   06: Linked game NPC
;   07: NPC in eyeglasses library (present)
;   08: Present NPC in the house above the ocean
.define INTERACID_FEMALE_VILLAGER	$3b

; Subid:
;   00: Listening to Nayru sing in intro
;   01: Kid turning to stone cutscene
;   02: Kid outside shop
;   03: Cutscene where kids talk about how they're scared of a ghost (red kid)
;   04: Cutscene where kids talk about how they're scared of a ghost (green kid)
;   05: Cutscene where kid is restored from stone
;   06: Cutscene where kid sees his dad turn to stone
;   07: Depressed kid in trade sequence
;   08: Kid who runs around in a pattern? Used in a credits cutscene maybe?
;   09: Same as $08, but different pattern.
;   0a: Cutscene?
;   0b: NPC in eyeglasses library present
;   0c: Cutscene where kid's dad gets restored from stone
;   0d: Kid with grandma who's either stone or was restored from stone
;   0e: NPC playing catch with dad, or standing next to his stone dad
;   0f: Cutscene where kid runs away?
;   10: Listening to Nayru sing in endgame
.define INTERACID_BOY			$3c

; Old lady in the present.
; Subid:
;   00: NPC with a grandson that is stone for part of the game
;   01: Cutscene where her grandson gets turned to stone
;   02: NPC in present, screen left from bipin&blossom's house
;   03: Cutscene where her grandson is restored from stone
;   04: Linked game NPC (clock shop secret)
;   05: Linked game NPC (ruul secret)
.define INTERACID_OLD_LADY		$3d

; Subid:
;   00: Cutscene at start of game (unposessing Impa)
;   01: Cutscene just before fighting posessed Ambi
;   02: Cutscene just after fighting posessed Ambi
.define INTERACID_GHOST_VERAN		$3e

; Boy with sort of hostile-looking eyes?
; Subid:
;   0: Boy in deku forest; appears only before getting bombs
;   1: Boy at top-left of Lynna city; only appears between beating d7 and getting maku sed
;   2: Boy in cutscene near spirit's grave
;   3: Used in linked game credits maybe?
.define INTERACID_BOY_2			$3f

; Subid:
;   00:
;   01:
;   02: Left palace guard
;   03:
;   04:
;   05: Guard escorting Link in intermediate screens (just moves straight up)
;   06: Guard in cutscene who takes mystery seeds from Link
;   07: Guard just after Link is escorted out of the palace
;   08: Used in a cutscene? (doesn't do anything)
;   09: Right palace guard
;   0a: Red soldier that brings you to Ambi (escorts you from deku forest)
;   0b: Red soldier that brings you to Ambi (just standing there after escorting you)
;   0c:
;   0d: Friendly soldier after finishing game. var03 is soldier index.
.define INTERACID_SOLDIER		$40

; Subid:
;   00: Guy standing outside d2 (before you get bombs)
;   01-05: Old man who hangs out around lynna city. Each subid is for a different phase
;          in the game, all mutually exclusive)
.define INTERACID_MISC_MAN		$41

; Subid:
;   00: Guy telling you about there being seeds in the woods
;   01: Guy in past telling you about how his island drifts
.define INTERACID_MUSTACHE_MAN		$42

; Subid:
;   00: Guy who wants to find something Ambi desires
;   01/02: Some NPC (same guy, but different locations for different game stages)
;   03: Guy in a cutscene (turning to stone?)
;   04: Guy in a cutscene (stuck as stone?)
;   05: Guy in a cutscene (being restored from stone?)
;   06: Guy watching family play catch (or is stone)
;   07: Guy turned to stone?
.define INTERACID_PAST_GUY		$43

; Subid:
;   00: NPC giving hint about what ambi wants
;   01: NPC in start-of-game cutscene who turns into an old man
;   02/03: Bearded NPC in Lynna City
;   04: Bearded hobo in the past, outside shooting gallery
.define INTERACID_MISC_MAN_2		$44

; Subid:
;   00: Old lady whose husband was sent to work on black tower
;   01: Old lady hanging around lynna village
.define INTERACID_PAST_OLD_LADY		$45

; Subid:
;   0: Normal shopkeeper
;   1: Secret shop / chest game guy
;   2: Advance shop
.define INTERACID_SHOPKEEPER		$46

; Subid is the item being sold:
;   00: Ring box upgrade (L2) (changes self to subid $14 if appropriate)
;   01: 3 hearts
;   02: Hidden shop gasha seed 1
;   03: L1 shield
;   04: 10 bombs
;   05: Hidden shop ring
;   06: Hidden shop gasha seed 2
;   07: Potion from syrup's shop
;   08: Gasha seed from syrup's shop
;   09: Potion from syrup's shop (shifted left to make room for bombchus)
;   0a: Gasha seed from syrup's shop (shifted left to make room for bombchus)
;   0b: Bombchus
;   0c: Nothing?
;   0d: Strange flute
;   0e: Advance shop gasha seed
;   0f: Advance shop GBA ring
;   10: Advance shop random ring
;   11: L2 shield
;   12: L3 shield
;   13: Normal shop gasha seed (linked only)
;   14: Ring box upgrade (L3)
;   15: Hidden shop heart piece
.define INTERACID_SHOP_ITEM		$47

; Subid:
;   00-04: Tokays in cutscene who steal your stuff
;   05: NPC who trades meat for stink bag
;   06: Past NPC holding sword
;   07: Past NPC holding shovel
;   08: Past NPC holding harp
;   09: Past NPC holding flippers
;   0a: Past NPC holding seed satchel
;   0b: Linked game cutscene where tokay runs away from Rosa
;   0c: Participant in Wild Tokay game
;   0d: Past NPC in charge of wild tokay game
;   0e: Shopkeeper (trades items)
;   0f-10: Tokays who try to eat Dimitri
;   11: Past NPC looking after scent seedling
;   12: Present NPC outside museum
;   13: Present NPC below time portal
;   14: Present NPC outside cook's hut
;   15: Past NPC outside trading hut
;   16: Past NPC outside wild tokay game
;   17: Past NPC standing next to time portal
;   18: Past NPC on southeast shore
;   19: Present NPC in charge of the wild tokay museum
;   1a-1c: Tokay "statues" in the wild tokay museum
;   1d: NPC holding shield upgrade
;   1e: Present NPC who talks to you after climbing down vine
;   1f: Past NPC standing on cliff at north shore
.define INTERACID_TOKAY			$48

; Subid:
;   00:
;   01: Discovered fairy who's now hanging out in "main" forest screen, until you finish
;       the game.
;   02: Unused?
;   03:
;   04:
;   05-07: Generic NPC (between completing the maze and entering jabu)
;   08-0a: Generic NPC (between jabu and finishing the game)
;   0b: NPC in unlinked game who takes a secret
;   0c-0d: Generic NPC (after beating game)
;   0e-10: Generic NPC (while looking for companion trapped in woods)
.define INTERACID_FOREST_FAIRY		$49

; Subid:
;    0-2: pieces of triforce
;    3: Sparkles?
;    4: The "glow" behind the pieces of the triforce (var03 is the index)
;    5: Object that responds to key inputs?
;    6:
;    7:
;    8: Extra tree branches when scrolling up tree before titlescreen
;    9: var03 is a value from 0-2? Spawns subid $0a?
;    a:
.define INTERACID_INTRO_SPRITES_1	$4a

; Subid:
;   00: Listening to Nayru at the start of the game
;   01: Rabbit hopping through screen (cutscene where they turn to stone)
;       If counter1 is nonzero, it will turn to stone once it hits 0.
;   02: "Controller" for the cutscene where rabbits turn to stone? (spawns subid $01)
;   03: Rabbit being restored from stone cutscene (gets restored and jumps away)
;   04: Rabbit being restored from stone cutscene (the one that wasn't stone)
;   05: Rabbit being restored from stone cutscene (bonks into other bunney)
;   06: Stone bunny (between jabu and beating the game)
;   07: Generic NPC waiting around in the spot Nayru used to sing
.define INTERACID_RABBIT			$4b

; Subid:
;   00: Listening to Nayru at the start of the game
;   01-03: Different colored birds that do nothing but hop? Used in a cutscene?
;   04: Bird with Impa when Zelda gets kidnapped
.define INTERACID_BIRD			$4c

; Subid:
;   00: Cutscene where you give mystery seeds to Ambi
;   01: Cutscene after escaping black tower
;   02: Credits cutscene where Ambi observes construction of Link statue
;   03: Cutscene where Ambi does evil stuff atop black tower (after d7)
;   04: Same cutscene as subid $03 (black tower after d7), but second part
;   05: Cutscene where Ralph confronts Ambi
;   06: Cutscene just before fighting posessed Ambi
;   07: Cutscene where Ambi regains control of herself
;   08: Cutscene after d3 where you're told Ambi's tower will soon be complete
;   09: Does nothing?
;   0a: NPC after Zelda is kidnapped
.define INTERACID_AMBI			$4d

; Subid:
;   00: Subrosian in lynna village (linked only)
;   01: Subrosian in goron dancing game (while dancing game is active?)
;   02: Subrosian in goron dancing game (var03 is 0 or 1 for green or red npcs)
;   03: Linked game NPC telling you the subrosian secret (for bombchus)
;   04: Linked game NPC telling you the smith secret (for shield upgrade)
.define INTERACID_SUBROSIAN		$4e

; Impa as an npc at various stages in the game. There's also INTERACID_IMPA_IN_CUTSCENE.
; Subid:
;   00: Impa in Nayru's house
;   01: Impa in past (after telling you about Ralph's heritage)
;   02: Impa after Zelda's been kidnapped
;   03: Impa after getting the maku seed
.define INTERACID_IMPA_NPC		$4f

.define INTERACID_50			$50 ; stub

; The guy who you trade a dumbbell to for a mustache
.define INTERACID_DUMBBELL_MAN		$51

; An old man NPC. Note: INTERACID_OLD_MAN_WITH_RUPEES uses the same sprites.
; Subid:
;   00: Old man who takes a secret to give you the shield (same spot as subid $02)
;   01: Old man who gives you book of seals
;   02: Old man guarding fairy powder in past (same spot as subid $00)
;   03-06: Generic NPCs in the past library
.define INTERACID_OLD_MAN		$52

; The dog lover.
; Subid:
;   $00: Only valid value
.define INTERACID_MAMAMU_YAN		$53

; Mamamu Yan's dog.
; Subid:
;   00: Dog in mamamu's house
;   01: Dog outside that Link needs to find for a "sidequest". var03 is the map index
;       (0-3).
.define INTERACID_DOG			$54

; Explosion animation; no collisions.
;   var03: if set, it has a higher draw priority?
.define INTERACID_EXPLOSION		$56

; A sword, as used by Ralph. Doesn't have collisions?
; Appears to check bit 7 of relatedObj1's animParameter to see when to do the sword swing
; animation. (That is, it's linked to a Ralph object that tells it when to animate.)
.define INTERACID_SWORD			$5e

; Not maple syrup, syrup the witch
.define INTERACID_SYRUP			$5f

; This is an object that Link can collect.
;   Subid: treasure index (see constants/treasure.s)
;   var03: index in "treasureObjectData.s" indicating graphic, text when obtained, etc.
;   var38: If nonzero, and not $ff, this overrides the parameter 'c' to pass to the
;         "giveTreasure" function? (normally this is determined from treasureObjectData.s)
.define INTERACID_TREASURE		$60

; Subid:
;   $3d: Monkey bow
;   $3f: Ball used by villagers (only in cutscene; when actually used it's INTERACID_BALL)
;   $73: Meat in tokay game
;
; var03: ?
.define INTERACID_ACCESSORY		$63

; When subid=$80, this spawns in your animal companion (used after playing the flute)
.define INTERACID_COMPANION_SPAWNER	$67

; Stub
.define INTERACID_6f			$6f

; Meat used in "wild tokay" game?
.define INTERACID_70			$70

; Subid:
;   0: link riding horse
;   1: link on horse neighing
;   2: cliff that horse stands on in temple shot
;   3: link on horse (closeup)
;   4: "sparkle" on closeup of link's face
;   5: birds
.define INTERACID_INTRO_SPRITE		$75

; This causes a tile  at a given position to change between 2 values depending on whether
; a certain switch is activated or not.
;   Subid:  Bitmask to check on wSwitchState (if nonzero, "active" tile is placed)
;   X:      "index" of tile replacement (defines what tiles are placed for on/off)
;   Y:      Position of tile that should change when wSwitchState changes
.define INTERACID_SWITCH_TILE_TOGGLER	$78

.define INTERACID_MOVING_PLATFORM	$79

; This interaction is created when "sent back by a strange force". It makes the entire
; screen turn into a giant sine wave.
.define INTERACID_SCREEN_DISTORTION	$7c

.define INTERACID_MINIBOSS_PORTAL	$7e

; Subid $04 is the scent seedling. Other subids are...?
.define INTERACID_SCENT_SEEDLING	$80

.define INTERACID_TOKAY_SHOP_ITEM	$81

; subid: 0: A tiny sparkle that disappears in an instant.
;        4: A big, red-and-blue orb that's probably used with the maku seed or something?
;        7: ?
;        8: ?
.define INTERACID_SPARKLE		$84

.define INTERACID_MAKU_TREE_CHILD	$88

; An ember seed that goes up for a bit, then disappears after falling a bit. Only used in
; the cutscene where you give ember seeds to Tokays.
.define INTERACID_TOKAY_CUTSCENE_EMBER_SEED	$8f

.define INTERACID_90			$90

; Bubbles created at random when swimming in a sidescrolling area
.define INTERACID_BUBBLE		$91

.define INTERACID_TWINROVA		$93

; Ball used by villagers.
.define INTERACID_BALL			$95

.define INTERACID_EXCLAMATION_MARK	$9f

; An image which moves up and to the left or right for 70 frames, then disappears.
; subid: 0: "Z" letter for a snoring character
;        1: A musical note
; var03: 0: Veer left
;        1: Veer right
.define INTERACID_FLOATING_IMAGE	$a0

.define INTERACID_TOUCHING_BOOK		$a5

; A flame used for the twinrova cutscenes (changes color based on parameters?)
.define INTERACID_TWINROVA_FLAME	$a9

; Decides which objects need to be spawned in the bipin/blossom family.
; Subid: 0 for left side of house, 1 for right side of house.
.define INTERACID_BIPIN_BLOSSOM_FAMILY_SPAWNER		$ac

.define INTERACID_ZELDA			$ad

; Used for the credits text in between the mini-cutscenes.
.define INTERACID_CREDITS_TEXT_HORIZONTAL	$ae
; Used for the credits after the cutscenes.
.define INTERACID_CREDITS_TEXT_VERTICAL	$af

; Energy thing that appears when you enter the final dungeon for the first time
.define INTERACID_FINAL_DUNGEON_ENERGY	$b5

; SubID: a unique value from $0-$f used as an index for wGashaSpot variables
.define INTERACID_GASHA_SPOT		$b6

; These are little hearts that float up when Zelda kisses Link in the ending cutscene.
.define INTERACID_KISS_HEART		$b7

.define INTERACID_HUMAN_VERAN		$bb

; Banana carried by Moosh in credits cutscene. Maybe also the obtainable banana in seasons?
.define INTERACID_BANANA		$c0

.define INTERACID_PIRATE_SHIP		$c2

; Play a harp song, and make music notes at Link's position. Used when Link learns a song.
;   Subid: song to play (0-2)
.define INTERACID_PLAY_HARP_SONG	$c5

; Creates an object of the given type with the given ID at every position where there's
; a tile of the specified index, then deletes itself.
; subid: tile index; an object will be spawned at each tile with this index.
; Y: ID of object to spawn
; X: bits 0-3: Subid of object to spawn
;    bits 4-7: object type (0=enemy, 1=part, 2=interaction)
.define INTERACID_CREATE_OBJECT_AT_EACH_TILEINDEX	$c7

.define INTERACID_CUCCO			$c9

.define INTERACID_d2			$d2

; Birds used while scrolling up the tree before the titlescreen
.define INTERACID_INTRO_BIRD			$d3

; This is for the great fairy that cleans the sea. For great fairies that heal, see
; "ENEMYID_GREAT_FAIRY".
; Subid:
;   0: ?
;   1: cutscene after being healed from being an octorok
.define INTERACID_GREAT_FAIRY		$d5

; Subid is the index of the secret (value of "wShortSecretIndex"?). This either creates
; a chest or just gives the item to Link (if it's an upgrade).
.define INTERACID_FARORE_GIVEITEM	$d9

; The warp animation that occurs when entering a time portal.
; SubID: 0: Initiating a warp (entered a portal from the source screen)
;        1: Completing a warp (warping in to the destination screen)
.define INTERACID_TIMEWARP		$dd

; A time portal created with the Tune of Currents or Tune of Ages.
; (TODO: wrap in ifdef)
.define INTERACID_TIMEPORTAL		$de

.ifdef ROM_SEASONS
.define INTERACID_DE			$de
.endif

; Blurb that displays the season/era at the top of the screen when entering an area.
.define INTERACID_ERA_OR_SEASON_INFO	$e0

; Creates a time portal when the Tune of Echoes is played.
.define INTERACID_TIMEPORTAL_SPAWNER	$e1

; Eyeball that looks at Link
.define INTERACID_STATUE_EYEBALL	$e2

; Subid: value from 0-2
.define INTERACID_RAFT			$e6
