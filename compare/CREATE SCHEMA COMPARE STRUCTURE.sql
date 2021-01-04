/****** Object:  Schema [DC]    Script Date: 11/17/2019 14:32:11 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'DC')
EXEC sys.sp_executesql N'CREATE SCHEMA [DC]'
GO
/****** Object:  Schema [INTEGRATION]    Script Date: 11/17/2019 14:32:11 ******/
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'INTEGRATION')
EXEC sys.sp_executesql N'CREATE SCHEMA [INTEGRATION]'
GO
/****** Object:  Table [INTEGRATION].[compare_MASTER_SLAVE]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[compare_MASTER_SLAVE]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[compare_MASTER_SLAVE](
	[DCDatabaseInstanceID_Master] [int] NOT NULL,
	[DatabaseID_Master] [int] NOT NULL,
	[DCDatabaseInstanceID_Slave] [int] NOT NULL,
	[DatabaseID_Slave] [int] NOT NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[Database]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[Database]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[Database](
	[DatabaseID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseName] [varchar](100) NOT NULL,
	[AccessInstructions] [varchar](500) NULL,
	[Size] [decimal](19, 6) NULL,
	[DatabaseInstanceID] [int] NULL,
	[SystemID] [int] NULL,
	[ExternalDatasourceName] [varchar](100) NULL,
	[DatabasePurposeID] [int] NULL,
	[DBDatabaseID] [int] NULL,
	[DatabaseEnvironmentTypeID] [int] NULL,
	[LastSeenDT] [datetime2](7) NULL,
	[IsBaseDatabase] [bit] NULL,
	[BaseReferenceDatabaseID] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Database] PRIMARY KEY CLUSTERED 
(
	[DatabaseID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[System]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[System]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[System](
	[SystemID] [int] IDENTITY(1,1) NOT NULL,
	[SystemName] [varchar](100) NOT NULL,
	[SystemAbbreviation] [varchar](10) NULL,
	[Description] [varchar](200) NULL,
	[AccessInstructions] [varchar](500) NULL,
	[UserID] [int] NULL,
	[IsBusinessApplication] [bit] NULL,
	[DataDomainID] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_System] PRIMARY KEY CLUSTERED 
(
	[SystemID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[DatabaseInstance]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DatabaseInstance]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[DatabaseInstance](
	[DatabaseInstanceID] [int] IDENTITY(1,1) NOT NULL,
	[DatabaseInstanceName] [varchar](50) NULL,
	[ServerID] [int] NOT NULL,
	[DatabaseAuthenticationTypeID] [int] NOT NULL,
	[AuthUsername] [varchar](50) NULL,
	[AuthPassword] [varchar](50) NULL,
	[IsDefaultInstance] [bit] NULL,
	[NetworkPort] [int] NULL,
	[ADFLinkedServiceID] [int] NULL,
	[DatabaseTechnologyTypeID] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DatabaseInstance] PRIMARY KEY CLUSTERED 
(
	[DatabaseInstanceID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[Field]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[Field]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[Field](
	[FieldID] [int] IDENTITY(1,1) NOT NULL,
	[FieldName] [varchar](1000) NOT NULL,
	[DataType] [varchar](500) NULL,
	[MaxLength] [int] NULL,
	[Precision] [int] NULL,
	[Scale] [int] NULL,
	[StringLength] [int] NULL,
	[Description] [varchar](1000) NULL,
	[IsPrimaryKey] [bit] NULL,
	[IsForeignKey] [bit] NULL,
	[DefaultValue] [varchar](1000) NULL,
	[SystemGenerated] [bit] NULL,
	[DataQualityScore] [varchar](50) NULL,
	[dpNullCount] [decimal](18, 2) NULL,
	[dpNullCountPerc] [decimal](18, 2) NULL,
	[dpDistinctCount] [decimal](18, 2) NULL,
	[dpDuplicateCount] [decimal](18, 2) NULL,
	[dpDuplicatCountPerc] [decimal](18, 2) NULL,
	[dpOrphaneDChildrenCount] [decimal](18, 2) NULL,
	[dpOrphaneDChildrenCountPerc] [decimal](18, 2) NULL,
	[dpMinimum] [decimal](18, 2) NULL,
	[dpMaximum] [decimal](18, 2) NULL,
	[dpAverage] [decimal](18, 2) NULL,
	[dpMedian] [decimal](18, 2) NULL,
	[dpStandardDeviation] [nchar](10) NULL,
	[DataEntityID] [int] NULL,
	[SystemEntityID] [int] NULL,
	[IsSystemEntityDefinedAtRecordLevel] [bit] NULL,
	[DQScore] [decimal](18, 2) NULL,
	[DBColumnID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[FriendlyName] [varchar](100) NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_Field] PRIMARY KEY CLUSTERED 
(
	[FieldID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[DataEntity]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DataEntity]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[DataEntity](
	[DataEntityID] [int] IDENTITY(1,1) NOT NULL,
	[DataEntityName] [varchar](100) NOT NULL,
	[FriendlyName] [varchar](100) NULL,
	[Description] [varchar](100) NULL,
	[DataEntityTypeID] [int] NULL,
	[RowsCount] [bigint] NULL,
	[ColumnsCount] [varchar](50) NULL,
	[Size] [varchar](50) NULL,
	[DataQualityScore2] [varchar](10) NULL,
	[DataQualityScore] [decimal](18, 3) NULL,
	[DESourceCredentialID] [int] NULL,
	[DESourceTypeID] [int] NULL,
	[DEFileFormatID] [int] NULL,
	[SchemaID] [int] NULL,
	[DBObjectID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_DataEntity] PRIMARY KEY CLUSTERED 
(
	[DataEntityID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[Schema]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[Schema]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[Schema](
	[SchemaID] [int] IDENTITY(1,1) NOT NULL,
	[SchemaName] [varchar](100) NOT NULL,
	[DatabaseID] [int] NOT NULL,
	[DBSchemaID] [int] NULL,
	[SystemID] [int] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_Schema] PRIMARY KEY CLUSTERED 
(
	[SchemaID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[Server]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[Server]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[Server](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) NOT NULL,
	[PublicIP] [varchar](100) NULL,
	[LocalIP] [varchar](100) NULL,
	[AccessInstructions] [varchar](500) NULL,
	[ServerTypeID] [int] NULL,
	[ServerLocationID] [int] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Server] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  View [DC].[vw_rpt_DatabaseFieldDetail_MASTER]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DC].[vw_rpt_DatabaseFieldDetail_MASTER]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS

SELECT	db.DatabaseID
		, db.DatabaseName
		, db.IsActive AS IsActive_DB
		, db.IsBaseDatabase
		, db.BaseReferenceDatabaseID
		, serv.ServerName
		, dbinst.DatabaseInstanceID
		, CASE WHEN dbinst.IsDefaultInstance = 1 
			THEN ''Default'' 
			ELSE dbinst.DatabaseInstanceName 
		  END AS DatabaseInstanceName
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemID
			ELSE SchemaSystem.SystemID
		  END AS [SystemID]
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemAbbreviation
			ELSE SchemaSystem.SystemAbbreviation
		  END AS SystemAbbreviation
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemName
			ELSE SchemaSystem.SystemName
		  END AS SystemName
		, [schema].SchemaID
		, [schema].SchemaName
		, [schema].DBSchemaID 
		, de.DataEntityID
		, de.DataEntityName
		, de.DBObjectID
		, de.IsActive AS IsActive_DE
		, de.CreatedDT AS DataEntity_CreatedDT
		, f.FieldID
		, f.FieldName
		, f.DBColumnID
		, f.DataType
		, f.MaxLength
		, f.Precision
		, f.Scale
		, f.IsPrimaryKey 
		, f.IsForeignKey
		, f.FriendlyName
		, f.FieldSortOrder
FROM	DC.[Database] AS db 
        INNER JOIN INTEGRATION.compare_MASTER_SLAVE AS cms ON cms.DCDatabaseInstanceID_Master = db.DatabaseInstanceID  AND cms.DatabaseID_Master = db.DatabaseID
	    LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	    LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	    LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	    LEFT OUTER JOIN DC.[Schema] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	    LEFT OUTER JOIN DC.[System] AS [SchemaSystem] ON SchemaSystem.SystemID = [Schema].SystemID
	    LEFT OUTER JOIN DC.DataEntity AS de ON de.SchemaID = [schema].SchemaID 
	    LEFT OUTER JOIN DC.Field AS f ON f.DataEntityID = de.DataEntityID

' 
GO
/****** Object:  View [DC].[vw_rpt_DatabaseFieldDetail_SLAVE]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DC].[vw_rpt_DatabaseFieldDetail_SLAVE]'))
EXEC dbo.sp_executesql @statement = N'

CREATE VIEW [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS

SELECT	db.DatabaseID
		, db.DatabaseName
		, db.IsActive AS IsActive_DB
		, db.IsBaseDatabase
		, db.BaseReferenceDatabaseID
		, serv.ServerName
		, dbinst.DatabaseInstanceID
		, CASE WHEN dbinst.IsDefaultInstance = 1 
			THEN ''Default'' 
			ELSE dbinst.DatabaseInstanceName 
		  END AS DatabaseInstanceName
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemID
			ELSE SchemaSystem.SystemID
		  END AS [SystemID]
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemAbbreviation
			ELSE SchemaSystem.SystemAbbreviation
		  END AS SystemAbbreviation
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemName
			ELSE SchemaSystem.SystemName
		  END AS SystemName
		, [schema].SchemaID
		, [schema].SchemaName
		, [schema].DBSchemaID 
		, de.DataEntityID
		, de.DataEntityName
		, de.DBObjectID
		, de.IsActive AS IsActive_DE
		, de.CreatedDT AS DataEntity_CreatedDT
		, f.FieldID
		, f.FieldName
		, f.DBColumnID
		, f.DataType
		, f.MaxLength
		, f.Precision
		, f.Scale
		, f.IsPrimaryKey 
		, f.IsForeignKey
		, f.FriendlyName
		, f.FieldSortOrder
FROM	DC.[Database] AS db 
        INNER JOIN INTEGRATION.compare_MASTER_SLAVE AS cms ON cms.DCDatabaseInstanceID_Slave = db.DatabaseInstanceID  AND cms.DatabaseID_Slave = db.DatabaseID
	    LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	    LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	    LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	    LEFT OUTER JOIN DC.[Schema] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	    LEFT OUTER JOIN DC.[System] AS [SchemaSystem] ON SchemaSystem.SystemID = [Schema].SystemID
	    LEFT OUTER JOIN DC.DataEntity AS de ON de.SchemaID = [schema].SchemaID 
	    LEFT OUTER JOIN DC.Field AS f ON f.DataEntityID = de.DataEntityID

' 
GO
/****** Object:  View [DC].[vw_SchemaComparison]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DC].[vw_SchemaComparison]'))
EXEC dbo.sp_executesql @statement = N'
-- SELECT * FROM [DC].[vw_SchemaComparison]
-- SHOW WHAT IS DIFFERENT? IN SCALE ECT
CREATE   VIEW [DC].[vw_SchemaComparison]
AS

  -- FIELD
 SELECT 
    ISNULL(mast.DatabaseName, dbm.DatabaseName) As MasterDatabaseName,
    ISNULL(mast.DatabaseInstanceID, dbm.DatabaseInstanceID) As MasterDatabaseInstanceID,
    ISNULL(mast.DatabaseID, dbm.DatabaseID) As MasterDatabaseID,
    ISNULL(slave.DatabaseName, dbs.DatabaseName) As SlaveDatabaseName,
    ISNULL(slave.DatabaseInstanceID, dbs.DatabaseInstanceID) As SlaveDatabaseInstanceID,
    ISNULL(slave.DatabaseID, dbs.DatabaseID) As SlaveDatabaseID,
    ''Field'' As CompareDimension,
    mast.FieldName AS MasterValue,
    slave.FieldName As SlaveValue,
    CompareResult = CASE 
                        WHEN mast.FieldName IS NULL THEN ''Field does not exists in Master''
                        WHEN slave.FieldName IS NULL THEN ''Field does not exists in Slave''
                        WHEN mast.FieldName <> slave.FieldName THEN ''Field Difference''
                        ELSE ''No Difference'' END,
    CompareStatus = CASE 
                        WHEN mast.FieldName IS NULL THEN ''Field Difference'' 
                        WHEN slave.FieldName IS NULL THEN ''Field Difference''
                        WHEN mast.FieldName <> slave.FieldName THEN ''Field Difference''
                        ELSE ''Field Equal'' END
    FROM
    (
        SELECT 
	           vrdfdm.[DatabaseName] AS [DatabaseName]
             , vrdfdm.DatabaseInstanceID
             , vrdfdm.DatabaseID
             , vrdfdm.[SchemaName] AS [SchemaName]
	         , vrdfdm.[DataEntityName] AS [TableName]
	         , vrdfdm.[FieldName] AS [FieldName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	           vrdfds.[DatabaseName] AS [DatabaseName]
             , vrdfds.DatabaseInstanceID
             , vrdfds.DatabaseID
             , vrdfds.[SchemaName] AS [SchemaName]
	         , vrdfds.[DataEntityName] AS [TableName]
	         , vrdfds.[FieldName] AS [FieldName]
        FROM 
	         [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
	    [INTEGRATION].[COMPARE_MASTER_SLAVE] AS [cms]
    LEFT JOIN 
        DC.[Database] AS [dbm]
        ON dbm.DatabaseInstanceID = cms.DCDatabaseInstanceID_Master
        AND dbm.DatabaseID = cms.DatabaseID_Master
    LEFT JOIN 
        DC.[Database] AS [dbs]
        ON dbs.DatabaseInstanceID = cms.DCDatabaseInstanceID_Slave
        AND dbs.DatabaseID = cms.DatabaseID_Slave


    UNION ALL


    -- DataType
        SELECT 
        ISNULL(mast.DatabaseName, dbm.DatabaseName) As MasterDatabaseName,
        ISNULL(mast.DatabaseInstanceID, dbm.DatabaseInstanceID) As MasterDatabaseInstanceID,
        ISNULL(mast.DatabaseID, dbm.DatabaseID) As MasterDatabaseID,
        ISNULL(slave.DatabaseName, dbs.DatabaseName) As SlaveDatabaseName,
        ISNULL(slave.DatabaseInstanceID, dbs.DatabaseInstanceID) As SlaveDatabaseInstanceID,
        ISNULL(slave.DatabaseID, dbs.DatabaseID) As SlaveDatabaseID,
        ''Field'' As CompareDimension,
        mast.FieldName AS MasterValue,
        slave.FieldName As SlaveValue,
        CompareResult = CASE 
                            WHEN mast.DataType <> slave.DataType THEN ''DataType Difference''
                            ELSE ''DataType Difference'' END,
        CompareStatus = CASE 
                            WHEN mast.DataType <> slave.DataType THEN ''Field Difference''
                            ELSE ''Field Equal'' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , vrdfdm.[FieldName] AS [FieldName]
                , vrdfdm.[DataType] AS [DataType]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , vrdfds.[FieldName] AS [FieldName]
                , vrdfds.[DataType] AS [DataType]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
	    [INTEGRATION].[COMPARE_MASTER_SLAVE] AS [cms]
    LEFT JOIN 
        DC.[Database] AS [dbm]
        ON dbm.DatabaseInstanceID = cms.DCDatabaseInstanceID_Master
        AND dbm.DatabaseID = cms.DatabaseID_Master
    LEFT JOIN 
        DC.[Database] AS [dbs]
        ON dbs.DatabaseInstanceID = cms.DCDatabaseInstanceID_Slave
        AND dbs.DatabaseID = cms.DatabaseID_Slave
    WHERE
        mast.FieldName IS NOT NULL
    and 
        slave.FieldName IS NOT NULL

 UNION ALL


    -- MaxLength
        SELECT 
        ISNULL(mast.DatabaseName, dbm.DatabaseName) As MasterDatabaseName,
        ISNULL(mast.DatabaseInstanceID, dbm.DatabaseInstanceID) As MasterDatabaseInstanceID,
        ISNULL(mast.DatabaseID, dbm.DatabaseID) As MasterDatabaseID,
        ISNULL(slave.DatabaseName, dbs.DatabaseName) As SlaveDatabaseName,
        ISNULL(slave.DatabaseInstanceID, dbs.DatabaseInstanceID) As SlaveDatabaseInstanceID,
        ISNULL(slave.DatabaseID, dbs.DatabaseID) As SlaveDatabaseID,
        ''Field'' As CompareDimension,
        mast.FieldName AS MasterValue,
        slave.FieldName As SlaveValue,
        CompareResult = CASE 
                            WHEN mast.[MaxLength] <> slave.[MaxLength] THEN ''MaxLength Difference''
                            ELSE ''MaxLength Equal'' END,
        CompareStatus = CASE 
                            WHEN mast.[MaxLength] <> slave.[MaxLength] THEN ''Field Difference''
                            ELSE ''Field Equal'' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , vrdfdm.[FieldName] AS [FieldName]
                , vrdfdm.[MaxLength] AS [MaxLength]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , vrdfds.[FieldName] AS [FieldName]
                , vrdfds.[MaxLength] AS [MaxLength]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
	    [INTEGRATION].[COMPARE_MASTER_SLAVE] AS [cms]
    LEFT JOIN 
        DC.[Database] AS [dbm]
        ON dbm.DatabaseInstanceID = cms.DCDatabaseInstanceID_Master
        AND dbm.DatabaseID = cms.DatabaseID_Master
    LEFT JOIN 
        DC.[Database] AS [dbs]
        ON dbs.DatabaseInstanceID = cms.DCDatabaseInstanceID_Slave
        AND dbs.DatabaseID = cms.DatabaseID_Slave
    WHERE
        mast.FieldName IS NOT NULL
    and 
        slave.FieldName IS NOT NULL

UNION ALL

-- Precision
        SELECT 
        ISNULL(mast.DatabaseName, dbm.DatabaseName) As MasterDatabaseName,
        ISNULL(mast.DatabaseInstanceID, dbm.DatabaseInstanceID) As MasterDatabaseInstanceID,
        ISNULL(mast.DatabaseID, dbm.DatabaseID) As MasterDatabaseID,
        ISNULL(slave.DatabaseName, dbs.DatabaseName) As SlaveDatabaseName,
        ISNULL(slave.DatabaseInstanceID, dbs.DatabaseInstanceID) As SlaveDatabaseInstanceID,
        ISNULL(slave.DatabaseID, dbs.DatabaseID) As SlaveDatabaseID,
        ''Field'' As CompareDimension,
        mast.FieldName AS MasterValue,
        slave.FieldName As SlaveValue,
        CompareResult = CASE 
                            WHEN mast.[Precision] <> slave.[Precision] THEN ''Precision Difference''
                            ELSE ''Precision Equal'' END,
        CompareStatus = CASE 
                            WHEN mast.[Precision] <> slave.[Precision] THEN ''Field Difference''
                            ELSE ''Field Equal'' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , vrdfdm.[FieldName] AS [FieldName]
                , vrdfdm.[Precision] AS [Precision]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , vrdfds.[FieldName] AS [FieldName]
                , vrdfds.[Precision] AS [Precision]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
	    [INTEGRATION].[COMPARE_MASTER_SLAVE] AS [cms]
    LEFT JOIN 
        DC.[Database] AS [dbm]
        ON dbm.DatabaseInstanceID = cms.DCDatabaseInstanceID_Master
        AND dbm.DatabaseID = cms.DatabaseID_Master
    LEFT JOIN 
        DC.[Database] AS [dbs]
        ON dbs.DatabaseInstanceID = cms.DCDatabaseInstanceID_Slave
        AND dbs.DatabaseID = cms.DatabaseID_Slave
    WHERE
        mast.FieldName IS NOT NULL
    and 
        slave.FieldName IS NOT NULL

    UNION ALL

    -- Scale
        SELECT 
        ISNULL(mast.DatabaseName, dbm.DatabaseName) As MasterDatabaseName,
        ISNULL(mast.DatabaseInstanceID, dbm.DatabaseInstanceID) As MasterDatabaseInstanceID,
        ISNULL(mast.DatabaseID, dbm.DatabaseID) As MasterDatabaseID,
        ISNULL(slave.DatabaseName, dbs.DatabaseName) As SlaveDatabaseName,
        ISNULL(slave.DatabaseInstanceID, dbs.DatabaseInstanceID) As SlaveDatabaseInstanceID,
        ISNULL(slave.DatabaseID, dbs.DatabaseID) As SlaveDatabaseID,
        ''Field'' As CompareDimension,
        mast.FieldName AS MasterValue,
        slave.FieldName As SlaveValue,
        CompareResult = CASE 
                            WHEN mast.[Scale] <> slave.[Scale] THEN ''Scale Difference''
                            ELSE ''No Difference'' END,
        CompareStatus = CASE 
                            WHEN mast.[Scale] <> slave.[Scale] THEN ''Field Difference''
                            ELSE ''Field Equal'' END
    FROM
    (
        SELECT 
	            vrdfdm.[DatabaseName] AS [DatabaseName]
                , vrdfdm.DatabaseInstanceID
                , vrdfdm.DatabaseID
                , vrdfdm.[SchemaName] AS [SchemaName]
	            , vrdfdm.[DataEntityName] AS [TableName]
	            , vrdfdm.[FieldName] AS [FieldName]
                , vrdfdm.[Scale] AS [Scale]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_MASTER] AS vrdfdm
    ) AS mast

    FULL JOIN 
    
    (
        SELECT 
	            vrdfds.[DatabaseName] AS [DatabaseName]
                , vrdfds.DatabaseInstanceID
                , vrdfds.DatabaseID
                , vrdfds.[SchemaName] AS [SchemaName]
	            , vrdfds.[DataEntityName] AS [TableName]
	            , vrdfds.[FieldName] AS [FieldName]
                , vrdfds.[Scale] AS [Scale]
        FROM 
	            [DC].[vw_rpt_DatabaseFieldDetail_SLAVE] AS vrdfds
    ) AS slave
    ON
        slave.SchemaName = mast.SchemaName
            AND slave.TableName = mast.TableName
                AND slave.FieldName = mast.FieldName
    CROSS JOIN 
	    [INTEGRATION].[COMPARE_MASTER_SLAVE] AS [cms]
    LEFT JOIN 
        DC.[Database] AS [dbm]
        ON dbm.DatabaseInstanceID = cms.DCDatabaseInstanceID_Master
        AND dbm.DatabaseID = cms.DatabaseID_Master
    LEFT JOIN 
        DC.[Database] AS [dbs]
        ON dbs.DatabaseInstanceID = cms.DCDatabaseInstanceID_Slave
        AND dbs.DatabaseID = cms.DatabaseID_Slave
    WHERE
        mast.FieldName IS NOT NULL
    and 
        slave.FieldName IS NOT NULL




--UNION ALL






--SELECT DISTINCT S.ServerName
--			   ,S.DatabaseName
--			   ,S.SchemaName
--			   ,S.DataEntityName AS SourceDataEntityName
--			   ,S.FieldName AS SourceFieldName
--			   ,S.DataType AS SourceDataType
--			   ,S.[MaxLength]
--			   ,S.[Precision]
--			   ,S.Scale
--			   ,T.ServerName
--			   ,T.DatabaseName
--			   ,T.SchemaName
--			   ,T.DataEntityName AS SlaveDataEntityName 
--			   ,T.FieldName AS SlaveFieldName 
--			   ,T.DataType AS SourceDataType
--			   ,T.[MaxLength]
--			   ,T.[Precision]
--			   ,T.Scale
--FROM DC.vw_rpt_DatabaseFieldDetail S
--FULL OUTER JOIN (SELECT 	ServerName
--						   ,DatabaseName
--						   ,SchemaName
--						   ,DataEntityName 
--						   ,FieldName
--						   ,DataType
--						   ,[MaxLength]
--						   ,[Precision]
--						   ,Scale 
--						   ,DatabaseID
--						   ,MasterReferenceDatabaseID
--						    FROM DC.vw_rpt_DatabaseFieldDetail 
--							WHERE MasterReferenceDatabaseID IS NOT NULL
--				 ) T ON
--						--S.ServerName = T.ServerName AND
--						--S.DatabaseName = T.DatabaseName AND
--						T.SchemaName = S.SchemaName
--							AND T.DataEntityName = S.DataEntityName
--							    AND T.FieldName = S.FieldName
--									AND s.DataType = T.DataType
--										AND S.[MaxLength] = T.[MaxLength]
--											AND S.[Precision] = T.[Precision]
--												AND S.Scale = T.Scale
--INNER JOIN (
--SELECT 	ServerName
--						   ,DatabaseName
--						   ,SchemaName
--						   ,DataEntityName 
--						   ,FieldName
--						   ,DataType
--						   ,[MaxLength]
--						   ,[Precision]
--						   ,Scale 
--						   ,DatabaseID
--						   ,MasterReferenceDatabaseID
--						    FROM DC.vw_rpt_DatabaseFieldDetail 
--							WHERE DatabaseID = 1) AS sq
--							ON S.MasterReferenceDatabaseID = sq.DatabaseID
----WHERE S.IsMasterDatabase = 1
--	WHERE S.DatabaseID = T.DatabaseID
----ORDER BY  S.DatabaseName , T.DatabaseName 
----	    , S.SchemaName , T.SchemaName 
----		, S.DataEntityName , T.DataEntityName



' 
GO
/****** Object:  View [DC].[vw_rpt_DatabaseFieldDetail]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DC].[vw_rpt_DatabaseFieldDetail]'))
EXEC dbo.sp_executesql @statement = N'CREATE VIEW [DC].[vw_rpt_DatabaseFieldDetail] AS

SELECT	db.DatabaseID
		, db.DatabaseName
		, db.IsActive AS IsActive_DB
		, db.IsBaseDatabase
		, db.BaseReferenceDatabaseID
		, serv.ServerName
		, dbinst.DatabaseInstanceID
		, CASE WHEN dbinst.IsDefaultInstance = 1 
			THEN ''Default'' 
			ELSE dbinst.DatabaseInstanceName 
		  END AS DatabaseInstanceName
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemID
			ELSE SchemaSystem.SystemID
		  END AS [SystemID]
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemAbbreviation
			ELSE SchemaSystem.SystemAbbreviation
		  END AS SystemAbbreviation
		, CASE WHEN [Schema].SystemID IS NULL --OR [Schema].SystemID = ''''
			THEN [system].SystemName
			ELSE SchemaSystem.SystemName
		  END AS SystemName
		, [schema].SchemaID
		, [schema].SchemaName
		, [schema].DBSchemaID 
		, de.DataEntityID
		, de.DataEntityName
		, de.DBObjectID
		, de.IsActive AS IsActive_DE
		, de.CreatedDT AS DataEntity_CreatedDT
		, f.FieldID
		, f.FieldName
		, f.DBColumnID
		, f.DataType
		, f.MaxLength
		, f.Precision
		, f.Scale
		, f.IsPrimaryKey 
		, f.IsForeignKey
		, f.FriendlyName
		, f.FieldSortOrder
FROM	DC.[Database] AS db 
	LEFT OUTER JOIN DC.DatabaseInstance AS dbinst ON dbinst.DatabaseInstanceID = db.DatabaseInstanceID 
	LEFT OUTER JOIN DC.[Server] AS serv ON serv.ServerID = dbinst.ServerID 
	LEFT OUTER JOIN DC.[System] AS [system] ON [system].SystemID = db.SystemID 
	LEFT OUTER JOIN DC.[Schema] AS [schema] ON [schema].DatabaseID = db.DatabaseID 
	LEFT OUTER JOIN DC.[System] AS [SchemaSystem] ON SchemaSystem.SystemID = [Schema].SystemID
	LEFT OUTER JOIN DC.DataEntity AS de ON de.SchemaID = [schema].SchemaID 
	LEFT OUTER JOIN DC.Field AS f ON f.DataEntityID = de.DataEntityID
' 
GO
/****** Object:  Table [DC].[ServerType]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[ServerType]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[ServerType](
	[ServerTypeID] [int] IDENTITY(1,1) NOT NULL,
	[ServerTypeCode] [varchar](50) NULL,
	[ServerTypeDescription] [varchar](100) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_ServerType] PRIMARY KEY CLUSTERED 
(
	[ServerTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[ServerLocation]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[ServerLocation]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[ServerLocation](
	[ServerLocationID] [int] IDENTITY(1,1) NOT NULL,
	[ServerLocationCode] [varchar](10) NULL,
	[ServerLocationName] [varchar](100) NULL,
	[IsCloudLocation] [bit] NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_ServerLocation] PRIMARY KEY CLUSTERED 
(
	[ServerLocationID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[DatabasePurpose]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DatabasePurpose]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[DatabasePurpose](
	[DatabasePurposeID] [int] IDENTITY(1,1) NOT NULL,
	[DatabasePurposeCode] [varchar](50) NULL,
	[DatabasePurposeName] [varchar](100) NULL,
	[DatabasePurposeDescription] [varchar](1000) NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_DatabasePurpose] PRIMARY KEY CLUSTERED 
(
	[DatabasePurposeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[DatabaseAuthenticationType]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DatabaseAuthenticationType]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[DatabaseAuthenticationType](
	[DatabaseAuthenticationTypeID] [int] IDENTITY(1,1) NOT NULL,
	[DBAuthTypeName] [varchar](50) NOT NULL,
	[IsAdfCompatible] [bit] NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_DatabaseAuthenticationType] PRIMARY KEY CLUSTERED 
(
	[DatabaseAuthenticationTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
END
GO
/****** Object:  View [DC].[vw_get_All_AdfConnections]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[DC].[vw_get_All_AdfConnections]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [DC].[vw_get_All_AdfConnections]
AS
SELECT 

 [di].[DatabaseInstanceID],
 [db].[DatabaseID],

 
   --     [ser].[ServerID]
   
   [ser].[ServerName]
--	 ,  [ser].[ServerTypeID]
 --    ,  [st].[ServerTypeCode]
--	 ,  [ser].[ServerLocationID]
  --   ,  [sl].[ServerLocationName]
    --   [sl].[IsCloudLocation]

   ,    [di].[IsDefaultInstance]
    -- ,
      , [di].[DatabaseInstanceName]
   


	
	 --, [di].[DatabaseAuthenticationTypeID]
    , [dat].[DBAuthTypeName]	
	 , [di].[AuthUsername]
	 , [di].[AuthPassword]
	
	-- , [di].[NetworkPort]
	-- , [di].[ADFLinkedServiceID]

      , [db].[DatabaseName]
  --   , [sy].[SystemID]
   --  , [sy].[SystemName]
--	 , [sy].[SystemAbbreviation]
	 --, [sy].[Description]
  --   , [dp].[DatabasePurposeID]
--	 , [dp].[DatabasePurposeCode]
 --    , 
	 
	 --, [db].[DatabaseEnvironmentTypeID]
	-- , [db].[IsBaseDatabase]
--	 , [db].[BaseReferenceDatabaseID]
--	 , [s].[SchemaID]
	 , [s].[SchemaName]
FROM 
	 [DC].[Schema] AS [s]
INNER JOIN
	[DC].[Database] AS [db]
	ON [db].[DatabaseID] = [s].[DatabaseID]
INNER JOIN
	[DC].[DatabasePurpose] AS [dp]
	ON [dp].[DatabasePurposeID] = [db].[DatabasePurposeID]
INNER JOIN
	[DC].[System] AS [sy]
	ON [sy].[SystemID] = [db].[SystemID]
INNER JOIN
	[dc].[DatabaseInstance] AS [di]
	ON [di].[DatabaseInstanceID] = [db].[DatabaseInstanceID]
INNER JOIN
    [DC].[DatabaseAuthenticationType] AS dat
    ON dat.DatabaseAuthenticationTypeID = di.DatabaseAuthenticationTypeID
INNER JOIN
	[DC].[Server] AS [ser]
	ON [ser].[ServerID] = [di].[ServerID]
INNER JOIN
	[DC].[ServerType] AS [st]
	ON [st].[ServerTypeID] = [ser].[ServerTypeID]
INNER JOIN
	[DC].[ServerLocation] AS [sl]
	ON [sl].[ServerLocationID] = [ser].[ServerLocationID]
----INNER JOIN TYPE.[Generic_Detail] AS gd
--ON gd.DetailID = db.DatabaseEnvironmentTypeID
--INNER JOIN TYPE.[Generic_Header] aS gh
--ON gh.HeaderID = gd.HeaderID

WHERE
			[dp].[DatabasePurposeCode] = ''DataManager''
			AND [dp].[IsActive] = 1
				--AND\
				--    gh.HeaderCode = ''DB_ENV''
                AND [s].[SchemaName] = ''INTEGRATION''
				AND [dat].[IsAdfCompatible] = 1
				AND [db].[IsExclude] = 0

' 
GO
/****** Object:  Table [DC].[DataEntityType]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DataEntityType]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[DataEntityType](
	[DataEntityTypeID] [int] NOT NULL,
	[DataEntityTypeName] [varchar](200) NOT NULL,
	[DataEntityTypeCode] [varchar](20) NULL,
	[DatabasePurposeID] [int] NULL,
	[IsAllowedInRawVault] [bit] NOT NULL,
	[IsAllowedInBizVault] [bit] NOT NULL,
	[DataEntityNamingPrefix] [varchar](20) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[Function]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[Function]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[Function](
	[FunctionID] [int] IDENTITY(1,1) NOT NULL,
	[FunctionName] [varchar](128) NOT NULL,
	[FunctionCode] [varchar](max) NOT NULL,
	[FunctionType] [int] NOT NULL,
	[SchemaID] [int] NOT NULL,
	[FunctionCreateDate] [datetime] NOT NULL,
	[FunctionMofifyDate] [datetime] NULL,
	[FunctionLastRunate] [datetime] NULL,
	[LinesOfCode] [int] NULL,
	[CheckSumOfCode] [varchar](max) NULL,
	[HasParameters] [bit] NULL,
	[HasDependency] [bit] NULL,
	[IsDependency] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_Function] PRIMARY KEY CLUSTERED 
(
	[FunctionID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[FunctionType]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[FunctionType]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[FunctionType](
	[FunctionTypeID] [int] IDENTITY(1,1) NOT NULL,
	[FunctionTypeName] [varchar](128) NOT NULL,
	[FunctionTypeCode] [varchar](max) NOT NULL,
	[SchemaID] [int] NOT NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_FunctionType] PRIMARY KEY CLUSTERED 
(
	[FunctionTypeID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[StoredProcedure]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[StoredProcedure]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[StoredProcedure](
	[StoredProcedureID] [int] IDENTITY(1,1) NOT NULL,
	[StoredProcedureName] [varchar](128) NOT NULL,
	[StoredProcedureCode] [varchar](max) NOT NULL,
	[SchemaID] [int] NOT NULL,
	[StoredProcedureCreateDate] [datetime] NOT NULL,
	[StoredProcedureMofifyDate] [datetime] NULL,
	[StoredProcedureLastRunate] [datetime] NULL,
	[LinesOfCode] [int] NULL,
	[CheckSumOfCode] [varchar](max) NULL,
	[HasParameters] [bit] NULL,
	[HasDependency] [bit] NULL,
	[IsDependency] [bit] NULL,
	[CreatedDT] [datetime2](7) NULL,
	[UpdatedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL,
	[LastSeenDT] [datetime2](7) NULL,
 CONSTRAINT [PK_StoredProcedure] PRIMARY KEY CLUSTERED 
(
	[StoredProcedureID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [DC].[SystemConfigurations]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[SystemConfigurations]') AND type in (N'U'))
BEGIN
CREATE TABLE [DC].[SystemConfigurations](
	[SystemConfigID] [int] IDENTITY(1,1) NOT NULL,
	[SystemID] [int] NOT NULL,
	[ConfigurationType] [varchar](200) NULL,
	[ConfigurationDescription] [varchar](200) NULL,
	[ConfigurationValue] [varchar](max) NULL,
	[CreatedBy] [varchar](50) NOT NULL,
	[CreatedDT] [datetime2](7) NOT NULL,
	[ModifiedBy] [varchar](50) NULL,
	[ModifiedDT] [datetime2](7) NULL,
	[IsActive] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DataCatalog]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DataCatalog]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DataCatalog](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DataCatalog_BACKUP_210191113_EF]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DataCatalog_BACKUP_210191113_EF]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DataCatalog_BACKUP_210191113_EF](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_DEV]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_DEV]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_DEV](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_Kevro]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_Kevro]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_Kevro](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_Master]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_Master]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_Master](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_PROD]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_PROD]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_PROD](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_QA]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_QA]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_QA](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
/****** Object:  Table [INTEGRATION].[ingress_DM_Sappo]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[ingress_DM_Sappo]') AND type in (N'U'))
BEGIN
CREATE TABLE [INTEGRATION].[ingress_DM_Sappo](
	[DCDatabaseInstanceID] [int] NULL,
	[DatabaseID] [int] NULL,
	[DatabaseName] [varchar](128) NULL,
	[SchemaID] [int] NULL,
	[SchemaName] [varchar](128) NULL,
	[DataEntityID] [int] NULL,
	[DataEntityName] [varchar](128) NULL,
	[ColumnID] [int] NULL,
	[ColumnName] [varchar](128) NULL,
	[DataType] [varchar](128) NULL,
	[MaxLength] [smallint] NULL,
	[Precision] [smallint] NULL,
	[Scale] [tinyint] NULL,
	[IsPrimaryKey] [int] NULL,
	[IsForeignKey] [int] NULL,
	[DefaultValue] [varchar](50) NULL,
	[IsSystemGenerated] [int] NULL,
	[RowCount] [int] NULL,
	[DataEntitySize] [decimal](18, 3) NULL,
	[DatabaseSize] [decimal](18, 3) NULL,
	[IsActive] [bit] NULL,
	[FieldSortOrder] [int] NULL,
	[DataEntityTypeCode] [varchar](50) NULL
) ON [PRIMARY]
END
GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__Database__Create__32AB8735]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[Database] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__Database__IsActi__339FAB6E]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[Database] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseA__IsAdf__74794A92]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabaseAuthenticationType] ADD  CONSTRAINT [DF__DatabaseA__IsAdf__74794A92]  DEFAULT ((0)) FOR [IsAdfCompatible]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseA__Creat__44CA3770]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabaseAuthenticationType] ADD  CONSTRAINT [DF__DatabaseA__Creat__44CA3770]  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseA__IsAct__45BE5BA9]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabaseAuthenticationType] ADD  CONSTRAINT [DF__DatabaseA__IsAct__45BE5BA9]  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseI__Creat__3A4CA8FD]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabaseInstance] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseI__IsAct__3B40CD36]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabaseInstance] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseP__Creat__3F115E1A]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabasePurpose] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__DatabaseP__IsAct__40058253]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[DatabasePurpose] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF_Schema_IsActive]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[Schema] ADD  CONSTRAINT [DF_Schema_IsActive]  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__Server__CreatedD__44CA3770]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[Server] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__Server__IsActive__45BE5BA9]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[Server] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__ServerLoc__Creat__46B27FE2]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[ServerLocation] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__ServerLoc__IsMas__489AC854]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[ServerLocation] ADD  DEFAULT ((0)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__ServerTyp__Creat__4B7734FF]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[ServerType] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__ServerTyp__IsAct__4C6B5938]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[ServerType] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__System__CreatedD__503BEA1C]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[System] ADD  DEFAULT (getdate()) FOR [CreatedDT]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF__System__IsActive__51300E55]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[System] ADD  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DC].[DF_SystemConfigurations_IsActive]') AND type = 'D')
--BEGIN
--ALTER TABLE [DC].[SystemConfigurations] ADD  CONSTRAINT [DF_SystemConfigurations_IsActive]  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[DF_ingress_DataCatalog_IsActive]') AND type = 'D')
--BEGIN
--ALTER TABLE [INTEGRATION].[ingress_DataCatalog] ADD  CONSTRAINT [DF_ingress_DataCatalog_IsActive]  DEFAULT ((1)) FOR [IsActive]
--END
--GO
--IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[DF_ingress_Dtempy_IsActive]') AND type = 'D')
--BEGIN
--ALTER TABLE [INTEGRATION].[ingress_DM_Master] ADD  CONSTRAINT [DF_ingress_Dtempy_IsActive]  DEFAULT ((1)) FOR [IsActive]
--END
--GO
/****** Object:  StoredProcedure [INTEGRATION].[sp_load_DataCatalog]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[sp_load_DataCatalog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [INTEGRATION].[sp_load_DataCatalog] AS' 
END
GO
-- =============================================
-- Author:      Karl Dinkelmann
-- Create Date: 6 Oct 2018
-- Description: Loads the data catalog tables from the INTEGRATION table.
-- =============================================
ALTER PROCEDURE [INTEGRATION].[sp_load_DataCatalog]
AS

/*========================================================================
********************************************************
-Update DBDatabaseID if it changed or if it is null 
********************************************************
Test Case:

Change a DBDatabaseID to Null and run this update statement
1. Pick a sepcific entry in the DC.Database that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM Dc.[Database]  
		WHERE DatabaseID = 136
2. Change the DBDatabaseID to 999/NULL
		UPDATE DC.[Database] 
		SET DBDatabaseID = 999 --(or NULL to check if NULL updates)
		WHERE DataBaseID = 136
3. Check if change happened
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
3. Run the Update statement below
4. Check if it updated back to DataBaseID = 136
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
							SUCCESS!
========================================================================*/
UPDATE d
SET  DBDatabaseID = idc.DatabaseID,
	 UpdatedDT = GETDATE()
