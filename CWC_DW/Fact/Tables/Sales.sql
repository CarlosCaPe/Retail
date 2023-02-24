CREATE TABLE [Fact].[Sales] (
    [Sales_Key]                         INT             IDENTITY (1, 1) NOT NULL,
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
    [ETL_Modified_Count]                SMALLINT        NULL,
    [Invoice_Key]                       INT             NULL,
    [Sales_Order_Fill_Key]              TINYINT         NULL,
    [Sales_Line_Price]                  NUMERIC (32, 6) NULL,
    [Sales_Margin_Key]                  TINYINT         NULL,
    [Extended_Sale_Amount]              AS              ([Sales_Line_Ordered_Quantity]*[Sales_Line_Price]),
    [Sales_Discount_Total]              AS              ([Sales_Line_Ordered_Quantity]*[Sales_Line_Price]-[Sales_Line_Amount]),
    [Sales_Margin]                      AS              ([Sales_Line_Amount]-[Sales_Line_Ordered_Quantity]*[Sales_Line_Cost_Price]),
    [Sales_Margin_Rate]                 AS              (case when [Sales_Line_Ordered_Quantity]*[Sales_Line_Cost_Price]<>(0) then ([Sales_Line_Amount]-[Sales_Line_Ordered_Quantity]*[Sales_Line_Cost_Price])/([Sales_Line_Ordered_Quantity]*[Sales_Line_Cost_Price]) else (0) end),
    [Extended_Sale_Cost]                AS              ([Sales_Line_Ordered_Quantity]*[Sales_Line_Cost_Price]),
    [Sales_Line_Ordered_Sales_Quantity] SMALLINT        NULL,
    [Sales_Line_Created_Date_EST]       DATETIME2 (5)   NULL,
    [Source_CD]                         VARCHAR (50)    NULL,
    [Catalog_Key]                       INT             NULL,
    CONSTRAINT [PK_Sales] PRIMARY KEY CLUSTERED ([Sales_Key] ASC),
    CONSTRAINT [UK_Sales_Order_Number_Line_Number] UNIQUE NONCLUSTERED ([Sales_Order_Number] ASC, [Sales_Line_Number] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_SalesOrder_Attribute_Amounts]
    ON [Fact].[Sales]([Sales_Order_Attribute_Key] ASC)
    INCLUDE([Sales_Line_Cost_Price], [Sales_Line_Amount], [Sales_Line_Discount_Amount], [Sales_Line_Ordered_Quantity]);


GO
CREATE NONCLUSTERED INDEX [IX_Returns_Credit_Only]
    ON [Fact].[Sales]([Sales_Line_Product_Key] ASC, [Sales_Line_Created_Date] ASC)
    INCLUDE([Sales_Order_Number], [Return_Invent_Trans_ID], [Sales_Header_Customer_Key], [Sales_Header_Property_Key], [Sales_Line_Property_Key], [Sales_Line_Amount]);


GO
CREATE NONCLUSTERED INDEX [IX_Fact_Sales_is_Removed_From_Source]
    ON [Fact].[Sales]([is_Removed_From_Source] ASC)
    INCLUDE([Sales_Header_Customer_Key], [Sales_Header_Property_Key], [Sales_Header_Location_Key], [Sales_Line_Property_Key], [Shipping_Inventory_Warehouse_Key], [Sales_Line_Employee_Key], [Sales_Order_Attribute_Key], [Sales_Line_Created_Date]);


GO
CREATE NONCLUSTERED INDEX [IX_Sales_Line_Created_Date_EST]
    ON [Fact].[Sales]([Sales_Line_Created_Date_EST] ASC)
    INCLUDE([Sales_Order_Number], [Sales_Line_Number], [Invent_Trans_ID], [Sales_Header_Customer_Key], [Sales_Header_Property_Key], [Sales_Line_Property_Key], [Sales_Line_Product_Key], [Sales_Line_Employee_Key], [Sales_Order_Attribute_Key], [Sales_Line_Amount], [Sales_Line_Discount_Amount], [Sales_Line_Cost_Price], [Sales_Line_Ordered_Quantity], [Sales_Line_Remain_Sales_Physical], [is_Removed_From_Source], [Sales_Order_Fill_Key]);


GO
CREATE NONCLUSTERED INDEX [IX_Return_Invent_Trans_ID]
    ON [Fact].[Sales]([Return_Invent_Trans_ID] ASC)
    INCLUDE([Sales_Order_Number], [Sales_Line_Number], [Sales_Line_Created_Date_EST]);


GO
CREATE NONCLUSTERED INDEX [IX_Invent_Trans_ID]
    ON [Fact].[Sales]([Invent_Trans_ID] ASC);

