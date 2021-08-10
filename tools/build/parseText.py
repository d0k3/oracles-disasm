#!/usr/bin/python3

# This is the program which parses text.yaml.
#
# TODOS:
# - "index: auto"
# - Don't hardcode address in the makefile; use DATA_ADDR value in disassembly along with macros
#   that allow for cross-bank data.

import sys
import io
import yaml
from common import *

if len(sys.argv) < 5:
    print('Usage: ' + sys.argv[0] + ' dictfile textfile outfile startaddress [--vwf]')
    print('dictfile: The dictionary file to use for compression.')
    print('textfile: a file such as the kind generated by dumpText.py.')
    print('outfile: an assembly file to be created for WLA containing the final data in a human-unreadable form.')
    print('startaddress: beginning address to place the text (text table starts here, then the text itself)')
    sys.exit(1)

argIndex = 1

dictFile = open(sys.argv[argIndex], 'r')
argIndex+=1
textFile = open(sys.argv[argIndex], 'r')
argIndex+=1
outFilename = sys.argv[argIndex]
argIndex+=1
startAddress = int(sys.argv[argIndex])
argIndex+=1

useVwf = False

EUText = False

while len(sys.argv) > argIndex:
    s = sys.argv[argIndex]
    argIndex+=1
    if s == '--vwf':
        useVwf = True
        spacingFilename = sys.argv[argIndex]
        argIndex+=1
    if s == '--EU':
        EUText = True



class TextStruct:

    def __init__(self, groupIndex, indices, names, isDict):
        self.indices = indices
        self.data = bytearray()
        self.compressedData = None
        self.names = names
        self.groupIndex = groupIndex
        self.isDict = isDict

        # List of tuples (index,name), where:
        #  "index" is an index for "data".
        #  "name" is a string which can be evaluated to a byte to be written there.
        self.unparsedNames = []

    def getPrimaryName(self):
        return self.names[0]

    def getGroupIndex(self):
        return self.groupIndex

    def getFinalData(self): # Data which will be written to output file
        if self.isDict:
            return self.data
        else:
            return self.compressedData


class GroupStruct:

    def __init__(self, i, isDict):
        self.index = i
        self.isDict = isDict
        self.textStructs = []
        self.lastTextIndex = 0

    def addTextStruct(self, indices, names):
        t = TextStruct(self.index, indices, names, self.isDict)
        self.textStructs.append(t)
        return t

    def getTextStruct(self, index):
        for textStruct in self.textStructs:
            if index in textStruct.indices:
                return textStruct

    def getTextName(self, index):
        struct = self.getTextStruct(index)
        if struct == None:
            return None
        i = struct.indices.index(index)
        return struct.names[i]

    # Turns a name into an index. Name must be from this group.
    def parseName(self, name):
        for textStruct in self.textStructs:
            if name in textStruct.names:
                i = textStruct.names.index(name)
                return textStruct.indices[i]
        raise ValueError

    # Gets the first index in this group that's not used already
    def getFreeIndex(self):
        for i in range(256):
            if self.getTextStruct(i) == None:
                return i
        raise Exception("Ran out of free indices")



class DictEntry:

    def __init__(self, i, s):
        self.fullIndex = i
        self.string = s


class EntryStruct:

    def __init__(self, d, a, b):
        self.dictEntry = d
        self.i = a
        self.j = b
# Maps string to DictEntry
textDictionary = {}

# Attempt to match the game's compression algorithm (epic failure)
def compressTextMatchGame(text, i):
    j = 0
    res = bytearray()
    dicts = []
    while j < len(text):
        dictEntry = None
        # Attempt to find the largest dictionary entry starting at j
        for k in range(len(text), j, -1):
            dictEntry = textDictionary.get(bytes(text[j:k]))
            if dictEntry is not None:
                dicts.append(EntryStruct(dictEntry, j, k))
                break

        j+=1

    dicts = sorted(dicts, key=lambda x: x.j-x.i)

    i = 0
    while i < len(dicts):
        j = i+1
        while j < len(dicts):
            e1 = dicts[i]
            e2 = dicts[j]
            if e1.j > e2.i and e2.j > e1.i:
                dicts.remove(e1)
                i-=1
                break
            j+=1
        i+=1

    res = bytearray()
    i = 0
    while i < len(text):
        entry = None
        for e in dicts:
            if e.i == i:
                entry = e
                break
        if entry is not None:
            res.append((e.dictEntry.fullIndex>>8)+2)
            res.append(e.dictEntry.fullIndex&0xff)
            i = e.j
        else:
            res.append(text[i])
            i+=1

    return res

