CREATE TABLE AuditLog (
    log_id INT IDENTITY(1,1),
    table_name NVARCHAR(50),
    operation_type NVARCHAR(20),
    record_id INT,
    old_value NVARCHAR(MAX),
    new_value NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);
go
CREATE OR ALTER TRIGGER trg_Ad_Audit
ON Ad
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- INSERT
    INSERT INTO AuditLog(table_name, operation_type, record_id, old_value, new_value)
    SELECT 
        'Ad',
        'INSERT',
        i.ad_id,
        NULL,
        CONCAT(i.title, '|', i.price)
    FROM inserted i
    LEFT JOIN deleted d ON i.ad_id = d.ad_id
    WHERE d.ad_id IS NULL;

    -- DELETE
    INSERT INTO AuditLog(table_name, operation_type, record_id, old_value, new_value)
    SELECT 
        'Ad',
        'DELETE',
        d.ad_id,
        CONCAT(d.title, '|', d.price),
        NULL
    FROM deleted d
    LEFT JOIN inserted i ON d.ad_id = i.ad_id
    WHERE i.ad_id IS NULL;

    -- UPDATE
    INSERT INTO AuditLog(table_name, operation_type, record_id, old_value, new_value)
    SELECT 
        'Ad',
        'UPDATE',
        i.ad_id,
        CONCAT(d.title, '|', d.price),
        CONCAT(i.title, '|', i.price)
    FROM inserted i
    INNER JOIN deleted d ON i.ad_id = d.ad_id;

END;
GO
INSERT INTO Ad(title, description, price, user_id, category_id, location_id, created_at, status, views_count)
VALUES ('Phone', 'Nice phone', 5000, 1, 1, 1, GETDATE(), 'active', 0);
UPDATE Ad
SET price = 2000
WHERE ad_id = 1;
DELETE FROM Ad
WHERE ad_id = 1;
SELECT *
FROM AuditLog;
ALTER TABLE [User]
ADD CONSTRAINT CK_User_Role
CHECK (role IN ('user','moderator','admin'));

ALTER TABLE Ad
ADD CONSTRAINT CK_Ad_Status
CHECK (status IN ('pending','active','sold','rejected'));

ALTER TABLE Ad
ADD CONSTRAINT CK_Ad_Price
CHECK (price >= 0);

ALTER TABLE Review
ADD CONSTRAINT CK_Review_Rating
CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE Review
ADD CONSTRAINT CK_Review_Self
CHECK (reviewer_id <> reviewed_user_id);

ALTER TABLE Conversation
ADD CONSTRAINT CK_Conversation_Users
CHECK (buyer_id <> seller_id);

ALTER TABLE Report
ADD CONSTRAINT CK_Report_Type
CHECK (target_type IN ('ad','user'));

ALTER TABLE Report
ADD CONSTRAINT CK_Report_Status
CHECK (status IN ('pending','resolved','rejected'));

ALTER TABLE ReportAction
ADD CONSTRAINT CK_ReportAction_Type
CHECK (action_type IN ('warning','delete_ad','ban_user','ignore'));


IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'AdminRole')
    CREATE ROLE AdminRole;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'ModeratorRole')
    CREATE ROLE ModeratorRole;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'UserRole')
    CREATE ROLE UserRole;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'GuestRole')
    CREATE ROLE GuestRole;

--1. Public Ads View
-- =========================================================
CREATE OR ALTER VIEW vw_PublicAds
AS
SELECT
    a.ad_id,
    a.title,
    a.description,
    a.price,
    a.currency,
    c.name AS category_name,
    l.city,
    l.area,
    u.name AS seller_name,
    a.created_at
FROM Ad a
JOIN Category c ON a.category_id = c.category_id
JOIN Location l ON a.location_id = l.location_id
JOIN [User] u ON a.user_id = u.user_id
WHERE a.status = 'active';
GO

