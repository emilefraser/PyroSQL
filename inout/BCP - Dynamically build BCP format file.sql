DROP PROCEDURE dbo.CreateBCPFormatFile
GO


CREATE PROCEDURE dbo.CreateBCPFormatFile
	@Header       NVARCHAR(MAX)		= NULL,    
    @Delimiter    NVARCHAR(6)       = ',',
    @Table        SYSNAME           = NULL
AS

SET NOCOUNT ON;

DECLARE

		@AddField		BIT,
		@CarryOver		BIT,
		@Column			NVARCHAR(255),
		@Field			NVARCHAR(255),
		@FieldNum		INT,
		@Length			VARCHAR(5),
		@Pos			INT,
		@Start			INT,
		@StartQuote		BIT,
		@Stop			INT,
		@TableId		INT,
		@TermChar		VARCHAR(6),
		@Terminator		VARCHAR(6),
		@Version		NVARCHAR(128),
		
--    constants...
		@Collation		NVARCHAR(35),
		@Quote			CHAR(1),
		@Quote_E		CHAR(2),
		@SQLChar		CHAR(7)

DECLARE    @Format    TABLE
			(    
				rowId			SMALLINT    IDENTITY PRIMARY KEY,
				colName			SYSNAME        NOT NULL,
				terminator		VARCHAR(6)    NOT NULL,
				colOrder		VARCHAR(5)    NOT NULL,
				fileLength		VARCHAR(5)    NOT NULL
			);

--    initialize variables
SELECT    @AddField		= 0
    ,    @CarryOver		= 0
    ,    @Column        = ''
    ,    @FieldNum		= 1
    ,    @Length        = ''
    ,    @StartQuote    = 0
    ,    @TableId		= OBJECT_ID(@Table)
    ,    @TermChar		= CASE @Delimiter WHEN CHAR(9) THEN '\t' ELSE @Delimiter END
    ,    @Terminator    = ''
    ,    @Version		= CONVERT(NVARCHAR(128), SERVERPROPERTY(N'ProductVersion'))
    --    constants...
    ,    @Collation		= CONVERT(NVARCHAR(128), SERVERPROPERTY(N'Collation'))
    ,    @Quote			= '"'
    ,    @Quote_E		= '\"'
    ,    @SQLChar		= 'SQLCHAR'

--    get the SQL Engine version...
SET @Version = LEFT(@Version, CHARINDEX('.', @Version) + 1);

-- create the header list containing all columns in the table if null is passed in
IF @Header IS NULL
BEGIN
   SELECT @Header = COALESCE (@Header + ', ', '') + Name 
   FROM syscolumns 
   WHERE id = @TableID 
   ORDER BY ColID
END



WHILE CHARINDEX(@Delimiter, @Header) > 0
BEGIN
    SET @Pos		= CHARINDEX(@Delimiter, @Header);                --    find the next delimiter
    SET @Field		= LEFT(@Header, @Pos - 1);                        --    collect that value
    SET @Header		= SUBSTRING(@Header, @Pos + 1, LEN(@Header));    --    shorten the header by the field just removed...
    SET @AddField	= 0;
    SET @CarryOver	=	CASE LEN(@Column)
							WHEN 0 THEN 0
							ELSE 1 
						END;

    SET @StartQuote	=   CASE LEFT(@Field, 1) 
							WHEN @Quote THEN 1
							ELSE 0 
						END;

    SET @Column     =    @Column + REPLACE(@Field, @Quote, '') + ' ';        --    remove quotes

    SET @Length     =    CAST(LEN(@Column) AS VARCHAR(5));        --    default length is the lenght from the "column"

    IF (@StartQuote = 1 OR @CarryOver = 1)
    BEGIN
        IF RIGHT(@Field, 1) = @Quote
        BEGIN
            SET @AddField		=    1;
            SET @Terminator		=    @Quote_E + @TermChar
									+	CASE LEFT(@Header, 1)
											WHEN @Quote THEN @Quote_E
											ELSE '' 
										END;
        END;
    END;
    ELSE
    BEGIN
        SET @AddField			=    1;
        SET @Terminator			=    @TermChar
									+	CASE LEFT(@Header, 1)
											WHEN @Quote THEN @Quote_E
											ELSE '' 
										END;
    END;


    IF (@AddField = 1)
    BEGIN
        SET @Column = RTRIM(@Column);
        IF(@FieldNum = 1 AND CHARINDEX(@Quote, @Field) > 0)
        BEGIN
            --    add an "dummy column" if it's the first field and it starts with a quote
            INSERT @Format VALUES('dummy_col', @Quote_E, 0, 0);
        END;


        --    add the column to the database
        INSERT @Format VALUES(@Column, @Terminator, @FieldNum, @Length);
        SET @FieldNum    = @FieldNum + 1;
        SET @Terminator = '';
        SET @Column        = '';
    END;
END;

--    the part of the header is the last field...
SET @Column        =    REPLACE(@Header, @Quote, '');
SET @Length        =    CAST(LEN(@Column) AS VARCHAR(5));
SET @Terminator    =    CASE RIGHT(@Header, 1)
							WHEN @Quote THEN @Quote_E
							ELSE '' 
						END + '\r\n'