FROM DC.[Database] d
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID, 
								DatabaseID, 
								DatabaseName 
				FROM [INTEGRATION].[ingress_DataCatalog]
				) idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID 
				  AND
				  idc.DatabaseName = d.DatabaseName
 WHERE ISNULL(DBDatabaseID,'') != idc.DatabaseID
    OR ISNULL(DBDatabaseID, '') != idc.DatabaseID

 /*========================================================================
********************************************************
Update Database name (renamed database)
********************************************************
1. Pick a sepcific entry in the DC.Database that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
2. Change the DatabaseName
		UPDATE DC.[Database]  
		SET DatabaseName = 'TestRename'
		WHERE DataBaseID = 136
3. Check if change happened
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
3. Run the Update statement below
4. Check if it updated back to DataBaseID = 136
		SELECT * 
		FROM DC.[Database]  
		WHERE DatabaseID = 136
							SUCCESS!
========================================================================*/

--KD 2019/09/10: Removed because DatabaseName should never be updated based on a possibly changing DBDatabaseID (DBDatabaseID is not reliable enough to do this).
--UPDATE d
--SET  DatabaseName = idc.DatabaseName,
--	 UpdatedDT = GETDATE()
--FROM DC.[Database] d
--	   INNER JOIN (	SELECT DISTINCT DCDatabaseInstanceID, 
--									DatabaseID,
--									DatabaseName 
--					FROM [INTEGRATION].[ingress_DataCatalog]
--				   ) idc ON
--					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--					 idc.DatabaseID = d.DBDatabaseID
--WHERE d.DatabaseName != idc.DatabaseName


  /*========================================================================
Update LastSeenDT for database - for all DB's crawled
========================================================================*/
UPDATE d
SET  d.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 d.UpdatedDT = CASE WHEN d.IsActive = 0 THEN GETDATE() ELSE d.UpdatedDT END,
	 d.IsActive = 1
