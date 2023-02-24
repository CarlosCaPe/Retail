CREATE TABLE [Marketing].[Ship_Confirmation_Carriers] (
    [Ship_Confirmation_Carrier_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Ship_Via]                      VARCHAR (50)  NULL,
    [Ship_Carrier]                  VARCHAR (50)  NULL,
    [is_Removed_From_Source]        BIT           NULL,
    [ETL_Created_Date]              DATETIME2 (5) NULL,
    [ETL_Modified_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Count]            TINYINT       NULL,
    CONSTRAINT [PK_Ship_Confirmation_Carriers] PRIMARY KEY CLUSTERED ([Ship_Confirmation_Carrier_Key] ASC)
);

