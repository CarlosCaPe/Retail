CREATE TABLE [Fact].[Sales_Remapping] (
    [Sales_Key]                     INT          NOT NULL,
    [Sales_Order_Number]            VARCHAR (50) NOT NULL,
    [Sales_Line_Number]             INT          NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT     NOT NULL,
    [Sales_Header_Property_Key_NEW] SMALLINT     NOT NULL,
    CONSTRAINT [PK_Sales_Remapping] PRIMARY KEY CLUSTERED ([Sales_Key] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Sales_Remapping_Audit] ON [Fact].Sales_Remapping
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Sales_Remapping]'
		,@Operation
		,@RecordCount
END