#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Madlib.toc" )

function test.before()
	MADLIB.game = nil
	chatLog = {}
end
function test.after()
end
function test.test_start_lower()
	MADLIB.CHAT_MSG_GUILD( "", "ml: start", "user1" )
	assertTrue( MADLIB.game, "game table should be created." )
	assertEquals( 1, MADLIB.game.index, "game index should be 1." )
	assertTrue( MADLIB.game.terms, "game terms should be created." )
	assertEquals( time(), MADLIB.game.started, "game start should be set.")
end
function test.test_start_upper()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START", "user1" )
	assertTrue( MADLIB.game.terms, "game terms should be created." )
end
function test.test_start_specific()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	assertTrue( MADLIB.game.terms, "game terms should be created." )
end
function test.test_give_adjective_1()
	MADLIB.CHAT_MSG_GUILD( "", "ML: START 1", "user1" )
	MADLIB.CHAT_MSG_GUILD( "", "ML: broken", "user1" )
	assertTrue( MADLIB.game.voteTerms.terms, "game terms should be created." )
	assertTrue( MADLIB.game.voteTerms.terms["broken"] )
end
function test.test_1_term_timeOut_onupdate()
	MADLIB.game = {
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
	assertEquals( time(), MADLIB.game.voteTerms.closeAt )
	assertEquals( "broken", MADLIB.game.terms[1], "broken should be added to list." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB.game = {
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
	for i, t in ipairs( MADLIB.game.voteTerms.map ) do
		if t == "red" then
			voteVal = i
		end
	end
	MADLIB.CHAT_MSG_GUILD( "", "ml: "..voteVal, "user1" )
	assertEquals( 1, MADLIB.game.voteTerms.terms.red, "red should have 1 vote." )
	assertEquals( 0, MADLIB.game.voteTerms.terms.broken, "broken should have 0 votes." )
end
function test.test_2_terms_timeOut_onupdate_voteStarted()
	MADLIB.game = {
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
	-- assertEquals( 1, MADLIB.game.voteTerms.terms.red, "red should have 1 vote." )
	-- assertEquals( 0, MADLIB.game.voteTerms.terms.broken, "broken should have 0 votes." )
end

function test.notest_fullGame()
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
