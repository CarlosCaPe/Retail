CREATE TABLE [Dimension].[Invoice_Properties] (
    [Invoice_Property_Key]         SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Payment_Term]                 VARCHAR (14)  NULL,
    [Invoice_Line_Unit]            VARCHAR (5)   NULL,
    [Invoice_Header_Delivery_Mode] VARCHAR (50)  NULL,
    [Expedited_Shipping]           AS            (case when [Invoice_Header_Delivery_Mode]='FedEx Overnight' OR [Invoice_Header_Delivery_Mode]='2-Day Air' then 'Expedited Shipping' else 'Not Expedited Shipping' end),
    [is_Removed_From_Source]       BIT           NULL,
    [is_Excluded]                  BIT           NULL,
    [ETL_Created_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Date]            DATETIME2 (5) NULL,
    [ETL_Modified_Count]           TINYINT       NULL,
    CONSTRAINT [PK_Invoice_Properties] PRIMARY KEY CLUSTERED ([Invoice_Property_Key] ASC)
);

