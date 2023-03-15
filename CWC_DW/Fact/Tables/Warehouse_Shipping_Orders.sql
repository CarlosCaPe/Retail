CREATE TABLE [Fact].[Warehouse_Shipping_Orders] (
    [Warehouse_Shipping_Order_Key] INT           IDENTITY (1, 1) NOT NULL,
    [Sales_Key]                    INT           NOT NULL,
    [Pick_ID]                      VARCHAR (50)  NOT NULL,
    [TP_Part_ID]                   VARCHAR (50)  NOT NULL,
    [Invent_Trans_ID]              VARCHAR (50)  NOT NULL,
    [Sales_Order_Number]           VARCHAR (50)  NOT NULL,
    [VP_ID]                        INT           NOT NULL,
    [Created_Date]                 DATETIME2 (5) NOT NULL,
    [Exported_Date]                DATETIME2 (5) NOT NULL,
    [Pick_Quantity]                SMALLINT      NOT NULL,
    [UPC]                          VARCHAR (50)  NOT NULL,
    [is_Removed_From_Source]       BIT           NOT NULL,
    [ETL_Created_Date]             DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]            DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]           SMALLINT      NOT NULL,
    CONSTRAINT [PK_Warehouse_Shipping_Orders] PRIMARY KEY CLUSTERED ([Warehouse_Shipping_Order_Key] ASC),
    CONSTRAINT [UK_Pick_ID_Sales_Key] UNIQUE NONCLUSTERED ([Pick_ID] ASC, [Sales_Key] ASC, [VP_ID] ASC)
);






GO
 CREATE TRIGGER [Fact].[tr_Warehouse_Shipping_Orders_Audit] ON [Fact].Warehouse_Shipping_Orders
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
					INNER JOIN deleted d ON i.Warehouse_Shipping_Order_Key = d.Warehouse_Shipping_Order_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Warehouse_Shipping_Order_Key = d.Warehouse_Shipping_Order_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Warehouse_Shipping_Orders]'
		,@Operation
		,@RecordCount
END