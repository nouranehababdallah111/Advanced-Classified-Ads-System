-- ===============================
-- 1. User Management
-- ===============================

DROP PROCEDURE IF EXISTS RegisterUser;
GO
CREATE PROCEDURE RegisterUser
    @Name NVARCHAR(100),
    @Email NVARCHAR(100),
    @Password NVARCHAR(100),
    @Phone NVARCHAR(20)
AS
BEGIN
    INSERT INTO [User](name, email, password, phone, role, status, created_at)
    VALUES (@Name, @Email, @Password, @Phone, 'user', 'active', GETDATE())
END
GO

DROP PROCEDURE IF EXISTS LoginUser;
GO
CREATE PROCEDURE LoginUser
    @Email NVARCHAR(100),
    @Password NVARCHAR(100)
AS
BEGIN
    SELECT * FROM [User]
    WHERE email = @Email AND password = @Password
END
GO

DROP PROCEDURE IF EXISTS UpdateUserStatus;
GO
CREATE PROCEDURE UpdateUserStatus
    @UserID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE [User]
    SET status = @Status
    WHERE user_id = @UserID
END
GO

DROP PROCEDURE IF EXISTS ChangeUserRole;
GO
CREATE PROCEDURE ChangeUserRole
    @UserID INT,
    @Role NVARCHAR(20)
AS
BEGIN
    UPDATE [User]
    SET role = @Role
    WHERE user_id = @UserID
END
GO

-- ===============================
-- 2. Advertisement Management
-- ===============================

DROP PROCEDURE IF EXISTS AddAdvertisement;
GO
CREATE PROCEDURE AddAdvertisement
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @Price DECIMAL(10,2),
    @UserID INT,
    @CategoryID INT,
    @LocationID INT
AS
BEGIN
    INSERT INTO Ad(title, description, price, user_id, category_id, location_id, created_at, status, views_count)
    VALUES (@Title, @Description, @Price, @UserID, @CategoryID, @LocationID, GETDATE(), 'active', 0)
END
GO

DROP PROCEDURE IF EXISTS UpdateAdvertisement;
GO
CREATE PROCEDURE UpdateAdvertisement
    @AdID INT,
    @Title NVARCHAR(200),
    @Description NVARCHAR(MAX),
    @Price DECIMAL(10,2)
AS
BEGIN
    UPDATE Ad
    SET title = @Title,
        description = @Description,
        price = @Price
    WHERE ad_id = @AdID
END
GO

DROP PROCEDURE IF EXISTS DeleteAdvertisement;
GO
CREATE PROCEDURE DeleteAdvertisement
    @AdID INT
AS
BEGIN
    DELETE FROM Ad WHERE ad_id = @AdID
END
GO

DROP PROCEDURE IF EXISTS AddAdImage;
GO
CREATE PROCEDURE AddAdImage
    @AdID INT,
    @ImageURL NVARCHAR(500)
AS
BEGIN
    INSERT INTO AdImage(ad_id, image_url)
    VALUES (@AdID, @ImageURL)
END
GO

DROP PROCEDURE IF EXISTS UpdateAdStatus;
GO
CREATE PROCEDURE UpdateAdStatus
    @AdID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    UPDATE Ad
    SET status = @Status
    WHERE ad_id = @AdID
END
GO

-- ===============================
-- 3. Category Management
-- ===============================

DROP PROCEDURE IF EXISTS AddCategory;
GO
CREATE PROCEDURE AddCategory
    @Name NVARCHAR(100),
    @ParentID INT = NULL
AS
BEGIN
    INSERT INTO Category(name, parent_id)
    VALUES (@Name, @ParentID)
END
GO

DROP PROCEDURE IF EXISTS UpdateCategory;
GO
CREATE PROCEDURE UpdateCategory
    @CategoryID INT,
    @Name NVARCHAR(100)
AS
BEGIN
    UPDATE Category
    SET name = @Name
    WHERE category_id = @CategoryID
END
GO

DROP PROCEDURE IF EXISTS DeleteCategory;
GO
CREATE PROCEDURE DeleteCategory
    @CategoryID INT
AS
BEGIN
    DELETE FROM Category WHERE category_id = @CategoryID
END
GO

-- ===============================
-- 4. Search
-- ===============================

DROP PROCEDURE IF EXISTS SearchAdvertisements;
GO
CREATE PROCEDURE SearchAdvertisements
    @Title NVARCHAR(200) = NULL,
    @CategoryID INT = NULL,
    @LocationID INT = NULL,
    @MinPrice DECIMAL(10,2) = NULL,
    @MaxPrice DECIMAL(10,2) = NULL
