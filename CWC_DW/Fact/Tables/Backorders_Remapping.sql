CREATE TABLE [Fact].[Backorders_Remapping] (
    [Snapshot_Date_Key]             INT      NOT NULL,
    [Sales_Key]                     INT      NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT NULL,
    [Sales_Header_Property_Key_New] SMALLINT NULL
);






GO
 CREATE TRIGGER [Fact].[tr_Backorders_Remapping_Audit] ON [Fact].Backorders_Remapping
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			SET @Operation = 'U'	
			SET @RecordCount = (	
					SELECT COUNT(*)	
					FROM inserted	
					)
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Backorders_Remapping]'
		,@Operation
		,@RecordCount
END