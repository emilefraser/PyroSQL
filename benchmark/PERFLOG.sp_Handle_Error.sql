SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE    PROCEDURE [PERFLOG].[sp_Handle_Error]
AS
BEGIN

/*Levels of Severity


Severity level

Description


0-9 Informational messages that return status information or report errors that are not severe. The Database Engine does not raise system errors with severities of 0 through 9. 
10 Informational messages that return status information or report errors that are not severe. For compatibility reasons, the Database Engine converts severity 10 to severity 0 before returning the error information to the calling application. 
11-16 Indicate errors that can be corrected by the user. 
11 Indicates that the given object or entity does not exist. 
12 A special severity for queries that do not use locking because of special query hints. In some cases, read operations performed by these statements could result in inconsistent data, since locks are not taken to guarantee consistency. 
13 Indicates transaction deadlock errors. 
14 Indicates security-related errors, such as permission denied. 
15 Indicates syntax errors in the Transact-SQL command. 
16 Indicates general errors that can be corrected by the user. 
17-19 Indicate software errors that cannot be corrected by the user. Inform your system administrator of the problem. 
17 Indicates that the statement caused SQL Server to run out of resources (such as memory, locks, or disk space for the database) or to exceed some limit set by the system administrator. 
18 Indicates a problem in the Database Engine software, but the statement completes execution, and the connection to the instance of the Database Engine is maintained. The system administrator should be informed every time a message with a severity level of 18 occurs. 
19 Indicates that a nonconfigurable Database Engine limit has been exceeded and the current batch process has been terminated. Error messages with a severity level of 19 or higher stop the execution of the current batch. Severity level 19 errors are rare and must be corrected by the system administrator or your primary support provider. Contact your system administrator when a message with a severity level 19 is raised. Error messages with a severity level from 19 through 25 are written to the error log. 
20-24 Indicate system problems and are fatal errors, which means that the Database Engine task that is executing a statement or batch is no longer running. The task records information about what occurred and then terminates. In most cases, the application connection to the instance of the Database Engine may also terminate. If this happens, depending on the problem, the application might not be able to reconnect. 
Error messages in this range can affect all of the processes accessing data in the same database and may indicate that a database or object is damaged. Error messages with a severity level from 19 through 24 are written to the error log. 
20 Indicates that a statement has encountered a problem. Because the problem has affected only the current task, it is unlikely that the database itself has been damaged. 
21 Indicates that a problem has been encountered that affects all tasks in the current database, but it is unlikely that the database itself has been damaged. 
22 Indicates that the table or index specified in the message has been damaged by a software or hardware problem. 
Severity level 22 errors occur rarely. If one occurs, run DBCC CHECKDB to determine whether other objects in the database are also damaged. The problem might be in the buffer cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, you must reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, you may have to restore the database.
If restarting the instance of the Database Engine does not correct the problem, then the problem is on the disk. Sometimes destroying the object specified in the error message can solve the problem. For example, if the message reports that the instance of the Database Engine has found a row with a length of 0 in a nonclustered index, delete the index and rebuild it. 
23 Indicates that the integrity of the entire database is in question because of a hardware or software problem.
Severity level 23 errors occur rarely. If one occurs, run DBCC CHECKDB to determine the extent of the damage. The problem might be in the cache only and not on the disk itself. If so, restarting the instance of the Database Engine corrects the problem. To continue working, you must reconnect to the instance of the Database Engine; otherwise, use DBCC to repair the problem. In some cases, you may have to restore the database. 
24 Indicates a media failure. The system administrator may have to restore the database. You may also have to call your hardware vendor. 
*/

