-----1. Automatically Set Advertisement Creation Date

CREATE OR ALTER TRIGGER trg_SetAdCreatedAt
ON dbo.Ad
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE a
    SET a.created_at = GETDATE()
    FROM dbo.Ad a
    INNER JOIN inserted i ON a.ad_id = i.ad_id
    WHERE a.created_at IS NULL;

    PRINT 'Created_at column automatically set for new ads.';
END;
GO

INSERT INTO dbo.Ad (title, description, price, user_id, category_id, location_id, status, views_count)
VALUES ('Test Ad Trigger', 'Testing created_at auto', 100, 1, 1, 1, 'active', 0);


SELECT TOP 5 ad_id, title, created_at FROM dbo.Ad
WHERE title = 'Test Ad Trigger'
ORDER BY ad_id DESC;


/*******************************************************/

---2.Increase Views Count Trigger

CREATE OR ALTER TRIGGER trg_IncreaseViews
ON dbo.Ad
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE a
    SET a.views_count = a.views_count + 1
    FROM dbo.Ad a
    INNER JOIN inserted i ON a.ad_id = i.ad_id
    WHERE i.views_count = a.views_count; 
END;
GO


INSERT INTO dbo.Ad (title, description, price, user_id, category_id, location_id, created_at, status, views_count)
VALUES ('Test Ad Views', 'Testing views_count trigger', 100, 1, 1, 1, GETDATE(), 'active', 0);


DECLARE @AdID INT = SCOPE_IDENTITY();

UPDATE dbo.Ad
SET price = price 
WHERE ad_id = @AdID;


SELECT ad_id, title, views_count
FROM dbo.Ad
WHERE ad_id = @AdID;

/*********************************************/
-----3.Prevent Negative Prices Trigger

CREATE OR ALTER TRIGGER trg_PreventNegativePrice
ON dbo.Ad
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE price < 0
    )
    BEGIN
        RAISERROR('Price cannot be negative.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


INSERT INTO dbo.Ad (title, description, price, user_id, category_id, location_id, created_at, status, views_count)
VALUES ('Test Ad Correct Price', 'Price is positive', 100, 1, 1, 1, GETDATE(), 'active', 0);


BEGIN TRY
    INSERT INTO dbo.Ad (title, description, price, user_id, category_id, location_id, created_at, status, views_count)
    VALUES ('Test Ad Negative Price', 'Price is negative', -50, 1, 1, 1, GETDATE(), 'active', 0);
END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
END CATCH;


/*************************************************/
----4.Log Deleted Advertisements Trigger
CREATE TABLE dbo.Ad_Audits (
    audit_id    INT IDENTITY PRIMARY KEY,
    ad_id       INT           NOT NULL,
    title       NVARCHAR(255),
    user_id     INT,
    price       DECIMAL(10,2),
    status      NVARCHAR(50),
    deleted_by  INT,           
    deleted_at  DATETIME      NOT NULL DEFAULT GETDATE(),
    operation   CHAR(3)       NOT NULL DEFAULT 'DEL'
);
GO




CREATE OR ALTER TRIGGER trg_protect_ad_delete
ON dbo.Ad
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserRole    NVARCHAR(50);
    DECLARE @CallerId    INT;
    DECLARE @AdOwnerRole NVARCHAR(50);

    SET @CallerId = CAST(SESSION_CONTEXT(N'user_id') AS INT);

    SELECT @UserRole = role
    FROM dbo.[User]
    WHERE user_id = @CallerId;

 
    SELECT @AdOwnerRole = u.role
    FROM dbo.[User] u
    JOIN deleted d ON u.user_id = d.user_id;

    -- ? Admin: cascade delete then hard delete
    IF @UserRole = 'admin'
    BEGIN
        IF @AdOwnerRole = 'admin' AND @CallerId <> (SELECT user_id FROM deleted)
        BEGIN
            RAISERROR('Access denied: Cannot delete an ad owned by another admin.', 16, 1);
            ROLLBACK; RETURN;
        END

        INSERT INTO dbo.Ad_Audits (ad_id, title, user_id, price, status, deleted_by)
        SELECT d.ad_id, d.title, d.user_id, d.price, d.status, @CallerId
        FROM deleted d;

        DELETE FROM dbo.Message WHERE conversation_id IN 
            (SELECT conversation_id FROM dbo.Conversation WHERE ad_id IN (SELECT ad_id FROM deleted));
        DELETE FROM dbo.Conversation WHERE ad_id IN (SELECT ad_id FROM deleted);
        DELETE FROM dbo.AdImage WHERE ad_id IN (SELECT ad_id FROM deleted);
        DELETE FROM dbo.AdAttributeValue WHERE ad_id IN (SELECT ad_id FROM deleted);
        DELETE FROM dbo.Favorite WHERE ad_id IN (SELECT ad_id FROM deleted);
        DELETE FROM dbo.Review WHERE ad_id IN (SELECT ad_id FROM deleted);

       
        DELETE FROM dbo.Ad WHERE ad_id IN (SELECT ad_id FROM deleted);

        PRINT 'Ad and all related data deleted successfully (Admin).';
    END
    -- ? Moderator: soft delete
    ELSE IF @UserRole = 'moderator'
    BEGIN
        UPDATE dbo.Ad
        SET status = 'deleted'
        WHERE ad_id IN (SELECT ad_id FROM deleted);
        PRINT 'Ad status changed to deleted (Moderator).';
    END
    -- ? Others: blocked
    ELSE
    BEGIN
        RAISERROR('Access denied: You do not have permission to delete ads.', 16, 1);
        ROLLBACK;
    END
END;
GO
/*****************/
-- Set roles
UPDATE dbo.[User] SET role = 'admin'     WHERE user_id = 1;
UPDATE dbo.[User] SET role = 'moderator' WHERE user_id = 2;
GO

-- Admin test
EXEC sp_set_session_context @key = N'user_id', @value = 1;
BEGIN TRY
    DELETE FROM dbo.Ad WHERE ad_id = 15;
    PRINT 'Admin test: passed';
END TRY
BEGIN CATCH
    PRINT 'Admin error: ' + ERROR_MESSAGE();
END CATCH;
GO
SELECT * FROM dbo.Ad_Audits;
-- Regular user test
EXEC sp_set_session_context @key = N'user_id', @value = 3;
BEGIN TRY
    DELETE FROM dbo.Ad WHERE ad_id = 9;
END TRY
BEGIN CATCH
    PRINT 'User error: ' + ERROR_MESSAGE();
END CATCH;
GO

-- View the audit log
SELECT * FROM dbo.Ad_Audits;

/**********************************/

----5. Automatically Resolve Report Date Trigger


CREATE OR ALTER TRIGGER trg_AutoResolveReport
ON dbo.Report
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE r
    SET resolved_at = GETDATE()
    FROM dbo.Report r
    INNER JOIN inserted i ON r.report_id = i.report_id
    WHERE i.status = 'resolved' AND r.resolved_at IS NULL;

    PRINT 'Resolved_at automatically set for reports marked as resolved.';
END;
GO

INSERT INTO dbo.Report (reporter_id, target_type, target_id, reason, status, assigned_to, created_at)
VALUES (1, 'ad', 101, 'Test reason', 'in_review', 2, GETDATE());

DECLARE @ReportID INT = SCOPE_IDENTITY();

UPDATE dbo.Report
SET status = 'resolved'
WHERE report_id = @ReportID;

SELECT report_id, status, resolved_at
FROM dbo.Report
WHERE report_id = @ReportID;
