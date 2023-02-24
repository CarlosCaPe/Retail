﻿CREATE PROC Import.usp_Marketing_Ship_Confirmation_Carriers_Merge

AS

SET NOCOUNT ON;

WITH src AS
(
SELECT DISTINCT
	 Ship_Via = [SHIPVIA]
	,Ship_Carrier = CASE 
					WHEN LEFT(NULLIF([SHIPVIA],''),3) = 'UPS' THEN 'UPS'
					WHEN LEFT(NULLIF([SHIPVIA],''),4) = 'USPS' THEN 'USPS'
					WHEN LEFT(NULLIF([SHIPVIA],''),3) = 'Fed' THEN 'FedEx'
					WHEN LEFT(NULLIF([SHIPVIA],''),3) = 'DHL' THEN 'DHL'
					ELSE NULLIF([SHIPVIA],'') END
	,[is_Removed_From_Source] = CAST(0 AS BIT)
	,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Count] = CAST(1 AS TINYINT)
--INTO [CWC_DW].[Marketing].[Ship_Confirmation_Carriers]
FROM [Entity_Staging].[dbo].[rsmShipConfirmationStaging] (NOLOCK) ship
WHERE NULLIF([SHIPVIA],'') IS NOT NULL
)
,tgt AS (SELECT * FROM [CWC_DW].[Marketing].[Ship_Confirmation_Carriers] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.Ship_Via = src.Ship_Via
WHEN NOT MATCHED THEN
	INSERT([Ship_Via],[Ship_Carrier],[is_Removed_From_Source],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
	VALUES(src.[Ship_Via],src.[Ship_Carrier],src.[is_Removed_From_Source],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
WHEN MATCHED AND
	tgt.[Ship_Carrier] <> src.[Ship_Carrier]
 OR tgt.[is_Removed_From_Source] <> src.[is_Removed_From_Source]
THEN UPDATE SET
     [Ship_Carrier] = src.[Ship_Carrier]
	,[is_Removed_From_Source] = src.[is_Removed_From_Source] 
	,[ETL_Modified_Date] = src.[ETL_Modified_Date]
	,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
WHEN NOT MATCHED BY SOURCE THEN UPDATE SET
	 tgt.[is_Removed_From_Source] = 1
	,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
