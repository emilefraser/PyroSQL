/*
When you have a number of servers to look after, it usually pays to keep information about them in a central database. Any DBA will tell you that there are a number of database and server objects that have to be monitored, such as the disk space, event logs, backup history, transaction log size, tempDB size, and database users. 

Once you have all this information to hand in a single database, it is easy to set up all sorts of simple monitoring and alerting systems which catch your eye and warn you of potential trouble before it happens.

We'll use SQLCMD to set up, as an example of what we mean, a user database that lists all the users on all the databases on all your servers, along with their details . Not only does it then become easier to answer questions such as 'Which databases on which server does x have access to?', but, if you do regular updates, you can tell when users were added or removed. 

For a lot of operations, this sort of work is best done in SMO/DMO, but nothing beats SQLCMD for getting something up and running quickly. Once you have a system in place and have a clearer idea of how valuable it is likely to be, then you can re-implement it as a more robust system using SMO/DMO

Lets imagine we want to keep a list of database users on a central database called MyServers, along with some general information about them such as their loginName and Groupname. First step is to write some SQL that will give us a resultset of all the users for a server and the databases they have access to. Users who have SQL 2000 servers will need to change Varchar(MAX) to Varchar(8000) for those servers.
*/
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
