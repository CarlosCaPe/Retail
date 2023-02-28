





CREATE PROC [Import].[usp_Fact_Sales_Merge]

AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;

BEGIN TRY

		;WITH Sales_Order_Header AS
			(
				SELECT DISTINCT
					   [Sales_Order_Number] = [SALESORDERNUMBER]
					  ,[Sales_Header_Customer_Key] = c.Customer_Key 
					  ,[Sales_Header_Location_Key] = l.Location_Key
					  ,[Sales_Header_Currency_Code] = [CURRENCYCODE]
					  ,[Sales_Header_Retail_Channel] = CASE WHEN LEFT([RETAILCHANNELID], 1) = 0 THEN 'Retail'
															WHEN [RetailChannelID] IN ('9000','9001') THEN 'Direct' 
															ELSE rc.NAME 
														END
					  ,[Sales_Header_Retail_Channel_Name] = CASE [Name] WHEN 'Ecommerce' THEN 'Web'
																  WHEN 'Direct' THEN 'Phone'
													ELSE [NAME] END 
					  ,[Sales_Header_Type] = CAST(CASE so.[SALESTYPE] WHEN 2 THEN 'Subscription'
														  WHEN 3 THEN 'Sale'
														  WHEN 4 THEN 'Return'
									  END AS VARCHAR(50))
					  ,[Sales_Header_Status] = CAST(CASE [SALESORDERSTATUS] 
													WHEN 0 THEN 'None'
													WHEN 1 THEN 'Backorder'
													WHEN 2 THEN 'Delivered'
													WHEN 3 THEN 'Invoiced'
													WHEN 4 THEN 'Canceled'
											  END AS VARCHAR(50))
					  ,[Sales_Header_Delivery_Mode] = CAST(CASE [DELIVERYMODECODE]
															WHEN 'STANDARD' Then 'Standard Ground'
															WHEN '2Day' THEN '2-Day Air'
															WHEN '' THEN NULL
															WHEN 'OVERNT' THEN 'FedEx Overnight'
															WHEN 'Pickup' THEN 'Pickup'
															WHEN 'TUSI' THEN 'US Indiana Truck'
															WHEN 'ACNX' THEN 'India Chennai Air'
												ELSE NULLIF([DELIVERYMODECODE],'') END AS VARCHAR(50))
					  ,[Sales_Header_Return_Reason_Group]  = CAST(CASE so.[RETURNREASONCODEID]
																		WHEN '01' THEN	'Fit/Fabric'
																		WHEN '02' THEN	'Fit/Fabric'
																		WHEN '03' THEN	'Serv/Qual'
																		WHEN '04' THEN	'Fit/Fabric'
																		WHEN '05' THEN	'Serv/Qual'
																		WHEN '06' THEN	'Serv/Qual'
																		WHEN '07' THEN	'Other'
																		WHEN '08' THEN	'Other'
																		WHEN '09' THEN	'Other'
																		WHEN '10' THEN	'Other'
																		WHEN '11' THEN	'Return'
																		WHEN '12' THEN	'Serv/Qual'
																		WHEN '13' THEN	'Other'
																		WHEN '14' THEN	'Other'
																		WHEN '15' THEN	'Serv/Qual'
																		WHEN '28' THEN	'Fit/Fabric'
																		WHEN '29' THEN	'Fit/Fabric'
																		WHEN '30' THEN	'Fit/Fabric'
																		WHEN '31' THEN	'Fit/Fabric'
																		WHEN '32' THEN	'Other'
																		WHEN '33' THEN	'Serv/Qual'
																		WHEN '34' THEN	'Serv/Qual'
																		WHEN '35' THEN	'Other'
																		WHEN 'BIG' THEN	'Fit/Fabric'
																		WHEN 'CM' THEN	'Other'
																		WHEN 'CREDIT' THEN	'Credit'
												ELSE  NULLIF(so.[RETURNREASONCODEID],'')
												END AS VARCHAR(50))
						,[Sales_Header_Return_Reason] = CAST(CASE so.[RETURNREASONCODEID]
																WHEN '01' THEN	'Too Small'
																WHEN '02' THEN	'Too Big'
																WHEN '03' THEN	'Item is Defective'
																WHEN '04' THEN	'Fabric/Material'
																WHEN '05' THEN	'Wrong Item Shipped'
																WHEN '06' THEN	'Arrived Too Late'
																WHEN '07' THEN	'Item Not as Described'
																WHEN '08' THEN	'Returning a Gift'
																WHEN '09' THEN	'Ordered Multiples'
																WHEN '10' THEN	'Changed Mind'
																WHEN '11' THEN	'Lost/Undelivered'
																WHEN '12' THEN	'Missing Item'
																WHEN '13' THEN	'No Reason Given'
																WHEN '14' THEN	'Refused'
																WHEN '15' THEN	'Shipping Error'
																WHEN '28' THEN	'Too Long'
																WHEN '29' THEN	'Too Short'
																WHEN '30' THEN	'Ordered Wrong Size'
																WHEN '31' THEN	'Construction'
																WHEN '32' THEN	'Do Not Like Color'
																WHEN '33' THEN	'Damaged In Transit'
																WHEN '34' THEN	'Did Not Hold Up'
																WHEN '35' THEN	'Just Did Not Like'
																WHEN 'BIG' THEN	'Too Big'
																WHEN 'CM' THEN	'Changed Mind'
																WHEN 'CREDIT' THEN	'Credit'
															ELSE NULLIF(so.[RETURNREASONCODEID],'')
															END AS VARCHAR(50))
					  ,[Sales_Header_Modified_Date] = CAST(so.[SALESTABLEMODIFIEDDATETIME] AS DATETIME2(5))
					  ,[Sales_Header_Created_Date] = CASE WHEN SALESCREATEDDATETIME='1900-01-01 00:00:00.000' THEN SALESTABLECREATEDDATETIME ELSE SALESCREATEDDATETIME END --11292022
					  ,[Sales_Header_On_Hold] = [ISSALESPROCESSINGSTOPPED]
				  FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] so  
				  LEFT JOIN [AX_PRODUCTION].[dbo].[RetailChannelStaging] rc   ON so.[RETAILCHANNELTABLE] = rc.[ITSRETAILCHANNELRECID]
				  LEFT JOIN [CWC_DW].[Dimension].[Customers] c   ON c.Customer_Account = so.[ORDERINGCUSTOMERACCOUNTNUMBER]
				  LEFT JOIN [CWC_DW].[Dimension].[Locations] l ON 
														ISNULL(l.[Street],'') = ISNULL(CAST(NULLIF(so.[DELIVERYADDRESSSTREET],'') AS VARCHAR(200)),'')
													AND ISNULL(l.[City],'') = ISNULL(CAST(NULLIF(so.[DELIVERYADDRESSCITY],'') AS VARCHAR(100)),'')
													AND ISNULL(l.[State],'') = ISNULL(CAST(NULLIF(so.[DELIVERYADDRESSSTATEID],'') AS VARCHAR(5)),'')
													AND ISNULL(l.[Zip_Code],'') = ISNULL(CAST(NULLIF(so.[DELIVERYADDRESSZIPCODE],'') AS VARCHAR(100)),'')
													AND ISNULL(l.[Country],'') = ISNULL(CAST(NULLIF(so.[DELIVERYADDRESSCOUNTRYREGIONID],'') AS VARCHAR(10)),'')
				  --WHERE l.Location_Key IS  NULL
			) --SELECT * FROM Sales_Order_Header WHERE [Sales_Order_Number] = 'D00507253'
		,Sales_Order_Header_Lines AS
		(		SELECT
					   s.[Sales_Order_Number]
					  ,[Invent_Trans_ID] = NULLIF(sl.INVENTTRANSID,'')
					  ,[Return_Invent_Trans_ID] = NULLIF(sl.INVENTTRANSIDRETURN,'')
					  ,[Sales_Header_Location_Key] 
					  ,s.[Sales_Header_Customer_Key]
					  ,[Sales_Line_Product_Key] = p.[Product_Key]
					  --  ,s.[Currency_Code]
					  ,sha.[Sales_Header_Property_Key]
					  ,[Shipping_Inventory_Warehouse_Key] = w.[Inventory_Warehouse_Key]
			  
					  --,[INVENTORYLOTID] = sl.[INVENTORYLOTID] May need this later

					  ,[Sales_Line_Status] = CASE sl.[SALESORDERLINESTATUS] 
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
					  --,sl.[ORDEREDINVENTORYSTATUSID]

					  ,[Sales_Line_Unit] = CASE sl.[SALESUNITSYMBOL] WHEN 'ea' THEN 'Each'
												 WHEN '' THEN NULL
												 WHEN 'dz' THEN 'Dozen'
											END
					  ,[Sales_Line_Description] = sl.[LINEDESCRIPTION]
					  ,[Sales_Line_Amount] = sl.[LINEAMOUNT]
			  
			  
					  ,[Sales_Line_Discount_Amount] = sl.[LINEDISCOUNTAMOUNT]
					  ,[Sales_Line_Discount_Percentage] = sl.[LINEDISCOUNTPERCENTAGE]
					  ,[Multi_Line_Discount_Code] = sl.[MULTILINEDISCOUNTAMOUNT]
					  ,[Multi_Line_Discount_Percentage] = sl.[MULTILINEDISCOUNTPERCENTAGE]

					  ,[Sales_Line_Reserve_Quantity] = CAST(sl.[RESERVEQTY] AS SMALLINT)
					  ,[Sales_Line_Ship_Quantity] = CAST(sl.[SHIPQTY] AS SMALLINT)
					  ,[Sales_Line_Cost_Price] = sl.[COSTPRICE]
					  ,[Sales_Line_Ordered_Quantity] = CAST(sl.[QTYORDERED] AS SMALLINT)
			  
					  ,[Sales_Line_Price_Quantity] = CAST(sl.[SALESPRICEQUANTITY] AS SMALLINT)
					  ,[Sales_Line_Confirmed_Receipt_Date] = CAST(sl.[CONFIRMEDRECEIPTDATE] AS DATETIME2(5))	
					  ,[Sales_Line_Requested_Receipt_Date] = CAST(sl.[REQUESTEDRECEIPTDATE] AS DATETIME2(5))	
					  ,[Sales_Line_Number] = sl.[LINECREATIONSEQUENCENUMBER]
					  --,sl.[INVENTTRANSID]  		  
					  ,[Sales_Line_Confirmed_Date] = CAST(sl.[CONFIRMEDDLV] AS DATETIME2(5))			  
					  ,[Sales_Line_Remain_Sales_Physical] = CAST(sl.[REMAINSALESPHYSICAL] AS SMALLINT)
					  ,s.[Sales_Header_Modified_Date]
					  ,s.[Sales_Header_Created_Date]
					  ,[Sales_Line_Created_Date] = CAST(sl.[SALESLINECREATEDDATETIME] AS DATETIME2(5))
					  ,[Sales_Line_Modified_Date] = CAST(sl.[SALESLINEMODIFIEDDATETIME] AS DATETIME2(5))	
					  ,[Sales_Line_Employee_Key] = e.[Employee_Key]
					  ,[Sales_Line_Created_By] = sl.[SALESLINECREATEDBY]
					  ,[Sales_Header_On_Hold] = s.[Sales_Header_On_Hold]
					  ,[Sales_Line_Price] = sl.SALESPRICE
					  ,[Sales_Line_Ordered_Sales_Quantity] = ORDEREDSALESQUANTITY
				FROM Sales_Order_Header s
				LEFT JOIN [CWC_DW].[Dimension].[Sales_Header_Properties]   sha ON 
																				CAST(ISNULL(s.[Sales_Header_Type],'') AS VARCHAR(20)) = CAST(ISNULL(sha.[Sales_Header_Type],'')  AS VARCHAR(20))
																			AND ISNULL(s.[Sales_Header_Status],'') = ISNULL(sha.[Sales_Header_Status],'')
																			AND ISNULL(s.[Sales_Header_Retail_Channel],'') = ISNULL(sha.[Sales_Header_Retail_Channel],'')
																			AND ISNULL(s.[Sales_Header_Retail_Channel_Name],'') = ISNULL(sha.[Sales_Header_Retail_Channel_Name],'')
																			AND ISNULL(s.[Sales_Header_Return_Reason_Group],'') = ISNULL(sha.[Sales_Header_Return_Reason_Group],'')
																			AND ISNULL(s.[Sales_Header_Return_Reason],'') = ISNULL(sha.[Sales_Header_Return_Reason],'')
																			AND ISNULL(s.[Sales_Header_Delivery_Mode],'') = ISNULL(sha.[Sales_Header_Delivery_Mode],'')
																			AND ISNULL(s.[Sales_Header_On_Hold],'') = ISNULL(sha.[Sales_Header_On_Hold],'')
				INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderLineStaging] sl   ON s.[Sales_Order_Number] = sl.[SALESORDERNUMBER]
				INNER JOIN [CWC_DW].[Dimension].[Products]   p ON ISNULL(sl.ITEMNUMBER,'') = ISNULL(p.Item_ID,'') 
																	 AND ISNULL(sl.PRODUCTCOLORID,'') = ISNULL(p.Color_ID,'') 
																	 AND ISNULL(sl.PRODUCTSIZEID,'') = ISNULL(p.Size_ID,'')
				LEFT JOIN [CWC_DW].[Dimension].[Inventory_Warehouses] w   ON w.Inventory_Warehouse_ID = sl.[SHIPPINGWAREHOUSEID]
				LEFT JOIN [CWC_DW].[Analytics].[v_Dim_Employees_By_User_ID] e   ON e.[User_ID] = sl.SALESLINECREATEDBY
		
		) 
		,src AS 
		(
		SELECT
			 [Sales_Order_Number]
			,[Sales_Line_Number]
			,[Invent_Trans_ID]
			,[Return_Invent_Trans_ID]
			,[Sales_Header_Customer_Key]
			,[Sales_Header_Property_Key]
			,sla.Sales_Line_Property_Key
			,[Sales_Line_Product_Key]
			,[Shipping_Inventory_Warehouse_Key]
			,[Sales_Line_Employee_Key]
			,[Sales_Header_Location_Key]
			,[Sales_Line_Amount]
			,[Sales_Line_Discount_Amount]
			,[Sales_Line_Cost_Price]
			,[Sales_Line_Discount_Percentage]
			,[Multi_Line_Discount_Code]
			,[Multi_Line_Discount_Percentage]
			,[Sales_Line_Reserve_Quantity]
			,[Sales_Line_Ordered_Quantity]		  
			,[Sales_Line_Price_Quantity]
			,[Sales_Line_Remain_Sales_Physical]
			,[Sales_Header_Modified_Date]
			,[Sales_Header_Created_Date]
			,[Sales_Line_Modified_Date]
			,[Sales_Line_Created_Date]
			,[Sales_Line_Confirmed_Date]
			,[Sales_Line_Confirmed_Receipt_Date]
			,[Sales_Line_Requested_Receipt_Date]
			,[Sales_Line_Created_By]
			,[Sales_Line_Price]
			,[Sales_Line_Ordered_Sales_Quantity]
			,[is_Removed_From_Source] = CAST(0 AS BIT)
			,[is_Excluded] = CAST(0 AS BIT)
			,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			,[ETL_Modified_Count] = CAST(1 AS TINYINT)
		FROM Sales_Order_Header_Lines s
		LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] sla   ON 
			   ISNULL(s.[Sales_Line_Status],'') = ISNULL(sla.[Sales_Line_Status],'') AND
			   ISNULL(s.[Sales_Line_Type],'') = ISNULL(sla.[Sales_Line_Type],'') AND
			   ISNULL(s.[Sales_Line_Tax_Group],'') = ISNULL(sla.[Sales_Line_Tax_Group],'') AND
			   ISNULL(s.[Sales_Line_Unit],'') = ISNULL(sla.[Sales_Line_Unit],'') AND
			   ISNULL(s.[Sales_Line_Return_Deposition_Action],'') = ISNULL(sla.[Sales_Line_Return_Deposition_Action],'') AND
			   ISNULL(s.[Sales_Line_Return_Deposition_Description],'') = ISNULL(sla.[Sales_Line_Return_Deposition_Description],'')
		) 


		,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Sales]  )

		MERGE INTO tgt USING src
			ON tgt.[Sales_Order_Number] = src.[Sales_Order_Number] AND tgt.[Sales_Line_Number] = src.[Sales_Line_Number]
				WHEN NOT MATCHED THEN
					INSERT([Sales_Order_Number],[Sales_Line_Number],[Invent_Trans_ID],[Return_Invent_Trans_ID],[Sales_Header_Customer_Key],[Sales_Header_Property_Key],[Sales_Line_Property_Key]
						  ,[Sales_Header_Location_Key],[Sales_Line_Product_Key],[Shipping_Inventory_Warehouse_Key],[Sales_Line_Employee_Key],[Sales_Line_Amount],[Sales_Line_Discount_Amount],[Sales_Line_Cost_Price]
						  ,[Sales_Line_Discount_Percentage],[Multi_Line_Discount_Code],[Multi_Line_Discount_Percentage],[Sales_Line_Reserve_Quantity] ,[Sales_Line_Ordered_Quantity]
						  ,[Sales_Line_Price_Quantity],[Sales_Line_Remain_Sales_Physical],[Sales_Header_Modified_Date],[Sales_Header_Created_Date],[Sales_Line_Modified_Date],[Sales_Line_Created_Date]
						  ,[Sales_Line_Confirmed_Date],[Sales_Line_Confirmed_Receipt_Date],[Sales_Line_Requested_Receipt_Date],[Sales_Line_Created_By],[Sales_Line_Price],[Sales_Line_Ordered_Sales_Quantity],[is_Removed_From_Source],[is_Excluded]
						  ,[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
					VALUES(src.[Sales_Order_Number],src.[Sales_Line_Number],src.[Invent_Trans_ID],src.[Return_Invent_Trans_ID],src.[Sales_Header_Customer_Key],src.[Sales_Header_Property_Key],src.[Sales_Line_Property_Key]
						  ,src.[Sales_Header_Location_Key],src.[Sales_Line_Product_Key],src.[Shipping_Inventory_Warehouse_Key],src.[Sales_Line_Employee_Key],src.[Sales_Line_Amount],src.[Sales_Line_Discount_Amount],src.[Sales_Line_Cost_Price]
						  ,src.[Sales_Line_Discount_Percentage],src.[Multi_Line_Discount_Code],src.[Multi_Line_Discount_Percentage],src.[Sales_Line_Reserve_Quantity] ,src.[Sales_Line_Ordered_Quantity]
						  ,src.[Sales_Line_Price_Quantity],src.[Sales_Line_Remain_Sales_Physical],src.[Sales_Header_Modified_Date],src.[Sales_Header_Created_Date],src.[Sales_Line_Modified_Date],src.[Sales_Line_Created_Date]
						  ,src.[Sales_Line_Confirmed_Date],src.[Sales_Line_Confirmed_Receipt_Date],src.[Sales_Line_Requested_Receipt_Date],src.[Sales_Line_Created_By],src.[Sales_Line_Price],src.[Sales_Line_Ordered_Sales_Quantity],src.[is_Removed_From_Source],src.[is_Excluded]
						  ,src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
					WHEN MATCHED AND
							 ISNULL(tgt.[Invent_Trans_ID],'') <> ISNULL(src.[Invent_Trans_ID],'')
						  OR ISNULL(tgt.[Return_Invent_Trans_ID],'') <> ISNULL(src.[Return_Invent_Trans_ID],'')
						  OR ISNULL(tgt.[Sales_Header_Customer_Key],'') <> ISNULL(src.[Sales_Header_Customer_Key],'')
						  OR ISNULL(tgt.[Sales_Header_Property_Key],'') <> ISNULL(src.[Sales_Header_Property_Key],'')
						  OR ISNULL(tgt.[Sales_Header_Location_Key],'') <> ISNULL(src.[Sales_Header_Location_Key],'')
						  OR ISNULL(tgt.[Sales_Line_Property_Key],'') <> ISNULL(src.[Sales_Line_Property_Key],'')
						  OR ISNULL(tgt.[Sales_Line_Product_Key],'') <> ISNULL(src.[Sales_Line_Product_Key],'')
						  OR ISNULL(tgt.[Shipping_Inventory_Warehouse_Key],'') <> ISNULL(src.[Shipping_Inventory_Warehouse_Key],'')
						  OR ISNULL(tgt.[Sales_Line_Employee_Key],'') <> ISNULL(src.[Sales_Line_Employee_Key],'')
						  OR ISNULL(tgt.[Sales_Line_Amount],'') <> ISNULL(src.[Sales_Line_Amount],'')
						  OR ISNULL(tgt.[Sales_Line_Discount_Amount],'') <> ISNULL(src.[Sales_Line_Discount_Amount],'')
						  OR ISNULL(tgt.[Sales_Line_Cost_Price],'') <> ISNULL(src.[Sales_Line_Cost_Price],'')
						  OR ISNULL(tgt.[Sales_Line_Discount_Percentage],'') <> ISNULL(src.[Sales_Line_Discount_Percentage],'')
						  OR ISNULL(tgt.[Multi_Line_Discount_Code],'') <> ISNULL(src.[Multi_Line_Discount_Code],'')
						  OR ISNULL(tgt.[Multi_Line_Discount_Percentage],'') <> ISNULL(src.[Multi_Line_Discount_Percentage],'')
						  OR ISNULL(tgt.[Sales_Line_Reserve_Quantity],'') <> ISNULL(src.[Sales_Line_Reserve_Quantity],'')
						  OR ISNULL(tgt.[Sales_Line_Ordered_Quantity],'') <> ISNULL(src.[Sales_Line_Ordered_Quantity],'')
						  OR ISNULL(tgt.[Sales_Line_Price_Quantity],'') <> ISNULL(src.[Sales_Line_Price_Quantity],'')
						  OR ISNULL(tgt.[Sales_Line_Remain_Sales_Physical],'') <> ISNULL(src.[Sales_Line_Remain_Sales_Physical],'')
						  OR ISNULL(tgt.[Sales_Header_Modified_Date],'') <> ISNULL(src.[Sales_Header_Modified_Date],'')
						  OR ISNULL(tgt.[Sales_Header_Created_Date],'') <> ISNULL(src.[Sales_Header_Created_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Modified_Date],'') <> ISNULL(src.[Sales_Line_Modified_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Created_Date],'') <> ISNULL(src.[Sales_Line_Created_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Confirmed_Date],'') <> ISNULL(src.[Sales_Line_Confirmed_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Confirmed_Receipt_Date],'') <> ISNULL(src.[Sales_Line_Confirmed_Receipt_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Requested_Receipt_Date],'') <> ISNULL(src.[Sales_Line_Requested_Receipt_Date],'')
						  OR ISNULL(tgt.[Sales_Line_Created_By],'') <> ISNULL(src.[Sales_Line_Created_By],'')
						  OR ISNULL(tgt.[Sales_Line_Price],'') <> ISNULL(src.[Sales_Line_Price],'')
						  OR ISNULL(tgt.[Sales_Line_Ordered_Sales_Quantity],0) <> ISNULL(src.[Sales_Line_Ordered_Sales_Quantity],0)
						  OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
					THEN UPDATE SET
						   [Invent_Trans_ID] = src.[Invent_Trans_ID]
						  ,[Return_Invent_Trans_ID] = src.[Return_Invent_Trans_ID]
						  ,[Sales_Header_Customer_Key] = src.[Sales_Header_Customer_Key]
						  ,[Sales_Header_Property_Key] = src.[Sales_Header_Property_Key]
						  ,[Sales_Header_Location_Key] = src.[Sales_Header_Location_Key]
						  ,[Sales_Line_Property_Key] = src.[Sales_Line_Property_Key]
						  ,[Sales_Line_Product_Key] = src.[Sales_Line_Product_Key]
						  ,[Shipping_Inventory_Warehouse_Key] = src.[Shipping_Inventory_Warehouse_Key]
						  ,[Sales_Line_Employee_Key] = src.[Sales_Line_Employee_Key]
						  ,[Sales_Line_Amount] = src.[Sales_Line_Amount]
						  ,[Sales_Line_Discount_Amount] = src.[Sales_Line_Discount_Amount]
						  ,[Sales_Line_Cost_Price] = src.[Sales_Line_Cost_Price]
						  ,[Sales_Line_Discount_Percentage] = src.[Sales_Line_Discount_Percentage]
						  ,[Multi_Line_Discount_Code] = src.[Multi_Line_Discount_Code]
						  ,[Multi_Line_Discount_Percentage] = src.[Multi_Line_Discount_Percentage]
						  ,[Sales_Line_Reserve_Quantity] = src.[Sales_Line_Reserve_Quantity]
						  ,[Sales_Line_Ordered_Quantity] = src.[Sales_Line_Ordered_Quantity]
						  ,[Sales_Line_Price_Quantity] = src.[Sales_Line_Price_Quantity]
						  ,[Sales_Line_Remain_Sales_Physical] = src.[Sales_Line_Remain_Sales_Physical]
						  ,[Sales_Header_Modified_Date] = src.[Sales_Header_Modified_Date]
						  ,[Sales_Header_Created_Date] = src.[Sales_Header_Created_Date]
						  ,[Sales_Line_Modified_Date] = src.[Sales_Line_Modified_Date]
						  ,[Sales_Line_Created_Date] = src.[Sales_Line_Created_Date]
						  ,[Sales_Line_Confirmed_Date] = src.[Sales_Line_Confirmed_Date]
						  ,[Sales_Line_Confirmed_Receipt_Date] = src.[Sales_Line_Confirmed_Receipt_Date]
						  ,[Sales_Line_Requested_Receipt_Date] = src.[Sales_Line_Requested_Receipt_Date]
						  ,[Sales_Line_Created_By] = src.[Sales_Line_Created_By]
						  ,[Sales_Line_Price] = src.[Sales_Line_Price]
						  ,[Sales_Line_Ordered_Sales_Quantity] = src.[Sales_Line_Ordered_Sales_Quantity]
						  ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
						  ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
						  ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
						WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
							tgt.[is_Removed_From_Source] = 1
						   ,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
						   ,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);

		--SET Sales Line Status to Canceled if order is removed from D365
		UPDATE s
		SET
		Sales_Line_Property_Key = slp2.Sales_Line_Property_Key
		FROM [CWC_DW].[Fact].[Sales] s
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp ON s.Sales_Line_Property_Key = slp.Sales_Line_Property_Key
			LEFT JOIN [CWC_DW].[Dimension].[Sales_Line_Properties] slp2 ON 
				CASE WHEN s.is_Removed_From_Source = 1 THEN 'Canceled' ELSE slp.Sales_Line_Status END = ISNULL(slp2.Sales_Line_Status,'')
				AND ISNULL(slp.Sales_Line_Unit,'') = ISNULL(slp2.Sales_Line_Unit,'')
				AND ISNULL(slp.Sales_Line_Type,'') = ISNULL(slp2.Sales_Line_Type,'')
				AND ISNULL(slp.Sales_Line_Tax_Group,'') = ISNULL(slp2.Sales_Line_Tax_Group,'')
				AND ISNULL(slp.Sales_Line_Return_Deposition_Description,'') = ISNULL(slp2.Sales_Line_Return_Deposition_Description,'')
				AND ISNULL(slp.Sales_Line_Return_Deposition_Action,'') = ISNULL(slp2.Sales_Line_Return_Deposition_Action,'')
		WHERE s.is_Removed_From_Source = 1 AND (slp2.Sales_Line_Property_Key <> slp.Sales_Line_Property_Key);

END TRY

BEGIN CATCH

	DECLARE @InputParameters NVARCHAR(MAX)
	If @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SELECT @InputParameters = '';
	EXEC Administration.usp_ErrorLogger_Insert @InputParameters;

END CATCH