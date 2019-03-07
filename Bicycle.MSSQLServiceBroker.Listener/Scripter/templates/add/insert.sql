SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF
SET ARITHABORT ON
GO

CREATE TRIGGER [%Table%_ServiceBrokerListenerForInsert] ON [%Scheme%].[%Table%] FOR INSERT
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX) = (SELECT * FROM inserted FOR XML RAW, ELEMENTS);

    IF ISNULL(@messageBody,'') = ''
        RETURN

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceForInsert]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceForInsert'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForInsert]
        WITH ENCRYPTION = OFF;

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForInsert] (@messageBody);
    COMMIT;
END	
GO
--=========================================