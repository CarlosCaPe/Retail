CREATE TABLE [Marketing].[Ship_Confirmations] (
    [Ship_Confirmation_Key]         INT              IDENTITY (1, 1) NOT NULL,
    [Sales_Key]                     INT              NULL,
    [Invoice_Key]                   INT              NULL,
    [Product_Key]                   INT              NULL,
    [Ship_Confirmation_Carrier_Key] TINYINT          NULL,
    [Ship_Date]                     DATE             NULL,
    [Quantity]                      SMALLINT         NULL,
    [Tracking_Number]               VARCHAR (50)     NOT NULL,
    [Return_Tracking_Number]        VARCHAR (50)     NOT NULL,
    [Total_Weight]                  NUMERIC (32, 12) NULL,
    [Export_Date]                   DATETIME2 (5)    NULL,
    [is_Exported]                   BIT              NULL,
    [is_Expired]                    AS               (case when [Ship_Date]<CONVERT([date],getdate()-(2)) then (1) else (0) end),
    [is_Removed_From_Source]        BIT              NULL,
    [ETL_Created_Date]              DATETIME2 (5)    NULL,
    [ETL_Modified_Date]             DATETIME2 (5)    NULL,
    [ETL_Modified_Count]            TINYINT          NULL,
    CONSTRAINT [PK_Ship_Confirmations] PRIMARY KEY CLUSTERED ([Ship_Confirmation_Key] ASC),
    CONSTRAINT [UX_Ship_Confirmations] UNIQUE NONCLUSTERED ([Sales_Key] ASC, [Invoice_Key] ASC, [Product_Key] ASC, [Ship_Date] ASC, [Tracking_Number] ASC)
);

