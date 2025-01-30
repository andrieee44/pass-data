# pass-data

[NAME](#NAME)  
[SYNOPSIS](#SYNOPSIS)  
[DESCRIPTION](#DESCRIPTION)  
[EXAMPLE](#EXAMPLE)  
[SEE ALSO](#SEE%20ALSO)  
[AUTHOR](#AUTHOR)  

------------------------------------------------------------------------

## NAME <span id="NAME"></span>

pass-data − pass extension for decrypting data for use in external
programs.

## SYNOPSIS <span id="SYNOPSIS"></span>

**pass data** *PATH PROGRAM ARGS ...*

## DESCRIPTION <span id="DESCRIPTION"></span>

***pass data*** is a pass extension, originally designed to work with
*calcurse*(1) using calendar data managed by *pass*(1). **pass data**
temporarily decrypts the data and makes it available to the program with
the environment variable **\$PASS_DATA** and reencrypts it after the
program is finished executing.

## EXAMPLE <span id="EXAMPLE"></span>

Run *calcurse*(1):

**\$ pass data calendar calcurse -D '"\$PASS_DATA"'**

## SEE ALSO <span id="SEE ALSO"></span>

***pass***(1), *calcurse*(1)

## AUTHOR <span id="AUTHOR"></span>

andrieee44 (andrieee44@gmail.com)

------------------------------------------------------------------------