/*
SQL Server Errors


message_id

Description

Article


? You may see “out of user memory quota” message in errorlog when you use In-Memory OLTP feature … Out of user memory quota 
? Logon Failure: The User has not Been Granted. The operating system returned the error ????? while … Compressed backup errors 
? A transport-level error has occurred when receiving results from the server. link1 
- The MSSQLSERVER service was unable to log on as SQLAuthority\SQLFarmService with the currently c … The User has not Been Granted 
0 A server error occurred on current command. The results, if any, should be discarded. Who owns your availability groups? 
102 Incorrect syntax near '%.*ls'. 102_link1,102_link2 
120 The select list for the INSERT statement contains fewer items than the insert list. The number of … 120_link1 
121 The select list for the INSERT statement contains more items than the insert list. The number of … 121_link1 
145 ORDER BY items must appear in the select list if SELECT DISTINCT is specified. 145_link1 
156 Incorrect syntax near the keyword 'ORDER'. 156_link1 
207 Invalid column name '%.*ls'. 207_link1 
213 Column name or number of supplied values does not match table definition. 213_link1,213_link2 
229 The %ls permission was denied on the object '%.*ls', database '%.*ls', schema '%.*ls'. 229_link1 
241 Conversion failed when converting date and/or time from character string. 241_link1 
264 The column name '%.*ls' is specified more than once in the SET clause or column list of an INSERT … 264_link1 
297 The user does not have permission to perform this action. 297_link1 
352 The table-valued parameter "%.*ls" must be declared with the READONLY option. 352_link1 
459 Collation '%.*ls' is supported on Unicode data types only and cannot be applied to char, varchar or … 459_link1 
535 The datediff function resulted in an overflow. The number of dateparts separating two date/time 535_link1 
596 Cannot continue execution because the session is in the kill state. 596_link1,596_link2,596_link3 
650 You can only specify the READPAST lock in the READ COMMITTED or REPEATABLE READ isolation levels. 650_link1 
657 Could not disable support for increased partitions in database … 657_link1 
666 The maximum system-generated unique value for a duplicate group was exceeded for index with … 666_link1 
701 There is insufficient system memory in resource pool '%ls' to run this query. … 701_link1,701_link2 
824 SQL Server detected a logical consistency-based I/O error … 824_link1,824_link2,KB2152734 
825 The operating system returned error %ls to SQL Server. It failed creating event for a %S_MSG at … 825_link1 
913 Could Not Find Database %d. Database May Not be Activated Yet or May be in Transition … 913_link1 
922 Database '%.*ls' is being recovered. Waiting until recovery is finished. 922_link1 
926 Database '%.*ls' cannot be opened. It has been marked SUSPECT by recovery. See the SQL Server errorlog … 926_link1 
1052 Conflicting %ls options "%ls" and "%ls". 1052_link1 
1065 The NOLOCK and READUNCOMMITTED lock hints are not allowed for target tables of INSERT, UPDATE, DELETE … 1065_link1 
1219 Your session has been disconnected because of a high priority DDL operation. 1219_link1 
1701 Creating or altering table %ls failed because the minimum row size would be 8061, including 10 b … 1701_link1 
1807 Could not obtain exclusive lock on database ‘model’. Retry the operation later. … 1807_link1 
1904 The statistics on table has 65 columns in the key list … 1904_link1 
1908 Column '%.*ls' is partitioning column of the index '%.*ls'. Partition columns for a unique index … 1908_link1 
2812 Could not find stored procedure '%.*ls'. 2812_link1 
3101 Exclusive access could not be obtained because the database is in use. … 3101_link1 
3154 The backup set holds a backup of a database other than the existing … 3154_link1 
3241 The media family on device '%ls' is incorrectly formed. SQL Server cannot process this media fam … 3241_link1 
3314 During undoing of a logged operation in database '%.*ls', an error occurred at log record ID %S … 3314_link1 
3634 The operating system returned the error '%ls' while attempting '%ls' on '%ls'. … 3634_link1 
3637 A parallel operation cannot be started from a DAC connection. 3637_link1 
3743 The database '%.*ls' is enabled for database mirroring. Database mirroring must be removed befor … 3743_link1 
3906 Failed to update database "%.*ls" because the database is read-only. 3906_link1 
3930 The current transaction cannot be committed and cannot support operations that write to the log … 3930_link1 
4064 Cannot open user default database. Login failed.Login failed. … 4064_link1 
4189 Cannot convert to text/ntext or collate to '%.*ls' because these legacy LOB types do not support UTF-8 … 4189_link1 
4629 Permissions on server scoped catalog views or system stored procedures or extended stored … 4629_link1 
4901 ALTER TABLE only allows columns to be added that can contain nulls, or have a DEFAULT definition … 4901_link1 
4922 ALTER TABLE ALTER COLUMN Address failed because one or more objects access this column. … 4922_link1 
4934 Computed column '%.*ls' in table '%.*ls' cannot be persisted because the column does user or … 4934_link1 
4947 ALTER TABLE SWITCH statement failed. There is no identical index in source table '%.*ls' for the … 4947_link1 
5004 To use ALTER DATABASE, the database must be in a writable state in which a checkpoint can be executed. 5004_link1 
5120 Unable to open the physical file ... Operating system error 5: "5(Access is denied.)" … SQL SERVER - FIX Error 5120 
5123 CREATE FILE encountered operating system error "%ls"(The system cannot find the path specified.) … 5123_link1, 5123_link2 
5171 %.*ls is not a primary database file. 5171_link1 
5172 The header for file '%ls' is not a valid database file header. The %ls property is incorrect. 5172_link1 
5846 Common language runtime (CLR) execution is not supported under lightweight pooling. Disable one of two … 5846_link1 
6335 XML datatype instance has too many levels of nested nodes. Maximum allowed depth is 128 levels. 6335_link1 
6348 Specified collection '%.*ls' cannot be created because it already exists or you do not have permission. 6348_link1 
6401 Cannot roll back %.*ls. No transaction or savepoint of that name was found. 6401_link1 
7341 Cannot get the current row value of column "%ls.%ls" from OLE DB provider "%ls" for linked server "%ls … 7341_link1 
7344 The OLE DB provider "%ls" for linked server "%ls" could not %ls table "%ls" because of column … 7344_link1 
7356 The OLE DB provider "%ls" for linked server "%ls" supplied inconsistent metadata for a column. … 7356_link1 
7357 Cannot process the object "%ls". The OLE DB provider "%ls" for linked server "%ls" indicates that … 7357_link1, 7357_link2 
7391 The operation could not be performed because OLE DB provider "%ls" for linked server "%ls" ... … 7391_link2 
7719 CREATE/ALTER partition function failed as only maximum of 1000 partitions can be created. … 657_link1 
8101 An explicit value for the identity column in table '%.*ls' can only be specified when a column list is … 8101_link1 
8107 IDENTITY_INSERT is already ON for table '%.*ls.%.*ls.%.*ls'. Cannot perform SET operation for table '% … 8107_link1 
8115 Arithmetic overflow error converting %ls to data type %ls. 8115_link1 
8180 Statement(s) could not be prepared. 8180_link1 
8127 Column "%.*ls.%.*ls" is invalid in the ORDER BY clause because it is not contained in either an … 8127_link1 
8624 Internal Query Processor Error: The query processor could not produce a query plan. 8624_link1 
8645 A timeout occurred while waiting for memory resources to execute the query in resource pool '%ls' (%ld … 8645_link1 
8651 Could not perform the operation because the requested memory grant was not available in resource … 8651_link1 
8672 The MERGE statement attempted to UPDATE or DELETE the same row more than once... … 8672_link1 
8909 Table error: Object ID %d, index ID %d, partition ID %I64d, alloc unit ID %I64d (type %.*ls), pa … 8909_link1 
8921 Check terminated. A failure was detected while collecting facts. Possibly tempdb out of space or … 8921_link1 
8948 Database error: Page %S_PGID is marked with the wrong type in PFS page %S_PGID. PFS status 0x%x … 8948_link1 
9001 The log for database '%.*ls' is not available. Check the operating system error log for related … 9001_link1 
9002 The transaction log for database '%ls' is full due to '%ls'. … 9002_link1,9002_link2,9002_link3 
9105 The provided statistics stream is corrupt. 9105_link1 
10314 An error occurred in the Microsoft .NET Framework while trying to load assembly id %d. The server may … 10314_link1 
10637 Cannot perform this operation on '%.*ls' with ID %I64d as one or more indexes are currently in … 10637_link1 
10794 The %S_MSG '%ls' is not supported with %S_MSG. 10794_link1 
11535 EXECUTE statement failed because its WITH RESULT SETS clause specified %d result set(s), and the … 11535_link1 
13515 Setting SYSTEM_VERSIONING to ON failed because history table '%.*ls' has custom unique keys defined. … 13515_link1 
13518 Setting SYSTEM_VERSIONING to ON failed because history table '%.*ls' has IDENTITY column specification … 13518_link1 
13523 Setting SYSTEM_VERSIONING to ON failed because table '%.*ls' has %d columns and table '%.*ls' has %d … 13523_link1 
13543 Setting SYSTEM_VERSIONING to ON failed because history table '%.*ls' contains invalid records with end … 13543_link1 
13570 The use of replication is not supported with system-versioned temporal table '%s' 13570_link1 
13573 Setting SYSTEM_VERSIONING to ON failed because history table '%.*ls' contains overlapping records. 13573_link1 
13575 ADD PERIOD FOR SYSTEM_TIME failed because table '%.*ls' contains records where end of period is not … 13575_link1 
13901 Identifier '%.*ls' in a MATCH clause is not a node table or an alias for a node table. 13901_link1 
13902 Identifier '%.*ls' in a MATCH clause is not an edge table or an alias for an edge table. 13902_link1 
15002 The procedure 'sys.sp_dbcmptlevel' cannot be executed within a transaction. … 15002_link1 
15021 Invalid value given for parameter %s. Specify a valid parameter value. 15021_link1 
15136 The database principal is set as the execution context of one or more procedures, functions, … 15136_link1 
15190 There are still remote logins or linked logins for the server '%s'. 15190_link1 
15199 The current security context cannot be reverted. Please switch to the original database where … 15199_link1 
15274 Access to the remote server is denied because the current security context is not trusted. 15274_link1 
15406 Cannot execute as the server principal because the principal "%.*ls" does not exist, this type of … 15406_link1 
17182 TDSSNIClient initialization failed with error 0x%lx, status code 0x%lx. Reason: %S_MSG %.*ls 17182_link1 
17190 Initializing the FallBack certificate failed with error code: %d, state: %d, error number: %d. … 17190_link1 
17300 SQL Server was unable to run a new system task, either because there is insufficient memory or the … 17300_link1 
18272 During restore restart, an I/O error occurred on checkpoint file '%s' (operating system error %s … 18272_link1 
18357 Reason: An attempt to login using SQL authentication failed. Server is configured for Integrated … 18357_link1 
18452 Login failed. The login is from an untrusted domain and cannot be used with Windows authenticati … 18452_link1 
18456 Login failed for user '%.*ls'.%.*ls%.*ls 18456_link1 
22911 The capture job cannot be used by Change Data Capture to extract changes from the log when … 22911_link1 
25713 The value specified for %S_MSG, "%.*ls", %S_MSG, "%.*ls", is invalid. 25713_link1,25713_link2 
26023 Server TCP provider failed to listen on [ %s <%s> %d]. Tcp port is already in use. 26023_link1 
33111 Cannot find server %S_MSG with thumbprint '%.*ls'. 33111_link1 
33206 SQL Server Audit failed to create the audit file '%s'. Make sure that the disk is not full and … 33206_link1 
35250 The connection to the primary replica is not active. The command cannot be processed. 35250_link1 
35337 UPDATE STATISTICS failed because statistics cannot be updated on a columnstore index. … 35337_link1 
35343 The statement failed. Column '%.*ls' has a data type that cannot participate in a columnstore index. 35343_link1 
39004 A '%s' script error occurred during execution of 'sp_execute_external_script' with HRESULT 0x%x. 39004_link1 

*/



SElECT
'0 - 10 Informational messages',
'11–18 Errors',
'19–25 Fatal errors'

end
GO
