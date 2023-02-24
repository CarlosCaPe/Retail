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

