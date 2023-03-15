CREATE PROCEDURE [Administration].[usp_Audit_Table_Insert] @TableName VARCHAR(100)
	,@Operation CHAR(1)
	,@RecordCount INT
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO Administration.Audit_Table (
		Table_Name
		,Operation
		,Record_Count
		,Audit_Date
		)
	VALUES (
		@TableName
		,@Operation
		,@RecordCount
		,GETDATE()
		);
END