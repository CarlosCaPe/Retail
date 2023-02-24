CREATE PROCEDURE [Import].[usp_Fact_Credit_Card_Declines_Merge]

AS

WITH Declines AS
(
	SELECT
		 Sales_Order_Number = SalesID
        ,Decline_Date = APPROVEDDATETIME
		--,Decline_Count = COUNT(*)
		,Authorization_Amount = cc.APPROVALAMOUNTCUR
		,Message_Description = cc.DESCRIPTION
		,Seq_First_Decline = ROW_NUMBER() OVER(PARTITION BY SalesID ORDER BY APPROVEDDATETIME)
		,Seq_Last_Decline = ROW_NUMBER() OVER(PARTITION BY SalesID ORDER BY APPROVEDDATETIME DESC)
	FROM [AX_PRODUCTION].[dbo].ITSCreditCardAuthTransStaging (NOLOCK) cc
	WHERE CAST(APPROVEDDATETIME AS DATE) > CAST('12/1/2020' AS DATE) AND DESCRIPTION LIKE '%Decline%'
)
,Sales_Orders AS
(
SELECT DISTINCT
	 [Sales_Order_Number]
    ,[Sales_Header_Customer_Key]
    ,[Sales_Header_Property_Key]
    ,[Sales_Header_Location_Key]
    ,[Sales_Header_Created_Date]
	,Seq = ROW_NUMBER() OVER(PARTITION BY [Sales_Order_Number] ORDER BY Sales_Line_Created_Date)
FROM [CWC_DW].[Fact].[Sales] (NOLOCK)
)
,Sales_Order AS
(
SELECT DISTINCT
	 [Sales_Order_Number]
    ,[Sales_Header_Customer_Key]
    ,[Sales_Header_Property_Key]
    ,[Sales_Header_Location_Key]
    ,[Sales_Header_Created_Date]
FROM Sales_Orders
WHERE Seq = 1
)
,First_Decline AS
(
	SELECT
		 Sales_Order_Number
		,First_Decline_Date = Decline_Date
		,First_Decline_Message = Message_Description
		,First_Decline_Amount = Authorization_Amount
	FROM Declines
	WHERE Seq_First_Decline = 1
)
,Last_Decline AS
(
	SELECT
		 Sales_Order_Number
		,Last_Decline_Date = Decline_Date
		,Last_Decline_Message = Message_Description
		,Last_Decline_Amount = Authorization_Amount
	FROM Declines
	WHERE Seq_Last_Decline = 1
)
,Decline_Total AS
(
	SELECT
		 Sales_Order_Number = SalesID
		,Decline_Count = COUNT(*)
	FROM [AX_PRODUCTION].[dbo].ITSCreditCardAuthTransStaging (NOLOCK) cc
	WHERE CAST(APPROVEDDATETIME AS DATE) > cast('12/1/2020' AS DATE) AND DESCRIPTION LIKE '%Decline%'
	GROUP BY SalesID
)
,Successes AS
(
	SELECT
		 Sales_Order_Number = SalesID
        ,Success_Date = APPROVEDDATETIME
		--,Success_Count = COUNT(*)
		,Authorization_Amount = cc.APPROVALAMOUNTCUR
		,Success_Description = cc.DESCRIPTION
		,Seq_First_Success = ROW_NUMBER() OVER(PARTITION BY SalesID ORDER BY APPROVEDDATETIME)
		,Seq_Last_Success = ROW_NUMBER() OVER(PARTITION BY SalesID ORDER BY APPROVEDDATETIME DESC)
	FROM [AX_PRODUCTION].[dbo].ITSCreditCardAuthTransStaging (NOLOCK) cc
	WHERE CAST(APPROVEDDATETIME AS DATE) > cast('12/1/2020' AS DATE) AND DESCRIPTION LIKE '%Successful%'
)
,First_Success AS
(
	SELECT
		 Sales_Order_Number
		,First_Success_Date = Success_Date
		,First_Success_Message = Success_Description
		,First_Success_Amount = Authorization_Amount
	FROM Successes
	WHERE Seq_First_Success = 1
) --SELECT * FROM First_Success
,Last_Success AS
(
	SELECT
		 Sales_Order_Number
		,Last_Success_Date = Success_Date
		,Last_Success_Message = Success_Description
		,Last_Success_Amount = Authorization_Amount
	FROM Successes
	WHERE Seq_Last_Success = 1
) --SELECT * FROM Last_Success
,Success_Total AS
(
	SELECT
		 Sales_Order_Number = SalesID
		,Success_Count = COUNT(*)
	FROM [AX_PRODUCTION].[dbo].ITSCreditCardAuthTransStaging (NOLOCK) cc
	WHERE CAST(APPROVEDDATETIME AS DATE) > cast('12/1/2020' AS DATE) AND DESCRIPTION LIKE '%Successful%'
	GROUP BY SalesID
)

