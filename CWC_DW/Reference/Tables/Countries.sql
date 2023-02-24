CREATE TABLE [Reference].[Countries] (
    [Country_Region_ID]  VARCHAR (50)  NOT NULL,
    [Country_Name_Long]  VARCHAR (255) NOT NULL,
    [Country_Name_Short] VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_Countries] PRIMARY KEY CLUSTERED ([Country_Region_ID] ASC)
);

