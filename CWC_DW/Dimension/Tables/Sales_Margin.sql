CREATE TABLE [Dimension].[Sales_Margin] (
    [Sales_Margin_Key]       TINYINT      IDENTITY (1, 1) NOT NULL,
    [Sales_Margin_Threshold] VARCHAR (25) NOT NULL,
    [Sales_Margin_Index]     TINYINT      NOT NULL,
    [Start_Range]            SMALLINT     NULL,
    [Stop_Range]             SMALLINT     NULL,
    PRIMARY KEY CLUSTERED ([Sales_Margin_Key] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Sales_Margin_Audit] ON [Dimension].[Sales_Margin]
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Sales_Margin]'
		,@Operation
		,@RecordCount
END