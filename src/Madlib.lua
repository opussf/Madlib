-- MADLIB @VERSION@
MADLIB_SLUG, MADLIB = ...
MADLIB_MSG_ADDONNAME = GetAddOnMetadata( MADLIB_SLUG, "Title" )
MADLIB_MSG_VERSION   = GetAddOnMetadata( MADLIB_SLUG, "Version" )
MADLIB_MSG_AUTHOR    = GetAddOnMetadata( MADLIB_SLUG, "Author" )

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

MADLIB_Data = {
	{ 	["story"] = "It was a %s, cold November day. I woke up to the %s smell of %s roasting in the %s downstairs. ",
		["terms"] = { "Adjective", "Adjective", "Type of Bird", "Room in a House" }
	}
}
MADLIB.submitTermTimelimit = 60
MADLIB.voteTermTimeLimit = 40
MADLIB.printQueue = {}
MADLIB.lastPrint = 0

function MADLIB.OnLoad()
	MadlibFrame:RegisterEvent( "CHAT_MSG_GUILD" )
end
function MADLIB.OnUpdate()
	if #MADLIB.printQueue > 0 then
		MADLIB.ProcessQueue()
	end
	if MADLIB_game and MADLIB_game.stopped then
		MADLIB_game = nil
	end
	if MADLIB_game then  -- only need to do something here
		-- print( "Game Active" )
		if MADLIB_game.voteTerms then
			-- print( "Collecting terms" )
			if MADLIB_game.voteTerms.voteAt and MADLIB_game.voteTerms.voteAt <= time() then
				-- print( "Vote for terms" )
				MADLIB.VoteForTerms()
			end
			if MADLIB_game.voteTerms.closeAt and MADLIB_game.voteTerms.closeAt <= time() then
				-- print( "ResolveVotes" )
				MADLIB.ResolveVotes()
			end
		else
			-- print( "Not collecting terms" )
			if #MADLIB_game.terms < #MADLIB_Data[MADLIB_game.index].terms then
				-- print( "Need a term" )
				MADLIB.AskForTerm()
			else
				-- print( "All terms collected, PUBLISH" )
				MADLIB.Publish()
			end
		end
	end
end
function MADLIB.Print( msg )
	local lineLength, wordLength, lineTable = 0, 0, {}
	for word in string.gmatch( msg, "([^ ]+)" ) do
		wordLength = string.len( word )
		if lineLength + wordLength + 1 < 250 then
			table.insert( lineTable, word )
			lineLength = lineLength + 1 + wordLength
		else
			table.insert( MADLIB.printQueue, table.concat( lineTable, " " ) )
			lineLength, lineTable = 0, { word }
		end
	end
	if lineLength > 0 then
		table.insert( MADLIB.printQueue, table.concat( lineTable, " " ) )
	end
end
function MADLIB.ProcessQueue()
	if MADLIB.printQueue and #MADLIB.printQueue > 0 and MADLIB.lastPrint + 1 < time() then
		SendChatMessage( table.remove( MADLIB.printQueue, 1 ), "GUILD", nil, nil )
		MADLIB.lastPrint = time()
	end
