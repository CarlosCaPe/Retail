CREATE TABLE [Dimension].[Credit_Card_Authorizations] (
    [Credit_Card_Authorization_Key] TINYINT       IDENTITY (1, 1) NOT NULL,
    [Authorization_Status]          VARCHAR (10)  NOT NULL,
    [First_Decline_Message]         VARCHAR (250) NOT NULL,
    [Last_Decline_Message]          VARCHAR (250) NULL,
    [First_Success_Message]         VARCHAR (250) NULL,
    [Last_Success_Message]          VARCHAR (250) NULL,
    [is_Removed_From_Source]        BIT           NULL,
    [is_Excluded]                   BIT           NULL,
    [ETL_Created_Date]              DATETIME2 (5) NULL,
    [ETL_Modified_Date]             DATETIME2 (5) NULL,
    [ETL_Modified_Count]            TINYINT       NULL,
    CONSTRAINT [PK_Credit_Card_Authorization_Attributes] PRIMARY KEY CLUSTERED ([Credit_Card_Authorization_Key] ASC)
);

