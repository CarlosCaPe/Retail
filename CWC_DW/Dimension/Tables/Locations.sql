﻿CREATE TABLE [Dimension].[Locations] (
    [Location_Key]           INT           IDENTITY (1, 1) NOT NULL,
    [Street]                 VARCHAR (200) NULL,
    [City]                   VARCHAR (100) NULL,
    [State]                  VARCHAR (5)   NULL,
    [Zip_Code]               VARCHAR (15)  NULL,
    [Country]                VARCHAR (10)  NULL,
    [is_Removed_From_Source] BIT           NULL,
    [is_Excluded]            BIT           NULL,
    [ETL_Created_Date]       DATETIME2 (5) NULL,
    [ETL_Modified_Date]      DATETIME2 (5) NULL,
    [ETL_Modified_Count]     TINYINT       NULL,
    CONSTRAINT [PK_Locations] PRIMARY KEY CLUSTERED ([Location_Key] ASC),
    CONSTRAINT [UK_Locations] UNIQUE NONCLUSTERED ([Street] ASC, [City] ASC, [State] ASC, [Zip_Code] ASC, [Country] ASC)
);






GO
 CREATE TRIGGER [Dimension].[tr_Locations_Audit] ON [Dimension].[Locations]
AFTER INSERT
	,UPDATE
	,DELETE
AS
BEGIN
	DECLARE @Operation CHAR(1)
	DECLARE @RecordCount INT

	IF EXISTS (
			SELECT NULL
			FROM inserted
			)
	BEGIN
		IF EXISTS (
				SELECT NULL
				FROM deleted
				)
		BEGIN
			IF EXISTS (
					SELECT NULL
					FROM inserted i
					INNER JOIN deleted d ON i.Location_Key = d.Location_Key
					WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
					)
			BEGIN
				SET @Operation = 'L'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted i
						INNER JOIN deleted d ON i.Location_Key = d.Location_Key
						WHERE i.is_removed_from_source = 1 AND (d.is_removed_from_source = 0 OR d.is_removed_from_source IS NULL)
						)
			END
			ELSE
			BEGIN
				SET @Operation = 'U'
				SET @RecordCount = (
						SELECT COUNT(*)
						FROM inserted
						)
			END
		END
		ELSE
		BEGIN
			SET @Operation = 'I'
			SET @RecordCount = @@ROWCOUNT
		END
	END
	ELSE
	BEGIN
		SET @Operation = 'D'
		SET @RecordCount = @@ROWCOUNT
	END

	EXEC [Administration].[usp_Audit_Table_Insert] '[Dimension].[Locations]'
		,@Operation
		,@RecordCount
END