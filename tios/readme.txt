--Calcsys 1.1 Source Code (Dan Englender...TCPA)
This source is not very well commented, organized, or optimized, but
people have been asking me for it, and there seems to be some demand
for examples of application source code, so here it is.

The Calcsys source code is organized into 4 main files:
-calcsys.asm  -- This is the main source file, containing all the code
-text.txt     -- This contains all the menu and most other text
-dtabstr.txt  -- This contains the text for the disassembler
-dtabdata.txt -- This contains the data tables for the disassembler

The three text files are pretty easy to follow, the the calcsys.asm
file deserves a bit more explanation.  Here's some labels, and their
functions:
-start        -- This is where the app begins executing
-mainmenu     -- This is the first main menu, which you see when you
                 first start up the app.
-mainmenu2    -- This is the second main menu, which you get to by
                 pressing 6 (more) on the first menu
-nextvataddr  -- A routine for finding the next vat entry
-getbyte      -- The general routine to get a byte in TIOS protocol
-recbyte      -- The actual link receive routine (as taken from the
                 rom...I didn't use the rom routine because I wanted to
                 lower the link timeout)
-sendbyte     -- same as getbyte, but sends a byte
-sendit       -- same as recbyte, but sends a byte
-dispbin      -- Displays a 8 bit number in binary, on the homescreen
-disphex      -- Displays a 8 bit hexadecimal number on the homescreen
-disphexhl    -- Displays a 16 bit hexadecimal number on the homescreen
-disptextm    -- A routine to display a block of text
-disptext     -- Same as rom _puts, but can display from apps
-getnumerich  -- Inputs a number in hexadecimal using _getkey
-getnumerichc -- Inputs a number in hexadecimal using _getcsc
-disphexscreen-- Displays the hexadecimal display screen
-gettext      -- Inputs string input
-parse        -- An extremely complex and unoptimized call that parses
                 input from the console.  Do not use this a model for
                 a good command parser :)
-conrun       -- The strange routine to run asm progs
-isvalidbytestring -- Determines if the text in a string is a hex value
                      Sort of like the expr() function in basic.
-quit         -- The routine to quit the program.
-conlangant   -- A secret
-consierpint  -- Oops...another secret

(note: You'll notice the generalerrorh label, which is commented out.
 This was a error handler for the entire application, any time a system
 error was generated and allowed you to quit to the homescreen or
 restart calcsys.  I took it out before the final version because it
 seemed worthless (and I was short on space))
(note: You'll see that getnumericb is commented out.  It was originally
 going to be a routine to input a number in binary, but I never
 finished it because there was no need for it in Calcsys)
(note: You'll also see getnumeric.  This is a completely functional
 routine to input a number in decimal.  I commented it out when I
 changed all Calcsys functions to input in hexadecimal)

It would probably also be useful to know what a few of the memory
variables are, so here are some of those:
-linkwait      -- The timeout for the link routines (TIOS has this
                  value at $FFFF, I found that $6000 worked fine and
                  transfered faster)
-port          -- Originally to keep the current port number in but it
                  turned into a temporary variable for lots of routines
-oldport       -- The last port value, used to see if the port was
                  changed or not (and if it was, make a log entry)
-hexaddr       -- Current address for hex editor
-rompage       -- Current rompage for hex editor
-daddr         -- Current address for disassembler
-rompaged      -- Current rompage for disassembler
-conxx (af,etc)-- Virtual registers for console
-vattable      -- Table of vat entries currently on screen
-strbuf        -- Buffer used to display app text
-textbuf       -- Buffer used to store inputted text
-command       -- Buffer used to store console text data
-args          -- Buffer used to store argument part of console data
-portlog       -- Flag to indicate if log mode is possible (option 2)
-logenabled    -- Flag to indicate if log is on right now
-gethexnoback  -- If this flag is set, you can't use backspace while
                  inputting hex numbers.
-fastdisasm    -- Nothing :)

...I hope this helps at least someone.  If you have any questions feel
free to email me at:
alfix97@hotmail.com