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
MADLIB.submitTermTimelimit = 40
MADLIB.voteTermTimeLimit = 40

function MADLIB.OnLoad()
	MadlibFrame:RegisterEvent( "CHAT_MSG_GUILD" )
end
function MADLIB.OnUpdate()
	print( "OnUpdate() @"..time() )
	if MADLIB_game then  -- only need to do something here
		print( "Game Active" )
		if MADLIB_game.voteTerms then
			print( "Collecting terms" )
			if MADLIB_game.voteTerms.voteAt and MADLIB_game.voteTerms.voteAt <= time() then
				print( "Vote for terms" )
				MADLIB.VoteForTerms()
			end
			if MADLIB_game.voteTerms.closeAt and MADLIB_game.voteTerms.closeAt <= time() then
				print( "ResolveVotes" )
				MADLIB.ResolveVotes()
			end

		else
			print( "Not collecting terms" )
			if #MADLIB_game.terms < #MADLIB_Data[MADLIB_game.index].terms then
				print( "Need a term" )
				MADLIB.AskForTerm()
			else
				print( "All terms collected, PUBLISH" )
				MADLIB.Publish()
			end
		end
	end
end

function MADLIB.Print( msg )
	SendChatMessage( msg, "GUILD", nil, nil )
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
		MADLIB.Print( "Hello, welcome to Guild Madlibs. Please start your responses with \"ml: \" (no quotes)." )
		-- MADLIB.AskForTerm()
	end
end

function MADLIB.AskForTerm()
	print( "AskForTerm()" )
	local termIndex = #MADLIB_game.terms + 1
	local termType = MADLIB_Data[MADLIB_game.index].terms[termIndex]
	local termPre = string.find( termType, "^[aAeEiIoOuU]" ) and "an" or "a"
	MADLIB_game.voteTerms = { ["voteAt"] = time()+MADLIB.submitTermTimelimit, ["terms"] = {} }
	MADLIB.Print( string.format( "Please give me %s %s. You have %d seconds to submit an answer.", termPre, termType, MADLIB.submitTermTimelimit ) )
end
function MADLIB.GetSubmission( term )
	print( "GetSubmission( "..term.." )" )
	-- really generic, context inputs
	if MADLIB_game.voteTerms then
		print("I have voteTerms")
		if MADLIB_game.voteTerms.map then
			print("I have voteTerms.map")
			voteVal = tonumber( term )
			print( "voteVal: "..(voteVal or "nil" ) )
			if voteVal then
				MADLIB_game.voteTerms.terms[ MADLIB_game.voteTerms.map[voteVal] ] =
						MADLIB_game.voteTerms.terms[ MADLIB_game.voteTerms.map[voteVal] ] + 1
			end
		else
			MADLIB_game.voteTerms.terms[term] = true
		end
	end
end
function MADLIB.VoteForTerms()
	print( "VoteForTerms()" )
	MADLIB_game.voteTerms.voteAt = nil   -- we are now voting
	MADLIB_game.voteTerms.map = {}
	for term, _ in pairs( MADLIB_game.voteTerms.terms ) do
		print( term, _ )
		table.insert( MADLIB_game.voteTerms.map, term )
		MADLIB_game.voteTerms.terms[term] = 0
	end
	if #MADLIB_game.voteTerms.map == 1 then
		print( "There is 1 item to vote on." )
		MADLIB_game.voteTerms.closeAt = time()-1
	elseif #MADLIB_game.voteTerms.map > 1 then
		print( "There are multiple items to vote on." )
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
	print( "ResolveVotes()" )
	local termCount = 0
	for k,v in pairs( MADLIB_game.voteTerms.terms ) do
		termCount = termCount + 1
	end
	print( "I have "..termCount.." terms to vote on." )

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
			print( "WinningTerm: "..winningTerm.." with votes: "..winningVoteCount )
		end
		MADLIB_game.voteTerms = nil
	end
	-- if not MADLIB_game.voteTerms then
	-- 	print( "no voteTerms" )
	-- 	MADLIB.AskForTerm()
	-- end
end
function MADLIB.Publish()
	MADLIB.Print( string.format( MADLIB_Data[MADLIB_game.index].story,
			table.unpack( MADLIB_game.terms )
	) )
	MADLIB_game = nil
end

MADLIB.commandList = {
	["start"] = { ["func"] = MADLIB.StartGame },
}

function MADLIB.CHAT_MSG_GUILD(...)
	_, msg, player, language, _, _, other = ...
	print( msg )
	s, e, cmd, param = string.find( string.lower( msg ), "^ml: *([^ ]+) *([^ ]*)" )
	print( s, e, cmd, param )
	if s then
		if MADLIB.commandList[cmd] and MADLIB.commandList[cmd].func then
			MADLIB.commandList[cmd].func( param )
		else
			MADLIB.GetSubmission( cmd )
		end
	end




	--SendChatMessage( STEPS.GetPostString(), chatChannel, nil, toWhom )

end

-- string.format( "%s %s", table.unpack( t ) )