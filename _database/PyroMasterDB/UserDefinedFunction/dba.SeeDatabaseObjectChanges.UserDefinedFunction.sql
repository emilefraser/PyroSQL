SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dba].[SeeDatabaseObjectChanges]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'  CREATE    FUNCTION [dba].[SeeDatabaseObjectChanges]


  /**
  Summary: >
    This function gives you a list
    of database object changes that happened between
    the two dates, taken from the default trace
  Author: Phil Factor
  Date: 04/10/2018
  Examples:
     - Select * from dbo.SeeDatabaseObjectChanges(DateAdd(day,-1,SysDateTime()),SysDateTime())
  Columns: datetime_local, action, databaseID, TransactionID, Hostname, ApplicationName, LoginName, spid, objectid 
  Returns: >
        datetime_local datetime
        action nvarchar(4000)
        databaseID int
        TransactionID bigint
        Hostname nvarchar(256)
        ApplicationName nvarchar(256)
        LoginName nvarchar(256)
        spid int
        objectid int
          **/
    (
    @Start DATETIME2,--the start of the period
    @finish DATETIME2--the end of the period
    )
  RETURNS TABLE
   --WITH ENCRYPTION|SCHEMABINDING, ..
  AS
  RETURN
	select * from sys.objects

  /*
    (
      SELECT     
        CONVERT(
          DATETIME2,
         SWITCHOFFSET(CONVERT(datetimeoffset, StartTime), DATENAME(TzOffset, SYSDATETIMEOFFSET()))
               )  AS datetime_local, 
           ''User ''+Coalesce(SessionLoginName,loginName,'''') +'' ''+ Replace(name, ''Object:'','''')
               +Coalesce('' ''+objtype,'''')+'' ''+ Coalesce(DatabaseName+''.''+ObjectName,databasename) AS action,
        databaseID, TransactionID, Hostname, ApplicationName, LoginName, spid,objectid
       FROM::fn_trace_gettable(--just use the latest trace
           (SELECT TOP 1 traces.path FROM sys.traces 
              WHERE traces.is_default = 1), DEFAULT) AS DT
        LEFT OUTER JOIN sys.trace_events AS TE
          ON DT.EventClass = TE.trace_event_id
        LEFT OUTER JOIN sys.trace_subclass_values AS SysTSV
          ON DT.EventClass = SysTSV.trace_event_id
         AND DT.ObjectType = SysTSV.subclass_value
          LEFT OUTER JOIN
        (
     VALUES(8259, ''Check Constraint''),( 8260, ''Default (constraint or standalone)''),( 8262, ''Foreign-key Constraint''),( 8272, ''Stored Procedure''),
     ( 8274, ''Rule''),( 8275, ''System Table''),( 8276, ''Trigger on Server''),( 8277, ''User Table''),( 8278, ''View''),
     ( 8280, ''Extended Stored Procedure''),(16724, ''CLR Trigger''),(16964, ''Database''),(16975, ''Object''),(17222, ''FullText Catalog''),
     (17232, ''CLR Stored Procedure''),(17235, ''Schema''),(17475, ''Credential''),(17491, ''DDL Event''),(17741, ''Management Event''),
     (17747, ''Security Event''),(17749, ''User Event''),(17985, ''CLR Aggregate Function''),(17993, ''Inline Table-valued SQL Function''),
     (18000, ''Partition Function''),(18002, ''Replication Filter Procedure''),(18004, ''Table-valued SQL Function''),(18259, ''Server Role''),
     (18263, ''Microsoft Windows Group''),(19265, ''Asymmetric Key''),(19277, ''Master Key''),(19280, ''Primary Key''),(19283, ''ObfusKey''),
     (19521, ''Asymmetric Key Login''),(19523, ''Certificate Login''),(19538, ''Role''),(19539, ''SQL Login''),(19543, ''Windows Login''),
     (20034, ''Remote Service Binding''),(20036, ''Event Notification on Database''),(20037, ''Event Notification''),(20038, ''Scalar SQL Function''),
     (20047, ''Event Notification on Object''),(20051, ''Synonym''),(20549, ''End Point''),(20801, ''Adhoc Queries which may be cached''),
     (20816, ''Prepared Queries which may be cached''),(20819, ''Service Broker Service Queue''),(20821, ''Unique Constraint''),
     (21057, ''Application Role''),(21059, ''Certificate''),(21075, ''Server''),(21076, ''Transact-SQL Trigger''),(21313, ''Assembly''),
     (21318, ''CLR Scalar Function''),(21321, ''Inline scalar SQL Function''),(21328, ''Partition Scheme''),(21333, ''User''),
     (21571, ''Service Broker Service Contract''),(21572, ''Trigger on Database''),(21574, ''CLR Table-valued Function''),
     (21577, ''Internal Table (For example, XML Node Table, Queue Table.)''),(21581, ''Service Broker Message Type''),(21586, ''Service Broker Route''),
     (21587, ''Statistics''),(21825, ''User''),(21827, ''User''),(21831, ''User''),(21843, ''User''),(21847, ''User''),(22099, ''Service Broker Service''),
     (22601, ''Index''),(22604, ''Certificate Login''),(22611, ''XMLSCHEMA''),(22868,  ''Type (e.g. Table Type)''))f(objectTypeid, ObjType)
     ON dt.objectType=objecttypeid
     WHERE StartTime BETWEEN @start AND @finish
      AND databasename NOT IN (''tempdb'', ''MASTER'')
    )

	*/
' 
END
GO
