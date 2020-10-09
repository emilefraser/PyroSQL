SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER OFF
CREATE PROCEDURE sysmail_help_queue_sp
   @queue_type nvarchar(6) = NULL -- Type of queue
AS
BEGIN

   SELECT @queue_type       = LTRIM(RTRIM(@queue_type))
   IF @queue_type           = '' SELECT @queue_type = NULL

   IF ( (@queue_type IS NOT NULL) AND
         (LOWER(@queue_type collate SQL_Latin1_General_CP1_CS_AS) NOT IN ( N'mail', N'status') ) )
   BEGIN
        RAISERROR(14266, -1, -1, '@queue_type', 'mail, status')
      RETURN(1) -- Failure
   END   

   DECLARE @depth      int
   DECLARE @temp TABLE (
                        queue_type nvarchar(6),
                        length INT NOT NULL, 
                        state nvarchar(64), 
                        last_empty_rowset_time DATETIME,
                        last_activated_time DATETIME
                       )
  
   IF ( (@queue_type IS NULL) OR (LOWER(@queue_type collate SQL_Latin1_General_CP1_CS_AS) = N'mail' ) )
   BEGIN
      SET @depth = (SELECT COUNT(*) FROM ExternalMailQueue WITH (NOWAIT NOLOCK READUNCOMMITTED))

      INSERT INTO @temp
         SELECT 
                N'mail',
                @depth, 
            qm.state as state,
            qm.last_empty_rowset_time as last_empty_rowset_time,
            qm.last_activated_time as last_activated_time
         FROM sys.dm_broker_queue_monitors qm
         JOIN sys.service_queues sq ON sq.object_id = qm.queue_id
         WHERE sq.name = 'ExternalMailQueue'
   END

   IF ( (@queue_type IS NULL) OR (LOWER(@queue_type collate SQL_Latin1_General_CP1_CS_AS) = N'status' ) )
   BEGIN
      SET @depth = (SELECT COUNT(*) FROM InternalMailQueue WITH (NOWAIT NOLOCK READUNCOMMITTED))

      INSERT INTO @temp
         SELECT 
                N'status',
                @depth, 
            qm.state as state,
            qm.last_empty_rowset_time as last_empty_rowset_time,
            qm.last_activated_time as last_activated_time
         FROM sys.dm_broker_queue_monitors qm
         JOIN sys.service_queues sq ON sq.object_id = qm.queue_id
         WHERE sq.name = 'InternalMailQueue'
   END

   SELECT * from @temp
END

GO
