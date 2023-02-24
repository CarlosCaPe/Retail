CREATE ROLE [db_executor]
    AUTHORIZATION [dbo];


GO
ALTER ROLE [db_executor] ADD MEMBER [CWD\SVC-PRD-D365];


GO
ALTER ROLE [db_executor] ADD MEMBER [vturchyk];


GO
ALTER ROLE [db_executor] ADD MEMBER [jmarquez];

