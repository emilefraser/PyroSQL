USE [MetricsVault]
GO

/****** Object:  Table [dbo].[Ensamble_Element]    Script Date: 2020/05/24 6:26:15 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Ensamble_ElementType](
	[ElementTypeID] [smallint] IDENTITY(1,1) NOT NULL,
	[ElementTypeCode] [varchar](30) NOT NULL,
	[ElementTypeName] [varchar](100) NOT NULL,
	[CreatedDT] DATETIME2(7) NOT NULL DEFAULT GETDATE(),
	[UpdatedDT] DATETIME2(7) NULL,
	[IsActive] BIT NOT NULL DEFAULT 1
) ON [PRIMARY]
GO

INSERT INTO [dbo].[Ensamble_ElementType]([ElementTypeCode],  [ElementTypeName])
VALUES 
	--('HUB', 'Hub'),
	--('LINK', 'Link'),
	--('SAT', 'Satellite'),
	--('REF', 'Reference Hub'),
	--('REFSAT', 'Reference Satellite'),
	--('SAL', 'Same-as Link'),
	--('HLINK', 'Hierarchical Link'),
	--('BRIDGE', 'Bridge'),
	--('PIT', 'Point-in-time Table'),
	--('STATSAT', 'Status Tracking Satellite'),
	('ODSTABLE', 'ODS Table'),
	('ODSDV', 'ODS DataVault View'),
	('SRC', 'Source Table'),
	('SRCVW', 'Source View')