FROM DC.[Database]  d
	   INNER JOIN (	SELECT DISTINCT DCDatabaseInstanceID, 
									DatabaseName 
					FROM [INTEGRATION].[ingress_DataCatalog]
				   ) idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName

  /*========================================================================
Insert new Database/s
========================================================================*/
INSERT INTO DC.[Database]  (DatabaseName,
						   DatabaseInstanceID,
						   DBDatabaseID,
						   CreatedDT,
						   LastSeenDT,
						   IsActive
						   )
SELECT DISTINCT idc.DatabaseName,
				idc.DCDatabaseInstanceID,
				idc.DatabaseID,
				GETDATE(),
				GETDATE(),
				1
FROM [INTEGRATION].[ingress_DataCatalog] idc
WHERE NOT EXISTS (SELECT 1
				  FROM DC.[Database]  d
				  WHERE d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
						 d.DatabaseName = idc.DatabaseName --KD 2019/09/10: Updated from Database Object ID.
				  )
  /*========================================================================
********************************************************
Update Schema details - missing SchemaID
********************************************************
Test case:
1. Find a DBSchemaID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
2. Change the DBSchemaID 
		UPDATE DC.[Schema]  
		SET DBSchemaID = NULL
		WHERE  SchemaID = 261
3.Check the change
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[Schema]  
		WHERE  SchemaID = 261
							!SUCCESS!
========================================================================*/
UPDATE s
SET  DBSchemaID = idc.SchemaID,
	 UpdatedDT = GETDATE()
