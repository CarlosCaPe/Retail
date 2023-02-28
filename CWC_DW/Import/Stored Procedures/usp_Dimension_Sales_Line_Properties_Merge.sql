




CREATE PROC [Import].[usp_Dimension_Sales_Line_Properties_Merge] AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	;WITH src AS
	(
	SELECT DISTINCT
	[Sales_Line_Status] = CASE sl.[SALESORDERLINESTATUS] 
												WHEN 0 THEN 'None'
												WHEN 1 THEN 'Backorder'
												WHEN 2 THEN 'Delivered'
												WHEN 3 THEN 'Invoiced'
												WHEN 4 THEN 'Canceled'
										  END
				  ,[Sales_Line_Type] = CASE sl.SALESTYPE WHEN 2 THEN 'Subscription'
													  WHEN 3 THEN 'Sale'
													  WHEN 4 THEN 'Return'
									END
				  ,[Sales_Line_Tax_Group] =	CASE sl.[SALESTAXGROUPCODE]
											WHEN 'STALL' THEN 'ST All Tax'
											WHEN '' THEN NULL
											WHEN 'EX' THEN 'Exempt from Sales Tax'
											WHEN 'IA' THEN 'Iowa State Sales Tax'
											WHEN 'IL' THEN 'Illinoise State Sales Tax'
											WHEN 'IN' THEN 'Indiana State Sales Tax'
											WHEN 'LKS' THEN 'Leawood, KS'
											WHEN 'MA' THEN 'Massachusetts Sales Tax'
											WHEN 'MI' THEN 'Michigan State Sales Tax'
											WHEN 'NM' THEN 'New Mexico Sales Tax'
											WHEN 'OH' THEN 'Ohio State Sales Tax'
											WHEN 'OK Tulsa' THEN 'Tulsa OK Tax Group'
											WHEN 'OKC' THEN 'Oklahoma City, OK'
											WHEN 'TX' THEN 'Texas State Sales Tax'
										END
				  ,[Sales_Line_Return_Deposition_Action] = CASE sl.[RETURNDISPOSITIONCODEID]
													WHEN '01' THEN 'Credit only'
													WHEN '02' THEN 'Credit only'
													WHEN '03' THEN 'Credit only'
													WHEN '04' THEN 'Credit only'
													WHEN '05' THEN 'Credit only'
													WHEN '06' THEN 'Credit only'
													WHEN '07' THEN 'Credit only'
													WHEN '08' THEN 'Credit only'
													WHEN '09' THEN 'Credit only'
													WHEN '10' THEN 'Credit only'
													WHEN '11' THEN 'Credit only'
													WHEN '12' THEN 'Credit only'
													WHEN 'CR' THEN 'Credit'
													WHEN 'CRO' THEN 'Credit only'
													WHEN 'RAS' THEN 'Replace and scrap'
													WHEN 'RCR' THEN 'Replace and credit'
													WHEN 'RTC' THEN 'Return to customer'
													WHEN 'SCR' THEN 'Scrap'
												END
				  ,[Sales_Line_Unit] = CASE sl.[SALESUNITSYMBOL] WHEN 'ea' THEN 'Each'
											 WHEN '' THEN NULL
											 WHEN 'dz' THEN 'Dozen'
										END
				  ,[Sales_Line_Return_Deposition_Description] = CASE sl.[RETURNDISPOSITIONCODEID]
														WHEN '01' THEN 'Store Return'
														WHEN '02' THEN 'Missing item from order'
														WHEN '03' THEN 'Order not received'
														WHEN '04' THEN 'Order discount adjustment'
														WHEN '05' THEN 'Wrong item received'
														WHEN '06' THEN 'Not my order'
														WHEN '07' THEN 'Refunded outbound shipping fee'
														WHEN '08' THEN 'Refunded return (6.95) shipping fee'
														WHEN '09' THEN 'Price adjustment'
														WHEN '10' THEN 'Defective item'
														WHEN '11' THEN 'Not posted return'
														WHEN '12' THEN 'General appeasement'
														WHEN 'CR' THEN 'Credit'
														WHEN 'CRO' THEN 'Credit only'
														WHEN 'RAS' THEN 'Replace and scrap'
														WHEN 'RCR' THEN 'Replace and credit'
														WHEN 'RTC' THEN 'Return to customer'
														WHEN 'SCR' THEN 'Scrap'
													END
				
					,[is_Removed_From_Source] = CAST(0 AS BIT)
					,[is_Excluded] = CAST(0 AS BIT)
					,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
					,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
					,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] s  
	INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[SALESORDERNUMBER] = sl.[SALESORDERNUMBER]

	UNION

	SELECT DISTINCT

	Sales_Line_Status = CASE WHEN s.is_Removed_From_Source = 1 THEN 'Canceled' ELSE slp.Sales_Line_Status END
	,slp.Sales_Line_Type
	,slp.Sales_Line_Tax_Group
	,slp.[Sales_Line_Return_Deposition_Action]
	,slp.Sales_Line_Unit
	,slp.[Sales_Line_Return_Deposition_Description]
	,[is_Removed_From_Source] = CAST(0 AS BIT)
	,[is_Excluded] = CAST(0 AS BIT)
	,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	FROM [CWC_DW].[Fact].[Sales] s
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
	LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp2 ON 

	CASE WHEN s.is_Removed_From_Source = 1 THEN 'Canceled' ELSE slp.Sales_Line_Status END = ISNULL(slp2.Sales_Line_Status,'')
	AND ISNULL(slp.Sales_Line_Unit,'') = ISNULL(slp2.Sales_Line_Unit,'')
	AND ISNULL(slp.Sales_Line_Type,'') = ISNULL(slp2.Sales_Line_Type,'')
	AND ISNULL(slp.Sales_Line_Tax_Group,'') = ISNULL(slp2.Sales_Line_Tax_Group,'')
	AND ISNULL(slp.Sales_Line_Status,'') = ISNULL(slp2.Sales_Line_Status,'')
	AND ISNULL(slp.Sales_Line_Return_Deposition_Description,'') = ISNULL(slp2.Sales_Line_Return_Deposition_Description,'')
	AND ISNULL(slp.Sales_Line_Return_Deposition_Action,'') = ISNULL(slp2.Sales_Line_Return_Deposition_Action,'')

	WHERE s.is_Removed_From_Source = 1 AND slp2.Sales_Line_Property_Key IS NULL

	) 
	,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Sales_Line_Properties])

	MERGE INTO tgt USING src
		ON ISNULL(tgt.[Sales_Line_Status],'') = ISNULL(src.[Sales_Line_Status],'') AND
		   ISNULL(tgt.[Sales_Line_Type],'') = ISNULL(src.[Sales_Line_Type],'') AND
		   ISNULL(tgt.[Sales_Line_Tax_Group],'') = ISNULL(src.[Sales_Line_Tax_Group],'') AND
		   ISNULL(tgt.[Sales_Line_Unit],'') = ISNULL(src.[Sales_Line_Unit],'') AND
		   ISNULL(tgt.[Sales_Line_Return_Deposition_Action],'') = ISNULL(src.[Sales_Line_Return_Deposition_Action],'') AND
		   ISNULL(tgt.[Sales_Line_Return_Deposition_Description],'') = ISNULL(src.[Sales_Line_Return_Deposition_Description],'')
		 WHEN NOT MATCHED THEN 
			INSERT([Sales_Line_Status],[Sales_Line_Type],[Sales_Line_Tax_Group],[Sales_Line_Unit],[Sales_Line_Return_Deposition_Action],[Sales_Line_Return_Deposition_Description]
				  ,[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Sales_Line_Status],src.[Sales_Line_Type],src.[Sales_Line_Tax_Group],src.[Sales_Line_Unit],src.[Sales_Line_Return_Deposition_Action],src.[Sales_Line_Return_Deposition_Description]
				  ,src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		 WHEN MATCHED AND tgt.[is_Removed_From_Source]  <> src.[is_Removed_From_Source]  
		 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = src.[is_Removed_From_Source]
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		 WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 1
			,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH
