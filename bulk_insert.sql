
BULK INSERT Location
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\location.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

BULK INSERT Category
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\category.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

BULK INSERT [User]
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\user.csv'
WITH (
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\r\n',
    FIELDQUOTE      = '"',    
    TABLOCK
);
GO

-- ④ Ad
BULK INSERT Ad
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\ad.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑤ AdImage
BULK INSERT AdImage
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\ad_image.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑥ AdAttribute
BULK INSERT AdAttribute
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\ad_attribute.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑦ AdAttributeValue
BULK INSERT AdAttributeValue
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\ad_attribute_value.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑧ Conversation
BULK INSERT Conversation
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\conversation.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑨ Message
BULK INSERT Message
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\message.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑩ Favorite
BULK INSERT Favorite
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\favorite.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑪ Review
BULK INSERT Review
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\review.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑫ Report
BULK INSERT Report
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\report.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO

-- ⑬ ReportAction
BULK INSERT ReportAction
FROM 'C:\Users\noura\OneDrive\Desktop\FINALYYY - Copy\report_action.csv'
WITH (FIRSTROW=2, FIELDTERMINATOR=',', ROWTERMINATOR='\n', TABLOCK);
GO