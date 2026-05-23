CREATE TABLE Location (
    location_id INT PRIMARY KEY IDENTITY(1,1),
    country NVARCHAR(50) NOT NULL,
    city NVARCHAR(50) NOT NULL,
    area NVARCHAR(50) NOT NULL
);

CREATE TABLE [User] (
    user_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    email NVARCHAR(100) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL,
    phone NVARCHAR(20),
    role NVARCHAR(20) CHECK (role IN ('user', 'moderator', 'admin')),
    status NVARCHAR(20) DEFAULT 'active',
    created_at DATETIME DEFAULT GETDATE(),
    is_email_verified BIT DEFAULT 0
);

CREATE TABLE Category (
    category_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    parent_id INT FOREIGN KEY REFERENCES Category(category_id)
);

CREATE TABLE Ad (
    ad_id INT PRIMARY KEY IDENTITY(1,1),
    title NVARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(18, 2),
    currency NVARCHAR(10) DEFAULT 'EGP',
    user_id INT FOREIGN KEY REFERENCES [User](user_id),
    category_id INT FOREIGN KEY REFERENCES Category(category_id),
    location_id INT FOREIGN KEY REFERENCES Location(location_id),
    created_at DATETIME DEFAULT GETDATE(),
    status NVARCHAR(20) DEFAULT 'pending',
    views_count INT DEFAULT 0,
    updated_at DATETIME DEFAULT GETDATE(),
);

CREATE TABLE AdImage (
    image_id INT PRIMARY KEY IDENTITY(1,1),
    ad_id INT FOREIGN KEY REFERENCES Ad(ad_id),
    image_url NVARCHAR(MAX) NOT NULL
);

CREATE TABLE AdAttribute (
    attribute_id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL
);

CREATE TABLE AdAttributeValue (
    ad_id INT FOREIGN KEY REFERENCES Ad(ad_id),
    attribute_id INT FOREIGN KEY REFERENCES AdAttribute(attribute_id),
    value NVARCHAR(MAX) NOT NULL,
    PRIMARY KEY (ad_id, attribute_id)
);

CREATE TABLE Favorite (
    user_id INT FOREIGN KEY REFERENCES [User](user_id),
    ad_id INT FOREIGN KEY REFERENCES Ad(ad_id),
    PRIMARY KEY (user_id, ad_id)
);

CREATE TABLE Conversation (
    conversation_id INT PRIMARY KEY IDENTITY(1,1),
    ad_id INT FOREIGN KEY REFERENCES Ad(ad_id),
    buyer_id INT FOREIGN KEY REFERENCES [User](user_id),
    seller_id INT FOREIGN KEY REFERENCES [User](user_id),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Message (
    message_id INT PRIMARY KEY IDENTITY(1,1),
    conversation_id INT FOREIGN KEY REFERENCES Conversation(conversation_id),
    sender_id INT FOREIGN KEY REFERENCES [User](user_id),
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Review (
    review_id INT PRIMARY KEY IDENTITY(1,1),
    reviewer_id INT FOREIGN KEY REFERENCES [User](user_id),
    reviewed_user_id INT FOREIGN KEY REFERENCES [User](user_id),
    ad_id INT FOREIGN KEY REFERENCES Ad(ad_id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE Report (
    report_id INT PRIMARY KEY IDENTITY(1,1),
    reporter_id INT FOREIGN KEY REFERENCES [User](user_id),
    target_type NVARCHAR(20),
    target_id INT NOT NULL,
    reason NVARCHAR(MAX),
    status NVARCHAR(20) DEFAULT 'pending',
    assigned_to INT FOREIGN KEY REFERENCES [User](user_id),
    created_at DATETIME DEFAULT GETDATE(),
    resolved_at DATETIME
);

CREATE TABLE ReportAction (
    action_id INT PRIMARY KEY IDENTITY(1,1),
    report_id INT FOREIGN KEY REFERENCES Report(report_id),
    moderator_id INT FOREIGN KEY REFERENCES [User](user_id),
    action_type NVARCHAR(50), -- (warning, delete_ad, ban_user, ignore)
    note NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);