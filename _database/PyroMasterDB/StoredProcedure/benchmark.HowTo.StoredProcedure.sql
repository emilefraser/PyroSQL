SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[benchmark].[HowTo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [benchmark].[HowTo] AS' 
END
GO
ALTER   PROCEDURE [benchmark].[HowTo]
AS
BEGIN

SELECT '
Duration
ObjectName
TextData
CPU
Reads
Writes
IntegerData
DatabaseName
ApplicationName
StartTime
EndTime
SPID
LoginName
EventSequence
BinaryData

Duration
This very useful data column provides the length of time in microseconds that an event takes from beginning to end, but what is curious is than when Duration is displayed from the Profiler GUI, it is shown, by default, in milliseconds. So internally, SQL Server stores Duration data as microseconds, but displays it as milliseconds in Profiler. If you want, you can change this default behavior by going to Tools|Options in Profiler and select “Show values in Duration column in microseconds”. I prefer to leave it to the default display of milliseconds, as it is easier to read. All the examples will be shown in milliseconds.

Since our goal in this trace is to identify long-running queries, the Duration data column is central to our analysis. Later, we will create both a filter and an aggregation on this data column to help with our analysis.

Note that the Duration data column only exists for the RPC:Completed, SP:StmtCompleted and SQL:BatchCompleted events.

ObjectName
This is the logical name of the object being referenced during an event. If a stored procedure is being executed, then the name of the stored procedure is displayed. If an isolated query is being executed, then the message “Dynamic SQL” is inserted in this data column. This column therefore provides a quick means of telling whether or not a query is part of a stored procedure.

Note that this data column is not captured for the SQL:BatchStarting or the SQL:BatchCompleted events.

TextData
As our previous examples have indicated, the contents of the TextData column depend on the event that is being captured and in what context.

For the SQL:BatchStarting or SQL:BatchCompleted events, the TextData column will either contain the name of the executing stored procedure or, for a query outside a stored procedure, the Transact-SQL code for that query.

If the event is SP:StmtCompleted, the TextData column contains the Transact-SQL code for the query executed within the stored procedure.

For the Showplan XML event, it includes the XML code used to create the graphical execution plan for the query.

CPU
This data column shows the amount of CPU time used by an event (in milliseconds). Obviously, the smaller this number, the fewer CPU resources were used for the query. Note that CPU data column is only captured for the RPC:Completed, SP:StmtCompleted, and the SQL:BatchCompleted events.

Reads
This data column shows the number of logical page reads that occurred during an event. Again, the smaller this number, the fewer disk I/O resources were used for the event. Note that Reads are only captured for the RPC:Completed, SP:StmtCompleted and the SQL:BatchCompleted events.

Writes
This data column shows the number of physical writes that occurred during an event and provides an indication of the I/O resources that were used for an event. Again, Writes is only captured for the RPC:Completed,  SP:StmtCompleted and the SQL:BatchCompleted events.

IntegerData
The value of this column depends on the event. For the SP:StmtCompleted event, the value is the actual number of rows that were returned for the event. For the ShowPlan XML event, it shows the estimated number of rows that were to be returned for the event, based on the query’s execution plan. The other events don’t use this data column. Knowing how many rows a query actually returns can help you determine how hard a query is working. If you know that a query returns a single row, then it should use a lot less resources than a query that returns 100,000 rows. If you notice that the actual number or rows returned is significantly different that the estimated value of rows returned, this may indicate that the statistics used by the Query Optimizer to create the execution plan for the query is out of date. Out of date statistics can result in poorly performing queries and they should be updated for optimal query performance.

DatabaseName
This is the name of the database the event occurred in. Often, you will want to filter on this data column so that you only capture those events that occur in a specific database.

ApplicationName
This is the name of the client application that is communicating with SQL Server. Some applications populate this data column; others don’t. Assuming this data column is populated, you can use it to filter events on a particular application.

StartTime
Virtually every event has a StartTime data column and, as you would expect, it includes the time the event started. Often, the start time of an event can be matched to other related events to identify their order of execution. It can also be compared to the stop time of events to determine the differences in time between when one event started and another completed.

EndTime
The EndTime data column is used for those events that have a specific end time associated with them. It can be used to help identify when a particular query or transaction runs at a specific point in time.

SPID
This data column is mandatory for every event, and contains the number of the server process ID (SPID) that is assigned to the client process creating the event. It can help identify what connections are being used for an event, and can also be used as a filter to limit the number of events returned to those of particular interest.

LoginName
Most events include the LoginName data column. It stores the login of the user that triggered the event. Depending on the type of login used, this column can contain either the SQL Server login ID or the Windows Login ID (domain\username). This very useful data column helps you identify who is causing potential problems. It is a good column to filter on, in order to limit trace results to those of a specific user.

EventSequence
Every event produced by SQL Server Profiler is assigned a sequence number that indicates the order that events occurred in SQL Server. Much of the time, you will capture traces in default order, which means the events are displayed in the order they occurred in the Profiler GUI. EventSequence numbers appear in ascending order.

However, should you choose to apply a custom grouping, based on a certain data column such as Duration, then the EventSequence data column makes it easier for you to see which events occurred before, or after, other events.

BinaryData
This data column is only populated for the Showplan XML event and includes the estimated cost of a query, which is used for displaying the graphical execution plan of the query. This data is not human-readable, and is used by Profiler internally to help display the graphical execution plan.

'

END
GO