end
function MADLIB.StartGame( param )
	param = tonumber( param )
	if MADLIB_game then
		MADLIB.Print( "A game has already started. Please respond to the current prompt." )
	else
		MADLIB_game = {
				["index"] = (param and param <= #MADLIB_Data) and param or random(#MADLIB_Data),
				["terms"] = {},
				["started"] = time()
		}
		MADLIB.Print( "Hello, welcome to Guild Madlibs! Please start your responses with \"ml: \" (no quotes)." )
	end
end
function MADLIB.AskForTerm()
	-- print( "AskForTerm()" )
	local termIndex = #MADLIB_game.terms + 1
	local termType = MADLIB_Data[MADLIB_game.index].terms[termIndex]
	local termPre = string.find( termType, "^[aAeEiIoOuU]" ) and "an" or "a"
	MADLIB_game.voteTerms = { ["voteAt"] = time()+MADLIB.submitTermTimelimit, ["terms"] = {} }
	MADLIB.Print( string.format( "For term %d of %d, please give me %s %s.", termIndex, #MADLIB_Data[MADLIB_game.index].terms, termPre, termType ) )
end
function MADLIB.ProcessInput( term )
	-- print( "ProcessInput( "..term.." )" )
	-- really generic, context inputs
	if MADLIB_game and MADLIB_game.voteTerms then
		-- print("I have voteTerms")
		if MADLIB_game.voteTerms.map then
			-- print("I have voteTerms.map")
			voteVal = tonumber( term )
			-- print( "voteVal: "..(voteVal or "nil" ) )
			if voteVal then
				MADLIB_game.voteTerms.terms[ MADLIB_game.voteTerms.map[voteVal] ] =
						MADLIB_game.voteTerms.terms[ MADLIB_game.voteTerms.map[voteVal] ] + 1
			end
		else
			MADLIB_game.voteTerms.terms[term] = true
		end
	end
	if MADLIB_newgame then
		-- print( "New game" )
		local newStory = {}
		for word in string.gmatch( term, "([^ ]+)" ) do
			-- print( word )
			local isTerm, _, newterm = string.find( word, "^%{(.+)}[.]?$" )
			if isTerm then
				-- print( "\t"..newterm.." is a term." )
				word = string.gsub( word, "{"..newterm.."}", "%%s" )
				newterm = string.gsub( newterm, "^%l", string.upper )
				table.insert( MADLIB_newgame.terms, newterm )
				-- print( word )
			end
			if MADLIB_newgame.sentenceWordCount == 0 then
				word = string.gsub( word, "^%l", string.upper )
			end
			table.insert( newStory, word )
			MADLIB_newgame.sentenceWordCount = MADLIB_newgame.sentenceWordCount + 1
			if string.find( word, "[.][/]*$" ) then
				-- print( "End of sentence." )
				MADLIB_newgame.sentenceWordCount = 0
			end
		end
		MADLIB_newgame.story = MADLIB_newgame.story..(string.len(MADLIB_newgame.story) > 0 and " " or "")..table.concat( newStory, " " )

		local continue = string.find( MADLIB_newgame.story, "[ ]*/$" )
		if continue then
			-- print( "\t---- Continue. "..MADLIB_newgame.story )
			MADLIB_newgame.story = string.sub( MADLIB_newgame.story, 1, continue-1 )
		else
			-- print( "\t---- DON'T Continue.")
			MADLIB_newgame.sentenceWordCount = nil
			table.insert( MADLIB_Data, MADLIB_newgame )
			MADLIB_newgame = nil
			MADLIB.Print( "New madlib added as story: "..#MADLIB_Data )
		end
	end
end
function MADLIB.VoteForTerms()
	-- print( "VoteForTerms()" )
	MADLIB_game.voteTerms.voteAt = nil   -- we are now voting
	MADLIB_game.voteTerms.map = {}
	local mapCount = 0
	for term, _ in pairs( MADLIB_game.voteTerms.terms ) do
		table.insert( MADLIB_game.voteTerms.map, term )
		mapCount = mapCount + 1
		MADLIB_game.voteTerms.terms[term] = 0
	end
	if mapCount == 0 then
		-- let it get stuck
		-- print( "WHAT DO I DO? There are no terms for the current collection." )
		-- MADLIB.Print( string.format( "Stopping Madlib #%d with %d/%d terms.",
		-- 		MADLIB_game.index, #MADLIB_game.terms, #MADLIB_Data[MADLIB_game.index].terms
		-- ) )
		-- MADLIB_game.stopped = true
	elseif mapCount == 1 then
		-- print( "There is 1 item to vote on." )
		MADLIB_game.voteTerms.closeAt = time()-1
	elseif mapCount > 1 then
		-- print( "There are multiple items to vote on." )
		MADLIB_game.voteTerms.voteStrTable = {}
		for i, t in ipairs( MADLIB_game.voteTerms.map ) do
			table.insert( MADLIB_game.voteTerms.voteStrTable, i.." - "..t )
		end
		MADLIB.Print( string.format( "I have recieved %d suggestions for %s. You have %d seconds to vote for your favorite:",
				#MADLIB_game.voteTerms.map,
				MADLIB_Data[MADLIB_game.index].terms[#MADLIB_game.terms + 1],
				MADLIB.voteTermTimeLimit
		) )
		MADLIB.Print( table.concat( MADLIB_game.voteTerms.voteStrTable, ", " ) )
		MADLIB_game.voteTerms.closeAt = time() + MADLIB.voteTermTimeLimit
		-- table.insert( MADLIB_game.terms, MADLIB_game.voteTerms.map[1] )
	-- else  -- what if there are no terms to vote on.  end game?
	end
end
function MADLIB.ResolveVotes()
	-- print( "ResolveVotes()" )
	local termCount = 0
	for k,v in pairs( MADLIB_game.voteTerms.terms ) do
		termCount = termCount + 1
	end
	-- print( "I have "..termCount.." terms to vote on." )

	if termCount == 0 then
		MADLIB.AskForTerm()
	elseif termCount == 1 then
		table.insert( MADLIB_game.terms, MADLIB_game.voteTerms.map[1] )
		MADLIB_game.voteTerms = nil
	else
		winningTerm, winningVoteCount = nil, 0
		for term, votes in pairs( MADLIB_game.voteTerms.terms ) do
			if votes >= winningVoteCount then
				winningVoteCount = votes
				winningTerm = term
			end
		end
		if winningTerm then
			table.insert( MADLIB_game.terms, winningTerm )
			-- print( "WinningTerm: "..winningTerm.." with votes: "..winningVoteCount )
		end
		MADLIB_game.voteTerms = nil
	end
	-- if not MADLIB_game.voteTerms then
	-- 	print( "no voteTerms" )
	-- 	MADLIB.AskForTerm()
	-- end
end
function MADLIB.Publish()
	MADLIB.Print( "<Processing Story>" )
	MADLIB.Print( string.format( MADLIB_Data[MADLIB_game.index].story,
			unpack( MADLIB_game.terms )
	) )
	MADLIB_game = nil
end
function MADLIB.AddGame()
	MADLIB_newgame = { ["terms"] = {}, ["story"] = "", ["sentenceWordCount"] = 0}
	MADLIB.Print( "Enter the new madlib as \"ml: Hello {name}.\" Use a trailing / to allow an additional line." )
end
function MADLIB.ListGames()
	MADLIB.Print( "MADLIB ("..MADLIB_MSG_VERSION..") list:" )
	for i, ml in pairs( MADLIB_Data ) do
		MADLIB.Print( string.format( "%i - %i terms. %s", i, #ml.terms, string.sub( ml.story, 1, 20 ) ) )
	end
end
function MADLIB.Help()
	MADLIB.Print( "MADLIB ("..MADLIB_MSG_VERSION..") Command list: ")
	for k, s in pairs( MADLIB.commandList ) do
		MADLIB.Print( "ml: "..k..(string.len(s.help[1]) > 0 and " "..s.help[1] or "").." -- "..s.help[2] )
	end
end

MADLIB.commandList = {
	["start"] = { ["func"] = MADLIB.StartGame, ["help"] = { "<madlib number>", "Start a madlib." } },
	["add"] = { ["func"] = MADLIB.AddGame, ["help"] = { "", "Add a new madlib." } },
	["list"] = { ["func"] = MADLIB.ListGames, ["help"] = {"", "List madlibs." } },
	["help"] = { ["func"] = MADLIB.Help, ["help"] = { "", "This list." } },
}
function MADLIB.CHAT_MSG_GUILD(...)
	_, msg, player, language, _, _, other = ...
	-- print( msg )
	s, e, cmd, param = string.find( string.lower( msg ), "^ml[:;] *([^ ]+) *([^ ]*)" )
	-- print( s, e, cmd, param )
	if s then
		if MADLIB.commandList[cmd] and MADLIB.commandList[cmd].func then
			MADLIB.commandList[cmd].func( param )
		else
			s, e, submission = string.find( string.lower( msg ), "^ml[:;] *(.+)" )
			-- print( s, e, submission )
			MADLIB.ProcessInput( submission )
		end
	end
end
