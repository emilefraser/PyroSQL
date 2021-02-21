SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[string].[udf_StringComparisonsLevenshteinFullMatrix]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'/*
{{##
	(WrittenBy)		Emile Fraser
	(CreatedDate)	2021-01-22
	(ModifiedDate)	2021-01-22
	(Description)	

	(Usage)	
					SELECT * FROM string.udf_StringComparisonsLevenshteinFullMatrix(@FirstString, @SecondString)
	(/Usage)
##}}
*/

CREATE   FUNCTION [string].[udf_StringComparisonsLevenshteinFullMatrix] (
	@FirstString     NVARCHAR(255)
  , @SecondString    NVARCHAR(255)) 
RETURNS INT
AS
	BEGIN
		DECLARE 
			@PseudoMatrix TABLE (
			[location]             INT IDENTITY PRIMARY KEY
		  , [FirstOrder]           INT NOT NULL
		  , [Firstch]              NCHAR(1)
		  , [SecondOrder]          INT NOT NULL
		  , [Secondch]             NCHAR(1)
		  , [TheValue]             INT NOT NULL
									   DEFAULT 0
		  , [PreviousRowValues]    VARCHAR(200));

		INSERT INTO              @PseudoMatrix(
			[FirstOrder]
		  , [Firstch]
		  , [SecondOrder]
		  , [Secondch]
		  , [TheValue]
		)
		SELECT           
			[TheFirst].[number]
		  , [TheFirst].[ch]
		  , [TheSecond].[number]
		  , [TheSecond].[ch]
		  , 0
		FROM
			--divide up the first string into a table of characters/sequence
			(
				SELECT     
					[number]
				  , SUBSTRING(@FirstString, [number], 1) AS [ch]
				FROM     
					[Numbers]
				WHERE [number] <= LEN(@FirstString)
				UNION ALL
				SELECT 
					0
				  , CHAR(0)
		) [TheFirst]
		CROSS JOIN --divide up the second string into a table of characters/sequence
			(
				SELECT     
					[number]
				  , SUBSTRING(@SecondString, [number], 1) AS [ch]
				FROM     
					[Numbers]
				WHERE [number] <= LEN(@SecondString)
				UNION ALL
				SELECT 
					0
				  , CHAR(0)
		) [TheSecond]
		--ON Thefirst.ch= Thesecond.ch --do all valid matches
		ORDER BY 
			[TheFirst].[number]
		  , [TheSecond].[number];

		DECLARE 
			@current    VARCHAR(255);
		DECLARE 
			@previous    VARCHAR(255);
		DECLARE 
			@TheValue    INT;
		DECLARE 
			@deletion        INT
		  , @insertion       INT
		  , @substitution    INT
		  , @minim           INT;

		SELECT 
			@current = ''''
		  , @previous = '''';
		UPDATE  @PseudoMatrix
			SET 
				@deletion = @TheValue + 1, 
				@insertion = ASCII(SUBSTRING(@previous, [SecondOrder] + 1, 1)) + 1, 
				@substitution = ASCII(SUBSTRING(@previous, ([SecondOrder]), 1)) + 1, 
				@minim = CASE
							 WHEN @deletion < @insertion
								 THEN @deletion
							 ELSE @insertion
						 END, 
				@TheValue = [TheValue] = CASE
											 WHEN [SecondOrder] = 0
												 THEN [FirstOrder]
											 WHEN [FirstOrder] = 0
												 THEN [SecondOrder]
											 WHEN [Firstch] = [Secondch]
												 THEN ASCII(SUBSTRING(@previous, ([SecondOrder]), 1))
											 ELSE CASE
													  WHEN @minim < @substitution
														  THEN @minim
													  ELSE @substitution
												  END
										 END, 
				@previous = [PreviousRowValues] = CASE
													  WHEN [SecondOrder] = 0
														  THEN @current
													  ELSE @previous
												  END, 
				@current = CASE
							   WHEN [SecondOrder] = 0
								   THEN CHAR(@TheValue)
							   ELSE @current + CHAR(@TheValue)
						   END;
		RETURN @TheValue;
	END;
' 
END
GO
