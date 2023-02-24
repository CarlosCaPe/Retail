CREATE TABLE [Fact].[Backorders_Remapping] (
    [Snapshot_Date_Key]             INT      NOT NULL,
    [Sales_Key]                     INT      NOT NULL,
    [Sales_Header_Property_Key]     SMALLINT NULL,
    [Sales_Header_Property_Key_New] SMALLINT NULL
);

