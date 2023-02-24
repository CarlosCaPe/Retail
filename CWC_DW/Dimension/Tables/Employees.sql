CREATE TABLE [Dimension].[Employees] (
    [Employee_Key]           SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Personnel_Number]       NVARCHAR (25)  NOT NULL,
    [User_ID]                NVARCHAR (20)  NULL,
    [Employee_Full_Name]     NVARCHAR (100) NOT NULL,
    [License_Source]         VARCHAR (15)   NULL,
    [Start_Date]             DATE           NOT NULL,
    [End_Date]               DATE           NULL,
    [Summary_Valid_From]     DATETIME2 (5)  NULL,
    [is_Active]              BIT            NOT NULL,
    [is_Removed_From_Source] BIT            NOT NULL,
    [is_Excluded]            BIT            NOT NULL,
    [ETL_Created_Date]       DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Date]      DATETIME2 (5)  NOT NULL,
    [ETL_Modified_Count]     TINYINT        NOT NULL,
    CONSTRAINT [PK_Employees] PRIMARY KEY CLUSTERED ([Employee_Key] ASC)
);

