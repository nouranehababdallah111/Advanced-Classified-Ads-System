--1. User Functions 
-- Function لحساب متوسط تقييم مستخدم معين
use classifid_ad
go

CREATE FUNCTION fn_GetUserAverageRating (@user_id INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @avg DECIMAL(3,2)
    SELECT @avg = AVG(rating)
    FROM Review
    WHERE reviewed_user_id = @user_id

    RETURN ISNULL(@avg, 0)
END
-- Function لحساب عدد الإعلانات الخاصة بمستخدم معين
go
CREATE FUNCTION fn_GetUserAdsCount (@user_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @count INT

    SELECT @count = COUNT(*)
    FROM Ad
    WHERE user_id = @user_id

    RETURN @count
END

-- Function للتحقق هل المستخدم نشط أم لا
go
CREATE FUNCTION fn_IsUserActive (@user_id INT)
RETURNS BIT
AS
BEGIN
    DECLARE @status NVARCHAR(20)

    SELECT @status = status
    FROM [User]
    WHERE user_id = @user_id

    RETURN CASE 
        WHEN @status = 'active' THEN 1
        ELSE 0
    END
END
--2. Advertisement Functions

-- Function لإرجاع عدد مشاهدات إعلان معين
go
CREATE FUNCTION fn_GetAdViewsCount (@ad_id INT)
RETURNS INT
AS
BEGIN
    DECLARE @views INT

    SELECT @views = views_count
    FROM Ad
    WHERE ad_id = @ad_id

    RETURN ISNULL(@views, 0)
END

-- Function لإرجاع تفاصيل إعلان معين
go
CREATE FUNCTION fn_GetAdDetails (@ad_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        a.ad_id,
        a.title,
        a.description,
        a.price,
        a.views_count,
        u.name AS user_name,
        c.name AS category_name
    FROM Ad a
    JOIN [User] u ON a.user_id = u.user_id
    JOIN Category c ON a.category_id = c.category_id
    WHERE a.ad_id = @ad_id
)
-- Function لإرجاع الإعلانات حسب الكاتيجوري
go
CREATE FUNCTION fn_GetAdsByCategory (@category_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Ad
    WHERE category_id = @category_id
)
-- Function لإرجاع الإعلانات حسب الموقع
go
CREATE FUNCTION [dbo].[fn_GetAdsByLocation] (@location_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Ad
    WHERE location_id = @location_id
)
--3. Search & Filter Functions
-- Function لفلترة الإعلانات حسب السعر
go
CREATE FUNCTION fn_FilterAdsByPrice (@max_price DECIMAL(10,2))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Ad
    WHERE price <= @max_price
)
-- Function للبحث عن الإعلانات باستخدام العنوان
go
CREATE FUNCTION fn_SearchAdsByTitle (@title NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Ad
    WHERE title LIKE '%' + @title + '%'
)
--4. Favorites Functions
-- Function لإرجاع الإعلانات المفضلة لمستخدم معين
go
CREATE FUNCTION fn_GetUserFavorites (@user_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT a.*
    FROM Favorite f
    JOIN Ad a ON f.ad_id = a.ad_id
    WHERE f.user_id = @user_id
)
--5. Messaging Functions
-- Function لإرجاع كل رسائل محادثة معينة
go
CREATE FUNCTION fn_GetConversationMessages (@conversation_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM Message
    WHERE conversation_id = @conversation_id
)
--6. Review Functions

-- Function لإرجاع كل التقييمات الخاصة بإعلان
go
CREATE FUNCTION fn_GetAdReviews (@ad_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.rating,
        r.comment,
        a.title AS ad_title
    FROM Review r
    JOIN Ad a ON r.ad_id = a.ad_id
    WHERE r.ad_id = @ad_id
)

-- Function لإرجاع كل تقييمات مستخدم معين
go
CREATE FUNCTION fn_GetUserReviews (@user_id INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        r.rating,
        r.comment,
        u.name AS user_name
    FROM Review r
    JOIN [User] u ON r.reviewed_user_id = u.user_id
    WHERE r.reviewed_user_id = @user_id
)
--7. Reporting Functions
-- Function لإرجاع عدد البلاغات التي لم يتم معالجتها
go
CREATE FUNCTION fn_GetPendingReportsCount ()
RETURNS INT
AS
BEGIN
    DECLARE @count INT

    SELECT @count = COUNT(*)
    FROM Report
    WHERE status = 'pending'

    RETURN @count
END
--8. Analytics Functions
-- Function لإرجاع أفضل المستخدمين من حيث التقييم
go
CREATE FUNCTION fn_GetTopRatedUsers ()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5 
        r.reviewed_user_id,
        u.name as UserName,
        AVG(r.rating) AS average_rating
    FROM Review r
    JOIN [User] u ON r.reviewed_user_id = u.user_id
    GROUP BY r.reviewed_user_id, u.name
    ORDER BY average_rating DESC
)
-- Function لإرجاع أكثر المستخدمين نشاطًا بناءً على عدد الإعلانات
go
CREATE FUNCTION fn_GetMostActiveUsers ()
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5 
        u.user_id,
        u.name as UserName,
        COUNT(a.ad_id) AS ads_count
    FROM [User] u
    JOIN Ad a ON u.user_id = a.user_id
    GROUP BY u.user_id, u.name
    ORDER BY ads_count DESC
)
