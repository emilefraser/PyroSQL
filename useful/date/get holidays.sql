-- =============================================
-- Author:      RE van Jaarsveld
-- Create Date: 16/04/2020
-- Description: Flags Holiday Dates in TimeDimention Table
-- =============================================
CREATE PROCEDURE [sp_Flag_Holidays]
(
     @Year VARCHAR(4) 
)
AS
BEGIN
--Set New Year's Day
DECLARE @FixedDate DATE = @Year +'0101'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;    
--Set Human Rights Day
SET @FixedDate = @Year +'0321'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Good Friday & Family Day
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = DATEADD(DAY,-2,CONVERT(DATE,dbo.GetEasterSunday(CAST(@Year AS INT)))) 
    OR CalendarDate = DATEADD(DAY,1,CONVERT(DATE,dbo.GetEasterSunday(CAST(@Year AS INT))))
--Set Freedom Day
Set @FixedDate = @Year +'0427'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Workers' Day
Set @FixedDate = @Year +'0501'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Youth Day
Set @FixedDate = @Year +'0616'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set National Women's Day
Set @FixedDate = @Year +'0809'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Heritage Day
Set @FixedDate = @Year +'0924'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Day of Reconciliation
Set @FixedDate = @Year +'1216'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Christman Day
Set @FixedDate = @Year +'1225'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
--Set Day of Goodwill
Set @FixedDate = @Year +'1226'
IF DATENAME(WEEKDAY,@FixedDate) = 'Sunday'
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate OR CalendarDate = DATEADD(DAY,1,@FixedDate);
ELSE
    UPDATE [dbo].[Calendar_TimeDim] 
    SET IsHoliday = 1
    WHERE CalendarDate = @FixedDate;
END
GO