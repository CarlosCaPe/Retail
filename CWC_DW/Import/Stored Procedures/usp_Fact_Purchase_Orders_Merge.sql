

CREATE PROC [Import].[usp_Fact_Purchase_Orders_Merge] AS

WITH Purchase_Order_Header AS
(
SELECT --TOP (1000) 
       [Purchase_Order_Number] = [PURCHASEORDERNUMBER]
      ,[Delivery_Location_Key] = l.[Location_Key]
      ,v.[Vendor_Key]
	  ,[Purchase_Order_Name] = [PURCHASEORDERNAME]
      ,[Purchase_Order_Header_Accounting_Date] =CAST([ACCOUNTINGDATE] AS DATE)--Create
      ,[Purchase_Order_Header_Confirmed_Delivery_Date] = CAST(NULLIF([CONFIRMEDDELIVERYDATE],'1900-01-01 00:00:00.000') AS DATE) --Confirmed Del
      ,[Purchase_Order_Header_Requested_Delivery_Date] = CAST(NULLIF([REQUESTEDDELIVERYDATE],'1900-01-01 00:00:00.000') AS DATE)
	  ,[Purchase_Order_Status] = CASE p.[PURCHASEORDERSTATUS] WHEN 1 THEN 'Open' WHEN 2 THEN 'Received' WHEN 3 THEN 'Invoiced' WHEN 4 THEN 'Canceled' END 
   --   ,REASONCOMMENT
	  --,REASONCODE
	  ,[Delivery_Mode_ID] = CAST(CASE NULLIF([DELIVERYMODEID],'')
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
      ,[Delivery_Terms_ID] = CASE  NULLIF([DELIVERYTERMSID],'')
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

      ,[Document_Approval_Status] = [DOCUMENTAPPROVALSTATUS]
      ,[Buyer_Group_ID] =  ISNULL(NULLIF(bg.[GROUPDESCRIPTION],''),NULLIF([BUYERGROUPID],''))
      ,[Payment_Terms_Name] = ISNULL(pt.Payment_Term_Name,NULLIF([PAYMENTTERMSNAME],''))
      --,[PAYMENTSCHEDULENAME]
      ,[Vendor_Payment_Method_Name] = CASE [VENDORPAYMENTMETHODNAME]
											WHEN 'CWD-CHK-WF' THEN 'Direct Bank of America Check'
											WHEN 'CWD-WIR-WF' THEN 'Bank of America Wire'
											WHEN 'RTL-CHK-WF' THEN 'Retail Wells Fargo Check'
											WHEN 'RTL-WIR-WF' THEN 'Retail Wells Fargo Wire'
										ELSE [VENDORPAYMENTMETHODNAME] END
	  ,[Purchase_Order_Header_Season_CD] = CAST(NULLIF(REASONCODE,'') AS VARCHAR(10))
	  ,[Purchase_Order_Header_Season] = CAST(NULLIF(REASONCOMMENT,'') AS VARCHAR(25))
  FROM [AX_PRODUCTION].[dbo].[PurchPurchaseOrderHeaderV2Staging] (NOLOCK) p
  LEFT JOIN [CWC_DW].[Reference].[Payment_Terms] (NOLOCK) pt ON pt.[Payment_Term_ID] = p.PAYMENTTERMSNAME
  LEFT JOIN [AX_PRODUCTION].[dbo].[InventBuyerGroupStaging] (NOLOCK) bg ON p.BUYERGROUPID = bg.GROUPID
  LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON 
											    ISNULL(l.[Street],'') = ISNULL(CAST(NULLIF(p.[DELIVERYADDRESSSTREET],'') AS VARCHAR(200)),'')
											AND ISNULL(l.[City],'') = ISNULL(CAST(NULLIF(p.[DELIVERYADDRESSCITY],'') AS VARCHAR(100)),'')
										    AND ISNULL(l.[State],'') = ISNULL(CAST(NULLIF(p.[DELIVERYADDRESSSTATEID],'') AS VARCHAR(5)),'')
										    AND ISNULL(l.[Zip_Code],'') = ISNULL(CAST(NULLIF(p.[DELIVERYADDRESSZIPCODE],'') AS VARCHAR(100)),'')
										    AND ISNULL(l.[Country],'') = ISNULL(CAST(NULLIF(p.[DELIVERYADDRESSCOUNTRYREGIONID],'') AS VARCHAR(10)),'')
  LEFT JOIN [CWC_DW].[Dimension].[Vendors] (NOLOCK) v ON v.[Vendor_Account_Number] = p.[ORDERVENDORACCOUNTNUMBER]
  --ORDER BY ACCOUNTINGDATE DESC
  ) --SELECT DISTINCT REASONCOMMENT,REASONCODE FROM Purchase_Order_Header
  ,src AS
  (
  SELECT 
	   [Purchase_Order_Number]
	  ,[Purchase_Order_Line_Number] = pl.[LINENUMBER]
	  ,[Invent_Trans_ID] = pl.[ITSINVENTTRANSID]
      ,[Delivery_Location_Key]
      ,[Vendor_Key]
	  ,[Purchase_Order_Property_Key]
	  ,[Product_Key]
	  ,[Purchase_Order_Name]
	  ,[Purchase_Line_Description] = pl.[LINEDESCRIPTION]
      ,[Purchase_Order_Header_Accounting_Date]
	  ,[Purchase_Line_Confirmed_Delivery_Date] = CAST(NULLIF(pl.[CONFIRMEDDELIVERYDATE],'1900-01-01 00:00:00.000') AS DATE)
      ,[Purchase_Line_Requested_Delivery_Date] = CAST(NULLIF(pl.[REQUESTEDDELIVERYDATE],'1900-01-01 00:00:00.000') AS DATE)
	  ,[Purchase_Line_Confirmed_Shipping_Date] = CAST(NULLIF(pl.[CONFIRMEDSHIPPINGDATE],'1900-01-01 00:00:00.000') AS DATE)
      ,[Purchase_Line_Requested_Shipping_Date] = CAST(NULLIF(pl.[REQUESTEDSHIPPINGDATE],'1900-01-01 00:00:00.000') AS DATE)
      ,[Purchase_Line_Amount] = pl.[LINEAMOUNT]
	  ,[Purchase_Line_Purchase_Price] = pl.[PURCHASEPRICE]
      ,[Purchase_Line_Discount_Amount] = pl.[LINEDISCOUNTAMOUNT]  
      ,[Purchase_Line_Price_Quantity] = CAST(pl.[PURCHASEPRICEQUANTITY] AS SMALLINT)    
      ,[Purchase_Line_Ordered_Quantity] = CAST(pl.[ORDEREDPURCHASEQUANTITY] AS SMALLINT)--,
	  ,[Received_Quantity] = 0
	  ,[Vendor_Packing_Slip_Count] = 0
	  ,[Barcode] = NULLIF(pl.[BARCODE],'')
	  ,[is_Removed_From_Source] = CAST(0 AS BIT)
	  ,[is_Excluded] = CAST(0 AS BIT)
	  ,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Count] = CAST(1 AS TINYINT)
FROM [Purchase_Order_Header] p
INNER JOIN [AX_PRODUCTION].[dbo].[PurchPurchaseOrderLineV2Staging] (NOLOCK) pl ON p.[Purchase_Order_Number] = pl.PURCHASEORDERNUMBER
LEFT JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) prod ON ISNULL(pl.[ITEMNUMBER],'') = ISNULL(prod.Item_ID,'') 
													   AND ISNULL(pl.PRODUCTCOLORID,'') = ISNULL(prod.Color_ID,'') 
													   AND ISNULL(pl.PRODUCTSIZEID,'') = ISNULL(prod.Size_ID,'')
