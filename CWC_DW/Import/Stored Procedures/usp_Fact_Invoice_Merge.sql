



CREATE PROC [Import].[usp_Fact_Invoice_Merge] AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY


	;WITH Inv_Mapping AS
	(
	SELECT
		   [Invoice_Number] = ih.[INVOICENUMBER]  
		  ,[Sales_Order_Number] = NULLIF([SALESORDERNUMBER],'')
		  ,[Invent_Trans_ID] = CAST(NULLIF([INVENTTRANSID],'') AS INT)
		  ,[Invoice_Customer_Key] = c.Customer_Key
		  ,[Invoice_Line_Product_Key] = p.Product_Key  
		  ,[Invoice_Customer_Account_Number] = NULLIF([INVOICECUSTOMERACCOUNTNUMBER],'')
		  ,[Invoice_Header_Date] = CAST(ih.[INVOICEDATE] AS DATE)
		  ,[Invoice_Line_Date_Key] = d.Date_Key --Added 4/23/2021 RG
		  ,[Invoice_Line_Date] = CAST(NULLIF(NULLIF(il.[INVOICEDATE],'1900-01-01 00:00:00.000'),'2029-08-27 00:00:00.000') AS DATE)
		  ,[Invoice_Line_Confirmed_Shipping_Date] = CAST(NULLIF(il.[CONFIRMEDSHIPPINGDATE],'1900-01-01 00:00:00.000') AS DATE)
		  ,[Invoice_Line_Sales_Price] = il.[SALESPRICE]
		  ,[Invoice_Line_Quantity] = CAST([INVOICEDQUANTITY] AS SMALLINT)
		  ,[Invoice_Line_Number] = il.[LINECREATIONSEQUENCENUMBER]
		  ,[Invoice_Line_Tax_Amount] = il.[LINETOTALTAXAMOUNT]
		  ,[Invoice_Line_Charge_Amount] = [LINETOTALCHARGEAMOUNT]
		  ,[Invoice_Line_Discount_Amount] = [LINETOTALDISCOUNTAMOUNT]
		  ,[Invoice_Line_Amount] = [LINEAMOUNT]
		  ,[Product_Name] = NULLIF([PRODUCTNAME],'')
		  ,[Invoice_Line_Product_Number] = NULLIF([PRODUCTNUMBER],'')
		  ,[Invoice_Line_Delivery_Date] = CAST(NULLIF(NULLIF(il.[DLVDATE],'1900-01-01 00:00:00.000'),'2029-08-27 00:00:00.000') AS DATE)
		  ,[Payment_Term] = CASE [PAYMENTTERMSNAME]
				WHEN 'CreditCard' THEN 'Credit Card'
				WHEN 'N00' THEN 'Due on Receipt'
				WHEN 'N30' THEN 'Net 30'
				WHEN 'N60' THEN 'Net 60'
				WHEN 'N90' THEN 'Net 60'
			END
		  ,[Invoice_Line_Unit] = CASE il.[SALESUNITSYMBOL] WHEN 'ea' THEN 'Each'
											 WHEN '' THEN NULL
											 WHEN 'dz' THEN 'Dozen'
										END
		  ,[Invoice_Header_Delivery_Mode] = CAST(CASE [DELIVERYMODECODE]
														WHEN 'STANDARD' Then 'Standard Ground'
														WHEN '2Day' THEN '2-Day Air'
														WHEN '' THEN NULL
														WHEN 'OVERNT' THEN 'FedEx Overnight'
														WHEN 'Pickup' THEN 'Pickup'
														WHEN 'TUSI' THEN 'US Indiana Truck'
														WHEN 'ACNX' THEN 'India Chennai Air'
											ELSE [DELIVERYMODECODE] END AS VARCHAR(50))
	  FROM [AX_PRODUCTION].[dbo].[ITSSalesInvoiceHeaderStaging] ih
	  INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesInvoiceLineStaging] il ON ih.INVOICENUMBER = il.INVOICENUMBER
	  LEFT JOIN [CWC_DW].[Dimension].[Customers] c ON ih.[INVOICECUSTOMERACCOUNTNUMBER] = c.[Customer_Account]
	  LEFT JOIN [CWC_DW].[Dimension].[Products] p ON il.[PRODUCTNUMBER] = CONCAT(p.Item_ID,p.Color_ID,p.Size_ID)
	  LEFT JOIN [CWC_DW].[Dimension].[Dates] d ON CAST(il.[INVOICEDATE] AS DATE) = d.Calendar_Date
	)
	,src AS
	(
		SELECT
			 [Invoice_Number]
			,[Invoice_Line_Number]
			,s.[Sales_Key]
			,i.[Sales_Order_Number]
			,i.[Invent_Trans_ID]
			,[Invoice_Line_Product_Key]
			,[Invoice_Line_Product_Number]
			,[Invoice_Customer_Key]
			,[Invoice_Customer_Account_Number]
			,[Invoice_Property_Key]
			,[Invoice_Header_Date]
			,[Invoice_Line_Date_Key]
			,[Invoice_Line_Date]
			,[Invoice_Line_Confirmed_Shipping_Date]
			,[Invoice_Line_Delivery_Date]
			,[Invoice_Line_Quantity]
			,[Invoice_Line_Sales_Price]
			,[Invoice_Line_Amount]
			,[Invoice_Line_Tax_Amount]
			,[Invoice_Line_Charge_Amount]
			,[Invoice_Line_Discount_Amount]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM [Inv_Mapping] i
		LEFT JOIN [CWC_DW].[Dimension].[Invoice_Properties] ip   ON ISNULL(i.Payment_Term,'') = ISNULL(ip.Payment_Term,'') 
																	   AND ISNULL(i.[Invoice_Line_Unit],'') = ISNULL(ip.[Invoice_Line_Unit],'')
																	   AND ISNULL(i.[Invoice_Header_Delivery_Mode],'') = ISNULL(ip.[Invoice_Header_Delivery_Mode],'')
		LEFT JOIN [CWC_DW].[Fact].[Sales] s   ON i.[Invent_Trans_ID] = s.[Invent_Trans_ID]
	) 
	,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Invoices])

	MERGE INTO tgt USING src
		ON tgt.[Invoice_Number] = src.[Invoice_Number] AND tgt.[Invoice_Line_Number] = src.[Invoice_Line_Number]
			WHEN NOT MATCHED THEN
				INSERT([Invoice_Number],[Invoice_Line_Number],[Sales_Key],[Sales_Order_Number],[Invent_Trans_ID],[Invoice_Line_Product_Key],[Invoice_Line_Product_Number],[Invoice_Customer_Key]
					  ,[Invoice_Customer_Account_Number],[Invoice_Property_Key],[Invoice_Header_Date],[Invoice_Line_Date_Key],[Invoice_Line_Date],[Invoice_Line_Confirmed_Shipping_Date]
					  ,[Invoice_Line_Delivery_Date],[Invoice_Line_Quantity],[Invoice_Line_Sales_Price],[Invoice_Line_Amount],[Invoice_Line_Tax_Amount],[Invoice_Line_Charge_Amount]
					  ,[Invoice_Line_Discount_Amount],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
				VALUES(src.[Invoice_Number],src.[Invoice_Line_Number],src.[Sales_Key],src.[Sales_Order_Number],src.[Invent_Trans_ID],src.[Invoice_Line_Product_Key],src.[Invoice_Line_Product_Number],src.[Invoice_Customer_Key]
					  ,src.[Invoice_Customer_Account_Number],src.[Invoice_Property_Key],src.[Invoice_Header_Date],src.[Invoice_Line_Date_Key],src.[Invoice_Line_Date],src.[Invoice_Line_Confirmed_Shipping_Date]
					  ,src.[Invoice_Line_Delivery_Date],src.[Invoice_Line_Quantity],src.[Invoice_Line_Sales_Price],src.[Invoice_Line_Amount],src.[Invoice_Line_Tax_Amount],src.[Invoice_Line_Charge_Amount]
					  ,src.[Invoice_Line_Discount_Amount],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
			WHEN MATCHED AND			  
					 ISNULL(src.[Sales_Order_Number],'') <> ISNULL(tgt.[Sales_Order_Number],'')
				  OR ISNULL(src.[Sales_Key],'') <> ISNULL(tgt.[Sales_Key],'')
				  OR ISNULL(src.[Invent_Trans_ID],'') <> ISNULL(tgt.[Invent_Trans_ID],'')
				  OR ISNULL(src.[Invoice_Line_Product_Key],'') <> ISNULL(tgt.[Invoice_Line_Product_Key],'')
				  OR ISNULL(src.[Invoice_Line_Product_Number],'') <> ISNULL(tgt.[Invoice_Line_Product_Number],'')
				  OR ISNULL(src.[Invoice_Customer_Key],'') <> ISNULL(tgt.[Invoice_Customer_Key],'')
				  OR ISNULL(src.[Invoice_Customer_Account_Number],'') <> ISNULL(tgt.[Invoice_Customer_Account_Number],'')
				  OR ISNULL(src.[Invoice_Property_Key],'') <> ISNULL(tgt.[Invoice_Property_Key],'')
				  OR ISNULL(src.[Invoice_Header_Date],'') <> ISNULL(tgt.[Invoice_Header_Date],'')
				  OR ISNULL(src.[Invoice_Line_Date_Key],'') <> ISNULL(tgt.[Invoice_Line_Date_Key],'')
				  OR ISNULL(src.[Invoice_Line_Date],'') <> ISNULL(tgt.[Invoice_Line_Date],'')
				  OR ISNULL(src.[Invoice_Line_Confirmed_Shipping_Date],'') <> ISNULL(tgt.[Invoice_Line_Confirmed_Shipping_Date],'')
				  OR ISNULL(src.[Invoice_Line_Delivery_Date],'') <> ISNULL(tgt.[Invoice_Line_Delivery_Date],'')
				  OR ISNULL(src.[Invoice_Line_Quantity],'') <> ISNULL(tgt.[Invoice_Line_Quantity],'')
				  OR ISNULL(src.[Invoice_Line_Sales_Price],'') <> ISNULL(tgt.[Invoice_Line_Sales_Price],'')
				  OR ISNULL(src.[Invoice_Line_Amount],'') <> ISNULL(tgt.[Invoice_Line_Amount],'')
				  OR ISNULL(src.[Invoice_Line_Tax_Amount],'') <> ISNULL(tgt.[Invoice_Line_Tax_Amount],'')
				  OR ISNULL(src.[Invoice_Line_Charge_Amount],'') <> ISNULL(tgt.[Invoice_Line_Charge_Amount],'')
				  OR ISNULL(src.[Invoice_Line_Discount_Amount],'') <> ISNULL(tgt.[Invoice_Line_Discount_Amount],'')
				  OR ISNULL(src.[is_Removed_From_Source],'') <> ISNULL(tgt.[is_Removed_From_Source],'')
			THEN UPDATE SET
				   [Sales_Order_Number] = src.[Sales_Order_Number]
				  ,[Sales_Key] = src.[Sales_Key]
				  ,[Invent_Trans_ID] = src.[Invent_Trans_ID]
				  ,[Invoice_Line_Product_Key] = src.[Invoice_Line_Product_Key]
				  ,[Invoice_Line_Product_Number] = src.[Invoice_Line_Product_Number]
				  ,[Invoice_Customer_Key] = src.[Invoice_Customer_Key]
				  ,[Invoice_Customer_Account_Number] = src.[Invoice_Customer_Account_Number]
				  ,[Invoice_Property_Key] = src.[Invoice_Property_Key]
				  ,[Invoice_Header_Date] = src.[Invoice_Header_Date]
				  ,[Invoice_Line_Date_Key] = src.[Invoice_Line_Date_Key]
				  ,[Invoice_Line_Date] = src.[Invoice_Line_Date]
				  ,[Invoice_Line_Confirmed_Shipping_Date] = src.[Invoice_Line_Confirmed_Shipping_Date]
				  ,[Invoice_Line_Delivery_Date] = src.[Invoice_Line_Delivery_Date]
				  ,[Invoice_Line_Quantity] = src.[Invoice_Line_Quantity]
				  ,[Invoice_Line_Sales_Price] = src.[Invoice_Line_Sales_Price]
				  ,[Invoice_Line_Amount] = src.[Invoice_Line_Amount]
				  ,[Invoice_Line_Tax_Amount] = src.[Invoice_Line_Tax_Amount]
				  ,[Invoice_Line_Charge_Amount] = src.[Invoice_Line_Charge_Amount]
				  ,[Invoice_Line_Discount_Amount] = src.[Invoice_Line_Discount_Amount]
				  ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
				  ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
				  ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
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
