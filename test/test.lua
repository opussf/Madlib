#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Madlib.toc" )

function test.before()
	MADLIB_game = nil
	MADLIB_newgame = nil
	chatLog = {}
	MADLIB_Data = {
		{	["story"] = "Adjective: %s, Noun: %s.",
			["terms"] = { "Adjective", "Noun" },
		},
	}
	MADLIB.lastPrint = 0
	MADLIB.printQueue = {}
end
function test.after()
end
function test.test_start_lower()
	MADLIB.CHAT_MSG_GUILD( "", "ml: start", "user1" )
	assertTrue( MADLIB_game, "game table should be created." )
	assertEquals( 1, MADLIB_game.index, "game index should be 1." )
	assertTrue( MADLIB_game.terms, "game terms should be created." )
	assertEquals( time(), MADLIB_game.started, "game start should be set.")
end
function test.test_start_upper()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START", "user1" )
	assertTrue( MADLIB_game.terms, "game terms should be created." )
end
function test.test_start_specific()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	assertTrue( MADLIB_game.terms, "game terms should be created." )
end
function test.test_give_adjective_1()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ML: broken", "user1" )
	assertTrue( MADLIB_game.voteTerms.terms, "game terms should be created." )
	assertTrue( MADLIB_game.voteTerms.terms["broken"] )
end
function test.test_give_adjective_noSpace()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ML:broken", "user1" )
	assertTrue( MADLIB_game.voteTerms.terms, "game terms should be created." )
	assertTrue( MADLIB_game.voteTerms.terms["broken"] )
end
function test.longer_a_test_0_term_timeOut_onupdate()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 41,
		["voteTerms"] = {
			["voteAt"] = time() - 41,
			["terms"] = {
			},
		}
	}
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()
	assertIsNil( MADLIB_game )
end
function test.test_1_term_timeOut_onupdate()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 41,
		["voteTerms"] = {
			["voteAt"] = time() - 41,
			["terms"] = {
				["broken"] = true,
			},
		}
	}
	MADLIB.OnUpdate()
	assertIsNil( MADLIB_game.voteTerms )
	assertEquals( "broken", MADLIB_game.terms[1], "broken should be added to list." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 31,
		["voteTerms"] = {
			["voteAt"] = time() - 31,
			["terms"] = {
				["green"] = true,
				["red"] = true,
			},
		}
	}
	MADLIB.OnUpdate()
	voteVal = 0
	for i, t in ipairs( MADLIB_game.voteTerms.map ) do
		if t == "red" then
			voteVal = i
		end
	end
	MADLIB.CHAT_MSG_GUILD( "", "ml: "..voteVal, "user1" )
	assertEquals( 1, MADLIB_game.voteTerms.terms.red, "red should have 1 vote." )
	assertEquals( 0, MADLIB_game.voteTerms.terms.green, "green should have 0 votes." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 31,
		["voteTerms"] = {
			["closeAt"] = time()-1,
			["map"] = { "broken", "red", "persistent" },
			["terms"] = {
				["yellow"] = 0,
				["red"] = 1,
				["persistent"] = 0,
			},
		},
	}
	MADLIB.OnUpdate()
	assertEquals( "red", MADLIB_game.terms[1], "red should be choosen." )