# These are the compression functions that are actually used

sys.setrecursionlimit(10000)
memo = {}

def compressTextMemoised(text, i):
    key=text[0:i]
    if key in memo:
        return memo[key]
    res = compressTextOptimal(text, i)
    memo[key] = res
    return res
# Compress first i characters of text

def compressTextOptimal(text, i):
    if i == 0:
        return bytearray()
    elif i == 1:
        b = bytearray()
        b.append(text[0])
        return b

    ret = bytearray(compressTextMemoised(text[:i-1], i-1))
    ret.append(text[i-1])

    j = 0
    get = textDictionary.get
    skip = False
    for c in text:
        if skip:
            j+=1
            skip = False
            continue
        dictEntry = get(text[j:])
        if dictEntry is not None:
            #print 'dictentry'
            res = compressTextMemoised(text[:j], j)
            if len(res)+2 < len(ret):
                res = bytearray(res)
                res.append((dictEntry.fullIndex>>8)+2)
                res.append(dictEntry.fullIndex&0xff)
                ret = res

        # Control codes can't have their parameters compressed
        if c >= 6 and c < 0x10:
            skip = True
        j+=1

    return ret

# This class used as a way to pass around variables in the parseTextFile
# function
class TextState:
    def __init__(self):
        # Normally the initial value would be zero, but after messing around
        # with the palettes, it's equivalent to 4. 0 and 4 are both white color
        # text, but they use different palettes for reasons.
        self.currentColor = 4
        # Number of pixel the line takes up so far
        self.lineWidth = 0
        self.widthUpToLastSpace = 0
        # Index of where to insert a newline if the current line
        # overflows
        self.lastSpaceIndex = 0
        # This is similar to currentColor, but it keeps track of the color of the current
        # 8x8 tile, for vwf. This is to help detect "color bleeding" when red and blue
        # colors are close together.
        self.currentTileColor = self.currentColor


# vwf stuff
if useVwf:
    spacingFile = open(spacingFilename, 'rb')
    characterSpacing = bytearray(spacingFile.read())
    spacingFile.close()
else:
    characterSpacing = bytearray()
    for i in range(256):
        characterSpacing.append(8)

MAX_LINE_WIDTH = 16*8+1


# Special chars tables. US version has some unused special characters, EU rom has more.
# (EU rom can handle values in both tables.)
US_available = "ÀÂÄÆÇÈÉÊËÎÏÑÖŒÙÛÜàâäæçèéêëîïñöœùûü"
US_values = [0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d,
        0x8e, 0x8f, 0x90, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0xa5, 0xa6, 0xa7, 0xa8, 0xa9, 0xaa, 0xab,
        0xac, 0xad, 0xae, 0xaf, 0xb0]

EU_additional = "ß¡¿´Ô°ÁÍÓÚÌÒÅôªáíóúìòå"
EU_values = [0x91, 0x98, 0x99, 0xb1, 0xc0, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xd0,
        0xd1, 0xd2, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7, 0xd8]

# Return True if the special character is handled in this version
def isHandledSpecialChar(c):
    # JP (characters carried from jp text engine but still available)
    if (c in ['“', '「', '」', '、', '”', '〜', '。']):
        return True
    # US and EU
    if (c in US_available):
        return True
    # EU only
    elif EUText and (c in EU_additional):
        return True
    return False

# Returns the encoding value of a special character from UNICODE
def specialCharValue(c):
    assert(isHandledSpecialChar(c))

    # JP characters
    if c == '“':
        return 0x1a
    if c == '「':
        return 0x1b
    if c == '」':
        return 0x1c
    if c == '、':
        return 0x1e
    if c == '”':
        return 0x22
    if c == '〜':
        return 0x5c
    if c == '。':
        return 0x5f

    ind = US_available.find(c)
    if (ind != -1):
        return US_values[ind]

    ind = EU_additional.find(c)
    if (ind != -1):
        return EU_values[ind]

    assert(False) # Character not found (should not happen)




groupDict = {}
parsedGroups = set()

totalTextDataSize = 0
textOffsetSplitIndex = 0xff # This will be changed if necessary

