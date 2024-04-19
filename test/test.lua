#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Madlib.toc" )

function test.before()
end
function test.after()
end



test.run()
