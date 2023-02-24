CREATE PROC [Import].[usp_Sales_Order_Coupon_Usage Staging_Merge]

AS

WITH src AS
(
SELECT --TOP 5000
	 [Usage_ID] = USAGEID
	,[Sales_Order_Number] = CAST(SALESORDERNUMBER AS VARCHAR(25))
	,[Customer_Account_Number] = CAST(CUSTOMERACCOUNT AS VARCHAR(25))
	,[Coupon_CD] = CAST(rc.COUPONCODEID AS VARCHAR(25))
	,[Coupon_Number] = CAST(c.COUPONNUMBER AS VARCHAR(25))
	,[Discount_Offer_ID] = CAST(c.DISCOUNTOFFERID AS VARCHAR(25))
	,[Promotion_Description] = CAST(c.Description AS VARCHAR(250))
	,[Status] = CAST(c.STATUS AS BIT)
	,[is_Removed_From_Source] = CAST(0 AS BIT)
	,[is_Excluded] = CAST(0 AS BIT)
	,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
	,[ETL_Modified_Count] = CAST(1 AS TINYINT)
--INTO [AX_PRODUCTION].[dbo].[SalesOrderCouponUsage]
FROM [AX_PRODUCTION].[dbo].[RetailCouponUsageStaging] (NOLOCK) rc
	INNER JOIN [AX_PRODUCTION].[dbo].[ITSSalesOrderHeaderEntityStaging] (NOLOCK) so ON rc.SALESID = so.SALESORDERNUMBER
	INNER JOIN [AX_PRODUCTION].[dbo].[RetailCouponCodeTableStaging] (NOLOCK) cc ON rc.[COUPONCODEID] = cc.[COUPONCODEID]
	INNER JOIN [AX_PRODUCTION].[dbo].[RetailCouponStaging] (NOLOCK) c ON cc.[COUPONNUMBER] = c.[COUPONNUMBER]
  )
,tgt AS (SELECT * FROM [AX_PRODUCTION].[dbo].[SalesOrderCouponUsageStaging] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.[Usage_ID] = src.[Usage_ID]
		WHEN NOT MATCHED THEN
			INSERT([Usage_ID],[Sales_Order_Number],[Customer_Account_Number],[Coupon_CD],[Coupon_Number],[Discount_Offer_ID],[Promotion_Description],[Status],[is_Removed_From_Source]
				  ,[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Usage_ID],src.[Sales_Order_Number],src.[Customer_Account_Number],src.[Coupon_CD],src.[Coupon_Number],src.[Discount_Offer_ID],src.[Promotion_Description],src.[Status],src.[is_Removed_From_Source]
				  ,src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count]);