INSERT @Format VALUES(@Column, @Terminator, @FieldNum, @Length)

--    return the resulting format file definition...
SELECT    FileOrder
    ,    FileType
    ,    PrefixLength    
    ,    FileLength
    ,    Terminator
    ,    ColumnOrder
    ,    ColumnName
    ,    ColumnCollation
FROM
	(    
		SELECT  
				0            AS TYPE
            ,   0            AS rowId
            ,   LEFT(@Version, 6)    AS FileOrder
            ,   ''            AS FileType
            ,   ''            AS PrefixLength    
            ,   ''            AS FileLength
            ,   ''            AS Terminator
            ,   ''            AS ColumnOrder
            ,   ''            AS ColumnName
            ,   ''            AS ColumnCollation

        UNION ALL

        SELECT   
				1            AS TYPE
            ,   0            AS rowId
            ,   CAST(@FieldNum AS VARCHAR(6))
            ,   ''            AS FileType
            ,   ''            AS PrefixLength    
            ,   ''            AS FileLength
            ,   ''            AS Terminator
            ,   ''            AS ColumnOrder
            ,   ''            AS ColumnName
            ,   ''            AS ColumnCollation

        UNION ALL

        SELECT   
				2            AS TYPE
            ,   f.rowId
            ,   CAST(f.rowId AS VARCHAR(6))
            ,   @SQLChar    AS FileType
            ,   '0'            AS PrefixLength    
            ,   ISNULL(c.max_length, f.FileLength)
            ,   '"' + ISNULL(Terminator, '') + '"'
            ,   ISNULL(c.column_id, f.colOrder)
            ,   ISNULL(c.name, f.colName)
            ,   ISNULL(c.collation_name, @Collation)
        FROM    @Format        f
        LEFT OUTER JOIN
            (    
				SELECT   
						CAST(column_id AS VARCHAR(5))    AS column_id
                    ,   name
                    ,   CAST(max_length AS VARCHAR(5))    AS max_length
                    ,   ISNULL(collation_name, '""')    AS collation_name
                FROM    sys.columns
                WHERE   OBJECT_ID = @TableId
            )    c ON f.colName = c.name
    )    f
ORDER BY f.TYPE, f.rowId;

RETURN @@ERROR;


/*
Sample:        @Header        = '"DVD_Title","Studio",Released,"Status","Sound","Versions",Price,"Rating","Year","Genre","Aspect","UPC",DVD_ReleaseDate,ID,Timestamp,Updated'
               @Delimiter    = ','
               @Table        = 'dbo.test_table'    --[optional] uses data from sys.columns for file length and position
                                                        otherwise it uses "column name" as length if table isn't 
                                                        found or column isn't matched
            create table dbo.test_table
                (    DVD_Title        varchar(128)
                ,    Studio            varchar(30)
                ,    Released        datetime
                ,    Status            varchar(10)
                ,    Sound            varchar(10)
                ,    Versions        varchar(10)
                ,    Price            money
                ,    Rating            varchar(10)
                ,    Year            char(4)
                ,    Genre            varchar(10)
                ,    Aspect            varchar(15)
                ,    UPC                varchar(25)
                ,    DVD_ReleaseDate    datetime
                ,    ID                int primary key
                ,    Timestamp        timestamp
                ,    Updated            smallint
                )



Yields the result set for a format file:
--		9.0                            
--		16                            
--		1     SQLCHAR    0    0      "\""       0    dummy_col           SQL_Latin1_General_CP1_CI_AS
--		2     SQLCHAR    0    128    "\",\""    1    DVD_Title           SQL_Latin1_General_CP1_CI_AS
--		3     SQLCHAR    0    30     "\","      2    Studio              SQL_Latin1_General_CP1_CI_AS
--		4     SQLCHAR    0    8      ",\""      3    Released            ""
--		5     SQLCHAR    0    10     "\",\""    4    Status              SQL_Latin1_General_CP1_CI_AS
--		6     SQLCHAR    0    10     "\",\""    5    Sound               SQL_Latin1_General_CP1_CI_AS
--		7     SQLCHAR    0    10     "\","      6    Versions            SQL_Latin1_General_CP1_CI_AS
--		8     SQLCHAR    0    8      ",\""      7    Price               ""
--		9     SQLCHAR    0    10     "\",\""    8    Rating              SQL_Latin1_General_CP1_CI_AS
--		10    SQLCHAR    0    4      "\",\""    9    Year                SQL_Latin1_General_CP1_CI_AS
--		11    SQLCHAR    0    10     "\",\""    10  Genre               SQL_Latin1_General_CP1_CI_AS
--		12    SQLCHAR    0    15     "\",\""    11  Aspect              SQL_Latin1_General_CP1_CI_AS
--		13    SQLCHAR    0    25     "\","      12  UPC                 SQL_Latin1_General_CP1_CI_AS
--		14    SQLCHAR    0    8      ","        13  DVD_ReleaseDate     ""
--		15    SQLCHAR    0    4      ","        14  ID                  ""
--		16    SQLCHAR    0    8      ","        15  Timestamp           ""
--		17    SQLCHAR    0    2      "\r\n"     16  Updated             ""    
*/