CREATE TABLE [Fact].[Purchase_Orders] (
    [Purchase_Order_Key]                    INT             IDENTITY (1, 1) NOT NULL,
    [Purchase_Order_Number]                 VARCHAR (50)    NOT NULL,
    [Purchase_Order_Line_Number]            INT             NOT NULL,
    [Invent_Trans_ID]                       VARCHAR (20)    NOT NULL,
    [Delivery_Location_Key]                 INT             NULL,
    [Vendor_Key]                            SMALLINT        NULL,
    [Purchase_Order_Property_Key]           SMALLINT        NULL,
    [Product_Key]                           INT             NULL,
    [Purchase_Order_Fill_Key]               TINYINT         NULL,
    [Purchase_Order_Name]                   VARCHAR (100)   NOT NULL,
    [Purchase_Line_Description]             VARCHAR (1000)  NOT NULL,
    [Purchase_Order_Header_Accounting_Date] DATE            NULL,
    [Purchase_Line_Confirmed_Delivery_Date] DATE            NULL,
    [Purchase_Line_Requested_Delivery_Date] DATE            NULL,
    [Purchase_Line_Confirmed_Shipping_Date] DATE            NULL,
    [Purchase_Line_Requested_Shipping_Date] DATE            NULL,
    [Purchase_Line_Amount]                  NUMERIC (32, 6) NOT NULL,
    [Purchase_Line_Open_Amount]             AS              ([Purchase_Line_Purchase_Price]*case when [Received_Quantity]>[Purchase_Line_Ordered_Quantity] then (0) else [Purchase_Line_Ordered_Quantity]-[Received_Quantity] end),
    [Purchase_Line_Received_Amount]         AS              ([Purchase_Line_Purchase_Price]*[Received_Quantity]),
    [Purchase_Line_Overfill_Amount]         AS              ([Purchase_Line_Purchase_Price]*case when [Received_Quantity]>[Purchase_Line_Ordered_Quantity] then [Received_Quantity]-[Purchase_Line_Ordered_Quantity] else (0) end),
    [Purchase_Line_Purchase_Price]          NUMERIC (32, 6) NOT NULL,
    [Purchase_Line_Discount_Amount]         NUMERIC (32, 6) NOT NULL,
    [Purchase_Line_Price_Quantity]          SMALLINT        NULL,
    [Purchase_Line_Ordered_Quantity]        SMALLINT        NULL,
    [Received_Quantity]                     SMALLINT        NULL,
    [Open_Quantity]                         AS              (case when [Received_Quantity]>[Purchase_Line_Ordered_Quantity] then (0) else [Purchase_Line_Ordered_Quantity]-[Received_Quantity] end),
    [Overfill_Quantity]                     AS              (case when [Received_Quantity]>[Purchase_Line_Ordered_Quantity] then [Received_Quantity]-[Purchase_Line_Ordered_Quantity] else (0) end),
    [Commission_Charge_Percentage]          NUMERIC (10, 6) NULL,
    [Tariff_Charge_Percentage]              NUMERIC (10, 6) NULL,
    [Duty_Charge_Percentage]                NUMERIC (10, 6) NULL,
    [Freight_Charge_Percentage]             NUMERIC (10, 6) NULL,
    [Freight_In_Charge_Percentage]          NUMERIC (10, 6) NULL,
    [Commission_Charge_Amount]              AS              ((([Commission_Charge_Percentage]/(100))*[Purchase_Line_Purchase_Price])*[Purchase_Line_Ordered_Quantity]),
    [Tariff_Charge_Amount]                  AS              ((([Tariff_Charge_Percentage]/(100))*[Purchase_Line_Purchase_Price])*[Purchase_Line_Ordered_Quantity]),
    [Duty_Charge_Amount]                    AS              ((([Duty_Charge_Percentage]/(100))*[Purchase_Line_Purchase_Price])*[Purchase_Line_Ordered_Quantity]),
    [Freight_Charge_Amount]                 AS              ((([Freight_Charge_Percentage]/(100))*[Purchase_Line_Purchase_Price])*[Purchase_Line_Ordered_Quantity]),
    [Freight_In_Charge_Amount]              AS              ((([Freight_In_Charge_Percentage]/(100))*[Purchase_Line_Purchase_Price])*[Purchase_Line_Ordered_Quantity]),
    [First_Cost]                            AS              ([Purchase_Line_Purchase_Price]*[Purchase_Line_Ordered_Quantity]),
    [Vendor_Packing_Slip_Count]             TINYINT         NULL,
    [Barcode]                               VARCHAR (80)    NULL,
    [is_Removed_From_Source]                BIT             NULL,
    [is_Excluded]                           BIT             NULL,
    [ETL_Created_Date]                      DATETIME2 (5)   NULL,
    [ETL_Modified_Date]                     DATETIME2 (5)   NULL,
    [ETL_Modified_Count]                    SMALLINT        NULL,
    CONSTRAINT [PK_Purchase_Orders] PRIMARY KEY CLUSTERED ([Purchase_Order_Key] ASC),
    CONSTRAINT [UK_Purchase_Orders] UNIQUE NONCLUSTERED ([Purchase_Order_Number] ASC, [Purchase_Order_Line_Number] ASC)
);




GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_217_216]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Header_Accounting_Date] ASC, [Open_Quantity] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Vendor_Key], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Open_Amount], [Purchase_Line_Purchase_Price], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Commission_Charge_Percentage], [Tariff_Charge_Percentage], [Duty_Charge_Percentage], [Freight_Charge_Percentage], [Freight_In_Charge_Percentage]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_215_214]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Property_Key] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Open_Quantity] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Vendor_Key], [Product_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Open_Amount], [Purchase_Line_Purchase_Price], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Commission_Charge_Percentage], [Tariff_Charge_Percentage], [Duty_Charge_Percentage], [Freight_Charge_Percentage], [Freight_In_Charge_Percentage]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_203_202]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Property_Key], [Product_Key], [Purchase_Order_Fill_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_201_200]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Property_Key] ASC, [is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC)
    INCLUDE([Product_Key], [Purchase_Order_Fill_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_199_198]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Order_Fill_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_197_196]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Fill_Key] ASC, [is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_195_194]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Open_Quantity] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Line_Number], [Invent_Trans_ID], [Vendor_Key], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Purchase_Price], [Commission_Charge_Percentage], [Tariff_Charge_Percentage], [Duty_Charge_Percentage], [Freight_Charge_Percentage], [Freight_In_Charge_Percentage]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_193_192]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Vendor_Key], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Line_Confirmed_Delivery_Date], [Purchase_Line_Purchase_Price], [Commission_Charge_Percentage], [Tariff_Charge_Percentage], [Duty_Charge_Percentage], [Freight_Charge_Percentage], [Freight_In_Charge_Percentage]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_143_142]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Purchase_Line_Confirmed_Delivery_Date] ASC)
    INCLUDE([Purchase_Order_Property_Key], [Product_Key], [Purchase_Order_Fill_Key], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_141_140]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Property_Key] ASC, [is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Purchase_Line_Confirmed_Delivery_Date] ASC)
    INCLUDE([Product_Key], [Purchase_Order_Fill_Key], [Purchase_Line_Ordered_Quantity], [Received_Quantity], [Open_Quantity]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_133_132]
    ON [Fact].[Purchase_Orders]([Product_Key] ASC)
    INCLUDE([Purchase_Line_Purchase_Price], [Purchase_Line_Ordered_Quantity], [Commission_Charge_Percentage], [Tariff_Charge_Percentage], [Duty_Charge_Percentage], [Freight_Charge_Percentage], [Freight_In_Charge_Percentage]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_125_124]
    ON [Fact].[Purchase_Orders]([is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Purchase_Line_Confirmed_Delivery_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Property_Key], [Product_Key], [Purchase_Order_Fill_Key]);


GO
CREATE NONCLUSTERED INDEX [CWC_DW_SQLOPS_Purchase_Orders_123_122]
    ON [Fact].[Purchase_Orders]([Purchase_Order_Fill_Key] ASC, [is_Removed_From_Source] ASC, [Purchase_Order_Header_Accounting_Date] ASC, [Purchase_Line_Confirmed_Delivery_Date] ASC)
    INCLUDE([Purchase_Order_Number], [Purchase_Order_Property_Key], [Product_Key]);

