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



test.run()
