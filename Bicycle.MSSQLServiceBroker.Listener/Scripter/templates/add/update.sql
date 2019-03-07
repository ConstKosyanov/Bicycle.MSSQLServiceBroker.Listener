SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF
SET ARITHABORT ON
GO

CREATE TRIGGER [%Scheme%].[%Table%_ServiceBrokerListenerForUpdate] ON [%Scheme%].[%Table%] FOR UPDATE
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX)= (SELECT * FROM inserted FOR XML RAW, ELEMENTS);

    IF ISNULL(@messageBody,'') = ''
        RETURN

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceForUpdate]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceForUpdate'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForUpdate]
        WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForUpdate] (@messageBody);
    COMMIT;
END	
GO
--=========================================