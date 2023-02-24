﻿/****** Script for SelectTopNRows command from SSMS  ******/
CREATE PROC [Import].[usp_Dimension_Catalogs_Merge]

AS

WITH src AS
	(
		SELECT
			   [Catalog_Number] = [CATALOGNUMBER]
			  --,[OWNERPARTYNUMBER]
			  ,[Catalog_Name] = [FRIENDLYNAME]
			  ,[Catalog_Description] = NULLIF([DESCRIPTION],'')
			  ,[Catalog_Drop_Date] = CAST([VALIDFROMDATE] AS DATE)
			  ,[is_Removed_From_Source] = CAST(0 AS BIT)
			  ,[is_Excluded] = CAST(0 AS BIT)
			  ,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			  ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			  ,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [AX_PRODUCTION].[dbo].[RetailCatalogStaging] (NOLOCK)
	)
,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Catalogs] (NOLOCK))


MERGE INTO tgt USING src
	ON tgt.[Catalog_Number] = src.[Catalog_Number]
		WHEN NOT MATCHED THEN
			INSERT([Catalog_Number],[Catalog_Name],[Catalog_Description],[Catalog_Drop_Date],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Catalog_Number],src.[Catalog_Name],src.[Catalog_Description],src.[Catalog_Drop_Date],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date]
				  ,src.[ETL_Modified_Date],src.[ETL_Modified_Count])
			WHEN MATCHED AND
				   ISNULL(tgt.[Catalog_Name],'') <> ISNULL(src.[Catalog_Name],'')
				OR ISNULL(tgt.[Catalog_Description],'') <> ISNULL(src.[Catalog_Description],'')
				OR ISNULL(tgt.[Catalog_Drop_Date],'') <> ISNULL(src.[Catalog_Drop_Date],'')
				OR ISNULL(src.[is_Removed_From_Source],'') <> ISNULL(tgt.[is_Removed_From_Source],'')
			THEN UPDATE SET
				[Catalog_Name] = src.[Catalog_Name]
			   ,[Catalog_Description] = src.[Catalog_Description]
			   ,[Catalog_Drop_Date] = src.[Catalog_Drop_Date]
			   ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
			   ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			   ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
			WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
				 tgt.[is_Removed_From_Source] = 1
				,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
				,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);