FROM DC.[Schema]  s
	 INNER JOIN DC.[Database]  d ON
				d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 SchemaID
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  )  idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName AND
					 idc.SchemaName = s.SchemaName
 WHERE s.DBSchemaID IS NULL OR
	   s.DBSchemaID != idc.SchemaID
	   
  /*========================================================================
Update LastSeenDT for Schema
========================================================================*/
UPDATE s
SET  s.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 s.UpdatedDT = CASE WHEN s.IsActive = 0 THEN GETDATE() ELSE s.UpdatedDT END,
	 s.IsActive = 1
FROM DC.[Schema]  s
	 INNER JOIN DC.[Database]  d ON
				d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName 
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  )  idc ON
					 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
					 idc.DatabaseName = d.DatabaseName AND
					 idc.SchemaName = s.SchemaName
  /*========================================================================
********************************************************
Insert new Schema/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO DC.[Schema]  (SchemaName,
						 DatabaseID,
						 DBSchemaID,
						 CreatedDT,
						 LastSeenDT,
						 IsActive
					     )
SELECT DISTINCT idc.SchemaName,
				d.DatabaseID,
				idc.SchemaID,
				GETDATE(),
				GETDATE(),
				1
FROM [INTEGRATION].[ingress_DataCatalog] idc
	 INNER JOIN DC.[Database] d ON
				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
				d.DatabaseName = idc.DatabaseName
WHERE NOT EXISTS
			    (SELECT 1
			     FROM DC.[Schema]  s
			     WHERE	s.SchemaName = idc.SchemaName AND
			    		s.DatabaseID = d.DatabaseID --AND
			    		--s.DBSchemaID = idc.SchemaID --KD 2019/09/10
			    ) AND
idc.SchemaID IS NOT NULL --A database can have no schemas in the Ingress table

/*========================================================================
********************************************************
Update table details - missing DBObjectID
********************************************************
Test case:
1. Find a DBObjectID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
2. Change the DBObjectID 
		UPDATE DC.[DataEntity] 
		SET DBObjectID = NULL
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
3.Check the change
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
							!SUCCESS!
========================================================================*/
UPDATE de
SET  DBObjectID = idc.DataEntityID,
	 UpdatedDT = GETDATE()
