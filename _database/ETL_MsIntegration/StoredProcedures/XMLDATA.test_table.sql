SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
create   procedure XMLDATA.test_table
as
declare @xmldoc xml
, @IntDoc INT 
, @TableId  varchar(50)
, @Version varchar(50)

set @Version = '2018'

SET @xmldoc = (
	SELECT
		CONVERT(XML, [BulkColumn]) AS [BulkColumn]
	FROM
		OPENROWSET(BULK 'C:\Sage 300 2018 AOM\AOM-2018\ASWPCR.xml', SINGLE_BLOB) AS x
	)

	-- SELECT statement that uses the OPENXML rowset provider.  
		EXEC sp_xml_preparedocument @IntDoc OUTPUT
								  , @Xmldoc

		
		SELECT @TableId = tableid
			FROM
			OPENXML(
			@IntDoc, '/page/pagebody/table', 2
			)
			WITH (
			tableid VARCHAR(100) '@name'
			)

			SELECT @tableid

			-- SELECT THE ELEMENTS OF THE TABLE 
			INSERT INTO XMLDATA.ApplicationTableField (
				[ApplicationTableID]
			  , [FieldCode]
			  , [FieldType]
			  , [FieldTitle]
			)
			SELECT XMLDATA.usp_get_ApplicationTableID(@TableId, @Version)
				 , [FieldName]
				 , [FieldType]
				 , [FieldDescription]
			FROM
			OPENXML(
			@IntDoc, '/page/pagebody/table/fieldlist/field', 1
			)
			WITH (
			[FieldName] VARCHAR(100) 'fieldname',
			[FieldType] VARCHAR(100) 'fieldtype',
			[FieldDescription] VARCHAR(100) 'fielddesc'
			)


			INSERT INTO [XMLDATA].[ApplicationTableAttribute] (
				[ApplicationTableFieldID]
			  , [AttributeKey]
			  , [AttributeValue]
			  , [AttributeDesciption]
			)

			SELECT XMLDATA.usp_get_ApplicationTableFieldID(@TableId, @Version, [FieldName]) AS [applicationviewfieldid]
				 , 'Presentation'															AS [attributekey]
				 , [index]																	AS [attributevalue]
				 , [value]																	AS [attributedesciption]
			FROM
			OPENXML(
			@IntDoc, '/page/pagebody/table/fieldlist/field/fieldpresentlist/fieldpresent', 1
			)
			WITH (
			[FieldName] VARCHAR(100) '../../fieldname'
			, [index] VARCHAR(100)
			, [value] VARCHAR(100)
			)



		EXEC sp_xml_removedocument @IntDoc

GO
