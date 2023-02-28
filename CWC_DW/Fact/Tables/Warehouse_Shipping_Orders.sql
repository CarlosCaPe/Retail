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
create  TRIGGER [Fact].[tr_Warehouse_Shipping_Orders_Audit] 
ON [Fact].Warehouse_Shipping_Orders
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @Operation char(1)
    DECLARE @RecordCount int
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        IF EXISTS (SELECT * FROM deleted)
        BEGIN
            SET @Operation = 'U'
            SET @RecordCount = (SELECT COUNT(*) FROM inserted) -- use inserted table to count records
        END
        ELSE
        BEGIN
            SET @Operation = 'I'
            SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for insert operations
        END
    END
    ELSE
    BEGIN
        SET @Operation = 'D'
        SET @RecordCount = @@ROWCOUNT -- use @@ROWCOUNT for delete operations
    END
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Warehouse_Shipping_Orders]', @Operation, @RecordCount
END