FROM [DC].[DataEntity] de
	 INNER JOIN DC.[Schema]  s ON
			    s.SchemaID = de.SchemaID
	 INNER JOIN DC.[Database]  d ON
			    d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 DataEntityName,
								 DataEntityID
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  ) idc ON
			    idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
			    idc.DatabaseName = d.DatabaseName AND
			    idc.SchemaName = s.SchemaName AND
			    idc.DataEntityName = de.DataEntityName		
WHERE de.DBObjectID IS NULL OR
	  de.DBObjectID != idc.DataEntityID

/*========================================================================
********************************************************
Update table information (table name)
********************************************************
Test case:
1. Find a DBObjectID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
2. Change the DBObjectID 
		UPDATE DC.[DataEntity] 
		SET DataEntityName  = 'Test'
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
3.Check the change
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[DataEntity] 
		WHERE  SchemaID = 276 AND
			DataEntityID = 9038
							!SUCCESS!
========================================================================*/
--KD 2019/09/10: Removed because DataEntityName should never be updated based on a possibly changing DBObjectID (DBObjectID is not reliable enough to do this).
--UPDATE de
--SET   DataEntityName = idc.DataEntityName,
--	  UpdatedDT = GETDATE()
--FROM  [DC].[DataEntity] de
--	  INNER JOIN DC.[Schema] s ON
--				 s.SchemaID = de.SchemaID
--	  INNER JOIN DC.[Database] d ON
--				 d.DatabaseID = s.DatabaseID
--	  INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
--				 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--				 idc.DatabaseID = d.DBDatabaseID AND
--				 idc.SchemaID = s.DBSchemaID AND
--			     idc.DataEntityID = de.DBObjectID
--WHERE de.DataEntityName != idc.DataEntityName

  /*========================================================================
Update LastSeenDT for DataEntity
========================================================================*/
UPDATE de
SET   de.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 de.UpdatedDT = CASE WHEN de.IsActive = 0 THEN GETDATE() ELSE de.UpdatedDT END,
	 de.IsActive = 1
