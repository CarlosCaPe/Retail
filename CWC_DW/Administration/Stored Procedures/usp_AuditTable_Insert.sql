CREATE PROCEDURE [Administration].[usp_AuditTable_Insert]
    @TableName varchar(100),
    @Operation char(1),
    @RecordCount int
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Administration.AuditTable (TableName, Operation, RecordCount, AuditDate)
    VALUES (@TableName, @Operation, @RecordCount, GETDATE());
END