CREATE TABLE [Fact].[Backorder_Summary] (
    [Backorder Date]             DATE            NOT NULL,
    [Backorder Amount]           NUMERIC (38, 6) NULL,
    [Backorder Units]            INT             NULL,
    [Backorder New Quantity]     INT             NULL,
    [Backorder New Amount]       NUMERIC (38, 6) NULL,
    [Backorder Shipped Amount]   NUMERIC (38, 6) NULL,
    [Backorder Shipped Quantity] INT             NULL,
    [Backorder Cancel Amount]    NUMERIC (38, 6) NULL,
    [Backorder Cancel Units]     INT             NULL
);






GO
 CREATE TRIGGER [Fact].[tr_Backorder_Summary_Audit] ON [Fact].[Backorder_Summary]
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Backorder_Summary]'
		,@Operation
		,@RecordCount
END