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

function MADLIB.OnLoad()
	MadlibFrame:RegisterEvent( "CHAT_MSG_GUILD" )
end
function MADLIB.OnUpdate()
	if MADLIB.game then  -- only need to do something here
		if not MADLIB.game.voteTerms.map and time() > MADLIB.game.voteTerms.started+30 then
			MADLIB.VoteForTerms()
		end
		if MADLIB.game.voteTerms.closeAt and time() > MADLIB.game.voteTerms.closeAt then
			MADLIB.ResolveVotes()
		end
	end
end

function MADLIB.Print( msg )
	SendChatMessage( msg, "GUILD", nil, nil )
end

function MADLIB.StartGame( param )
	param = tonumber( param )
	if MADLIB.game then
		MADLIB.Print( "A game has already started. Please respond to the current prompt." )
	else
		MADLIB.game = {
				["index"] = (param and param <= #MADLIB_Data) and param or random(#MADLIB_Data),
				["terms"] = {},
				["started"] = time()
		}
		MADLIB.Print( "Hello, welcome to Guild Madlibs. Please start your responses with \"ml: \" (no quotes)." )
		MADLIB.AskForTerm()
	end
end

function MADLIB.AskForTerm()
	local termIndex = #MADLIB.game.terms + 1
	local termType = MADLIB_Data[MADLIB.game.index].terms[termIndex]
	local termPre = string.find( termType, "^[aAeEiIoOuU]" ) and "an" or "a"
	MADLIB.game.voteTerms = { ["started"] = time(), ["terms"] = {} }
	MADLIB.Print( string.format( "Please give me %s %s. You have 30 seconds to submit an answer.", termPre, termType ) )
end
function MADLIB.GetSubmission( term )
	print( "GetSubmission( "..term.." )" )
	-- really generic, context inputs
	if MADLIB.game.voteTerms then
		print("I have voteTerms")
		if MADLIB.game.voteTerms.map then
			print("I have voteTerms.map")
			voteVal = tonumber( term )
			print( "voteVal: "..voteVal )
			if voteVal then
				MADLIB.game.voteTerms.terms[ MADLIB.game.voteTerms.map[voteVal] ] =
						MADLIB.game.voteTerms.terms[ MADLIB.game.voteTerms.map[voteVal] ] + 1
			end
		else
			MADLIB.game.voteTerms.terms[term] = true
		end
	end
end
function MADLIB.VoteForTerms()
	print( "VoteForTerms" )
	MADLIB.game.voteTerms.map = {}
	for term, _ in pairs( MADLIB.game.voteTerms.terms ) do
		print( term )
		table.insert( MADLIB.game.voteTerms.map, term )
		MADLIB.game.voteTerms.terms[term] = 0
	end
	if #MADLIB.game.voteTerms.map == 1 then
		MADLIB.game.voteTerms.closeAt = time()
	elseif #MADLIB.game.voteTerms.map > 1 then
		MADLIB.game.voteTerms.voteStrTable = {}
		for i, t in ipairs( MADLIB.game.voteTerms.map ) do
			table.insert( MADLIB.game.voteTerms.voteStrTable, i.." - "..t )
		end
		MADLIB.Print( string.format( "I have recieved %d suggestions for %s. You have 30 seconds to vote for your favorite:",
				#MADLIB.game.voteTerms.map,
				MADLIB_Data[MADLIB.game.index].terms[#MADLIB.game.terms + 1]
		) )
		MADLIB.Print( table.concat( MADLIB.game.voteTerms.voteStrTable, ", " ) )
		MADLIB.game.voteTerms.closeAt = time() + 30
		-- table.insert( MADLIB.game.terms, MADLIB.game.voteTerms.map[1] )
	-- else  -- what if there are no terms to vote on.  end game?
	end
end
function MADLIB.ResolveVotes()

end

MADLIB.commandList = {
	["start"] = { ["func"] = MADLIB.StartGame },
}

function MADLIB.CHAT_MSG_GUILD(...)
	_, msg, player, language, _, _, other = ...
	-- print( msg )
	s, e, cmd, param = string.find( string.lower( msg ), "^ml: ([^ ]+) *([^ ]*)" )
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