def parseTextFile(textFile, isDictionary):
    global groupDict, totalTextDataSize, textOffsetSplitIndex

    yamlData = yaml.safe_load(textFile)
    textFile.close()

    for yamlGroup in yamlData['groups']:
        if isDictionary:
            adjustedIndex = yamlGroup['group']
        else:
            adjustedIndex = yamlGroup['group'] + 4

        if adjustedIndex in groupDict:
            raise Exception('Group 0x%.2x defined twice.' % yamlGroup['group'])

        textGroup = GroupStruct(adjustedIndex, isDictionary)
        groupDict[textGroup.index] = textGroup

        if textGroup.index in parsedGroups:
            print('WARNING: Parsing group 0x' + myhex(textGroup.index, 2) + ' more than once.')

        for yamlTextData in yamlGroup['data']:
            indices = yamlTextData['index']
            if type(indices) != list:
                indices = [indices]

            names = yamlTextData['name']
            if type(names) != list:
                names = [names]

            if len(names) != len(indices):
                raise Exception("Mismatch between # of names & indices for " + names[0] + ".")

            try:
                for i in range(len(indices)):
                    if indices[i] == 'auto': # Special case; can be this string instead of a number
                        indices[i] = textGroup.getFreeIndex()
                    index = indices[i]
                    if index < 0 or index > 255:
                        raise ValueError("Index " + hex(index) + " is invalid.")
                    if textGroup.getTextStruct(index) != None:
                        raise Exception('Index 0x%.2x already defined.' % index)
                    textGroup.lastTextIndex = max(textGroup.lastTextIndex, index)

                textStruct = textGroup.addTextStruct(indices, names)

                state = TextState()

                def addWidth(state, w):
                    oldWidth = state.lineWidth
                    state.lineWidth += w
                    if state.lineWidth > MAX_LINE_WIDTH:
                        if state.lastSpaceIndex != 0:
                            textStruct.data[state.lastSpaceIndex] = 0x01
                            state.lastSpaceIndex = 0
                            state.lineWidth -= state.widthUpToLastSpace
                            state.currentTileColor = state.currentColor

                    # vwf: when we pass a tile boundary, update the currentTileColor.
                    # Uses oldWidth-2 because characters always end with a space.
                    if (oldWidth-2)//8 != state.lineWidth//8:
                        state.currentTileColor = state.currentColor

                i = 0

                def textEq(s):
                    nonlocal i
                    if text[i:i+len(s)] == s:
                        i += len(s)
                        return True
                    return False
                
                text = yamlTextData['text']
                while i < len(text):
                    c = text[i]
                    if c == '\n':
                        textStruct.data.append(0x01)
                        state.lineWidth = 0
                        state.lastSpaceIndex = 0
                        state.currentTileColor = state.currentColor
                        i+=1
                    elif c == '\\':
                        i+=1

                        validToken = False

                        # Check values which don't need to use brackets
                        if textEq('Link') or textEq('link'):
                            validToken = True
                            textStruct.data.append(0x0a)
                            textStruct.data.append(0x00)
                            addWidth(state, 8*5)
                        elif textEq('Child') or textEq('child'):
                            validToken = True
                            textStruct.data.append(0x0a)
                            textStruct.data.append(0x01)
                            addWidth(state, 8*5)
                        elif textEq('secret1'):
                            validToken = True
                            textStruct.data.append(0x0a)
                            textStruct.data.append(0x02)
                            addWidth(state, 8*5)
                        elif textEq('secret2'):
                            validToken = True
                            textStruct.data.append(0x0a)
                            textStruct.data.append(0x03)
                            addWidth(state, 8*5)
                        elif textEq('num1'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(1<<3)
                            addWidth(state, 8*2) # Could actually be up to 3 digits so be careful
                        elif textEq('opt'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(2<<3)
                            addWidth(state, 8)
                        elif textEq('stop'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(3<<3)
                        elif textEq('heartpiece'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(5<<3)
                            addWidth(state, 16)
                        elif textEq('num2'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(6<<3)
                            addWidth(state, 8*2) # Could actually be up to 3 digits so be careful
                        elif textEq('slow'):
                            validToken = True
                            textStruct.data.append(0x0c)
                            textStruct.data.append(7<<3)
                        elif textEq('circle'):
                            validToken = True
                            c = 0x10
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('club'):
                            validToken = True
                            c = 0x11
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('diamond'):
                            validToken = True
                            c = 0x12
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('spade'):
                            validToken = True
                            c = 0x13
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('heart'):
                            validToken = True
                            c = 0x14

                            if useVwf:
                                # vwf stuff: the heart is always supposed to be
                                # red. Since I messed with the palettes this
                                # needs to be fixed
                                if state.currentColor >= 2:
                                    textStruct.data.append(0x09)
                                    textStruct.data.append(0x00)
                                    state.currentColor = 0x00

                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('up'):
                            validToken = True
                            c = 0x15
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('down'):
                            validToken = True
                            c = 0x16
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('left'):
                            validToken = True
                            c = 0x17
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('right'):
                            validToken = True
                            c = 0x18
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('times'):
                            validToken = True
                            c = 0x19
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('abtn'):
                            validToken = True
                            c = 0xb8
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                            c = 0xb9
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('bbtn'):
                            validToken = True
                            textStruct.data.append(0xba)
                            textStruct.data.append(0xbb)
                            addWidth(state, characterSpacing[0xba]+characterSpacing[0xbb])
                        elif textEq('triangle'):
                            validToken = True
                            c = 0x7e
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('rectangle'):
                            validToken = True
                            c = 0x7f
                            textStruct.data.append(c)
                            addWidth(state, characterSpacing[c])
                        elif textEq('n'): # NOTE: shares prefix with "num1", "num2"
                            validToken = True
                            textStruct.data.append(0x01)
                            state.lineWidth = 0
                            state.lastSpaceIndex = 0
                            state.currentTileColor = state.currentColor
                        elif textEq('\\'):  # 2 backslashes
                            validToken = True
                            textStruct.data.append('\\')
                            addWidth(state, characterSpacing[ord('\\')])

                        if validToken:
                            try: # Allow optional empty brackets
                                if i+1 < len(text) and text[i] == '(' and text[i+1] == ')':
                                    i+=2
                            except exceptions.IndexError:
                                pass
                            continue

                        x = str.find(text, '(', i)
                        token = ''
                        param = -1

                        if x != -1:
                            y = str.find(text, ')', i)
                            if y != -1:
                                token = text[i:x]
                                param = text[x+1:y]

                        # Check values which use brackets (tokens)
                        if token == 'item':
                            if useVwf:
                                # Symbols must be aligned to a tile.

                                # Remove a space if there was one, because
                                # it will be weirdly spaced out.
                                if (len(textStruct.data) >= 3
                                        and textStruct.data[-3] == ord(' ') # There was a space
                                        and textStruct.data[-2] == 0x09 # Then a color opcode
                                        and textStruct.data[-1] >= 0x80 # Color opcode's parameter
                                        and state.lineWidth >= characterSpacing[ord(' ')]
                                        and (state.lineWidth&7) < 4 ):
                                    textStruct.data[-3] = textStruct.data[-2]
                                    textStruct.data[-2] = textStruct.data[-1]
                                    textStruct.data.pop()

                                    state.lineWidth -= characterSpacing[ord(' ')]
                                    print('Trimming space for item in ' + textStruct.getPrimaryName())

                                # Align to the next tile
                                if state.lineWidth & 7 != 0:
                                    state.lineWidth &= ~7
                                    state.lineWidth += 8
                                addWidth(state, 8)
                            else:
                                addWidth(state, 8)

                            textStruct.data.append(0x06)
                            textStruct.data.append(parseVal(param) | 0x80)

                        elif token == 'sym':
                            textStruct.data.append(0x06)
                            textStruct.data.append(parseVal(param))
                            addWidth(state, 8)
                        elif token == 'jump':
                            textStruct.data.append(0x07)
                            try:
                                textStruct.data.append(parseVal(param))
                            except ValueError:
                                textStruct.unparsedNames.append( (len(textStruct.data), param) )
                                textStruct.data.append(0xff)
                        elif token == 'col':
                            p = parseVal(param)

                            if useVwf:
                                # Check if 2 non-white colors are adjacent
                                def colorCmp(x,y):
                                    return x!=0 and y!=0 \
                                            and x<4 and y<4 \
                                            and x != y

                                # Check if separate colors are too close
                                # together
                                if colorCmp(state.currentTileColor,p):
                                    print('Red/blue colors too close together in "' + textStruct.getPrimaryName() + '", adding extra space')
                                    addWidth(state, characterSpacing[ord(' ')])
                                    textStruct.data.append(ord(' '))

                                # Special behaviour for vwf: in order to
                                # prevent colors from "leaking", after using
                                # color 3, it must switch to color 4 for the
                                # normal color instead of color 0
                                if state.currentColor == 3 and p == 0:
                                    p = 4

                            textStruct.data.append(0x09)
                            textStruct.data.append(p)
                            state.currentColor = p
                        elif token == 'charsfx':
                            textStruct.data.append(0x0b)
                            textStruct.data.append(parseVal(param))
                        elif token == 'speed':
                            p = parseVal(param)
                            assert p >= 0 and p < 4, '"\speed" takes parameters from 0-3'
                            textStruct.data.append(0x0c)
                            textStruct.data.append(p)
                        elif token == 'pos':
                            p = parseVal(param)
                            assert p >= 0 and p < 4, '"\pos" takes parameters from 0-3'
                            textStruct.data.append(0x0c)
                            textStruct.data.append((4<<3) | p)
                        elif token == 'wait':
                            textStruct.data.append(0x0d)
                            textStruct.data.append(parseVal(param))
                        elif token == 'sfx':
                            textStruct.data.append(0x0e)
                            textStruct.data.append(parseVal(param))
                        elif token == 'call':
                            textStruct.data.append(0x0f)
                            try:
                                textStruct.data.append(parseVal(param))
                            except ValueError:
                                textStruct.unparsedNames.append( (len(textStruct.data), param) )
                                textStruct.data.append(0xff)
                        elif len(token) == 4 and\
                                token[0:3] == 'cmd' and\
                                isHex(token[3]):
                            textStruct.data.append(int(token[3], 16))
                            textStruct.data.append(parseVal(param))
                        elif text[i] == 'x':
                            textStruct.data.append(int(text[i+1:i+3], 16))
                            i+=3

                            try:
                                if i+1 < len(text) and text[i] == '(' and text[i+1] == ')':
                                    i+=2
                            except exceptions.IndexError:
                                pass

                            continue
                        else:
                            raise Exception("Couldn't parse '" + token + "'.")

                        assert(param != -1)
                        i = y+1

                    # Adding special characters (natively handled by the game)
                    elif isHandledSpecialChar(c):
                        b = specialCharValue(c)
                        textStruct.data.append(b)
                        addWidth(state, characterSpacing[b])
                        i+=1

                    else:
                        c = text[i]
                        textStruct.data.append(ord(c))

                        if c == ' ':
                            state.lastSpaceIndex = len(textStruct.data)-1
                            state.widthUpToLastSpace = state.lineWidth+characterSpacing[ord(c)]

                        addWidth(state, characterSpacing[ord(c)])

                        i+=1


                # Outside while loop
                if not 'null_terminator' in yamlTextData:
                    yamlTextData['null_terminator'] = True

                if yamlTextData['null_terminator']:
                    textStruct.data.append(0)


            except:
                print('Error parsing text: "' + textStruct.getPrimaryName() + '".')
                raise

        # Once finished parsing this group, go through all the TextStructs to deal with the unparsedNames.
        for struct in textGroup.textStructs:
            for tup in struct.unparsedNames:
                i = tup[0]
                name = tup[1]
                try:
                    struct.data[i] = textGroup.parseName(name)
                except ValueError:
                    raise ValueError('Error: \"' + name + '\" is an invalid name to jump to from %s.' % struct.getPrimaryName())

        # Now compress text (if not a dictionary entry) and check whether the "textOffsetSplitIndex"
        # needs to be updated
        groupTextDataSize = 0
        for textStruct in textGroup.textStructs:
            if totalTextDataSize >= 0x10000:
                #print(hex(textGroup.index)) # Debugging
                #print(textStruct.getPrimaryName())
                if textOffsetSplitIndex != 0xff:
                    raise Exception("Too much text; Drenn needs to add 2nd textOffsetSplitIndex to parser")
                textOffsetSplitIndex = textGroup.index

                # Reset totalTextDataSize to be only the size of this group so far (the new
                # textOffsetSplitIndex applies to the entire group, not just this entry)
                totalTextDataSize = groupTextDataSize

            if not isDictionary:
                textStruct.compressedData = compressTextMemoised(bytes(textStruct.data), len(textStruct.data))

            totalTextDataSize += len(textStruct.getFinalData())
            groupTextDataSize += len(textStruct.getFinalData())


# Parse dictionary text file
parseTextFile(dictFile, True)

# Compile dictionary
for i in range(4):
    if not i in groupDict:
        continue
    group = groupDict[i]
    for textStruct in group.textStructs:
        if len(textStruct.data) != 0:
            dat = bytearray(textStruct.data)
            if dat[-1] != 0:
                print('Expected null terminator on dictionary entry ' + textStruct.getPrimaryName())
                continue
            dat = dat[:-1]
            textDictionary[bytes(dat)] = DictEntry((textStruct.getGroupIndex() << 8) | textStruct.indices[0], dat)


# Parse main text file
parseTextFile(textFile, False)


numGroups = max(groupDict)+1
# Hardcoded stuff: groups 5e-63 are unused but still have pointers defined
if numGroups < 0x64:
    numGroups = 0x64

# Find 'skipped groups': list of group numbers which are skipped over
skippedGroups = []
i = 0
for g in sorted(groupDict):
    group = groupDict[g]
    while group.index != i:
        skippedGroups.append(i)
        i+=1
    i+=1
while i < numGroups:
    skippedGroups.append(i)
    i+=1

# Begin generating output
outFile = open(outFilename, 'w')

address = (startAddress%0x4000)+0x4000
bank = startAddress//0x4000

textOffset1 = groupDict[0].textStructs[0]
textOffset2 = groupDict[textOffsetSplitIndex].textStructs[0]

# Print defines

definesFile = open('build/textDefines.s', 'w')

definesFile.write('.define TEXT_OFFSET_SPLIT_INDEX ' + wlahex(textOffsetSplitIndex, 2) + '\n\n')

for group in groupDict.values():
    if group.index >= 4:
        for textStruct in group.textStructs:
            for i in range(len(textStruct.names)):
                fullIndex = ((textStruct.getGroupIndex() - 4) << 8) | textStruct.indices[i]
                definesFile.write('.define ' + textStruct.names[i] + ' ' + wlahex(fullIndex, 4) + '\n')

definesFile.close()

# Print tables

outFile.write('.BANK ' + wlahex(bank, 2) + '\n')
outFile.write('.ORGA ' + wlahex(address, 4) + '\n\n')

outFile.write('textTableENG:\n')

for i in range(0, numGroups):
    outFile.write('\t.dw textTableENG_' + myhex(i, 2) + ' - textTableENG\n')
    address += 2

# All skipped groups reference group 0
outFile.write('\ntextTableENG_00:\n')
for g in sorted(skippedGroups):
    outFile.write('textTableENG_' + myhex(g, 2) + ':\n')

for group in groupDict.values():
    if group.index != 0:
        outFile.write('textTableENG_' + myhex(group.index, 2) + ':\n')

    if group.index < textOffsetSplitIndex:
        textOffset = 'TEXT_OFFSET_1'
    else:
        textOffset = 'TEXT_OFFSET_2'

    for i in range(0, group.lastTextIndex+1):
        textName = group.getTextName(i)
        if textName is None:
            outFile.write('\t.dw $0000 ; Undefined\n')
            print('WARNING: Text index ' + myhex(((group.index-4) << 8) | i, 4) + ' undefined.')
            address += 2
        else:
            outFile.write(
                '\tm_RelativePointer ' + textName + '_ADDR  ' + textOffset + '\n')
            address += 2


outFile.write('\n')

# Print actual text
for group in groupDict.values():
    for textStruct in group.textStructs:
        data = textStruct.getFinalData() # Uncompressed if dictionary, compressed otherwise

        if textOffset1 == textStruct:
            outFile.write('TEXT_OFFSET_1:\n')
        elif textOffset2 == textStruct:
            outFile.write('TEXT_OFFSET_2:\n')

        for name in textStruct.names:
            outFile.write(name + '_ADDR:\n')
        i = 0
        lineEntries = 0
        while i < len(data):
            if lineEntries >= 8:
                outFile.write('\n')
                lineEntries = 0
            if lineEntries == 0:
                outFile.write('\t.db')
            outFile.write(' ' + wlahex(data[i], 2))
            i+=1
            lineEntries+=1
            address+=1

            if address >= 0x8000:
                address = 0x4000
                bank += 1
                outFile.write('\n\n.BANK ' + wlahex(bank, 2) + '\n')
                outFile.write('.ORGA ' + wlahex(address, 4) + '\n\n')
                lineEntries = 0

        outFile.write('\n')

        # Debug output
#                 outFile2 = open('build/debug/' + textStruct.name + '.cmp', 'wb')
#                 outFile2.write(data)
#                 outFile2.close()


outFile.write('\n.DEFINE TEXT_END_ADDR ' + wlahex(address, 4) + '\n')
outFile.write('.DEFINE TEXT_END_BANK ' + wlahex(bank, 2))
outFile.close()

# Debug output: if this is equivalent to the debug output from "dumpText.py", then the text was at
# least parsed correctly.
#outFile = open('text/test2.bin','wb')
#for group in groupDict.values():
#    for textStruct in group.textStructs:
#        outFile.write(bytes(textStruct.data))
#outFile.close()
