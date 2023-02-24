CREATE VIEW Analytics.v_Dim_Employees_By_User_ID

AS

WITH User_Dedup AS
	(
		SELECT 
			 [Employee_Key]
      ,[Personnel_Number]
      ,[User_ID]
      ,[Employee_Full_Name]
      ,[License_Source]
      --,[Start_Date]
      --,[End_Date]
		,Seq = ROW_NUMBER() OVER(PARTITION BY User_ID ORDER BY Employee_Key DESC)
		FROM [CWC_DW].[Dimension].[Employees] (NOLOCK)
		WHERE User_ID IS NOT NULL
	)
SELECT
	   [Employee_Key]
      ,[Personnel_Number]
      ,[User_ID]
      ,[Employee_Full_Name]
      ,[License_Source]
      --,[Start_Date]
      --,[End_Date]
FROM User_Dedup
WHERE Seq = 1