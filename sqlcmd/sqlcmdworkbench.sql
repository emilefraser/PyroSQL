/* Robyn and Phil feel strongly that there are two striking features in SSMS that extends its usefulness dramatically. The first is the Template, and the second is the powerful functionality hidden by those strange words 'SQLCMD Mode'. Here they try to demonstrate how useful SQLCMD can be to anyone who is tasked with having to administer a database.

Contents
   1. Introduction
   2. Adding a user or group
   3. Running scripts in more than one database
   4. The macro statements
   5. Maintaining database lists
   6. Gathering data
   7. Command-line SQLCMD
   8. Winding up, and further reading 

Introduction
 There are two ways of using SSMS to automate repetitive tasks that involve TSQL. One is by the use of templates. This gives you a ready-made library of standard routines that you can turn into executable TSQL simply by hitting Ctrl Shift M on the keyboard. Great for ad-hoc admin work, but not so hot for the routine stuff.
The other system uses macro-substitution at Runtime and involves SQLCMD mode. We’ll call them Macro Scripts, to distinguish them from templates.
.Why bother with SQLCMD? If you are doing repetitive SQL Statements with just a change in one or two parameters then it is wonderful. If you are doing them to a whole lot of databases, maybe on different servers, it is wonderful. If you want it to be done in series, with error-checking and so on, or if you want it scheduled as a regular routine, then it is essential.  It is also great to build and test a script in SSMS, and then run it as a command-line script, maybe put it on the windows scheduler. It gives you a lot of freedom to do admin tasks the way that suits your particular workload.
Adding a user or a group
Imagine you have to create a server login for a user and then grant him access to the current database: You open up a query window in SSMS and check that you are in SQLCMD mode (Query --> SQLCMD mode). If the lines beginning with a colon are shaded silver, then you are in SQLCMD mode
Here is a sample Macro Script to add a windows user or group to your database in the role you specify. You would need to change the parameters to suit, of course */
--the user to do

:setvar rolename "sales"
:setvar membername "Kilgore"
:setvar login "SimpleTalk\KilgoreTrout"
 
--1
Declare @ret int
PRINT 'added windows login $(login) to '+ db_name()+' on '+@@Servername + ' as "$(membername)"'
/* Adds a security account in the current database for a SQL Server login or Windows
 user or group, and enables it to be granted permissions to perform activities in the
 database*/
EXEC @ret=sp_grantdbaccess '$(login)', '$(membername)'
if @ret=0 print 'successfully' else print 'with errors!'
PRINT 'added $(membername) to $(rolename) on '+ db_name()+' on '+@@Servername
/*Adds the database user, database role, Windows login, or Windows group to a database role in the current database.*/
EXEC @ret=sp_addrolemember '$(rolename)', '$(membername)'
if @ret=0 print 'successfully' else print 'with errors!'
Go
--2
/* You’ll see immediately that adding the login, the name of the user and the role to the macro definition on the line that starts ‘:setvar’ will speed things up from a simple script, if you have to add several users. But that is just a start.
Running scripts in more than one database
Imagine we have to add these database users on three databases on the same server. All we need to do is to  
   1. Save the code above, between –-1 and –-2, (so as to leave out the macros for the details of the user to add)  to a file called AddUser.SQL
   2. open up a new query window in SSMS and check that  you are in SQLCMD mode (Query --> SQLCMD mode). Run the following code in this query window: */ 
--the user to do
:setvar rolename "sales"
:setvar membername "Kilgore"
:setvar login "SimpleTalk\KilgoreTrout"
--the file names and paths
:setvar FileToexecute "adduser.sql"
:setvar Errorfile "Errors.txt"
:setvar workpath "c:\MyPath\"
 
--specify the name of the error file
:Error $(workpath)$(Errorfile)
--now we specify the output data file which we'll use to collect the data
:OUT $(workpath)$(Datafile)
-- if a datafile exists it is deleted: you cannot append to an existing file
 
use payroll --or whatever the database name is
:r $(workpath)$(FileToExecute)
use accounts--or whatever the database name is
:r $(workpath)$(FileToExecute)
use HR--or whatever the database name is
:r $(workpath)$(FileToExecute)
use manufacturing--or whatever the database name is
:r $(workpath)$(FileToExecute)
 
