
CREATE PROC [Import].[usp_Dimension_Sales_Header_Properties_Merge] AS

;WITH src AS
(
SELECT DISTINCT
       --[Currency_Code] = [CURRENCYCODE]
	   
       [Sales_Header_Type] = CASE so.[SALESTYPE] WHEN 2 THEN 'Subscription'
										  WHEN 3 THEN 'Sale'
									      WHEN 4 THEN 'Return'
					  END
	  ,[Sales_Header_Status] = CASE [SALESORDERSTATUS] 
									WHEN 0 THEN 'None'
									WHEN 1 THEN 'Backorder'
									WHEN 2 THEN 'Delivered'
									WHEN 3 THEN 'Invoiced'
									WHEN 4 THEN 'Canceled'
							  END
		,[Sales_Header_Retail_Channel] = CASE WHEN LEFT([RETAILCHANNELID], 1) = 0 THEN 'Retail'
                WHEN [RetailChannelID] IN ('9000','9001') THEN 'Direct' 
                ELSE rc.NAME 
            END
		,[Sales_Header_Retail_Channel_Name] = CASE [Name] WHEN 'Ecommerce' THEN 'Web'
														  WHEN 'Direct' THEN 'Phone'
											ELSE [NAME] END 
		--,so.[RETURNREASONCODEID]
		,Sales_Header_Return_Reason_Group  = CASE so.[RETURNREASONCODEID]
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
								END
			,Sales_Header_Return_Reason = CASE so.[RETURNREASONCODEID]
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
							END 
	  ,[Sales_Header_Delivery_Mode] = CASE [DELIVERYMODECODE]
									WHEN 'STANDARD' Then 'Standard Ground'
									WHEN '2Day' THEN '2-Day Air'
									WHEN '' THEN NULL
									WHEN 'OVERNT' THEN 'FedEx Overnight'
									WHEN 'Pickup' THEN 'Pickup'
									WHEN 'TUSI' THEN 'US Indiana Truck'
									WHEN 'ACNX' THEN 'India Chennai Air'
								ELSE NULLIF([DELIVERYMODECODE],'') END
	  ,[Sales_Header_On_Hold] = ISNULL([ISSALESPROCESSINGSTOPPED],0)
	  ,[is_Removed_From_Source] = CAST(0 AS BIT)
	  ,[is_Excluded] = CAST(0 AS BIT)
	  ,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	  ,[ETL_Modified_Count] = CAST(1 AS TINYINT)
--INTO [Dimension].[Sales_Header_Attributes]
FROM [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] so (NOLOCK)
LEFT JOIN [AX_PRODUCTION].[dbo].[RetailChannelStaging] rc (NOLOCK) ON so.[RETAILCHANNELTABLE] = rc.[ITSRETAILCHANNELRECID]
--WHERE SALESORDERNUMBER = 'E03459275'
) --SELECT * FROM src
,tgt AS (SELECT * FROM [CWC_DW].[Dimension].[Sales_Header_Properties] (NOLOCK))

MERGE INTO tgt USING src
	ON ISNULL(tgt.[Sales_Header_Type],'') = ISNULL(src.[Sales_Header_Type],'')
   AND ISNULL(tgt.[Sales_Header_Status],'') = ISNULL(src.[Sales_Header_Status],'')
   AND ISNULL(tgt.[Sales_Header_Retail_Channel],'') = ISNULL(src.[Sales_Header_Retail_Channel],'')
   AND ISNULL(tgt.[Sales_Header_Retail_Channel_Name],'') = ISNULL(src.[Sales_Header_Retail_Channel_Name],'')
   AND ISNULL(tgt.[Sales_Header_Return_Reason_Group],'') = ISNULL(src.[Sales_Header_Return_Reason_Group],'')
   AND ISNULL(tgt.[Sales_Header_Return_Reason],'') = ISNULL(src.[Sales_Header_Return_Reason],'')
   AND ISNULL(tgt.[Sales_Header_Delivery_Mode],'') = ISNULL(src.[Sales_Header_Delivery_Mode],'')
   AND ISNULL(tgt.[Sales_Header_On_Hold],'') = ISNULL(src.[Sales_Header_On_Hold],'')
WHEN NOT MATCHED THEN
	INSERT([Sales_Header_Type],[Sales_Header_Status],[Sales_Header_Retail_Channel],[Sales_Header_Retail_Channel_Name],[Sales_Header_Return_Reason_Group],[Sales_Header_Return_Reason],[Sales_Header_Delivery_Mode],[Sales_Header_On_Hold],[is_Removed_From_Source]
		  ,[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
	VALUES(src.[Sales_Header_Type],src.[Sales_Header_Status],src.[Sales_Header_Retail_Channel],src.[Sales_Header_Retail_Channel_Name],src.[Sales_Header_Return_Reason_Group],src.[Sales_Header_Return_Reason],src.[Sales_Header_Delivery_Mode]
		  ,src.[Sales_Header_On_Hold],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
WHEN MATCHED AND tgt.[is_Removed_From_Source] = 1 THEN UPDATE SET
	     tgt.[is_Removed_From_Source] = 0
		,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
		 tgt.[is_Removed_From_Source] = 1
		,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);
