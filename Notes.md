# Notes

Stages:

1 	- no game
	MADLIB_game is nil

2   - Game started, ask for term
	MADLIB_game is present
	MADLIB_game.voteTerms.started  is present and < now
	MADLIB_game.voteTerms.terms    is present and #< #MADLIB_Data.terms

3   - Vote for terms
    MADLIB_game is present
    MADLIB_game.voteTerms.terms   is present and > 1
    MADLIB_game.voteTerms.closeAt is present and > now

4   - Resolve term (votes)
    MADLIB_game is present
    MADLIB_game.voteTerms.terms   is present
    MADLIB_game.voteTerms.closeAt is present and < now

4 -> 2

5   - Print Madlib



https://hobbylark.com/party-games/How-to-Make-Your-Own-Mad-Libs

https://www.thewordfinder.com/wordlibs/


ml: start <n>

Hello, welcome to Guild Madlibs. Please start your responses with "ml: " (no quotes).  Thanks.

Please give me a Noun.  You have 30 seconds to submit an answer.

ml: chair
ml: desk
ml: floor

I have recieved 3 suggestions for Noun.  Please vote for your favorite: 1 - chair, 2 - desk, 3 - floor.

ml: 1
ml: 1
ml: 2

Voting is closed. "chair" for Noun has won.

Please give me an Adjective.  You have 30 seconds to submit an answer.


    { "Coffeehouses are in! Gone are the local corner %s and the neighborhood ice-cream %s. It doesn’t matter if you live in a/an %s city or a/an %s town;
    there is bound to be a coffee %s in your %s neighborhood. Coffeehouses have become the place where %s friends gather, sit, and chew the %s,
    remembering the good old %s as they sip their steaming cups of %s. Coffeehouses cater to busy business , who use them to %s million- deals.
    Coffeehouses are also favorite spots for single men and %s, who love to linger over their mugs of as they watch the attractive go by,
    hoping to catch his or her , and maybe even %s a date. Most evenings, coffeehouses are filled by young lovers drinking out of each
    other's %s as they whisper sweet %s in each other’s %s.",
        "Noun", "Noun", "Adjective", "Adjective", "Noun", "Adjective", "Adjective", "Noun", "Plural Noun", "Verb", "Plural Noun", "Verb", "Plural Noun", "Plural Noun", "Part Of the Body" }
}