/*Hmm, nice.
You’ll see a report of what you did and its success/failure  in a file called  Report.txt, and any errors in Errors.txt. you can even type them out from the script at the end using*/
!!type $(workpath)$(Errorfile)
!!type  $(workpath)$(Datafile)
--Now save the following snippet to a file called  removeuser.sql
EXEC sp_droprolemember '$(rolename)', '$(membername)'
EXEC sp_revokedbaccess '$(membername)'
--Alter the
:setvar FileToexecute "adduser.sql"
 --To
:setvar FileToexecute "removeuser.sql"
/* Now Execute the script again and you will have removed the user you just put in, just to tidy up.
the macro statements
You’ll see in the script above a number of keywords which start with a colon and must start at the beginning of the line these do some fairly magically useful things
:!! [<command>]
    -Executes a command in the Windows command shell. 
:connect server[\instance] [-l timeout] [-U user [-P password]]
    -Connects to a SQL Server instance. 
:ed
    -Edits the current or last executed statement cache. 
:error <dest>
    -Redirects error output to a file, stderr, or stdout. 
:exit
    -Quits sqlcmd immediately. 
:exit()
    -Execute statement cache; quit with no return value. 
:exit(<query>)
    -Execute the specified query; returns numeric result. 
go [<n>]
    -Executes the statement cache (n times). 
:help
    -Shows this list of commands. 
:list
    -Prints the content of the statement cache. 
:listvar
    -Lists the set sqlcmd scripting variables. 
:on error [exit|ignore]
    -Action for batch or sqlcmd command errors. 
:out <filename>|stderr|stdout
    -Redirects query output to a file, stderr, or stdout. 
:perftrace <filename>|stderr|stdout
    -Redirects timing output to a file, stderr, or stdout. 
:quit
    -Quits sqlcmd immediately. 
:r <filename>
    -Append file contents to the statement cache. 
:reset
    -Discards the statement cache. 
:serverlist
    -Lists local and SQL Servers on the network. 
:setvar {variable}
    -Removes a sqlcmd scripting variable. 
:setvar <variable> <value>
    -Sets a sqlcmd scripting variable. 
Some of these commands are extremely useful, others will make you scratch your head in puzzlement.
You can run these scripts from the command line, specifying, for example, the server you want to run it on. (if you have to use a SQL Server login, you can specify userid and password)
sqlcmd -S myServer\instanceName -i C:\myScript.sql
now, as it stands, this is OK but not entirely useful for us, but you can also define variables for the command line version using the –v . You have to enclose each value in quotation marks if the value contains spaces.
sqlcmd S myServer\instanceName  -d MyDatabase -i C:\adduser.sql  -v rolename="sales” membername="Kilgore"  login="SimpleTalk\KilgoreTrout"
So what you have here is a means of adding a user (or any other repetitive action)  to any database on any server via a batch.
It is good but it aint good enough. Where, for example, is the error handling?  (you cannot concatenate to the end of a file with SQLCMD)
Maintaining database lists
An alternative approach is to maintain a list of servers and databases for running maintenance tasks. Each domain role (e.g. Sales, Marketing, development, manufacturing) will require a different list of servers and databases. We want something which will specify the list, and the action to run, along with the parameters.
The list will look something like this */
--connect to production
:CONNECT myServer\MyInstance
use payroll --or whatever the database name is
:r $(workpath)$(FileToExecute)
use accounts--or whatever the database name is
:r $(workpath)$(FileToExecute)
use HR--or whatever the database name is
:r $(workpath)$(FileToExecute)
use manufacturing--or whatever the database name is
:r $(workpath)$(FileToExecute)
--connect to test server
:CONNECT myServer\MyInstance
use payroll --or whatever the database name is
:r $(workpath)$(FileToExecute)
use accounts--or whatever the database name is
:r $(workpath)$(FileToExecute)
use HR--or whatever the database name is
:r $(workpath)$(FileToExecute)
use manufacturing--or whatever the database name is
:r $(workpath)$(FileToExecute)
--and so on for all your 200 servers!
/*
You can use …
:d payroll
…instead of
Use payroll
We save this lot as ‘MyDatabaseList.SQL’ (or whatever)
So now all you have to do is to set all your variables, and execute the file*/
--the user to do
:setvar rolename "sales"
:setvar membername "Kilgore"
:setvar login "SimpleTalk\KilgoreTrout"
--the file names and paths
--1/ the actual script to execute
:setvar FileToexecute "adduser.sql"
--the list of databases and servers
:setvar ListOfDatabases "MyDatabaseList.sql"
-- the file that any errors go into
:setvar Errorfile "Errors.txt"
--and the directory we keep this lot in
:setvar workpath "c:\MyPath\"
--specify the name of the error file
:Error $(workpath)$(Errorfile)
--now we specify the output data file which we'll use to collect the data
:OUT $(workpath)$(Datafile)
--and just execute the list of databases and servers
:r $(workpath)$(ListOfDatabases)
/* And you can see that it will do a whole list of  users, though rather slowly!  You can, for example, save this file without the user definitions, and call it repeatedly from a file that has a list containing  the ‘defines’ each user followed by the  R command for the file you’ve just saved.)

Gathering data

Having got this far, you’ll wonder how you can collect information from a whole lot of servers and databases, using SQLCMD. What is more, can one use the batch mode on a timer to collect information regularly?
Yes you can.
When you have a number of servers to look after, it usually pays to keep information about them in a central database. Any DBA will tell you that there are a number of database and server objects that have to be monitored, such as the disk space, event logs, backup history, transaction log size, tempDB size, and database users.
Once you have all this information to hand in a single database, it is easy to set up all sorts of simple monitoring and alerting systems which catch your eye and warn you of potential trouble before it happens.
We'll use SQLCMD to set up, as an example of what we mean, a user database that lists all the users on all the databases on all your servers, along with their details . Not only does it then become easier to answer questions such as 'Which databases on which server does x have access to?', but, if you do regular updates, you can tell when users were added or removed.
For a lot of operations, this sort of work is best done in SMO/DMO, but nothing beats SQLCMD for getting something up and running quickly. Once you have a system in place and have a clearer idea of how valuable it is likely to be, then you can re-implement it as a more robust system using SMO/DMO
Lets imagine we want to keep a list of database users on a central database called MyServers, along with some general information about them such as their loginName and Groupname. We’ll keep this simple for the example … */

