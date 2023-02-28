


CREATE PROC [Import].[usp_Dimension_Purchase_Order_Properties_Merge]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

BEGIN TRY

	  WITH src AS
	  (
	  SELECT DISTINCT
  		   [Purchase_Order_Header_Status] = CASE p.[PURCHASEORDERSTATUS] WHEN 1 THEN 'Open' WHEN 2 THEN 'Received' WHEN 3 THEN 'Invoiced' WHEN 4 THEN 'Canceled' END 
		  ,[Purchase_Order_Header_Delivery_Mode_ID] = CAST(CASE NULLIF([DELIVERYMODEID],'')
															WHEN 'STANDARD' Then 'Standard Ground'
															WHEN '2Day' THEN '2-Day Air'
															WHEN '' THEN NULL
															WHEN 'OVERNT' THEN 'FedEx Overnight'
															WHEN 'Pickup' THEN 'Pickup'
															WHEN 'AIR' THEN 'Air'
															WHEN 'ATHB' THEN 'Thailand Bangkok Air'
															WHEN 'APEL' THEN 'Peru Lima Ocean'
															WHEN 'OINC' THEN 'India Chennai Ocean'
															WHEN 'OVNH' THEN 'Vietnam Ho Chi Minh Ocean'
															WHEN 'TUSI' THEN 'US Indiana Truck'
															WHEN 'ACNX' THEN 'India Chennai Air'
															WHEN 'OHKH' THEN 'Hong Kong Ocean'
															WHEN 'OCNS' THEN 'China Shanghai Ocean'
															WHEN 'OCNN' THEN 'China Ningbo Ocean'
															WHEN 'OCNX' THEN 'China Xiamin Ocean'
															WHEN 'OCNQ' THEN 'China QingDao Ocean'
															WHEN 'OINM' THEN 'India Mudra Ocean'
															WHEN 'OTHL' THEN 'Thailand Laem Chabang Oce Thaian'
															WHEN 'OCNQ' THEN 'China QingDao Ocean'
															WHEN 'TUSL' THEN 'US Lakeville Truck'
															WHEN 'OEGA' THEN 'Egypt Alexandria Ocean'
															WHEN 'AIDJ' THEN 'Indonesia Jakarta Air'
															WHEN 'AGTL' THEN 'Guatemala La Aurora Air'
															WHEN 'AHKH' THEN 'Hong Kong Hong Kong Air'
															WHEN 'OIDJ' THEN 'Indonesia Jakarta Ocean'
															WHEN 'AEGA' THEN 'Egypt Alexandria Air'
															WHEN 'OGTL' THEN 'Guatemala La Aurora OCN'
															WHEN 'AVNH' THEN 'Vietnam Ho Chi Minh Air'
															WHEN 'AINC' THEN 'India Chennai Air'
															WHEN 'AIND' THEN 'India Delhi Air'
															WHEN 'ACNN' THEN 'China Ningbo Air'
															WHEN 'ACNQ' THEN 'China QingDao Air'
															WHEN 'ACNS' THEN 'Air China Shanghai'
												ELSE NULLIF([DELIVERYMODEID],'') END AS VARCHAR(50))
		  ,[Purchase_Order_Header_Delivery_Terms_ID] = CASE  NULLIF([DELIVERYTERMSID],'')
															WHEN 'CPTP' THEN 'FOB Vendor, Air ship mode, Vendor to pay sea / air difference'
															WHEN 'DDP' THEN 'Delivery Duty Paid'
															WHEN 'DDPC' THEN 'DDP Vendor, CWD paying freight'
															WHEN 'DDPP' THEN 'DDP Lakeville, Vendor paying Freight'
															WHEN 'FCAC' THEN 'FOB Vendor, CWD to pay air cost'
															WHEN 'FCAP' THEN 'FOB Vendor, Vendor to pay 100% air cost'
															WHEN 'FOB' THEN 'Free on Board'
															WHEN 'FOBC' THEN 'FOB Vendor, CWD to pay vessel cost'
															WHEN 'FOBO' THEN 'FOB Non Apparel Vendor, Outsource Shipping'
															WHEN 'PPD' THEN 'PrePaid'
															WHEN 'Standard' THEN 'Standard Dlv Terms'
														ELSE NULLIF([DELIVERYTERMSID],'') END

		  ,[Purchase_Order_Header_Document_Approval_Status] = NULLIF([DOCUMENTAPPROVALSTATUS],'')
		  ,[Purchase_Order_Header_Buyer_Group_ID] =  ISNULL(NULLIF(bg.[GROUPDESCRIPTION],''),NULLIF([BUYERGROUPID],''))
		  ,[Purchase_Order_Header_Payment_Terms_Name] = ISNULL(pt.Payment_Term_Name,NULLIF([PAYMENTTERMSNAME],''))
		  ,[Purchase_Order_Header_Vendor_Payment_Method_Name] = CASE [VENDORPAYMENTMETHODNAME]
																	WHEN 'CWD-CHK-WF' THEN 'Direct Bank of America Check'
																	WHEN 'CWD-WIR-WF' THEN 'Bank of America Wire'
																	WHEN 'RTL-CHK-WF' THEN 'Retail Wells Fargo Check'
																	WHEN 'RTL-WIR-WF' THEN 'Retail Wells Fargo Wire'
																ELSE NULLIF([VENDORPAYMENTMETHODNAME],'') END
		,[Purchase_Order_Line_Status] = CASE pl.[PURCHASEORDERLINESTATUS] WHEN 1 THEN 'Open' WHEN 2 THEN 'Received' WHEN 3 THEN 'Invoiced' WHEN 4 THEN 'Canceled' END
		,[Purchase_Order_Header_Season_CD] = CAST(NULLIF(REASONCODE,'') AS VARCHAR(10))
		,[Purchase_Order_Header_Season] = s.Purchase_Order_Header_Season
		,[is_Removed_From_Source] = CAST(0 AS BIT)
		,[is_Excluded] = CAST(0 AS BIT)
		,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Count] = CAST(1 AS TINYINT)
	FROM [AX_PRODUCTION].[dbo].[PurchPurchaseOrderHeaderV2Staging]   p
	INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineV2Staging]   pl ON p.PURCHASEORDERNUMBER = pl.PURCHASEORDERNUMBER
	LEFT JOIN [AX_PRODUCTION].[dbo].[InventBuyerGroupStaging] bg ON p.BUYERGROUPID = bg.[GROUPID]
	LEFT JOIN [CWC_DW].[Reference].[Payment_Terms]   pt ON pt.[Payment_Term_ID] = p.PAYMENTTERMSNAME
	LEFT JOIN [CWC_DW].[Reference].[Purchace_Order_Seasons]   s ON p.REASONCODE = s.Purchase_Order_Header_Season_CD
	) --SELECT * FROM src
	,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Purchase_Order_Properties]  )

	MERGE INTO tgt USING src
		ON     ISNULL(tgt.[Purchase_Order_Header_Status],'') = ISNULL(src.[Purchase_Order_Header_Status],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Delivery_Mode_ID],'') = ISNULL(src.[Purchase_Order_Header_Delivery_Mode_ID],'') 
		   AND ISNULL(tgt.[Purchase_Order_Header_Delivery_Terms_ID],'') = ISNULL(src.[Purchase_Order_Header_Delivery_Terms_ID],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Document_Approval_Status],'') = ISNULL(src.[Purchase_Order_Header_Document_Approval_Status],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Buyer_Group_ID],'') = ISNULL(src.[Purchase_Order_Header_Buyer_Group_ID],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Payment_Terms_Name],'') = ISNULL(src.[Purchase_Order_Header_Payment_Terms_Name],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Vendor_Payment_Method_Name],'') = ISNULL(src.[Purchase_Order_Header_Vendor_Payment_Method_Name],'')
		   AND ISNULL(tgt.[Purchase_Order_Line_Status],'') = ISNULL(src.[Purchase_Order_Line_Status],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Season_CD],'') = ISNULL(src.[Purchase_Order_Header_Season_CD],'')
		   AND ISNULL(tgt.[Purchase_Order_Header_Season],'') = ISNULL(src.[Purchase_Order_Header_Season],'')
	WHEN NOT MATCHED THEN
		INSERT([Purchase_Order_Header_Status],[Purchase_Order_Header_Delivery_Mode_ID],[Purchase_Order_Header_Delivery_Terms_ID],[Purchase_Order_Header_Document_Approval_Status]
			  ,[Purchase_Order_Header_Buyer_Group_ID],[Purchase_Order_Header_Payment_Terms_Name],[Purchase_Order_Header_Vendor_Payment_Method_Name],[Purchase_Order_Line_Status]
			  ,[Purchase_Order_Header_Season_CD],[Purchase_Order_Header_Season],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
		VALUES(src.[Purchase_Order_Header_Status],src.[Purchase_Order_Header_Delivery_Mode_ID],src.[Purchase_Order_Header_Delivery_Terms_ID],src.[Purchase_Order_Header_Document_Approval_Status]
			  ,src.[Purchase_Order_Header_Buyer_Group_ID],src.[Purchase_Order_Header_Payment_Terms_Name],src.[Purchase_Order_Header_Vendor_Payment_Method_Name],src.[Purchase_Order_Line_Status]
			  ,src.[Purchase_Order_Header_Season_CD],src.[Purchase_Order_Header_Season],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
	WHEN MATCHED AND tgt.[is_Removed_From_Source] = 1 THEN UPDATE SET
			 tgt.[is_Removed_From_Source] = 0
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
