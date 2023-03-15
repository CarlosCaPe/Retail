CREATE TABLE [Dimension].[Sales_Order_Attributes] (
    [Sales_Order_Attribute_Key] TINYINT      IDENTITY (1, 1) NOT NULL,
    [Order_Classification]      VARCHAR (15) NOT NULL,
    [Future_Return]             VARCHAR (75) NOT NULL,
    [On_Pick_List]              VARCHAR (25) NOT NULL,
    CONSTRAINT [PK_Sales_Order_Attributes] PRIMARY KEY CLUSTERED ([Sales_Order_Attribute_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Sales_Order_Attributes_Audit] ON [Dimension].[Sales_Order_Attributes]
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Sales_Order_Attributes]'
		,@Operation
		,@RecordCount
END