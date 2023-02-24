




CREATE VIEW [Analytics].[v_Fact_Purchase_Orders]

AS

WITH Vendor_Packing_Slips AS
(
    SELECT Purchase_Order_Key,Received_Quantity = SUM([Vendor_Packing_Slip_Quantity])
    FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
	GROUP BY Purchase_Order_Key
)
SELECT po.[Purchase_Order_Key]
      ,[Purchase_Order_Number]
      ,[Purchase_Order_Line_Number]
      ,[Invent_Trans_ID]
      ,[Delivery_Location_Key]
      ,[Vendor_Key]
      ,[Purchase_Order_Property_Key]
      ,[Product_Key]
	  ,[Purchase_Order_Header_Accounting_Date_Key] = ad.Date_Key
	  ,[Purchase_Line_Confirmed_Delivery_Date_Key] = cd.Date_Key
      ,[Purchase_Order_Name]
      ,[Purchase_Line_Description]
      ,[Purchase_Order_Header_Accounting_Date]
      ,[Purchase_Line_Confirmed_Delivery_Date]
      --,[Purchase_Line_Requested_Delivery_Date]
      --,[Purchase_Line_Confirmed_Shipping_Date]
      --,[Purchase_Line_Requested_Shipping_Date]
      ,[Purchase_Line_Amount]
      ,[Purchase_Line_Purchase_Price]
      ,[Purchase_Line_Discount_Amount]
      ,[Purchase_Line_Price_Quantity]
      ,[Purchase_Line_Ordered_Quantity]
	  ,[Purchase_Line_Received_Quantity] = CAST(ISNULL(vps.[Received_Quantity],0) AS INT)
	/*,[Received_Status] = CASE 
								WHEN CAST(vps.[Received_Quantity] AS INT) = 0 THEN 'No Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) = [Purchase_Line_Ordered_Quantity] THEN 'Full Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) BETWEEN CAST(vps.[Received_Quantity] AS INT) AND [Purchase_Line_Ordered_Quantity] THEN 'Partial Receipt'
								WHEN CAST(vps.[Received_Quantity] AS INT) > [Purchase_Line_Ordered_Quantity] THEN 'Over Receipt'
							END
	  ,[Receipt_Percentage] = CASE WHEN [Purchase_Line_Ordered_Quantity] > 0 THEN vps.[Received_Quantity]/[Purchase_Line_Ordered_Quantity] ELSE 0 END					
	  ,[Commission_Charge_Percentage]
      ,[Tariff_Charge_Percentage]
      ,[Duty_Charge_Percentage]
      ,[Freight_Charge_Percentage]
      ,[Freight_In_Charge_Percentage]*/
      ,[Commission_Charge_Amount]
      ,[Tariff_Charge_Amount]
      ,[Duty_Charge_Amount]
      ,[Freight_Charge_Amount]
      ,[Freight_In_Charge_Amount]
      --,[Barcode]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
  FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
  LEFT JOIN [CWC_DW].[Dimension].[Dates] ad ON po.Purchase_Order_Header_Accounting_Date = ad.Calendar_Date
  LEFT JOIN [CWC_DW].[Dimension].[Dates] cd ON po.[Purchase_Line_Confirmed_Delivery_Date] = cd.Calendar_Date
  LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
  WHERE po.is_Removed_From_Source = 0;

