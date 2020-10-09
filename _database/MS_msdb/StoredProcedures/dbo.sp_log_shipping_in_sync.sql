SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
CREATE PROCEDURE sp_log_shipping_in_sync
  @last_updated        DATETIME,
  @compare_with        DATETIME,
  @threshold           INT,
  @outage_start_time   INT,
  @outage_end_time     INT,
  @outage_weekday_mask INT,
  @enabled             BIT = 1,
  @delta               INT = NULL OUTPUT
AS BEGIN
  SET NOCOUNT ON
  DECLARE @cur_time INT

  SELECT @delta = DATEDIFF (mi, @last_updated, @compare_with)
  -- in sync
  IF (@delta <= @threshold)
    RETURN (0) -- in sync

  IF (@enabled = 0) 
    RETURN(0) -- in sync

  IF (@outage_weekday_mask & DATEPART(dw, GETDATE ()) > 0) -- potentially in outage window
  BEGIN
    SELECT @cur_time = DATEPART (hh, GETDATE()) * 10000 +
                       DATEPART (mi, GETDATE()) * 100 + 
                       DATEPART (ss, GETDATE())
     -- outage doesn't span midnight
    IF (@outage_start_time < @outage_end_time)
    BEGIN
      IF (@cur_time >= @outage_start_time AND @cur_time < @outage_end_time)
        RETURN(1) -- in outage
    END
     -- outage does span midnight
   ELSE IF (@outage_start_time > @outage_end_time)
   BEGIN
     IF (@cur_time >= @outage_start_time OR @cur_time < @outage_end_time)
       RETURN(1) -- in outage
   END
  END
  RETURN(-1 ) -- not in outage, not in sync
END

GO
