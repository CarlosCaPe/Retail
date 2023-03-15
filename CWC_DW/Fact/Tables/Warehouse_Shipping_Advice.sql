CREATE TABLE [Fact].[Warehouse_Shipping_Advice] (
    [Warehouse_Shipping_Advice_Key] INT             IDENTITY (1, 1) NOT NULL,
    [Sales_Key]                     INT             NOT NULL,
    [Shipping_Advice_Cancel_Key]    TINYINT         NOT NULL,
    [Pick_ID]                       VARCHAR (20)    NULL,
    [TP_Part_ID]                    VARCHAR (25)    NULL,
    [Invent_Trans_ID]               VARCHAR (15)    NULL,
    [Sales_Order_Number]            VARCHAR (25)    NULL,
    [VP_ID]                         INT             NULL,
    [Created_Date]                  DATETIME2 (3)   NULL,
    [Exported_Date]                 DATETIME2 (3)   NULL,
    [Ship_Quantity]                 NUMERIC (18, 2) NULL,
    [UPC]                           VARCHAR (30)    NULL,
    [Tracking_Number]               VARCHAR (100)   NULL,
    [is_Removed_From_Source]        BIT             NULL,
    [ETL_Created_Date]              DATETIME2 (5)   NULL,
    [ETL_Modified_Date]             DATETIME2 (5)   NULL,
    [ETL_Modified_Count]            SMALLINT        NULL,
    CONSTRAINT [PK_Warehouse_Shipping_Advice] PRIMARY KEY CLUSTERED ([Warehouse_Shipping_Advice_Key] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Warehouse_Shipping_Advice_Audit] ON [Fact].Warehouse_Shipping_Advice
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
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Warehouse_Shipping_Advice_Key = d.Warehouse_Shipping_Advice_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Warehouse_Shipping_Advice_Key = d.Warehouse_Shipping_Advice_Key
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Warehouse_Shipping_Advice]'
		,@Operation
		,@RecordCount
END