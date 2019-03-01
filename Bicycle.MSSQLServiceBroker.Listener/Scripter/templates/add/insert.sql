CREATE TRIGGER [%Table%_ServiceBrokerListenerForInsert] ON [%Table%] FOR INSERT
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @ch UNIQUEIDENTIFIER
    DECLARE @messageBody NVARCHAR(MAX);

    BEGIN DIALOG CONVERSATION @ch
        FROM SERVICE [%Table%_ServiceBrokerListenerServiceNameForInsert]
        TO SERVICE '%Table%_ServiceBrokerListenerServiceNameForInsert'
        ON CONTRACT [%Table%_ServiceBrokerListenerContractForInsert]
        WITH ENCRYPTION = OFF;

    SET @messageBody = (SELECT *
    FROM inserted
    FOR XML RAW, ELEMENTS);

    SEND ON CONVERSATION @ch MESSAGE TYPE [%Table%_ServiceBrokerListenerMessageTypeForInsert] (@messageBody);
    COMMIT;
END	
GO
--=========================================