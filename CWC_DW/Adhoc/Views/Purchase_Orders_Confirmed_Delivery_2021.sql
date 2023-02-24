/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [Adhoc].[Purchase_Orders_Confirmed_Delivery_2021]
AS


WITH Vendor_Packing_Slips AS
(
    SELECT Purchase_Order_Key,Received_Quantity = SUM([Vendor_Packing_Slip_Quantity])
    FROM [CWC_DW].[Fact].[Vendor_Packing_Slips] (NOLOCK)
	GROUP BY Purchase_Order_Key
)
SELECT 
	    --[Purchase_Order_Key]
       po.[Purchase_Order_Number]
      ,po.[Purchase_Order_Line_Number]
      --,[Invent_Trans_ID]
      --,[Delivery_Location_Key]
      --,[Vendor_Key]
      --,[Purchase_Order_Property_Key]
      --,[Product_Key]
	  --,p.[Product_Varient_Number]
      ,[Department] = p.[Department_Name]
      ,[Class] = p.[Class_Name]
      ,[Item] = p.[Item_Name]
      ,[Color] = p.[Color_Name]
      ,[Size] = p.[Size_Name]
      ,[Style] = p.[Style_Name]
	  ,pop.[Purchase_Order_Header_Status]
      ,pop.[Purchase_Order_Line_Status]
      --,pop.[Purchase_Order_Header_Delivery_Mode_ID]
      --,pop.[Purchase_Order_Header_Delivery_Terms_ID]
      --,pop.[Purchase_Order_Header_Document_Approval_Status]
      --,pop.[Purchase_Order_Header_Buyer_Group_ID]
      --,pop.[Purchase_Order_Header_Payment_Terms_Name]
      --,pop.[Purchase_Order_Header_Vendor_Payment_Method_Name]
      ,po.[Purchase_Order_Name]
      ,po.[Purchase_Line_Description]
      ,po.[Purchase_Order_Header_Accounting_Date]
      ,po.[Purchase_Line_Confirmed_Delivery_Date]
      --,po.[Purchase_Line_Requested_Delivery_Date]
      --,po.[Purchase_Line_Confirmed_Shipping_Date]
      --,po.[Purchase_Line_Requested_Shipping_Date]
	  ,po.[Purchase_Line_Ordered_Quantity]
      ,po.[Purchase_Line_Amount]
      ,po.[Purchase_Line_Purchase_Price]
      --,po.[Purchase_Line_Discount_Amount]
	  ,[Purchase_Line_Received_Quantity] = CAST(vps.[Received_Quantity] AS INT)
      --,po.[Purchase_Line_Price_Quantity]
      
      --,po.[Commission_Charge_Percentage]
      --,po.[Tariff_Charge_Percentage]
      --,po.[Duty_Charge_Percentage]
      --,po.[Freight_Charge_Percentage]
      --,po.[Freight_In_Charge_Percentage]
      ,po.[Commission_Charge_Amount]
      ,po.[Tariff_Charge_Amount]
      ,po.[Duty_Charge_Amount]
      ,po.[Freight_Charge_Amount]
      ,po.[Freight_In_Charge_Amount]
      --,[Barcode]
      --,[is_Removed_From_Source]
      --,[is_Excluded]
      --,[ETL_Created_Date]
      --,[ETL_Modified_Date]
      --,[ETL_Modified_Count]
FROM [CWC_DW].[Fact].[Purchase_Orders] (NOLOCK) po
	INNER JOIN [CWC_DW].[Dimension].[Purchase_Order_Properties] (NOLOCK) pop ON po.[Purchase_Order_Property_Key] = pop.[Purchase_Order_Property_Key]
	INNER JOIN [CWC_DW].[Dimension].[Products] (NOLOCK) p ON p.[Product_Key] = po.[Product_Key]
	LEFT JOIN [Vendor_Packing_Slips] vps ON po.[Purchase_Order_Key] = vps.[Purchase_Order_Key]
WHERE (pop.[Purchase_Order_Header_Status] <> 'Canceled' AND pop.[Purchase_Order_Line_Status] <> 'Canceled')
	AND CAST(Purchase_Order_Header_Accounting_Date AS DATE) BETWEEN '8/31/2020' AND '1/2/2021'
	AND CAST(po.[Purchase_Line_Confirmed_Delivery_Date] AS DATE) BETWEEN '1/1/2021' AND '12/31/2021';
