
CREATE  VIEW [Administration].[Audit_Report]
AS
 
WITH Latest_Executions AS (
    SELECT 
        PROCEDURE_NAME,
        Execution_Start_Date,
        Execution_End_Date,
        Execution_Elapsed_Time_Minutes,
        Execution_Status,
        Execution_Merge_Rows,
        Updated_Rows,
        Inserted_Rows,
        Logical_Deleted_Rows,
        ROW_NUMBER() OVER (PARTITION BY PROCEDURE_NAME ORDER BY Execution_Start_Date DESC) AS RowNum,
        SUM(Execution_Elapsed_Time_Minutes) OVER (PARTITION BY PROCEDURE_NAME) AS Total_Execution_Elapsed_Time_Minutes
    FROM [Administration].[Audit_By_Procedure_Execution]
)

SELECT 
    LE.PROCEDURE_NAME,
    COUNT(LE.Execution_Start_Date) AS Executions,
    MAX(CASE WHEN LE.RowNum = 1 THEN LE.Execution_Start_Date END) AS Last_Execution_Start_Date,
    MAX(CASE WHEN LE.RowNum = 1 THEN LE.Execution_End_Date END) AS Last_Execution_End_Date,

	MAX(CASE	WHEN LE.RowNum = 1  THEN LE.Execution_Elapsed_Time_Minutes END) AS Last_Execution_Elapsed_Time_Minutes,
	((MAX(CASE	WHEN LE.RowNum = 1  THEN LE.Execution_Elapsed_Time_Minutes END)) *100)/ (SUM(MAX(CASE WHEN LE.RowNum = 1 THEN LE.Execution_Elapsed_Time_Minutes END)) over()) AS [Last_Execution_Elapsed_Time_%],
    MAX(CASE WHEN LE.RowNum = 1 THEN LE.Execution_Status END) AS Last_Execution_Status,
    MAX(CASE WHEN LE.RowNum = 1 THEN LE.Execution_Merge_Rows END) AS Last_Execution_Merge_Rows,
	MAX(CASE WHEN LE.RowNum = 1 THEN LE.Updated_Rows END) AS Last_Updated_Rows,
	MAX(CASE WHEN LE.RowNum = 1 THEN LE.Inserted_Rows END) AS Last_Inserted_Rows,
    MAX(CASE WHEN LE.RowNum = 1 THEN LE.Logical_Deleted_Rows END) AS Last_Logical_Deleted_Rows,
	AVG(CASE	WHEN LE.RowNum <> 1 THEN LE.Execution_Elapsed_Time_Minutes ELSE ABPE.Execution_Elapsed_Time_Minutes END) AS AVG_Execution_Elapsed_Time_Minutes,
	((AVG(CASE	WHEN LE.RowNum <> 1 THEN LE.Execution_Elapsed_Time_Minutes ELSE ABPE.Execution_Elapsed_Time_Minutes END)) *100)/ (SUM(AVG(CASE WHEN LE.RowNum <> 1 THEN LE.Execution_Elapsed_Time_Minutes ELSE ABPE.Execution_Elapsed_Time_Minutes END)) over()) AS [AVG_Execution_Elapsed_Time_%],
    AVG(CASE WHEN LE.RowNum <> 1 THEN LE.Execution_Merge_Rows ELSE ABPE.Execution_Merge_Rows END) AS AVG_Execution_Merge_Rows,
    AVG(CASE WHEN LE.RowNum <> 1 THEN LE.Updated_Rows ELSE ABPE.Updated_Rows END) AS AVG_Updated_Rows,
    AVG(CASE WHEN LE.RowNum <> 1 THEN LE.Inserted_Rows ELSE ABPE.Inserted_Rows END) AS AVG_Inserted_Rows,
    AVG(CASE WHEN LE.RowNum <> 1 THEN LE.Logical_Deleted_Rows ELSE ABPE.Logical_Deleted_Rows END) AS AVG_Logical_Deleted_Rows
FROM 
    Latest_Executions LE
    LEFT JOIN [Administration].[Audit_By_Procedure_Execution] ABPE ON LE.PROCEDURE_NAME = ABPE.PROCEDURE_NAME
GROUP BY 
    LE.PROCEDURE_NAME;