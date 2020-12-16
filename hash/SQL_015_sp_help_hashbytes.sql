use master;
GO
IF OBJECT_ID('[dbo].[sp_help_hashbytes]') IS NOT NULL 
DROP  PROCEDURE [dbo].[sp_help_hashbytes] 
GO
--#################################################################################################
-- Real World DBA Toolkit version 4.94 Lowell Izaguirre lowell@stormrage.com
--#################################################################################################
CREATE PROCEDURE [dbo].[sp_help_hashbytes]
AS
--https://msdn.microsoft.com/en-us/library/ms174415.aspx
SELECT 'MD2'       AS Algorythm, 128 AS BitStrength,16 AS ByteStrength,8000 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2014' AS MaxServerVersion,'SELECT HASHBYTES(''MD2'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'MD4'       AS Algorythm, 128 AS BitStrength,16 AS ByteStrength,8000 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2014' AS MaxServerVersion,'SELECT HASHBYTES(''MD4'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'MD5'       AS Algorythm, 128 AS BitStrength,16 AS ByteStrength,8000 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2014' AS MaxServerVersion,'SELECT HASHBYTES(''MD5'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'SHA'       AS Algorythm, 160 AS BitStrength,20 AS ByteStrength,8000 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2014' AS MaxServerVersion,'SELECT HASHBYTES(''SHA'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'SHA1'      AS Algorythm, 160 AS BitStrength,20 AS ByteStrength,8000 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2014' AS MaxServerVersion,'SELECT HASHBYTES(''SHA1'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'SHA2_256'  AS Algorythm, 256 AS BitStrength,32 AS ByteStrength,  -1 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2016' AS MaxServerVersion,'SELECT HASHBYTES(''SHA2_256'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand UNION ALL
SELECT 'SHA2_512'  AS Algorythm, 512 AS BitStrength,64 AS ByteStrength,  -1 AS MaxbytesForInput,'SQL2012' AS MinServerVersion, 'SQL2016' AS MaxServerVersion,'SELECT HASHBYTES(''SHA2_512'', ''AnExample_String_Or_Varbinary_Value_Or_Column'')' As ExampleCommand 