AS
BEGIN
    SELECT * FROM Ad
    WHERE 
        (@Title IS NULL OR title LIKE '%' + @Title + '%')
        AND (@CategoryID IS NULL OR category_id = @CategoryID)
        AND (@LocationID IS NULL OR location_id = @LocationID)
        AND (@MinPrice IS NULL OR price >= @MinPrice)
        AND (@MaxPrice IS NULL OR price <= @MaxPrice)
END
GO

-- ===============================
-- 5. Favorites
-- ===============================

DROP PROCEDURE IF EXISTS AddToFavorites;
GO
CREATE PROCEDURE AddToFavorites
    @UserID INT,
    @AdID INT
AS
BEGIN
    INSERT INTO Favorite(user_id, ad_id)
    VALUES (@UserID, @AdID)
END
GO

DROP PROCEDURE IF EXISTS RemoveFromFavorites;
GO
CREATE PROCEDURE RemoveFromFavorites
    @UserID INT,
    @AdID INT
AS
BEGIN
    DELETE FROM Favorite
    WHERE user_id = @UserID AND ad_id = @AdID
END
GO

-- ===============================
-- 6. Messaging
-- ===============================

DROP PROCEDURE IF EXISTS CreateConversation;
GO
CREATE PROCEDURE CreateConversation
    @AdID INT,
    @BuyerID INT,
    @SellerID INT
AS
BEGIN
    INSERT INTO Conversation(ad_id, buyer_id, seller_id, created_at)
    VALUES (@AdID, @BuyerID, @SellerID, GETDATE())
END
GO

DROP PROCEDURE IF EXISTS SendMessage;
GO
CREATE PROCEDURE SendMessage
    @ConversationID INT,
    @SenderID INT,
    @Content NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Message(conversation_id, sender_id, content, created_at)
    VALUES (@ConversationID, @SenderID, @Content, GETDATE())
END
GO

-- ===============================
-- 7. Review
-- ===============================

DROP PROCEDURE IF EXISTS AddReview;
GO
CREATE PROCEDURE AddReview
    @ReviewerID INT,
    @ReviewedUserID INT,
    @AdID INT,
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Review(reviewer_id, reviewed_user_id, ad_id, rating, comment, created_at)
    VALUES (@ReviewerID, @ReviewedUserID, @AdID, @Rating, @Comment, GETDATE())
END
GO

DROP PROCEDURE IF EXISTS UpdateReview;
GO
CREATE PROCEDURE UpdateReview
    @ReviewID INT,
    @Rating INT,
    @Comment NVARCHAR(MAX)
AS
BEGIN
    UPDATE Review
    SET rating = @Rating,
        comment = @Comment
    WHERE review_id = @ReviewID
END
GO

DROP PROCEDURE IF EXISTS DeleteReview;
GO
CREATE PROCEDURE DeleteReview
    @ReviewID INT
AS
BEGIN
    DELETE FROM Review WHERE review_id = @ReviewID
END
GO

-- ===============================
-- 8. Reporting
-- ===============================

DROP PROCEDURE IF EXISTS CreateReport;
GO
CREATE PROCEDURE CreateReport
    @ReporterID INT,
    @TargetType NVARCHAR(50),
    @TargetID INT,
    @Reason NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO Report(reporter_id, target_type, target_id, reason, status, created_at)
    VALUES (@ReporterID, @TargetType, @TargetID, @Reason, 'pending', GETDATE())
END
GO

DROP PROCEDURE IF EXISTS AssignReportToModerator;
GO
CREATE PROCEDURE AssignReportToModerator
    @ReportID INT,
    @ModeratorID INT
AS
BEGIN
    UPDATE Report
    SET assigned_to = @ModeratorID,
        status = 'in_review'
    WHERE report_id = @ReportID
END
GO

DROP PROCEDURE IF EXISTS TakeReportAction;
GO
CREATE PROCEDURE TakeReportAction
    @ReportID INT,
    @ModeratorID INT,
    @ActionType NVARCHAR(50),
    @Note NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO ReportAction(report_id, moderator_id, action_type, note, created_at)
    VALUES (@ReportID, @ModeratorID, @ActionType, @Note, GETDATE())

    UPDATE Report
    SET status = 'resolved',
        resolved_at = GETDATE()
    WHERE report_id = @ReportID
END
GO

