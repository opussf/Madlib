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
	StripDiceFrame:RegisterEvent( "CHAT_MSG_GUILD" )
end
function MADLIB.OnUpdate()
	if MADLIB.game then  -- only need to do something here
		if not MADLIB.game.voteTerms.votes and time() > MADLIB.game.voteTerms.started+30 then
			MADLIB.VoteForTerms()
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
				["started"] = time()}
		MADLIB.Print( "Hello, welcome to Guild Madlibs. Please start your responses with \"ml: \" (no quotes). Thanks." )
		MADLIB.AskForTerm()
	end
end

function MADLIB.AskForTerm()
	termIndex = #MADLIB.game.terms + 1
	termType = MADLIB_Data[MADLIB.game.index].terms[termIndex]
	termPre = string.find( termType, "^[aAeEiIoOuU]" ) and "an" or "a"
	MADLIB.game.voteTerms = { ["started"] = time(), ["terms"] = {} }
	MADLIB.Print( string.format( "Please give me %s %s. You have 30 seconds to submit an answer.", termPre, termType ) )
end
function MADLIB.GetTerm( term )
	if MADLIB.game.voteTerms then
		MADLIB.game.voteTerms.terms[term] = true
	end
end
function MADLIB.VoteForTerms()
	MADLIB.game.voteTerms.votes = {}

	-- I have recieved 3 suggestions for Noun.  Please vote for your favorite: 1 - chair, 2 - desk, 3 - floor.
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
			MADLIB.GetTerm( cmd )
		end
	end




	--SendChatMessage( STEPS.GetPostString(), chatChannel, nil, toWhom )

end

-- string.format( "%s %s", table.unpack( t ) )