LEFT JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop ON ISNULL(p.[Purchase_Order_Status],'') = ISNULL(pop.[Purchase_Order_Header_Status],'')
																			   AND ISNULL(p.[Delivery_Mode_ID],'') = ISNULL(pop.[Purchase_Order_Header_Delivery_Mode_ID],'') 
																			   AND ISNULL(p.[Delivery_Terms_ID],'') = ISNULL(pop.[Purchase_Order_Header_Delivery_Terms_ID],'')
																			   AND ISNULL(p.[Document_Approval_Status],'') = ISNULL(pop.[Purchase_Order_Header_Document_Approval_Status],'')
																			   AND ISNULL(p.[Buyer_Group_ID],'') = ISNULL(pop.[Purchase_Order_Header_Buyer_Group_ID],'')
																			   AND ISNULL(p.[Payment_Terms_Name],'') = ISNULL(pop.[Purchase_Order_Header_Payment_Terms_Name],'')
																			   AND ISNULL(p.[Vendor_Payment_Method_Name],'') = ISNULL(pop.[Purchase_Order_Header_Vendor_Payment_Method_Name],'')
																			   AND CASE pl.[PURCHASEORDERLINESTATUS] WHEN 1 THEN 'Open' WHEN 2 THEN 'Received' WHEN 3 THEN 'Invoiced' WHEN 4 THEN 'Canceled' END = ISNULL(pop.[Purchase_Order_Line_Status],'')
																			   AND ISNULL(p.[Purchase_Order_Header_Season_CD],'') = ISNULL(pop.[Purchase_Order_Header_Season_CD],'')

) --SELECT TOP 1000 * FROM src WHERE Purchase_Order_Property_Key IS NULL
,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.[Purchase_Order_Number] = src.[Purchase_Order_Number]
   AND tgt.[Purchase_Order_Line_Number] = src.[Purchase_Order_Line_Number]
	WHEN NOT MATCHED THEN
		INSERT([Purchase_Order_Number],[Purchase_Order_Line_Number],[Invent_Trans_ID],[Delivery_Location_Key],[Vendor_Key],[Purchase_Order_Property_Key],[Product_Key],[Purchase_Order_Name],[Purchase_Line_Description]
			  ,[Purchase_Order_Header_Accounting_Date],[Purchase_Line_Confirmed_Delivery_Date],[Purchase_Line_Requested_Delivery_Date],[Purchase_Line_Confirmed_Shipping_Date],[Purchase_Line_Requested_Shipping_Date]
			  ,[Purchase_Line_Amount],[Purchase_Line_Purchase_Price],[Purchase_Line_Discount_Amount],[Purchase_Line_Price_Quantity],[Purchase_Line_Ordered_Quantity],[Received_Quantity],[Vendor_Packing_Slip_Count],[Barcode],[is_Removed_From_Source]
			  ,[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
		VALUES(src.[Purchase_Order_Number],src.[Purchase_Order_Line_Number],src.[Invent_Trans_ID],src.[Delivery_Location_Key],src.[Vendor_Key],src.[Purchase_Order_Property_Key],src.[Product_Key],src.[Purchase_Order_Name],src.[Purchase_Line_Description]
			  ,src.[Purchase_Order_Header_Accounting_Date],src.[Purchase_Line_Confirmed_Delivery_Date],src.[Purchase_Line_Requested_Delivery_Date],src.[Purchase_Line_Confirmed_Shipping_Date],src.[Purchase_Line_Requested_Shipping_Date]
			  ,src.[Purchase_Line_Amount],src.[Purchase_Line_Purchase_Price],src.[Purchase_Line_Discount_Amount],src.[Purchase_Line_Price_Quantity],src.[Purchase_Line_Ordered_Quantity],src.[Received_Quantity],src.[Vendor_Packing_Slip_Count],src.[Barcode],src.[is_Removed_From_Source]
			  ,src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
			   ISNULL(tgt.[Invent_Trans_ID],'') <> ISNULL(src.[Invent_Trans_ID],'')
			OR ISNULL(tgt.[Delivery_Location_Key],'') <> ISNULL(src.[Delivery_Location_Key],'')
			OR ISNULL(tgt.[Vendor_Key],'') <> ISNULL(src.[Vendor_Key],'')
			OR ISNULL(tgt.[Purchase_Order_Property_Key],'') <> ISNULL(src.[Purchase_Order_Property_Key],'')
			OR ISNULL(tgt.[Product_Key],'') <> ISNULL(src.[Product_Key],'')
			OR ISNULL(tgt.[Purchase_Order_Name],'') <> ISNULL(src.[Purchase_Order_Name],'')
			OR ISNULL(tgt.[Purchase_Line_Description],'') <> ISNULL(src.[Purchase_Line_Description],'')
			OR ISNULL(tgt.[Purchase_Order_Header_Accounting_Date],'') <> ISNULL(src.[Purchase_Order_Header_Accounting_Date],'')
			OR ISNULL(tgt.[Purchase_Line_Confirmed_Delivery_Date],'') <> ISNULL(src.[Purchase_Line_Confirmed_Delivery_Date],'')
			OR ISNULL(tgt.[Purchase_Line_Requested_Delivery_Date],'') <> ISNULL(src.[Purchase_Line_Requested_Delivery_Date],'')
			OR ISNULL(tgt.[Purchase_Line_Confirmed_Shipping_Date],'') <> ISNULL(src.[Purchase_Line_Confirmed_Shipping_Date],'')
			OR ISNULL(tgt.[Purchase_Line_Requested_Shipping_Date],'') <> ISNULL(src.[Purchase_Line_Requested_Shipping_Date],'')
			OR ISNULL(tgt.[Purchase_Line_Amount],'') <> ISNULL(src.[Purchase_Line_Amount],'')
			OR ISNULL(tgt.[Purchase_Line_Purchase_Price],'') <> ISNULL(src.[Purchase_Line_Purchase_Price],'')
			OR ISNULL(tgt.[Purchase_Line_Discount_Amount],'') <> ISNULL(src.[Purchase_Line_Discount_Amount],'')
			OR ISNULL(tgt.[Purchase_Line_Price_Quantity],'') <> ISNULL(src.[Purchase_Line_Price_Quantity],'')
			OR ISNULL(tgt.[Purchase_Line_Ordered_Quantity],'') <> ISNULL(src.[Purchase_Line_Ordered_Quantity],'')
			OR ISNULL(tgt.[Barcode],'') <> ISNULL(src.[Barcode],'')
			OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
		THEN UPDATE SET
			 [Invent_Trans_ID] = src.[Invent_Trans_ID]
			,[Delivery_Location_Key] = src.[Delivery_Location_Key]
			,[Vendor_Key] = src.[Vendor_Key]
			,[Purchase_Order_Property_Key] = src.[Purchase_Order_Property_Key]
			,[Product_Key] = src.[Product_Key]
			,[Purchase_Order_Name] = src.[Purchase_Order_Name]
			,[Purchase_Line_Description] = src.[Purchase_Line_Description]
			,[Purchase_Order_Header_Accounting_Date] = src.[Purchase_Order_Header_Accounting_Date]
			,[Purchase_Line_Confirmed_Delivery_Date] = src.[Purchase_Line_Confirmed_Delivery_Date]
			,[Purchase_Line_Requested_Delivery_Date] = src.[Purchase_Line_Requested_Delivery_Date]
			,[Purchase_Line_Confirmed_Shipping_Date] = src.[Purchase_Line_Confirmed_Shipping_Date]
			,[Purchase_Line_Requested_Shipping_Date] = src.[Purchase_Line_Requested_Shipping_Date]
			,[Purchase_Line_Amount] = src.[Purchase_Line_Amount]
			,[Purchase_Line_Purchase_Price] = src.[Purchase_Line_Purchase_Price]
			,[Purchase_Line_Discount_Amount] = src.[Purchase_Line_Discount_Amount]
			,[Purchase_Line_Price_Quantity] = src.[Purchase_Line_Price_Quantity]
			,[Purchase_Line_Ordered_Quantity] = src.[Purchase_Line_Ordered_Quantity]
			,[Barcode] = src.[Barcode]
			,[is_Removed_From_Source] = src.[is_Removed_From_Source]
			,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			  tgt.[is_Removed_From_Source] = 1
			 ,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			 ,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
