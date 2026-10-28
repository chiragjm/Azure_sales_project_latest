/*
Azure Sales Project - DROP AND RECREATE TABLES
WARNING: This script permanently deletes the existing project tables and their data.
Run only in your dedicated project database, before running azure_sales_sample_data_v2.sql.
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRANSACTION;

-- Drop child tables before parent tables because of foreign-key dependencies.
IF OBJECT_ID(N'dbo.SalesOrderDetails', N'U') IS NOT NULL
    DROP TABLE dbo.SalesOrderDetails;

IF OBJECT_ID(N'dbo.SalesOrders', N'U') IS NOT NULL
    DROP TABLE dbo.SalesOrders;

IF OBJECT_ID(N'dbo.Products', N'U') IS NOT NULL
    DROP TABLE dbo.Products;

IF OBJECT_ID(N'dbo.Customers', N'U') IS NOT NULL
    DROP TABLE dbo.Customers;


-- Customers
CREATE TABLE dbo.Customers
(
    CustomerID   INT           NOT NULL,
    FirstName    NVARCHAR(50)  NOT NULL,
    LastName     NVARCHAR(50)  NOT NULL,
    EmailAddress NVARCHAR(255) NOT NULL,
    Phone        NVARCHAR(30)  NULL,
    CompanyName  NVARCHAR(100) NULL,
    City         NVARCHAR(100) NOT NULL,
    StateProvince NVARCHAR(100) NOT NULL,
    created_date DATETIME2(0)  NOT NULL CONSTRAINT DF_Customers_created_date DEFAULT SYSUTCDATETIME(),
    updated_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_Customers_updated_at DEFAULT SYSUTCDATETIME(),
    is_deleted   BIT           NOT NULL CONSTRAINT DF_Customers_is_deleted DEFAULT (0),
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID)
);

-- Products
CREATE TABLE dbo.Products
(
    ProductID   INT            NOT NULL,
    ProductName NVARCHAR(100)  NOT NULL,
    Category    NVARCHAR(100)  NOT NULL,
    UnitPrice   DECIMAL(12, 2) NOT NULL,
    created_date DATETIME2(0)  NOT NULL CONSTRAINT DF_Products_created_date DEFAULT SYSUTCDATETIME(),
    updated_at   DATETIME2(0)  NOT NULL CONSTRAINT DF_Products_updated_at DEFAULT SYSUTCDATETIME(),
    is_deleted   BIT           NOT NULL CONSTRAINT DF_Products_is_deleted DEFAULT (0),
    CONSTRAINT PK_Products PRIMARY KEY (ProductID),
    CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0)
);

-- Sales orders
CREATE TABLE dbo.SalesOrders
(
    SalesOrderID INT          NOT NULL,
    CustomerID   INT          NOT NULL,
    OrderDate    DATE         NOT NULL,
    OrderStatus  NVARCHAR(30) NOT NULL,
    created_date DATETIME2(0) NOT NULL CONSTRAINT DF_SalesOrders_created_date DEFAULT SYSUTCDATETIME(),
    updated_at   DATETIME2(0) NOT NULL CONSTRAINT DF_SalesOrders_updated_at DEFAULT SYSUTCDATETIME(),
    is_deleted   BIT          NOT NULL CONSTRAINT DF_SalesOrders_is_deleted DEFAULT (0),
    CONSTRAINT PK_SalesOrders PRIMARY KEY (SalesOrderID),
    CONSTRAINT FK_SalesOrders_Customers FOREIGN KEY (CustomerID)
        REFERENCES dbo.Customers(CustomerID)
);

-- Sales order details
CREATE TABLE dbo.SalesOrderDetails
(
    SalesOrderDetailID INT            NOT NULL,
    SalesOrderID       INT            NOT NULL,
    ProductID          INT            NOT NULL,
    OrderQuantity      INT            NOT NULL,
    UnitPrice          DECIMAL(12, 2) NOT NULL,
    LineTotal          DECIMAL(14, 2) NOT NULL,
    created_date       DATETIME2(0)   NOT NULL CONSTRAINT DF_SalesOrderDetails_created_date DEFAULT SYSUTCDATETIME(),
    updated_at         DATETIME2(0)   NOT NULL CONSTRAINT DF_SalesOrderDetails_updated_at DEFAULT SYSUTCDATETIME(),
    is_deleted         BIT            NOT NULL CONSTRAINT DF_SalesOrderDetails_is_deleted DEFAULT (0),
    CONSTRAINT PK_SalesOrderDetails PRIMARY KEY (SalesOrderDetailID),
    CONSTRAINT FK_SalesOrderDetails_SalesOrders FOREIGN KEY (SalesOrderID)
        REFERENCES dbo.SalesOrders(SalesOrderID),
    CONSTRAINT FK_SalesOrderDetails_Products FOREIGN KEY (ProductID)
        REFERENCES dbo.Products(ProductID),
    CONSTRAINT CK_SalesOrderDetails_OrderQuantity CHECK (OrderQuantity > 0),
    CONSTRAINT CK_SalesOrderDetails_UnitPrice CHECK (UnitPrice >= 0),
    CONSTRAINT CK_SalesOrderDetails_LineTotal CHECK (LineTotal >= 0)
);


COMMIT TRANSACTION;