end
function test.test_full_terms()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {"A","N"},
		["started"] = time() - 31,
	}
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()
	MADLIB.lastPrint = 0
	MADLIB.OnUpdate()
	assertEquals( "Adjective: A, Noun: N.", chatLog[#chatLog].msg )
	assertIsNil( MADLIB_game )
end
function test.test_term_multiple_words_2()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time(),
		["voteTerms"] = {
			["voteAt"] = time() + 40,
			["terms"] = {
			},
		}
	}
	MADLIB.CHAT_MSG_GUILD( "", "ml:green, and blue", "user1" )
	assertTrue( MADLIB_game.voteTerms.terms["green, and blue"] )
end
------  Add
function test.test_add_start()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	assertTrue( MADLIB_newgame )
	assertIsNil( MADLIB_newgame.terms[1] )
	assertEquals( "", MADLIB_newgame.story )
end
function test.test_add_start_message()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	assertEquals( "Enter the new madlib as \"ml: Hello {name}.\" Use a trailing / to allow an additional line.", chatLog[#chatLog].msg )
end
function test.test_add_oneline_story()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: There once was a {Noun} from {place}.", "user1" )
	MADLIB.OnUpdate()
	assertTrue( MADLIB_Data[2] )
	assertEquals( "There once was a %s from %s.", MADLIB_Data[2].story )
end
function test.test_add_oneline_twosentences()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: There once was a {Noun} from {place}. It was very {adjective}.", "user1" )
	MADLIB.OnUpdate()
	assertTrue( MADLIB_Data[2] )
	assertEquals( "There once was a %s from %s. It was very %s.", MADLIB_Data[2].story )
end
function test.test_add_oneline_twosentences_no_tracking_var()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: There once was a {Noun} from {place}. It was very {adjective}.", "user1" )
	MADLIB.OnUpdate()
	assertTrue( MADLIB_Data[2] )
	assertIsNil( MADLIB_Data[2].sentenceWordCount )
end
function test.test_add_oneline_terms()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: There once was a {Noun} from {place}.", "user1" )
	MADLIB.OnUpdate()
	assertIsNil( MADLIB_newgame )
	assertEquals( "Noun", MADLIB_Data[2].terms[1] )
	assertEquals( "Place", MADLIB_Data[2].terms[2] )
end
function test.test_add_twoline_story()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: Hello {name}. Please /", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: don't {verb} me./", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: bye.", "user1" )
	MADLIB.OnUpdate()
	assertEquals( "Hello %s. Please don't %s me. Bye.", MADLIB_Data[2].story )
end
function test.test_add_twoline_terms()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: add", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: Hello {name}. Please /", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: don't {verb} me.", "user1" )
	MADLIB.OnUpdate()
	assertEquals( "Verb", MADLIB_Data[2].terms[2] )
end
-- List
function test.test_list_()
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: list", "user1" )
	assertEquals( "MADLIB (@VERSION@) list:", MADLIB.printQueue[1] )
	assertEquals( "1 - 2 terms. Adjective: %s, Noun:", MADLIB.printQueue[2] )
end

-- Adjective: %s, Noun: %s.

function sorted_pairs( tableIn )
	local keys = {}
	for k in pairs( tableIn ) do table.insert( keys, k ) end
	table.sort( keys )
	local lcv = 0
	local iter = function()
		lcv = lcv + 1
		if keys[lcv] == nil then return nil
		else return keys[lcv], tableIn[keys[lcv]]
		end
	end
	return iter
end
function EscapeStr( strIn )
	-- This escapes a str
	strIn = string.gsub( strIn, "\\", "\\\\" )
	strIn = string.gsub( strIn, "\"", "\\\"" )
	return strIn
end
function dump( tableIn, depth )
	depth = depth or 1
	for k, v in sorted_pairs( tableIn ) do
		io.write( ("%s[\"%s\"] = "):format( string.rep("\t", depth), k ) )
		if ( type( v ) == "boolean" ) then
			io.write( v and "true" or "false" )
		elseif ( type( v ) == "table" ) then
			io.write( "{\n" )
			dump( v, depth+1 )
			io.write( ("%s}"):format( string.rep("\t", depth) ) )
		elseif ( type( v ) == "string" ) then
			io.write( "\""..EscapeStr( v ).."\"" )
		else
			io.write( v )
		end
		io.write( ",\n" )
	end
end

function test.notest_fullGame()
	-- Start game
	MADLIB.CHAT_MSG_GUILD( "", "ml: start", "user1" )
	MADLIB.OnUpdate()
	print( chatLog[#chatLog-1].msg )
	print( chatLog[#chatLog].msg )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml: persistent", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ml:sexy", "user1" )
	MADLIB.OnUpdate()
	MADLIB_game.started = time() - 42; MADLIB_game.voteTerms.voteAt = time()-42
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()
	print( chatLog[#chatLog-1].msg )
	print( chatLog[#chatLog].msg )
	dump( MADLIB_game )
	MADLIB.CHAT_MSG_GUILD( "", "ml:2", "user1" )
	MADLIB.OnUpdate()
	MADLIB_game.started = time() - 42; MADLIB_game.voteTerms.closeAt = time()-1;
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()
	print( chatLog[#chatLog].msg )
	MADLIB.CHAT_MSG_GUILD( "", "ml:beast", "user1" )
	MADLIB.OnUpdate()
	MADLIB_game.started = time() - 42; MADLIB_game.voteTerms.voteAt = time()-42
	MADLIB.OnUpdate()
	MADLIB.OnUpdate()

	print( chatLog[#chatLog].msg )
	-- dump( MADLIB_game )
	-- MADLIB_game.started = time() - 42; MADLIB_game.voteTerms.started = time()-42
	-- MADLIB.OnUpdate()
	-- MADLIB_game.voteTerms.closeAt = time()-1;
	-- MADLIB.OnUpdate()


	print( "==============" )
	for _, s in ipairs( chatLog ) do
		print( s.msg )
	end

	dump( MADLIB_game, 1 )
	fail("oops")
end


test.run()