FROM  [DC].[DataEntity] de
	  INNER JOIN DC.[Schema]  s ON
				 s.SchemaID = de.SchemaID
	  INNER JOIN DC.[Database]  d ON
				 d.DatabaseID = s.DatabaseID
	 INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID,
								 DatabaseName, 
								 SchemaName,
								 DataEntityName
				 FROM [INTEGRATION].[ingress_DataCatalog]
				  ) idc ON
				 idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				 idc.DatabaseName = d.DatabaseName AND
				 idc.SchemaName = s.SchemaName AND
			     idc.DataEntityName = de.DataEntityName

/*========================================================================
********************************************************
Insert new Table/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO [DC].[DataEntity]
           ([DataEntityName]
           ,[SchemaID]
		   ,[DBObjectID]
		   ,CreatedDT
		   ,LastSeenDT
		   ,IsActive
		   ,DataEntityTypeID)
SELECT DISTINCT idc.DataEntityName,
				s.SchemaID,
				idc.DataEntityID,
				GETDATE(),
				GETDATE(),
				1,
				det.DataEntityTypeID
  FROM [INTEGRATION].[ingress_DataCatalog] idc
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseName = idc.DatabaseName AND
				  d.DatabaseInstanceID = idc.DCDatabaseInstanceID
	   INNER JOIN DC.[Schema]  s ON
				  s.DatabaseID = d.DatabaseID AND
				  s.SchemaName = idc.SchemaName
	   INNER JOIN DC.[DataEntityType] det ON
				  det.DataEntityTypeCode = idc.DataEntityTypeCode
 WHERE NOT EXISTS
			(SELECT 1
			 FROM DC.[DataEntity] de
			 WHERE de.DataEntityName = idc.DataEntityName AND
					de.SchemaID = s.SchemaID)
AND idc.DataEntityID IS NOT NULL --Empty databases in the ingress table


 /*========================================================================
********************************************************
Update field information (field name, etc.)
********************************************************
Test case:
1. Find a DBColumnID that is NB: currently in the INTEGRATION.ingress_DataCatalog :
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
2. Change the DBColumnID 
		UPDATE DC.[Field] 
		SET FieldName  = 'Test'
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
3.Check the change
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
4.Run the Update statement below
5.Check if it was returned to DBSchemaID = 1
		SELECT * 
		FROM   DC.[Field] 
		WHERE  DataEntityID = 9038 AND
			FieldID = 443336
							!SUCCESS!
========================================================================*/
UPDATE f
   SET --FieldName = idc.ColumnName,
       DBColumnID = idc.ColumnID,
	   DataType = idc.DataType,
	   MAXLENGTH = idc.MAXLENGTH,
	   PRECISION = idc.PRECISION,
	   Scale = idc.Scale,
	   IsPrimaryKey = idc.IsPrimaryKey,
	   IsForeignKey = idc.IsForeignKey,
	   DataEntitySize = idc.dataentitysize,
	   DatabaseSize = idc.DatabaseSize,
	   DefaultValue = idc.defaultvalue,
	   UpdatedDT = GETDATE(),
	   FieldSortOrder = idc.FieldSortOrder
  FROM [DC].Field f
	   INNER JOIN [DC].DataEntity de ON
				  de.DataEntityID = f.DataEntityID
	   INNER JOIN DC.[Schema]  s ON
				  s.SchemaID = de.SchemaID
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseID = s.DatabaseID
	   INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				  idc.DatabaseName = d.DatabaseName AND
				  idc.SchemaName = s.SchemaName AND
				  idc.DataEntityName = de.DataEntityName AND
				  idc.ColumnName = f.FieldName
 WHERE (
		--f.FieldName != idc.ColumnName OR
	    f.DBColumnID IS NULL OR
	    f.DBColumnID != idc.ColumnID OR
		f.DataType != idc.DataType OR
		ISNULL(f.MAXLENGTH, -1) != idc.MAXLENGTH OR
		ISNULL(f.PRECISION, -1) != idc.PRECISION OR
		ISNULL(f.Scale, -1) != idc.Scale OR
		f.FieldSortOrder is NULL OR
		f.FieldSortOrder != idc.FieldSortOrder
	    )

