CREATE TABLE [Dimension].[Purchase_Order_Fill] (
    [Purchase_Order_Fill_Key]         TINYINT      IDENTITY (1, 1) NOT NULL,
    [Purchase_Order_Line_Fill_CD]     TINYINT      NOT NULL,
    [Purchase_Order_Fill_CD]          TINYINT      NOT NULL,
    [Purchase_Order_Line_Fill]        VARCHAR (25) NOT NULL,
    [Purchase_Order_Fill]             VARCHAR (25) NOT NULL,
    [Purchase_Order_Line_Fill_Status] VARCHAR (25) NOT NULL,
    [Purchase_Order_Fill_Status]      VARCHAR (12) NOT NULL,
    CONSTRAINT [PK__Purchase__40C3905198B964D7] PRIMARY KEY CLUSTERED ([Purchase_Order_Fill_Key] ASC)
);

