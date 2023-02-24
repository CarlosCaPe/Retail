CREATE TABLE [Fact].[Vendor_Packing_Slips] (
    [Vendor_Packing_Slip_Key]        INT            IDENTITY (1, 1) NOT NULL,
    [Vendor_Packing_Slip_ID]         VARCHAR (50)   NOT NULL,
    [Invent_Trans_ID]                VARCHAR (50)   NOT NULL,
    [Vendor_Account_Number]          VARCHAR (50)   NOT NULL,
    [Purchase_Order_Number]          VARCHAR (50)   NOT NULL,
    [Purchase_Order_Line_Number]     INT            NOT NULL,
    [Purchase_Order_Key]             INT            NOT NULL,
    [Vendor_Key]                     SMALLINT       NULL,
    [Product_Key]                    INT            NULL,
    [Delivery_Location_Key]          INT            NULL,
    [Purchase_Order_Name]            VARCHAR (100)  NOT NULL,
    [Purchase_Line_Description]      VARCHAR (1000) NOT NULL,
    [Vendor_Packing_Slip_Quantity]   INT            NOT NULL,
    [Vendor_Packing_Trans_Rec_ID]    BIGINT         NOT NULL,
    [Vendor_Packing_Accounting_Date] DATE           NOT NULL,
    [is_Backordered_Product]         BIT            NULL,
    [is_Removed_From_Source]         BIT            NOT NULL,
    [is_Excluded]                    BIT            NOT NULL,
    [ETL_Created_Date]               DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Date]              DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Count]             TINYINT        NOT NULL,
    CONSTRAINT [PK_Vendor_Packing_Slips] PRIMARY KEY CLUSTERED ([Vendor_Packing_Slip_Key] ASC),
    CONSTRAINT [UK_Vendor_Packing_Slips] UNIQUE NONCLUSTERED ([Vendor_Packing_Slip_ID] ASC, [Invent_Trans_ID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_Purchase_Order_Key]
    ON [Fact].[Vendor_Packing_Slips]([Purchase_Order_Key] ASC)
    INCLUDE([Vendor_Packing_Slip_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Vendor_Packing_Slips_213_212]
    ON [Fact].[Vendor_Packing_Slips]([Vendor_Packing_Slip_Quantity] ASC, [Vendor_Packing_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Purchase_Order_Key], [Product_Key]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Vendor_Packing_Slips_191_190]
    ON [Fact].[Vendor_Packing_Slips]([Vendor_Packing_Slip_Quantity] ASC, [Vendor_Packing_Accounting_Date] ASC)
    INCLUDE([Invent_Trans_ID], [Purchase_Order_Number], [Purchase_Order_Line_Number], [Purchase_Order_Key], [Product_Key]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Vendor_Packing_Slips_187_186]
    ON [Fact].[Vendor_Packing_Slips]([Vendor_Packing_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Key], [Product_Key], [Vendor_Packing_Slip_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Vendor_Packing_Slips_145_144]
    ON [Fact].[Vendor_Packing_Slips]([Vendor_Packing_Accounting_Date] ASC)
    INCLUDE([Vendor_Packing_Slip_Quantity], [is_Backordered_Product]);