/*========================================================================
Update LastSeenDT for DataEntity
========================================================================*/
UPDATE f
   SET f.LastSeenDT = GETDATE(),
	 --Set the UpdatedDT only if it was inactive and now we're making it active
	 f.UpdatedDT = CASE WHEN f.IsActive = 0 THEN GETDATE() ELSE f.UpdatedDT END,
	 f.IsActive = 1
  FROM [DC].Field f
	   INNER JOIN [DC].DataEntity de ON
				  de.DataEntityID = f.DataEntityID
	   INNER JOIN DC.[Schema]  s ON
				  s.SchemaID = de.SchemaID
	   INNER JOIN DC.[Database]  d ON
				  d.DatabaseID = s.DatabaseID
	   INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
				  idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
				  idc.DatabaseName = d.DatabaseName AND
				  idc.SchemaName = s.SchemaName AND
				  idc.DataEntityName = de.DataEntityName AND
				  idc.ColumnName = f.FieldName

/*========================================================================
********************************************************
Insert new Field/s
********************************************************
This has been tested : Don not delete entries
========================================================================*/
INSERT INTO [DC].[Field]
           ([FieldName]
           ,[DataType]
           ,[MaxLength]
           ,[Precision]
           ,[Scale]
           ,[IsPrimaryKey]
           ,[IsForeignKey]
           ,[DefaultValue]
           ,[SystemGenerated]
           ,[DataEntityID]
           ,[DBColumnID]
		   ,CreatedDT
		   ,DataEntitySize
		   ,DatabaseSize
		   ,FieldSortOrder
		   ,LastSeenDT
		   ,IsActive)
