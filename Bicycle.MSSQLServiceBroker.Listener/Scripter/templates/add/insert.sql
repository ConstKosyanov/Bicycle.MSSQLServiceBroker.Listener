CREATE TRIGGER [%Scheme%].[%Table%_ServiceBrokerListenerForInsert] ON [%Scheme%].[%Table%] FOR INSERT
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Scheme%_%Table%_ServiceBrokerListenerServiceNameForInsert]
        TO SERVICE '%Scheme%_%Table%_ServiceBrokerListenerServiceNameForInsert'
        ON CONTRACT [%Scheme%_%Table%_ServiceBrokerListenerContractForInsert]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM inserted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Scheme%_%Table%_ServiceBrokerListenerMessageTypeForInsert] (@messageBody);
    COMMIT;
END	
GO
--=========================================