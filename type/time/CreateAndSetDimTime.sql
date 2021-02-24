SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 
SET ANSI_PADDING ON 
GO

CREATE OR ALTER PROCEDURE CreateDimTime
AS
BEGIN

CREATE TABLE [dt].[DimTime]( 
[TimeKey] [int] NOT NULL, 
[TimeAltKey] [int] NOT NULL, 
[Time30] [varchar](8) NOT NULL, 
[Hour30] [tinyint] NOT NULL, 
[MinuteNumber] [tinyint] NOT NULL, 
[SecondNumber] [tinyint] NOT NULL, 
[TimeInSecond] [int] NOT NULL, 
[HourlyBucket] varchar(15)not null, 
[DayTimeBucketGroupKey] int not null, 
[DayTimeBucket] varchar(100) not null 
CONSTRAINT [PK_DimTime] PRIMARY KEY CLUSTERED 
( 
[TimeKey] ASC 
) 
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, _
IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] 
) 
ON [PRIMARY] 
END
GO 


SET ANSI_PADDING OFF 
GO 
SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 

CREATE OR ALTER  PROCEDURE [dt].[FillDimTime] 
as 
BEGIN 
--Specify Total Number of Hours You need to fill in Time Dimension 
DECLARE @Size INTEGER 
--iF @Size=32 THEN This will Fill values Upto 32:59 hr in Time Dimension 
Set @Size=23 
DECLARE @hour INTEGER 
DECLARE @minute INTEGER 
DECLARE @second INTEGER 
DECLARE @k INTEGER 
DECLARE @TimeAltKey INTEGER 
DECLARE @TimeInSeconds INTEGER 
DECLARE @Time30 varchar(25) 
DECLARE @Hour30 varchar(4) 
DECLARE @Minute30 varchar(4) 
DECLARE @Second30 varchar(4) 
DECLARE @HourBucket varchar(15) 
DECLARE @HourBucketGroupKey int 
DECLARE @DayTimeBucket varchar(100) 
DECLARE @DayTimeBucketGroupKey int 
SET @hour = 0 
SET @minute = 0 
SET @second = 0 
SET @k = 0 
SET @TimeAltKey = 0 
WHILE(@hour<= @Size ) 
BEGIN 
if (@hour <10 ) 
begin 
set @Hour30 = '0' + cast( @hour as varchar(10)) 
end 
else 
begin 
set @Hour30 = @hour 
end 
--Create Hour Bucket Value 
set @HourBucket= @Hour30+':00' +'-' +@Hour30+':59' 
WHILE(@minute <= 59) 
BEGIN 
WHILE(@second <= 59) 
BEGIN 
set @TimeAltKey = @hour *10000 +@minute*100 +@second 
set @TimeInSeconds =@hour * 3600 + @minute *60 +@second 
If @minute <10 
begin 
set @Minute30 = '0' + cast ( @minute as varchar(10) ) 
end 
else 
begin 
set @Minute30 = @minute 
end 
if @second <10 
begin 
set @Second30 = '0' + cast ( @second as varchar(10) ) 
end 
else 
begin 
set @Second30 = @second 
end 
--Concatenate values for Time30 
set @Time30 = @Hour30 +':'+@Minute30 +':'+@Second30 
--DayTimeBucketGroupKey can be used in Sorting of DayTime Bucket In proper Order 
SELECT @DayTimeBucketGroupKey = 
CASE 
WHEN (@TimeAltKey >= 00000 AND @TimeAltKey <= 25959) THEN 0 
WHEN (@TimeAltKey >= 30000 AND @TimeAltKey <= 65959) THEN 1 
WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959) THEN 2 
WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) THEN 3 
WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959)THEN 4 
WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)THEN 5 
WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959) THEN 6 
WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)THEN 7 
WHEN (@TimeAltKey >= 240000) THEN 8 
END 
--print @DayTimeBucketGroupKey 
-- DayTimeBucket Time Divided in Specific Time Zone 
-- So Data can Be Grouped as per Bucket for Analyzing as per time of day 
SELECT @DayTimeBucket = 
CASE 
WHEN (@TimeAltKey >= 00000 AND @TimeAltKey <= 25959) _
THEN 'Late Night (00:00 AM To 02:59 AM)' 
WHEN (@TimeAltKey >= 30000 AND @TimeAltKey <= 65959) _
THEN 'Early Morning(03:00 AM To 6:59 AM)' 
WHEN (@TimeAltKey >= 70000 AND @TimeAltKey <= 85959) _
THEN 'AM Peak (7:00 AM To 8:59 AM)' 
WHEN (@TimeAltKey >= 90000 AND @TimeAltKey <= 115959) _
THEN 'Mid Morning (9:00 AM To 11:59 AM)' 
WHEN (@TimeAltKey >= 120000 AND @TimeAltKey <= 135959) _
THEN 'Lunch (12:00 PM To 13:59 PM)' 
WHEN (@TimeAltKey >= 140000 AND @TimeAltKey <= 155959)_
THEN 'Mid Afternoon (14:00 PM To 15:59 PM)' 
WHEN (@TimeAltKey >= 50000 AND @TimeAltKey <= 175959)_
THEN 'PM Peak (16:00 PM To 17:59 PM)' 
WHEN (@TimeAltKey >= 180000 AND @TimeAltKey <= 235959)_
THEN 'Evening (18:00 PM To 23:59 PM)' 
WHEN (@TimeAltKey >= 240000) THEN 'Previous Day Late Night _
(24:00 PM to '+cast( @Size as varchar(10)) +':00 PM )' 
END


-- print @DayTimeBucket 
INSERT into dt.DimTime (TimeKey,TimeAltKey,[Time30] ,[Hour30] ,_
[MinuteNumber],[SecondNumber],[TimeInSecond],[HourlyBucket],_
DayTimeBucketGroupKey,DayTimeBucket) 
VALUES (@k,@TimeAltKey ,@Time30 ,@hour ,@minute,@Second , _
@TimeInSeconds,@HourBucket,@DayTimeBucketGroupKey,@DayTimeBucket ) 
SET @second = @second + 1 
SET @k = @k + 1 
END 
SET @minute = @minute + 1 
SET @second = 0 
END 
SET @hour = @hour + 1 
SET @minute =0 
END

END 


--Exec [FillDimTime] 
--select * from DimTime