-- =========================================================
-- 2. Active Users View
-- =========================================================
CREATE OR ALTER VIEW vw_ActiveUsers
AS
SELECT
    user_id,
    name,
    email,
    phone,
    role,
    is_email_verified,
    created_at
FROM [User]
WHERE status = 'active';
GO

-- =========================================================
-- 3. Moderator Reports View
-- =========================================================
CREATE OR ALTER VIEW vw_ModeratorReports
AS
SELECT
    r.report_id,
    r.reporter_id,
    u1.name AS reporter_name,
    r.target_type,
    r.target_id,
    r.reason,
    r.status,
    r.assigned_to,
    u2.name AS assigned_to_name,
    r.created_at,
    r.resolved_at
FROM Report r
LEFT JOIN [User] u1 ON r.reporter_id = u1.user_id
LEFT JOIN [User] u2 ON r.assigned_to = u2.user_id;
GO


-- =========================================================
-- 4. User Favorites View
-- =========================================================
CREATE OR ALTER VIEW vw_UserFavorites
AS
SELECT
    f.user_id,
    u.name AS user_name,
    f.ad_id,
    a.title,
    a.price,
    a.currency,
    a.status
FROM Favorite f
JOIN [User] u ON f.user_id = u.user_id
JOIN Ad a ON f.ad_id = a.ad_id;
GO

CREATE OR ALTER VIEW vw_AuditLogs
AS
SELECT
    log_id,
    table_name,
    operation_type,
    record_id,
    old_value,
    new_value,
    created_at
FROM AuditLog;
GO

DROP VIEW IF EXISTS vw_AuditLogs;
DROP TRIGGER IF EXISTS trg_Ad_Audit;
DROP TABLE IF EXISTS AuditLog;


DROP TRIGGER IF EXISTS trg_Ad_Insert;
DROP TRIGGER IF EXISTS trg_Ad_Update;
DROP TRIGGER IF EXISTS trg_Ad_Audit;
DROP VIEW IF EXISTS vw_AuditLogs;
DROP TABLE IF EXISTS AuditLog;
DROP TRIGGER IF EXISTS trg_Ad_Delete ;


GRANT SELECT, INSERT, UPDATE, DELETE
ON Ad TO AdminRole;

GRANT SELECT
ON vw_AuditLogs TO AdminRole;

GRANT SELECT
ON vw_ActiveUsers TO AdminRole;

GRANT SELECT, INSERT, UPDATE, DELETE
ON Report TO AdminRole;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ReportAction TO AdminRole;

GRANT SELECT
ON vw_PublicAds TO AdminRole;

GRANT SELECT, UPDATE
ON Report TO ModeratorRole;

GRANT INSERT, UPDATE
ON ReportAction TO ModeratorRole;

GRANT SELECT
ON vw_ModeratorReports TO ModeratorRole;

GRANT SELECT
ON vw_PublicAds TO ModeratorRole;

GRANT SELECT
ON vw_PublicAds TO UserRole;

GRANT SELECT
ON vw_UserFavorites TO UserRole;

GRANT INSERT, SELECT
ON Message TO UserRole;

GRANT INSERT, SELECT
ON Review TO UserRole;

GRANT INSERT
ON Favorite TO UserRole;

GRANT SELECT
ON vw_PublicAds TO GuestRole;

CREATE LOGIN Nouran WITH PASSWORD = '103050';
CREATE LOGIN Elaf WITH PASSWORD = '204060';
CREATE LOGIN Shahd WITH PASSWORD = '306090'

USE master;
GO
 use ClassifiedAdsDB ;
 GO

CREATE USER Nouran FOR LOGIN Nouran;
CREATE USER Elaf FOR LOGIN Elaf;
CREATE USER Shahd FOR LOGIN Shahd;

ALTER ROLE AdminRole ADD MEMBER Nouran;
ALTER ROLE ModeratorRole ADD MEMBER Shahd;
ALTER ROLE UserRole ADD MEMBER Elaf;
