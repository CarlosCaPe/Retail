CREATE TABLE [Fact].[Invoices] (
    [Invoice_Key]                          INT             IDENTITY (1, 1) NOT NULL,
    [Invoice_Number]                       VARCHAR (50)    NOT NULL,
    [Invoice_Line_Number]                  INT             NOT NULL,
    [Sales_Key]                            INT             NULL,
    [Sales_Order_Number]                   VARCHAR (50)    NULL,
    [Invent_Trans_ID]                      INT             NULL,
    [Invoice_Line_Product_Key]             INT             NULL,
    [Invoice_Line_Product_Number]          VARCHAR (70)    NULL,
    [Invoice_Customer_Key]                 INT             NULL,
    [Invoice_Customer_Account_Number]      VARCHAR (50)    NULL,
    [Invoice_Property_Key]                 SMALLINT        NULL,
    [Invoice_Header_Date]                  DATE            NULL,
    [Invoice_Line_Date]                    DATE            NULL,
    [Invoice_Line_Confirmed_Shipping_Date] DATE            NULL,
    [Invoice_Line_Delivery_Date]           DATE            NULL,
    [Invoice_Line_Quantity]                SMALLINT        NULL,
    [Invoice_Line_Sales_Price]             NUMERIC (32, 6) NOT NULL,
    [Invoice_Line_Amount]                  NUMERIC (32, 6) NOT NULL,
    [Invoice_Line_Tax_Amount]              NUMERIC (32, 6) NOT NULL,
    [Invoice_Line_Charge_Amount]           NUMERIC (32, 6) NOT NULL,
    [Invoice_Line_Discount_Amount]         NUMERIC (32, 6) NOT NULL,
    [is_Removed_From_Source]               BIT             NULL,
    [is_Excluded]                          BIT             NULL,
    [ETL_Created_Date]                     DATETIME2 (5)   NULL,
    [ETL_Modified_Date]                    DATETIME2 (5)   NULL,
    [ETL_Modified_Count]                   TINYINT         NULL,
    [Invoice_Line_Date_Key]                INT             NULL,
    [Invoice_Attribute_Key]                TINYINT         NULL,
    [Invoice_Header_Total_Charge_Amount]   NUMERIC (18, 4) NULL,
    CONSTRAINT [PK_Invoices] PRIMARY KEY CLUSTERED ([Invoice_Key] ASC),
    CONSTRAINT [UK_Invoices] UNIQUE NONCLUSTERED ([Invoice_Number] ASC, [Invoice_Line_Number] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Sales_Key]
    ON [Fact].[Invoices]([Sales_Key] ASC)
    INCLUDE([Invoice_Property_Key], [Invoice_Line_Delivery_Date], [Invoice_Line_Date_Key]);


GO
CREATE NONCLUSTERED INDEX [IX_Invent_Trans_ID]
    ON [Fact].[Invoices]([Invent_Trans_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_Line_Quantity]
    ON [Fact].[Invoices]([Invoice_Line_Date] ASC, [Invoice_Line_Quantity] ASC)
    INCLUDE([Sales_Key], [Invoice_Line_Product_Key], [Invoice_Line_Amount], [Invoice_Attribute_Key]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_Line_Product_Key]
    ON [Fact].[Invoices]([Invoice_Line_Product_Key] ASC)
    INCLUDE([Sales_Key], [Invoice_Attribute_Key]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_Date]
    ON [Fact].[Invoices]([Invoice_Line_Date] ASC)
    INCLUDE([Invoice_Number], [Invoice_Line_Number], [Sales_Key], [Invoice_Line_Product_Key], [Invoice_Property_Key], [Invoice_Line_Quantity], [Invoice_Line_Amount], [Invoice_Line_Tax_Amount], [Invoice_Line_Charge_Amount], [Invoice_Line_Discount_Amount], [Invoice_Line_Date_Key], [Invoice_Attribute_Key], [Invoice_Header_Total_Charge_Amount]);


GO
CREATE NONCLUSTERED INDEX [IX_Invoice_Number_Invoice_Line_Date]
    ON [Fact].[Invoices]([Invoice_Number] ASC, [Invoice_Line_Date] ASC)
    INCLUDE([Invoice_Line_Number], [Invent_Trans_ID], [Invoice_Line_Product_Key], [Invoice_Customer_Key], [Invoice_Property_Key], [Invoice_Line_Quantity], [Invoice_Line_Amount], [Invoice_Line_Discount_Amount], [Invoice_Attribute_Key], [Invoice_Header_Total_Charge_Amount]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Invoices_1541_1540]
    ON [Fact].[Invoices]([Invoice_Attribute_Key] ASC, [Invoice_Line_Date] ASC)
    INCLUDE([Invoice_Number], [Invent_Trans_ID]);


GO
CREATE TRIGGER [Fact].[tr_Invoices_Audit] 
ON [Fact].Invoices 
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
    EXEC [Administration].[usp_AuditTable_Insert] '[Fact].[Invoices]', @Operation, @RecordCount
END