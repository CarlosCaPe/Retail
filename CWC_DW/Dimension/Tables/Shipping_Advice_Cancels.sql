CREATE TABLE [Dimension].[Shipping_Advice_Cancels] (
    [Shipping_Advice_Cancel_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [is_Canceled]                INT           NOT NULL,
    [Cancel_Reason_CD]           VARCHAR (50)  NULL,
    [Cancel]                     VARCHAR (12)  NULL,
    [Cancel_Reason]              VARCHAR (50)  NULL,
    [is_Removed_From_Source]     BIT           NOT NULL,
    [ETL_Created_Date]           DATETIME2 (5) NOT NULL,
    [ETL_Modified_Date]          DATETIME2 (5) NOT NULL,
    [ETL_Modified_Count]         SMALLINT      NOT NULL,
    CONSTRAINT [PK_Shipping_Advice_Cancels] PRIMARY KEY CLUSTERED ([Shipping_Advice_Cancel_Key] ASC)
);