-- =============================================
-- Creating the MyServers database
-- =============================================
/* Now we create the sample version of the database with just the table of users and the log which records the main details of what happens
*/
USE master
GO
 
-- Drop the database if it already exists
IF  EXISTS (
     SELECT name
          FROM sys.databases
          WHERE name = N'MyServers'
)
DROP DATABASE MyServers
GO
 
CREATE DATABASE MyServers
GO
USE MyServers
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MyUsers](
     [MyUsers_ID] [int] IDENTITY(1,1) NOT NULL,
     [SERVER_name] [sysname] NULL,
     [Database_name] [sysname] NULL,
     [UserName] [sysname] NULL,
     [GroupName] [sysname] NULL,
     [LoginName] [sysname] NULL,
     [DefDBName] [sysname] NULL,
     [DefSchemaName] [sysname] NULL,
     [UserID] [int] NULL,
     [InsertionDate] [datetime] NOT NULL
 CONSTRAINT [DF_MyUsers_InsertionDate]  DEFAULT (getdate()),
     [TerminationDate] [datetime] NULL,
 CONSTRAINT [PK_MyUsers] PRIMARY KEY CLUSTERED
(
     [MyUsers_ID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF,
  IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON,
   ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
 
 
IF OBJECT_ID('dbo.UpdateLog', 'U') IS NOT NULL
  DROP TABLE dbo.UpdateLog
GO
CREATE TABLE dbo.UpdateLog
(
     [UpdateLog_id] [int] IDENTITY(1,1) NOT NULL,
     [action] VARCHAR(2000) NOT NULL,
     [creator] [varchar](80) NOT NULL
       CONSTRAINT [DF_UpdateLog_creator]  DEFAULT (user_name()),
     [insertiondate] [datetime] NOT NULL
       CONSTRAINT [DF_UpdateLog_insertiondate]  DEFAULT (getdate()),
     [terminationdate] [datetime] NULL
      CONSTRAINT PK_dbo_UpdateLog PRIMARY KEY (UpdateLog_id)
)
GO
-- Add description to table object
EXEC sys.sp_addextendedproperty
     @name=N'MS_Description',
     @value=N'Table to log any updates. These will generally be done by a scheduled process and logging them here gives a single view on  the process' ,
     @level0type=N'SCHEMA',
     @level0name=N'dbo',
     @level1type=N'TABLE',
     @level1name=N'UpdateLog'
GO
 
 
/* First step is to write some SQL that will give us a resultset of all the users for a server and the databases they have access to. Users who have SQL 2000 servers will need to change Varchar(MAX) to Varchar(8000) for those servers. */
SET NOCOUNT ON
create table #temp
    (
      SERVER_name sysname NULL,
      Database_name sysnaME NULL,
      UserName sysname,
      GroupName sysname,
      LoginName sysname null,
      DefDBName sysname null,
      DefSchemaName sysname null,
      UserID int,
      [SID] varbinary(85)
    )
 
Declare @command VARCHAR(max)
--this will contain all the databases (and their sizes!)
--on a server
DECLARE @databases TABLE
    (
      Database_name VARCHAR(128),
      Database_size INT,
      remarks VARCHAR(255)
    )
INSERT  INTO @databases--stock the table with the list of databases
        EXEC sp_databases
 
SELECT  @command = coalesce(@command, '') + '
USE ' + database_name
        + '
insert into #temp (UserName,GroupName, LoginName,
                    DefDBName, DefSchemaName,UserID,[SID])
     Execute sp_helpuser
UPDATE #TEMP SET database_name=DB_NAME(),
                 server_name=@@ServerName
where database_name is null
'
     FROM    @databases
EXECUTE ( @command )--execute the code to get all the users from all the databases
/* now we pass it back to SQLCMD as a tab-delimited result. This is because SQLCMD is poor at formatting results in such a way as to make it easy to import them into SQL Server. We can save them as XML, but then each one would have to be saved to a separate file, and also, the version of SQLCMD that runs in SSMS doen't understand the  :XML ON  directive for saving results!*/
SELECT [users] =
      COALESCE(LEFT(SERVER_name,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(Database_name,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(UserName,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(GroupName,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(LoginName,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(DefDBName,80),'NULL')+CHAR(09)+
      COALESCE(LEFT(DefSchemaName,80),'NULL')+CHAR(09)+
      COALESCE(CONVERT(VARCHAR(5),[UserID]),'null')
 FROM  #temp
/*OK So far! But I've got 80 servers! The first thing is to save the code above here to a file. We'll call it GetUsers.SQL (We've put it in the speech-bubble above)'
Now, assuming you're using SSMS, click the Query->SQLCMD mode menu item
----Snip----
*/
/* Let's set our 'macro' SQLCMD variables just so we can execute the batch in SSMS before making it a command-line thing. Then, the command line can specify these values.
We can then break down the file so that we need only have, and maintain one list of servers that we can then use to execute any number of script files.
*/
:setvar workpath "c:\MyPath\"
:setvar workfile "GetUsers.SQL"
:setvar Datafile "users.txt"
:setvar Errorfile "Errors.txt"
 
--now pop the errors into a file as, from the command line, the errors
--will not be otherwise logged
:Error $(workpath)$(Errorfile)
--now we specify the output data file which we'll use to collect the data
:OUT $(workpath)$(Datafile)
-- if a datafile exists it is deleted: you cannot append to an existing file
 
/*now we go to each of our servers in turn and find out who is using what and we'll see if someone has been doing stuff they didn't oughter*/
--do the first
:CONNECT MyServer\MyDatabase
:r $(workpath)$(workfile)
GO
--and then the second (you'd log this normally)
:CONNECT MyServer\AnotherDatabase
:r $(workpath)$(workfile)
GO
-- and so on
-- and so on
/*Now the job is done, we have a huge file groaning with users. What we've done isn't perfect because if a database or server has gone offline, we are going to think the users have walked. */
-- snip X----------- (normally the end of the list of servers would end here and the consolidation routine below would be in a separate file, but we're demonstrating the process here, lads.'
--go to our database of servers
:CONNECT MyServer\AnotherDatabase
USE MyServers
:OUT stdout
/*Firstly we read the file into a 'limbo' table to work on. The file is a mess, full of status information, headers and other gubbins*/
 
-- Hmm, better check to see if there are any errors.
-- If so then don't read in the file '
CREATE TABLE #errors ( line VARCHAR(8000) )
DECLARE @errors VARCHAR(MAX)
INSERT  INTO #Errors ( line )--any Errors
        EXECUTE xp_cmdshell 'TYPE $(workpath)$(Errorfile)'
SELECT @errors=COALESCE(@Errors,'')+line FROM #errors
IF LEN(@errors)>5
     BEGIN --report the error and quit
     INSERT  INTO UpdateLog ( [ACTION] )
        SELECT  'there was an error getting the information. "'
              + @errors
                + '." Sorry'
 
     RAISERROR ('there were errors %s', 16,1,@errors)
--you don't normally see this do you?'
     end
ELSE
     begin
     CREATE TABLE #limbo ( line VARCHAR(8000) )
     INSERT  INTO #limbo ( line )--read it in, holding it at arms length
              EXECUTE xp_cmdshell 'TYPE $(workpath)$(Datafile)'
     --mow filter out all the junk: headers, status messages etc
     CREATE TABLE #UserchoppingBlock
     --we use a temporary table to massage the data
          (
            line VARCHAR(8000),
            SERVER_name SYSNAME NULL,
            Database_name SYSNAME NULL,
            UserName SYSNAME NULL,
            GroupName SYSNAME NULL,
            LoginName SYSNAME NULL,
            DefDBName SYSNAME NULL,
            DefSchemaName SYSNAME NULL,
            UserID INT,
            tab1 INT, tab2 INT, tab3 INT, tab4 INT,
            tab5 INT, tab6 INT,tab7 INT
          )
     /*All we want are the tab-delimited rows with data in them. Everything else gets thrown away*/     
     INSERT  INTO #userChoppingBlock ( line )
              SELECT  line
              FROM    #limbo
              WHERE   LEN(line) - LEN(REPLACE(line, CHAR(09), '')) = 7
     --our data has seven delimiters in a valid row.
 
     DECLARE @tab1 INT, @tab2 INT, @tab3 INT, @tab4 INT,
              @tab5 INT, @tab6 INT, @tab7 INT
     /* Now we extract the tab-delimited data in two stages. Firstly we record where the tab-positions are in each row */
     UPDATE  #userChoppingBlock
     SET     @Tab1 = tab1 = CHARINDEX(CHAR(09), line, 1),
              @Tab2 = tab2 = CHARINDEX(CHAR(09), line, @tab1 + 1),
              @Tab3 = tab3 = CHARINDEX(CHAR(09), line, @tab2 + 1),
              @Tab4 = tab4 = CHARINDEX(CHAR(09), line, @tab3 + 1),
              @Tab5 = tab5 = CHARINDEX(CHAR(09), line, @tab4 + 1),
              @Tab6 = tab6 = CHARINDEX(CHAR(09), line, @tab5 + 1),
              tab7 = CHARINDEX(CHAR(09), line, @tab6 + 1)
     /*Then we get every column from the string*/                
     UPDATE  #UserChoppingBlock
     SET     SERVER_name = SUBSTRING(line, 1, tab1 - 1),
              Database_name = SUBSTRING(line, tab1 + 1, tab2 - tab1 - 1),
              UserName = SUBSTRING(line, tab2 + 1, tab3 - tab2 - 1),
              GroupName = SUBSTRING(line, tab3 + 1, tab4 - tab3 - 1),
              LoginName = SUBSTRING(line, tab4 + 1, tab5 - tab4 - 1),
              DefDBName = SUBSTRING(line, tab5 + 1, tab6 - tab5 - 1),
              DefSchemaName = SUBSTRING(line, tab6 + 1, tab7 - tab6 - 1),
              UserID = CONVERT(INT, LTRIM(SUBSTRING(line, tab7 + 1,
                                                           LEN(line) - tab7 + 1)))
     /* we then add just the new users that have appeared since last we ran the routine. Because there is a default on the 'InsertionDate' column, it gets filled with the time it happened, so we get the date of when we first became aware that a new user was addrd*/     
     INSERT  INTO MyUsers
              (
                SERVER_name,
                Database_name,
                UserName,
                GroupName,
                LoginName,
                DefDBName,
                DefSchemaName,
                UserID
              )
              SELECT  n.SERVER_name,
                        n.Database_name,
                        n.UserName,
                        n.GroupName,
                        n.LoginName,
                        n.DefDBName,
                        n.DefSchemaName,
                        n.UserID
              FROM    #UserChoppingBlock n
                        LEFT OUTER JOIN MyUsers o
                        ON o.SERVER_name = n.SERVER_name
                         AND o.Database_name = n.Database_name
                         AND o.UserName = n.UserName
                         AND o.GroupName = n.Groupname
                         AND o.LoginName = n.LoginName
                         AND o.DefDBName = n.DefDBName
                         AND o.DefSchemaName = n.DefSchemaName
                         AND o.terminationDate IS NULL
              WHERE   o.Username IS NULL
     --and we log how many got put in.
     INSERT  INTO UpdateLog ( [ACTION] )
              SELECT  'Inserted ' + CONVERT(VARCHAR(5), @@ROWCOUNT)
                        + ' users INTO the USER table'
     /* it would be nice to know when users disappear too, wouldn't it. */
     UPDATE  MyUsers
     SET     terminationDate = GETDATE()
     WHERE   MyUsers_ID IN (
              SELECT  o.MyUsers_ID
              FROM    MyUsers o
                        LEFT OUTER JOIN #UserChoppingBlock n
                        ON o.SERVER_name = n.SERVER_name
                        AND o.Database_name = n.Database_name
                        AND o.UserName = n.UserName
                        AND o.GroupName = n.Groupname
                        AND o.LoginName = n.LoginName
                        AND o.DefDBName = n.DefDBName
                        AND o.DefSchemaName = n.DefSchemaName
              WHERE   n.Username IS NULL AND o.terminationDate IS NULL )
     --and log the users that have gone.
     INSERT  INTO UpdateLog ( [ACTION] )
              SELECT  'Deleted ' + CONVERT(VARCHAR(5), @@ROWCOUNT)
                        + ' users from the USER table'
     end
/*
Command-Line SQLCMD- The Command-line switches
The joy of SQLCMD is that you can develop scripts in SSMS and then execute tyhem in SQLCMD command-line. Actually, whenever Phil opens up command-line SQLCMD, he gives a little sigh of satisfaction at the stark character-based interface, free of any menus, popups, or other tat. (Phil: all entirely untrue, but it is a relief sometimes to develop stuff in SQLCMD command-line) SQLCMD is a direct replacement for isql and osql, but this is not the only justification for it.
Just for reference, here are the switches, so you don't have to look it all up on MSDN!
-U 	login id 	-P 	password
-S 	server 	-H 	hostname
-E 	trusted connection 	-d 	use database name
-l 	login timeout 	-t 	query timeout
-h 	headers 	-s 	colseparator
-w 	screen width 	-a 	packetsize
-e 	echo input 	-I 	Enable Quoted Identifiers
-c 	cmdend 	-L 	list servers
-LC 	list servers clean output 	-q 	"cmdline query"
-Q 	"cmdline query" and exit 	-m 	errorlevel
-V 	severitylevel 	-W 	remove trailing spaces
-u 	unicode output 	-r(0|1) 	msgs to stderr
-i 	inputfile 	-o 	outputfile
-z 	new password 	-f 	<codepage> | i:<codepage>(,o:<codepage>)
-K1|2] 	remove[replace] control characters] 	-Z 	new password and exit
-k(1|2) 	remove(replace) control characters 	-y 	variable length type display width
-Y 	fixed length type display width 	-p(1) 	print statistics (colon format)
-R 	use client regional setting 	-b 	On error batch abort
-v 	var = "value"... 	-A 	dedicated admin connection
-X(1) 	disable commands, startup script, enviroment variables (and exit) 	-x 	disable variable substitution
-? 	show syntax summary
Winding up, and further reading
So there you are, but it is really just a quick taste of the sort of automation you can achieve with the tools provided. What makes SQLCMD so good is the speed at which one can debug and run scripts. It is real rapid application development, and all without having to crank up C# or VB! We should strike a note of caution here. SQLCMD is not designed to be for everyone's tastes. If you feel at all nervous about the complexity of the approach, it is much better to use something like SQL Multiscript which is designed for the less technical DBA, and which is able to execute scripts in parallel.
Have a look at:
    * The SQLCMD utility
    * sqlcmd Utility Tutorial
    * Intoduction to SQLCMD
    * Using sqlcmd with Scripting Variables 
*/