,src AS
(
	SELECT 
		 Sales_Order_Number = CAST(fd.Sales_Order_Number AS VARCHAR(25))
		,Credit_Card_Authorization_Key = CASE WHEN ls.Last_Success_Date > ld.Last_Decline_Date THEN 1
						WHEN ls.Last_Success_Date < ld.Last_Decline_Date THEN 3
						ELSE 2
					END
		,[Sales_Header_Customer_Key]
		,[Sales_Header_Property_Key]
		,[Sales_Header_Location_Key]
		,[Sales_Header_Created_Date]
		,Decline_Count = dt.Decline_Count
		,fd.First_Decline_Date
		,Last_Decline_Date = CAST(ld.Last_Decline_Date AS DATETIME2(5))
		,fd.First_Decline_Amount
		,ld.Last_Decline_Amount
		,Success_Count = st.Success_Count
		,First_Success_Date = CAST(fs.First_Success_Date AS DATETIME2(5))
		,Last_Success_Date = CAST(ls.Last_Success_Date AS DATETIME2(5))
		,fs.First_Success_Amount
		,ls.Last_Success_Amount
		,[is_Removed_From_Source] = CAST(0 AS BIT)
		,[is_Excluded] = CAST(0 AS BIT)
		,[ETL_Created_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
		,[ETL_Modified_Count] = CAST(1 AS SMALLINT)
	--INTO Fact.Credit_Card_Declines
	FROM First_Decline fd --ON d.Sales_Order_Number = fd.Sales_Order_Number
		LEFT JOIN Last_Decline ld ON fd.Sales_Order_Number = ld.Sales_Order_Number
		LEFT JOIN Decline_Total dt ON fd.Sales_Order_Number = dt.Sales_Order_Number
		LEFT JOIN First_Success fs ON fd.Sales_Order_Number = fs.Sales_Order_Number
		LEFT JOIN Last_Success ls ON fd.Sales_Order_Number = ls.Sales_Order_Number
		LEFT JOIN Success_Total st ON fd.Sales_Order_Number = st.Sales_Order_Number
		LEFT JOIN Sales_Order s ON fd.Sales_Order_Number = s.Sales_Order_Number 
) --SELECT * FROM src
,tgt AS (SELECT * FROM [CWC_DW].[Fact].[Credit_Card_Declines] (NOLOCK))

MERGE INTO tgt USING src
	ON tgt.Sales_Order_Number = src.Sales_Order_Number
		WHEN NOT MATCHED THEN
			INSERT([Sales_Order_Number],[Credit_Card_Authorization_Key],[Sales_Header_Customer_Key],[Sales_Header_Property_Key],[Sales_Header_Location_Key] ,[Sales_Header_Created_Date]
				  ,[Decline_Count],[First_Decline_Date],[Last_Decline_Date],[First_Decline_Amount],[Last_Decline_Amount],[Success_Count],[First_Success_Date] ,[Last_Success_Date]
			      ,[First_Success_Amount],[Last_Success_Amount],[is_Removed_From_Source],[is_Excluded],[ETL_Created_Date],[ETL_Modified_Date],[ETL_Modified_Count])
			VALUES(src.[Sales_Order_Number],src.[Credit_Card_Authorization_Key],src.[Sales_Header_Customer_Key],src.[Sales_Header_Property_Key],src.[Sales_Header_Location_Key] ,src.[Sales_Header_Created_Date]
				  ,src.[Decline_Count],src.[First_Decline_Date],src.[Last_Decline_Date],src.[First_Decline_Amount],src.[Last_Decline_Amount],src.[Success_Count],src.[First_Success_Date] ,src.[Last_Success_Date]
			      ,src.[First_Success_Amount],src.[Last_Success_Amount],src.[is_Removed_From_Source],src.[is_Excluded],src.[ETL_Created_Date],src.[ETL_Modified_Date],src.[ETL_Modified_Count])
		WHEN MATCHED AND
			     ISNULL(tgt.[Credit_Card_Authorization_Key],'') <> ISNULL(src.[Credit_Card_Authorization_Key],'')
			  OR ISNULL(tgt.[Sales_Header_Customer_Key],'') <> ISNULL(src.[Sales_Header_Customer_Key],'')
			  OR ISNULL(tgt.[Sales_Header_Property_Key],'') <> ISNULL(src.[Sales_Header_Property_Key],'')
			  OR ISNULL(tgt.[Sales_Header_Location_Key],'') <> ISNULL(src.[Sales_Header_Location_Key],'')
			  OR ISNULL(tgt.[Sales_Header_Created_Date],'') <> ISNULL(src.[Sales_Header_Created_Date],'')
			  OR ISNULL(tgt.[Decline_Count],0) <> ISNULL(src.[Decline_Count],0)
			  OR ISNULL(tgt.[First_Decline_Date],'') <> ISNULL(src.[First_Decline_Date],'')
			  OR ISNULL(tgt.[Last_Decline_Date],'') <> ISNULL(src.[Last_Decline_Date],'')
			  OR ISNULL(tgt.[First_Decline_Amount],-1) <> ISNULL(src.[First_Decline_Amount],-1)
			  OR ISNULL(tgt.[Last_Decline_Amount],-1) <> ISNULL(src.[Last_Decline_Amount],-1)
			  OR ISNULL(tgt.[Success_Count],0) <> ISNULL(src.[Success_Count],0)
			  OR ISNULL(tgt.[First_Success_Date],'') <> ISNULL(src.[First_Success_Date],'')
			  OR ISNULL(tgt.[Last_Success_Date],'') <> ISNULL(src.[Last_Success_Date],'')
			  OR ISNULL(tgt.[First_Success_Amount],-1) <> ISNULL(src.[First_Success_Amount],-1)
			  OR ISNULL(tgt.[Last_Success_Amount],-1) <> ISNULL(src.[Last_Success_Amount],-1)
			  OR ISNULL(tgt.[is_Removed_From_Source],'') <> ISNULL(src.[is_Removed_From_Source],'')
			  --OR ISNULL(tgt.[is_Excluded],'') <> ISNULL(src.[is_Excluded],'')
			  --OR ISNULL(tgt.[ETL_Created_Date],'') <> ISNULL(src.[ETL_Created_Date],'')
			  --OR ISNULL(tgt.[ETL_Modified_Date],'') <> ISNULL(src.[ETL_Modified_Date],'')
			  --OR ISNULL(tgt.[ETL_Modified_Count],'') <> ISNULL(src.[ETL_Modified_Count],'')
		THEN UPDATE SET
			   [Credit_Card_Authorization_Key] = src.[Credit_Card_Authorization_Key]
			  ,[Sales_Header_Customer_Key] = src.[Sales_Header_Customer_Key]
			  ,[Sales_Header_Property_Key] = src.[Sales_Header_Property_Key]
			  ,[Sales_Header_Location_Key] = src.[Sales_Header_Location_Key]
			  ,[Sales_Header_Created_Date] = src.[Sales_Header_Created_Date]
			  ,[Decline_Count] = src.[Decline_Count]
			  ,[First_Decline_Date] = src.[First_Decline_Date]
			  ,[Last_Decline_Date] = src.[Last_Decline_Date]
			  ,[First_Decline_Amount] = src.[First_Decline_Amount]
			  ,[Last_Decline_Amount] = src.[Last_Decline_Amount]
			  ,[Success_Count] = src.[Success_Count]
			  ,[First_Success_Date] = src.[First_Success_Date]
			  ,[Last_Success_Date] = src.[Last_Success_Date]
			  ,[First_Success_Amount] = src.[First_Success_Amount]
			  ,[Last_Success_Amount] = src.[Last_Success_Amount]
			  ,[is_Removed_From_Source] = src.[is_Removed_From_Source]
			  ,[ETL_Modified_Date] = src.[ETL_Modified_Date]
			  ,[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1)
		WHEN NOT MATCHED BY SOURCE AND tgt.[is_Removed_From_Source] <> 1 THEN UPDATE SET
			   tgt.[is_Removed_From_Source] = 1
			  ,tgt.[ETL_Modified_Date] = CAST(SYSUTCDATETIME() AS DATETIME2(5))
			  ,tgt.[ETL_Modified_Count] = (ISNULL(tgt.[ETL_Modified_Count],1) + 1);