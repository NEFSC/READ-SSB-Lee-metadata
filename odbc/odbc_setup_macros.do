/* 
Min-Yang's preferred approach to connecting to NEFSC's Oracle from Stata is:

odbc load,  exec("select something from schema.table 
	where blah blah blah;")
	conn("$mydb1_connection") lower;

where $mydb1_connection contains a connection string for the oracale database

This sample file shows how to build one.
Because there are semicolons inside the connection string, you should not use semicolons as delimiters in this file*/

/* windows notes: you need oracle instant client set up; tnsnames.ora in the proper place.
Your database connections (sole and nova) have to be set up in ODBC Data sources. */


version 15.1
#delimit cr
global myuid "your_uid"
global mypwd "your_pwd_here"
global mygarfo_pwd "your_garfo_pwd"



/* if you have a properly set up odbcinst.ini , then this will work. for Linux */
global mydb1_connection "Driver={OracleODBC-11g};Dbq=path.to.db1.server.gov:PORT/nova;Uid=mlee;Pwd=$mypwd;"
global mygarfo_conn "Driver={OracleODBC-11g};Dbq=NNN.NNN.NN.NNN/perhaps.more.letters.here.nfms.gov;Uid=mlee;Pwd=$mygarfo_pwd;"


/* If not, you'll need to paste in the full path tor your libsqora.so.11.1 driver. 

global mydb1_connection "Driver=/usr/lib/oracle/11.2/client64/lib/libsqora.so.11.1;Dbq=path.to.db1.server.gov:PORT/sole;Uid=mlee;Pwd=$mypwd;"
*/


/* if you have a properly set up odbc where db1name is the Name of the DSN, then this will work (on Windows). */
global mydb1_connection "dsn(db1name) user($myuid) password($mypwd) lower"
global mygarfo_conn "dsn(garfo_name) user($myuid) password($mygarfo_pwd) lower"


/*code to test
odbc load, exec("select * from cfdbs.cfspp") $mydb1_connection
*/