SELECT idc.ColumnName,
	   idc.DataType,
	   idc.MaxLength,
	   idc.Precision,
	   idc.Scale,
	   idc.IsPrimaryKey,
	   idc.IsForeignKey,
	   idc.DefaultValue,
	   idc.IsSystemGenerated,
	   de.DataEntityID,
	   idc.ColumnID,
	   GETDATE(),
	   idc.DataEntitySize, 
	   idc.DatabaseSize ,
	   idc.FieldSortOrder,
	   GETDATE(),
	   1
FROM [INTEGRATION].[ingress_DataCatalog] idc
	 INNER JOIN [DC].[Database]  d ON
				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
				d.DatabaseName = idc.DatabaseName
	 INNER JOIN DC.[Schema] s ON
				s.DatabaseID = d.DatabaseID AND
			    s.SchemaName = idc.SchemaName
	 INNER JOIN DC.DataEntity de ON
				de.SchemaID = s.SchemaID AND
				de.DataEntityName = idc.DataEntityName
WHERE NOT EXISTS
			(SELECT 1
			 FROM [DC].[Field] f
			 WHERE f.FieldName = idc.ColumnName AND
				   f.DataEntityID = de.DataEntityID
		     ) AND
idc.ColumnID IS NOT NULL --Empty databases in ingress table
					
/*========================================================================
--insert new fieldtypefield for PK's
========================================================================*/

--Redundant table - TODO Remove
--INSERT INTO DC.FieldTypeField
--SELECT f.fieldid,
--	   1,
--	   getdate(),
--	   null,
--	   1
--FROM [INTEGRATION].[ingress_DataCatalog] idc
--	 INNER JOIN DC.[Database] d ON
--				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
--				d.DBDatabaseID = idc.DatabaseID
--	 INNER JOIN DC.[Schema] s ON
--				s.DBSchemaID = idc.SchemaID AND
--				s.DatabaseID = d.DatabaseID
--	 INNER JOIN DC.DataEntity de ON
--				de.DBObjectID = idc.DataEntityID AND
--				de.SchemaID = s.SchemaID
--	 INNER JOIN DC.Field f on
--				f.DataEntityID = de.DataEntityID
--	 INNER JOIN dc.FieldTypeField ftf on
--				ftf.FieldID = f.FieldID
--	 INNER JOIN dc.fieldtype ft ON
--				ft.fieldtypeid = ftf.FieldTypeID
--WHERE not exists (SELECT 1
--				  FROM  dc.FieldTypeField ftf1
--				  WHERE ftf1.FieldID = f.FieldId AND
--						ftf1.FieldTypeID = 1
--				  ) AND
--idc.IsPrimaryKey = 1

--Insert new fieldtypefield for FK's
--Insert into DC.FieldTypeField
--select f.fieldid,
--	   2,
--	   getdate(),
--	   null,
--	   1
--FROM [INTEGRATION].[ingress_DataCatalog] idc
--	 INNER JOIN DC.[Database] d ON
--				d.DatabaseInstanceID = idc.DCDatabaseInstanceID AND
--				d.DBDatabaseID = idc.DatabaseID
--	 INNER JOIN DC.[Schema] s ON
--				s.DBSchemaID = idc.SchemaID AND
--				s.DatabaseID = d.DatabaseID
--	 INNER JOIN DC.DataEntity de ON
--				de.DBObjectID = idc.DataEntityID AND
--				de.SchemaID = s.SchemaID
--	 INNER JOIN DC.Field f on
--				f.DataEntityID = de.DataEntityID
--	 INNER JOIN dc.FieldTypeField ftf on
--				ftf.FieldID = f.FieldID
--	 INNER JOIN dc.fieldtype ft ON
--				ft.fieldtypeid = ftf.FieldTypeID
--WHERE not exists (SELECT 1
--				  FROM  dc.FieldTypeField ftf1
--				  WHERE	ftf1.FieldID = f.FieldId AND
--						ftf1.FieldTypeID = 2
--				  ) AND
--idc.IsForeignKey = 1





			




			


--update new fieldtypefield

--TODO: Update Table Size in DC as at current value

--update dc.DataEntity 
--	set		Size = idc.DataEntitySize,
--			ModifiedDT = GETDATE()
--	from    [DC].[DataEntity] de
--			INNER JOIN DC.[Schema]  s ON
--				s.SchemaID = de.SchemaID
--			INNER JOIN DC.[Database]  d ON
--				d.DatabaseID = s.DatabaseID
--			INNER JOIN [INTEGRATION].[ingress_DataCatalog] idc ON
--				idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--				idc.DatabaseID = d.DBDatabaseID AND
--				idc.SchemaID = s.DBSchemaID AND
--				idc.DataEntityName = de.DataEntityName

--			where de.Size = idc.DataEntitySize

--TODO: Update Database Size in DC as at current value
--UPDATE dc.[Database] 
--  SET	Size = idc.[DatabaseSize],
--		ModifiedDT = GETDATE()
--  FROM DC.[Database]  d
--	   INNER JOIN (SELECT DISTINCT DCDatabaseInstanceID, DatabaseID, DatabaseSize FROM [INTEGRATION].[ingress_DataCatalog]) idc ON
--			idc.DCDatabaseInstanceID = d.DatabaseInstanceID AND
--			idc.DatabaseID = d.DBDatabaseID
--	where d.size != idc.[DatabaseSize]
     
--TODO: Update History tracking of table and database table

--insert into dc.HistoryTracking_Size
--(	 [HistoryDT]
--	,[ObjectID]
--	,[ObjectTypeID]
--	,[Size_MB])

--(select
--getdate() as HistoryDT
--,de.DBObjectID as ObjectID
--,3 as ObjectTypeID
--,de.Size as Size_MB
--from    INTEGRATION.ingress_DataCatalog dci
--    inner join DC.DatabaseInstance dbi 
--        on dci.DCDatabaseInstanceID = dbi.[DatabaseInstanceID]
--    inner join DC.[Database]  db
--        on db.DatabaseID = dci.DatabaseID
--        and db.DatabaseID = dci.DatabaseID
--    inner join DC.[Schema]  sc 
--		on sc.DatabaseID = db.DatabaseID
--    inner join DC.DataEntity de 
--		on de.SchemaID = sc.SchemaID
--        and de.DBObjectID = dci.DataEntityID

--)
--union all

--(select
--getdate() as HistoryDT
--,db.DBDatabaseID as ObjectID
--,1 as ObjectTypeID
--,db.Size as Size_MB
--from    INTEGRATION.ingress_DataCatalog dci
--    inner join DC.DatabaseInstance dbi 
--        on dci.DCDatabaseInstanceID = dbi.[DatabaseInstanceID]
--    inner join DC.[Database]  db
--        on db.DatabaseID = dci.DatabaseID
--        and db.DatabaseID = dci.DatabaseID
--    inner join DC.[Schema]  sc 
--		on sc.DatabaseID = db.DatabaseID
--    inner join DC.DataEntity de 
--		on de.SchemaID = sc.SchemaID
--        and de.DBObjectID = dci.DataEntityID

--)
GO
/****** Object:  StoredProcedure [INTEGRATION].[sp_Truncate_Before_Populate]    Script Date: 11/17/2019 14:32:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[INTEGRATION].[sp_Truncate_Before_Populate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [INTEGRATION].[sp_Truncate_Before_Populate] AS' 
END
GO
ALTER PROCEDURE [INTEGRATION].[sp_Truncate_Before_Populate]
AS
BEGIN

	TRUNCATE TABLE INTERGRATION.ingress_DataCatalog

END
GO
ALTER DATABASE [SCHEMA_COMPARE] SET  READ_WRITE 
GO
