#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Madlib.toc" )

function test.before()
	MADLIB_game = nil
	chatLog = {}
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
	MADLIB.CHAT_MSG_GUILD( "", "ML: broken", "user1" )
	assertTrue( MADLIB_game.voteTerms.terms, "game terms should be created." )
	assertTrue( MADLIB_game.voteTerms.terms["broken"] )
end
function test.test_give_adjective_noSpace()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	MADLIB.OnUpdate()
	MADLIB.CHAT_MSG_GUILD( "", "ML:broken", "user1" )
	MADLIB.OnUpdate()
	assertTrue( MADLIB_game.voteTerms.terms, "game terms should be created." )
	assertTrue( MADLIB_game.voteTerms.terms["broken"] )
end
function test.notest_1_term_timeOut_onupdate()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 31,
		["voteTerms"] = {
			["started"] = time() - 31,
			["terms"] = {
				["broken"] = true,
			},
		}
	}
	MADLIB.OnUpdate()
	assertEquals( time(), MADLIB_game.voteTerms.closeAt )
	assertEquals( "broken", MADLIB_game.terms[1], "broken should be added to list." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 31,
		["voteTerms"] = {
			["started"] = time() - 31,
			["terms"] = {
				["broken"] = true,
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
	assertEquals( 0, MADLIB_game.voteTerms.terms.broken, "broken should have 0 votes." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB_game = {
		["index"] = 1,
		["terms"] = {},
		["started"] = time() - 31,
		["voteTerms"] = {
			["started"] = time() - 31,
			["closeAt"] = time(),
			["map"] = { "broken", "red", "persistent" },
			["terms"] = {
				["broken"] = 0,
				["red"] = 0,
				["persistent"] = 1,
			},
		},
	}
	MADLIB.OnUpdate()
	-- assertEquals( 1, MADLIB_game.voteTerms.terms.red, "red should have 1 vote." )
	-- assertEquals( 0, MADLIB_game.voteTerms.terms.broken, "broken should have 0 votes." )
end

function test.test_fullGame()
	-- Start game
	MADLIB.CHAT_MSG_GUILD( "", "ml: start", "user1" )
	for _, s in ipairs( chatLog ) do
		print( s.msg )
	end
	MADLIB.CHAT_MSG_GUILD( "", "ml: persistent", "user1" )
	for _, s in ipairs( chatLog ) do
		print( s.msg )
	end
end


test.run()
