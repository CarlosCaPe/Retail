CREATE TABLE [Fact].[Backorders] (
    [Snapshot_Date_Key]                 INT             NOT NULL,
    [Sales_Key]                         INT             NOT NULL,
    [Sales_Order_Number]                VARCHAR (50)    NOT NULL,
    [Sales_Line_Number]                 INT             NOT NULL,
    [Invent_Trans_ID]                   INT             NULL,
    [Return_Invent_Trans_ID]            INT             NULL,
    [Sales_Header_Customer_Key]         INT             NULL,
    [Sales_Header_Property_Key]         SMALLINT        NULL,
    [Sales_Header_Location_Key]         INT             NULL,
    [Sales_Line_Property_Key]           SMALLINT        NULL,
    [Sales_Line_Product_Key]            INT             NOT NULL,
    [Shipping_Inventory_Warehouse_Key]  TINYINT         NOT NULL,
    [Sales_Line_Employee_Key]           SMALLINT        NULL,
    [Sales_Order_Attribute_Key]         TINYINT         NULL,
    [Sales_Line_Amount]                 NUMERIC (32, 6) NOT NULL,
    [Sales_Line_Discount_Amount]        NUMERIC (32, 6) NOT NULL,
    [Sales_Line_Cost_Price]             NUMERIC (32, 6) NOT NULL,
    [Sales_Line_Discount_Percentage]    NUMERIC (32, 6) NOT NULL,
    [Multi_Line_Discount_Code]          NUMERIC (32, 6) NOT NULL,
    [Multi_Line_Discount_Percentage]    NUMERIC (32, 6) NOT NULL,
    [Sales_Line_Reserve_Quantity]       SMALLINT        NULL,
    [Sales_Line_Ordered_Quantity]       SMALLINT        NULL,
    [Sales_Line_Price_Quantity]         SMALLINT        NULL,
    [Sales_Line_Remain_Sales_Physical]  SMALLINT        NULL,
    [Sales_Header_Modified_Date]        DATETIME2 (5)   NULL,
    [Sales_Header_Created_Date]         DATETIME2 (5)   NULL,
    [Sales_Line_Modified_Date]          DATETIME2 (5)   NULL,
    [Sales_Line_Created_Date]           DATETIME2 (5)   NULL,
    [Sales_Line_Confirmed_Date]         DATETIME2 (5)   NULL,
    [Sales_Line_Confirmed_Receipt_Date] DATETIME2 (5)   NULL,
    [Sales_Line_Requested_Receipt_Date] DATETIME2 (5)   NULL,
    [Sales_Line_Created_By]             NVARCHAR (20)   NOT NULL,
    [is_Removed_From_Source]            BIT             NULL,
    [is_Excluded]                       BIT             NULL,
    [ETL_Created_Date]                  DATETIME2 (5)   NULL,
    [ETL_Modified_Date]                 DATETIME2 (5)   NULL,
    [ETL_Modified_Count]                TINYINT         NULL,
    [Invoice_Key]                       INT             NULL,
    [Sales_Order_Fill_Key]              TINYINT         NULL,
    [Sales_Line_Price]                  NUMERIC (32, 6) NULL,
    [Sales_Margin_Key]                  TINYINT         NULL,
    [Extended_Sale_Amount]              NUMERIC (38, 6) NULL,
    [Sales_Discount_Total]              NUMERIC (38, 6) NULL,
    [Sales_Margin]                      NUMERIC (38, 6) NULL,
    [Sales_Margin_Rate]                 NUMERIC (38, 6) NULL,
    [Extended_Sale_Cost]                NUMERIC (38, 6) NULL,
    [Sales_Line_Ordered_Sales_Quantity] SMALLINT        NULL,
    [Sales_Line_Created_Date_EST]       DATETIME2 (5)   NULL,
    [Source_CD]                         VARCHAR (50)    NULL,
    [Catalog_Promotion_Key]             INT             NULL,
    CONSTRAINT [PK_Backorders] PRIMARY KEY CLUSTERED ([Snapshot_Date_Key] ASC, [Sales_Key] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Snapshot_Date_Key_is_Removed_From_Source]
    ON [Fact].[Backorders]([Snapshot_Date_Key] ASC, [is_Removed_From_Source] ASC)
    INCLUDE([Sales_Line_Amount], [Sales_Line_Remain_Sales_Physical], [Sales_Line_Ordered_Sales_Quantity]);


GO
 CREATE TRIGGER [Fact].[tr_Backorders_Audit] ON [Fact].Backorders
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
					INNER JOIN deleted d ON i.Snapshot_Date_Key= d.Snapshot_Date_Key and i.Sales_Key= d.Sales_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Snapshot_Date_Key= d.Snapshot_Date_Key and i.Sales_Key= d.Sales_Key
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

	EXEC [Administration].[usp_Audit_Table_Insert] '[Fact].[Backorders]'
		,@Operation
		,@RecordCount
END