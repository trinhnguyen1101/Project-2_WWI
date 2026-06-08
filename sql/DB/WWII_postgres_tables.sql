CREATE SCHEMA IF NOT EXISTS "Application";
CREATE SCHEMA IF NOT EXISTS "Purchasing";
CREATE SCHEMA IF NOT EXISTS "Sales";
CREATE SCHEMA IF NOT EXISTS "Warehouse";

CREATE TABLE "Warehouse"."Colors_Archive" (
    "ColorID" integer NOT NULL,
    "ColorName" varchar(20) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Warehouse"."Colors" (
    "ColorID" integer NOT NULL,
    "ColorName" varchar(20) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_Colors" PRIMARY KEY ("ColorID"),
    CONSTRAINT "UQ_Warehouse_Colors_ColorName" UNIQUE ("ColorName")
);

CREATE TABLE "Warehouse"."PackageTypes_Archive" (
    "PackageTypeID" integer NOT NULL,
    "PackageTypeName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Warehouse"."PackageTypes" (
    "PackageTypeID" integer NOT NULL,
    "PackageTypeName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_PackageTypes" PRIMARY KEY ("PackageTypeID"),
    CONSTRAINT "UQ_Warehouse_PackageTypes_PackageTypeName" UNIQUE ("PackageTypeName")
);

CREATE TABLE "Warehouse"."StockGroups_Archive" (
    "StockGroupID" integer NOT NULL,
    "StockGroupName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Warehouse"."StockGroups" (
    "StockGroupID" integer NOT NULL,
    "StockGroupName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_StockGroups" PRIMARY KEY ("StockGroupID"),
    CONSTRAINT "UQ_Warehouse_StockGroups_StockGroupName" UNIQUE ("StockGroupName")
);

CREATE TABLE "Application"."StateProvinces_Archive" (
    "StateProvinceID" integer NOT NULL,
    "StateProvinceCode" varchar(5) NOT NULL,
    "StateProvinceName" varchar(50) NOT NULL,
    "CountryID" integer NOT NULL,
    "SalesTerritory" varchar(50) NOT NULL,
    "Border" text,
    "LatestRecordedPopulation" bigint,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."StateProvinces" (
    "StateProvinceID" integer NOT NULL,
    "StateProvinceCode" varchar(5) NOT NULL,
    "StateProvinceName" varchar(50) NOT NULL,
    "CountryID" integer NOT NULL,
    "SalesTerritory" varchar(50) NOT NULL,
    "Border" text,
    "LatestRecordedPopulation" bigint,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_StateProvinces" PRIMARY KEY ("StateProvinceID"),
    CONSTRAINT "UQ_Application_StateProvinces_StateProvinceName" UNIQUE ("StateProvinceName")
);

CREATE TABLE "Application"."Cities_Archive" (
    "CityID" integer NOT NULL,
    "CityName" varchar(50) NOT NULL,
    "StateProvinceID" integer NOT NULL,
    "Location" text,
    "LatestRecordedPopulation" bigint,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."Cities" (
    "CityID" integer NOT NULL,
    "CityName" varchar(50) NOT NULL,
    "StateProvinceID" integer NOT NULL,
    "Location" text,
    "LatestRecordedPopulation" bigint,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_Cities" PRIMARY KEY ("CityID")
);

CREATE TABLE "Purchasing"."Suppliers_Archive" (
    "SupplierID" integer NOT NULL,
    "SupplierName" varchar(100) NOT NULL,
    "SupplierCategoryID" integer NOT NULL,
    "PrimaryContactPersonID" integer NOT NULL,
    "AlternateContactPersonID" integer NOT NULL,
    "DeliveryMethodID" integer,
    "DeliveryCityID" integer NOT NULL,
    "PostalCityID" integer NOT NULL,
    "SupplierReference" varchar(20),
    "BankAccountName" varchar(50),
    "BankAccountBranch" varchar(50),
    "BankAccountCode" varchar(20),
    "BankAccountNumber" varchar(20),
    "BankInternationalCode" varchar(20),
    "PaymentDays" integer NOT NULL,
    "InternalComments" text,
    "PhoneNumber" varchar(20) NOT NULL,
    "FaxNumber" varchar(20) NOT NULL,
    "WebsiteURL" varchar(256) NOT NULL,
    "DeliveryAddressLine1" varchar(60) NOT NULL,
    "DeliveryAddressLine2" varchar(60),
    "DeliveryPostalCode" varchar(10) NOT NULL,
    "DeliveryLocation" text,
    "PostalAddressLine1" varchar(60) NOT NULL,
    "PostalAddressLine2" varchar(60),
    "PostalPostalCode" varchar(10) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Purchasing"."Suppliers" (
    "SupplierID" integer NOT NULL,
    "SupplierName" varchar(100) NOT NULL,
    "SupplierCategoryID" integer NOT NULL,
    "PrimaryContactPersonID" integer NOT NULL,
    "AlternateContactPersonID" integer NOT NULL,
    "DeliveryMethodID" integer,
    "DeliveryCityID" integer NOT NULL,
    "PostalCityID" integer NOT NULL,
    "SupplierReference" varchar(20),
    "BankAccountName" varchar(50),
    "BankAccountBranch" varchar(50),
    "BankAccountCode" varchar(20),
    "BankAccountNumber" varchar(20),
    "BankInternationalCode" varchar(20),
    "PaymentDays" integer NOT NULL,
    "InternalComments" text,
    "PhoneNumber" varchar(20) NOT NULL,
    "FaxNumber" varchar(20) NOT NULL,
    "WebsiteURL" varchar(256) NOT NULL,
    "DeliveryAddressLine1" varchar(60) NOT NULL,
    "DeliveryAddressLine2" varchar(60),
    "DeliveryPostalCode" varchar(10) NOT NULL,
    "DeliveryLocation" text,
    "PostalAddressLine1" varchar(60) NOT NULL,
    "PostalAddressLine2" varchar(60),
    "PostalPostalCode" varchar(10) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Purchasing_Suppliers" PRIMARY KEY ("SupplierID"),
    CONSTRAINT "UQ_Purchasing_Suppliers_SupplierName" UNIQUE ("SupplierName")
);

CREATE TABLE "Sales"."Customers_Archive" (
    "CustomerID" integer NOT NULL,
    "CustomerName" varchar(100) NOT NULL,
    "BillToCustomerID" integer NOT NULL,
    "CustomerCategoryID" integer NOT NULL,
    "BuyingGroupID" integer,
    "PrimaryContactPersonID" integer NOT NULL,
    "AlternateContactPersonID" integer,
    "DeliveryMethodID" integer NOT NULL,
    "DeliveryCityID" integer NOT NULL,
    "PostalCityID" integer NOT NULL,
    "CreditLimit" numeric(18, 2),
    "AccountOpenedDate" date NOT NULL,
    "StandardDiscountPercentage" numeric(18, 3) NOT NULL,
    "IsStatementSent" boolean NOT NULL,
    "IsOnCreditHold" boolean NOT NULL,
    "PaymentDays" integer NOT NULL,
    "PhoneNumber" varchar(20) NOT NULL,
    "FaxNumber" varchar(20) NOT NULL,
    "DeliveryRun" varchar(5),
    "RunPosition" varchar(5),
    "WebsiteURL" varchar(256) NOT NULL,
    "DeliveryAddressLine1" varchar(60) NOT NULL,
    "DeliveryAddressLine2" varchar(60),
    "DeliveryPostalCode" varchar(10) NOT NULL,
    "DeliveryLocation" text,
    "PostalAddressLine1" varchar(60) NOT NULL,
    "PostalAddressLine2" varchar(60),
    "PostalPostalCode" varchar(10) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Sales"."Customers" (
    "CustomerID" integer NOT NULL,
    "CustomerName" varchar(100) NOT NULL,
    "BillToCustomerID" integer NOT NULL,
    "CustomerCategoryID" integer NOT NULL,
    "BuyingGroupID" integer,
    "PrimaryContactPersonID" integer NOT NULL,
    "AlternateContactPersonID" integer,
    "DeliveryMethodID" integer NOT NULL,
    "DeliveryCityID" integer NOT NULL,
    "PostalCityID" integer NOT NULL,
    "CreditLimit" numeric(18, 2),
    "AccountOpenedDate" date NOT NULL,
    "StandardDiscountPercentage" numeric(18, 3) NOT NULL,
    "IsStatementSent" boolean NOT NULL,
    "IsOnCreditHold" boolean NOT NULL,
    "PaymentDays" integer NOT NULL,
    "PhoneNumber" varchar(20) NOT NULL,
    "FaxNumber" varchar(20) NOT NULL,
    "DeliveryRun" varchar(5),
    "RunPosition" varchar(5),
    "WebsiteURL" varchar(256) NOT NULL,
    "DeliveryAddressLine1" varchar(60) NOT NULL,
    "DeliveryAddressLine2" varchar(60),
    "DeliveryPostalCode" varchar(10) NOT NULL,
    "DeliveryLocation" text,
    "PostalAddressLine1" varchar(60) NOT NULL,
    "PostalAddressLine2" varchar(60),
    "PostalPostalCode" varchar(10) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_Customers" PRIMARY KEY ("CustomerID"),
    CONSTRAINT "UQ_Sales_Customers_CustomerName" UNIQUE ("CustomerName")
);

CREATE TABLE "Warehouse"."ColdRoomTemperatures_Archive" (
    "ColdRoomTemperatureID" bigint NOT NULL,
    "ColdRoomSensorNumber" integer NOT NULL,
    "RecordedWhen" timestamp(6) NOT NULL,
    "Temperature" numeric(10, 2) NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Warehouse"."ColdRoomTemperatures" (
    "ColdRoomTemperatureID" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    "ColdRoomSensorNumber" integer NOT NULL,
    "RecordedWhen" timestamp(6) NOT NULL,
    "Temperature" numeric(10, 2) NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_ColdRoomTemperatures" PRIMARY KEY ("ColdRoomTemperatureID")
);

CREATE TABLE "Application"."People_Archive" (
    "PersonID" integer NOT NULL,
    "FullName" varchar(50) NOT NULL,
    "PreferredName" varchar(50) NOT NULL,
    "SearchName" varchar(101) NOT NULL,
    "IsPermittedToLogon" boolean NOT NULL,
    "LogonName" varchar(50),
    "IsExternalLogonProvider" boolean NOT NULL,
    "HashedPassword" bytea,
    "IsSystemUser" boolean NOT NULL,
    "IsEmployee" boolean NOT NULL,
    "IsSalesperson" boolean NOT NULL,
    "UserPreferences" text,
    "PhoneNumber" varchar(20),
    "FaxNumber" varchar(20),
    "EmailAddress" varchar(256),
    "Photo" bytea,
    "CustomFields" text,
    "OtherLanguages" text,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."People" (
    "PersonID" integer NOT NULL,
    "FullName" varchar(50) NOT NULL,
    "PreferredName" varchar(50) NOT NULL,
    "SearchName" varchar(101) NOT NULL,
    "IsPermittedToLogon" boolean NOT NULL,
    "LogonName" varchar(50),
    "IsExternalLogonProvider" boolean NOT NULL,
    "HashedPassword" bytea,
    "IsSystemUser" boolean NOT NULL,
    "IsEmployee" boolean NOT NULL,
    "IsSalesperson" boolean NOT NULL,
    "UserPreferences" text,
    "PhoneNumber" varchar(20),
    "FaxNumber" varchar(20),
    "EmailAddress" varchar(256),
    "Photo" bytea,
    "CustomFields" text,
    "OtherLanguages" text,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_People" PRIMARY KEY ("PersonID")
);

CREATE TABLE "Warehouse"."StockItems_Archive" (
    "StockItemID" integer NOT NULL,
    "StockItemName" varchar(100) NOT NULL,
    "SupplierID" integer NOT NULL,
    "ColorID" integer,
    "UnitPackageID" integer NOT NULL,
    "OuterPackageID" integer NOT NULL,
    "Brand" varchar(50),
    "Size" varchar(20),
    "LeadTimeDays" integer NOT NULL,
    "QuantityPerOuter" integer NOT NULL,
    "IsChillerStock" boolean NOT NULL,
    "Barcode" varchar(50),
    "TaxRate" numeric(18, 3) NOT NULL,
    "UnitPrice" numeric(18, 2) NOT NULL,
    "RecommendedRetailPrice" numeric(18, 2),
    "TypicalWeightPerUnit" numeric(18, 3) NOT NULL,
    "MarketingComments" text,
    "InternalComments" text,
    "Photo" bytea,
    "CustomFields" text,
    "Tags" text,
    "SearchDetails" text NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Warehouse"."StockItems" (
    "StockItemID" integer NOT NULL,
    "StockItemName" varchar(100) NOT NULL,
    "SupplierID" integer NOT NULL,
    "ColorID" integer,
    "UnitPackageID" integer NOT NULL,
    "OuterPackageID" integer NOT NULL,
    "Brand" varchar(50),
    "Size" varchar(20),
    "LeadTimeDays" integer NOT NULL,
    "QuantityPerOuter" integer NOT NULL,
    "IsChillerStock" boolean NOT NULL,
    "Barcode" varchar(50),
    "TaxRate" numeric(18, 3) NOT NULL,
    "UnitPrice" numeric(18, 2) NOT NULL,
    "RecommendedRetailPrice" numeric(18, 2),
    "TypicalWeightPerUnit" numeric(18, 3) NOT NULL,
    "MarketingComments" text,
    "InternalComments" text,
    "Photo" bytea,
    "CustomFields" text,
    "Tags" text,
    "SearchDetails" text NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_StockItems" PRIMARY KEY ("StockItemID"),
    CONSTRAINT "UQ_Warehouse_StockItems_StockItemName" UNIQUE ("StockItemName")
);

CREATE TABLE "Application"."Countries_Archive" (
    "CountryID" integer NOT NULL,
    "CountryName" varchar(60) NOT NULL,
    "FormalName" varchar(60) NOT NULL,
    "IsoAlpha3Code" varchar(3),
    "IsoNumericCode" integer,
    "CountryType" varchar(20),
    "LatestRecordedPopulation" bigint,
    "Continent" varchar(30) NOT NULL,
    "Region" varchar(30) NOT NULL,
    "Subregion" varchar(30) NOT NULL,
    "Border" text,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."Countries" (
    "CountryID" integer NOT NULL,
    "CountryName" varchar(60) NOT NULL,
    "FormalName" varchar(60) NOT NULL,
    "IsoAlpha3Code" varchar(3),
    "IsoNumericCode" integer,
    "CountryType" varchar(20),
    "LatestRecordedPopulation" bigint,
    "Continent" varchar(30) NOT NULL,
    "Region" varchar(30) NOT NULL,
    "Subregion" varchar(30) NOT NULL,
    "Border" text,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_Countries" PRIMARY KEY ("CountryID"),
    CONSTRAINT "UQ_Application_Countries_CountryName" UNIQUE ("CountryName"),
    CONSTRAINT "UQ_Application_Countries_FormalName" UNIQUE ("FormalName")
);

CREATE TABLE "Application"."DeliveryMethods_Archive" (
    "DeliveryMethodID" integer NOT NULL,
    "DeliveryMethodName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."DeliveryMethods" (
    "DeliveryMethodID" integer NOT NULL,
    "DeliveryMethodName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_DeliveryMethods" PRIMARY KEY ("DeliveryMethodID"),
    CONSTRAINT "UQ_Application_DeliveryMethods_DeliveryMethodName" UNIQUE ("DeliveryMethodName")
);

CREATE TABLE "Application"."PaymentMethods_Archive" (
    "PaymentMethodID" integer NOT NULL,
    "PaymentMethodName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."PaymentMethods" (
    "PaymentMethodID" integer NOT NULL,
    "PaymentMethodName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_PaymentMethods" PRIMARY KEY ("PaymentMethodID"),
    CONSTRAINT "UQ_Application_PaymentMethods_PaymentMethodName" UNIQUE ("PaymentMethodName")
);

CREATE TABLE "Application"."TransactionTypes_Archive" (
    "TransactionTypeID" integer NOT NULL,
    "TransactionTypeName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Application"."TransactionTypes" (
    "TransactionTypeID" integer NOT NULL,
    "TransactionTypeName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_TransactionTypes" PRIMARY KEY ("TransactionTypeID"),
    CONSTRAINT "UQ_Application_TransactionTypes_TransactionTypeName" UNIQUE ("TransactionTypeName")
);

CREATE TABLE "Purchasing"."SupplierCategories_Archive" (
    "SupplierCategoryID" integer NOT NULL,
    "SupplierCategoryName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Purchasing"."SupplierCategories" (
    "SupplierCategoryID" integer NOT NULL,
    "SupplierCategoryName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Purchasing_SupplierCategories" PRIMARY KEY ("SupplierCategoryID"),
    CONSTRAINT "UQ_Purchasing_SupplierCategories_SupplierCategoryName" UNIQUE ("SupplierCategoryName")
);

CREATE TABLE "Sales"."BuyingGroups_Archive" (
    "BuyingGroupID" integer NOT NULL,
    "BuyingGroupName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Sales"."BuyingGroups" (
    "BuyingGroupID" integer NOT NULL,
    "BuyingGroupName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_BuyingGroups" PRIMARY KEY ("BuyingGroupID"),
    CONSTRAINT "UQ_Sales_BuyingGroups_BuyingGroupName" UNIQUE ("BuyingGroupName")
);

CREATE TABLE "Sales"."CustomerCategories_Archive" (
    "CustomerCategoryID" integer NOT NULL,
    "CustomerCategoryName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL
);

CREATE TABLE "Sales"."CustomerCategories" (
    "CustomerCategoryID" integer NOT NULL,
    "CustomerCategoryName" varchar(50) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "ValidFrom" timestamp(6) NOT NULL,
    "ValidTo" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_CustomerCategories" PRIMARY KEY ("CustomerCategoryID"),
    CONSTRAINT "UQ_Sales_CustomerCategories_CustomerCategoryName" UNIQUE ("CustomerCategoryName")
);

CREATE TABLE "Application"."SystemParameters" (
    "SystemParameterID" integer NOT NULL,
    "DeliveryAddressLine1" varchar(60) NOT NULL,
    "DeliveryAddressLine2" varchar(60),
    "DeliveryCityID" integer NOT NULL,
    "DeliveryPostalCode" varchar(10) NOT NULL,
    "DeliveryLocation" text NOT NULL,
    "PostalAddressLine1" varchar(60) NOT NULL,
    "PostalAddressLine2" varchar(60),
    "PostalCityID" integer NOT NULL,
    "PostalPostalCode" varchar(10) NOT NULL,
    "ApplicationSettings" text NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Application_SystemParameters" PRIMARY KEY ("SystemParameterID")
);

CREATE TABLE "Purchasing"."PurchaseOrderLines" (
    "PurchaseOrderLineID" integer NOT NULL,
    "PurchaseOrderID" integer NOT NULL,
    "StockItemID" integer NOT NULL,
    "OrderedOuters" integer NOT NULL,
    "Description" varchar(100) NOT NULL,
    "ReceivedOuters" integer NOT NULL,
    "PackageTypeID" integer NOT NULL,
    "ExpectedUnitPricePerOuter" numeric(18, 2),
    "LastReceiptDate" date,
    "IsOrderLineFinalized" boolean NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Purchasing_PurchaseOrderLines" PRIMARY KEY ("PurchaseOrderLineID")
);

CREATE TABLE "Purchasing"."PurchaseOrders" (
    "PurchaseOrderID" integer NOT NULL,
    "SupplierID" integer NOT NULL,
    "OrderDate" date NOT NULL,
    "DeliveryMethodID" integer NOT NULL,
    "ContactPersonID" integer NOT NULL,
    "ExpectedDeliveryDate" date,
    "SupplierReference" varchar(20),
    "IsOrderFinalized" boolean NOT NULL,
    "Comments" text,
    "InternalComments" text,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Purchasing_PurchaseOrders" PRIMARY KEY ("PurchaseOrderID")
);

CREATE TABLE "Purchasing"."SupplierTransactions" (
    "SupplierTransactionID" integer NOT NULL,
    "SupplierID" integer NOT NULL,
    "TransactionTypeID" integer NOT NULL,
    "PurchaseOrderID" integer,
    "PaymentMethodID" integer,
    "SupplierInvoiceNumber" varchar(20),
    "TransactionDate" date NOT NULL,
    "AmountExcludingTax" numeric(18, 2) NOT NULL,
    "TaxAmount" numeric(18, 2) NOT NULL,
    "TransactionAmount" numeric(18, 2) NOT NULL,
    "OutstandingBalance" numeric(18, 2) NOT NULL,
    "FinalizationDate" date,
    "IsFinalized" boolean,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Purchasing_SupplierTransactions" PRIMARY KEY ("SupplierTransactionID")
);

CREATE TABLE "Sales"."CustomerTransactions" (
    "CustomerTransactionID" integer NOT NULL,
    "CustomerID" integer NOT NULL,
    "TransactionTypeID" integer NOT NULL,
    "InvoiceID" integer,
    "PaymentMethodID" integer,
    "TransactionDate" date NOT NULL,
    "AmountExcludingTax" numeric(18, 2) NOT NULL,
    "TaxAmount" numeric(18, 2) NOT NULL,
    "TransactionAmount" numeric(18, 2) NOT NULL,
    "OutstandingBalance" numeric(18, 2) NOT NULL,
    "FinalizationDate" date,
    "IsFinalized" boolean,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_CustomerTransactions" PRIMARY KEY ("CustomerTransactionID")
);

CREATE TABLE "Sales"."InvoiceLines" (
    "InvoiceLineID" integer NOT NULL,
    "InvoiceID" integer NOT NULL,
    "StockItemID" integer NOT NULL,
    "Description" varchar(100) NOT NULL,
    "PackageTypeID" integer NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(18, 2),
    "TaxRate" numeric(18, 3) NOT NULL,
    "TaxAmount" numeric(18, 2) NOT NULL,
    "LineProfit" numeric(18, 2) NOT NULL,
    "ExtendedPrice" numeric(18, 2) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_InvoiceLines" PRIMARY KEY ("InvoiceLineID")
);

CREATE TABLE "Sales"."Invoices" (
    "InvoiceID" integer NOT NULL,
    "CustomerID" integer NOT NULL,
    "BillToCustomerID" integer NOT NULL,
    "OrderID" integer,
    "DeliveryMethodID" integer NOT NULL,
    "ContactPersonID" integer NOT NULL,
    "AccountsPersonID" integer NOT NULL,
    "SalespersonPersonID" integer NOT NULL,
    "PackedByPersonID" integer NOT NULL,
    "InvoiceDate" date NOT NULL,
    "CustomerPurchaseOrderNumber" varchar(20),
    "IsCreditNote" boolean NOT NULL,
    "CreditNoteReason" text,
    "Comments" text,
    "DeliveryInstructions" text,
    "InternalComments" text,
    "TotalDryItems" integer NOT NULL,
    "TotalChillerItems" integer NOT NULL,
    "DeliveryRun" varchar(5),
    "RunPosition" varchar(5),
    "ReturnedDeliveryData" text,
    "ConfirmedDeliveryTime" timestamp(6),
    "ConfirmedReceivedBy" text,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_Invoices" PRIMARY KEY ("InvoiceID")
);

CREATE TABLE "Sales"."OrderLines" (
    "OrderLineID" integer NOT NULL,
    "OrderID" integer NOT NULL,
    "StockItemID" integer NOT NULL,
    "Description" varchar(100) NOT NULL,
    "PackageTypeID" integer NOT NULL,
    "Quantity" integer NOT NULL,
    "UnitPrice" numeric(18, 2),
    "TaxRate" numeric(18, 3) NOT NULL,
    "PickedQuantity" integer NOT NULL,
    "PickingCompletedWhen" timestamp(6),
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_OrderLines" PRIMARY KEY ("OrderLineID")
);

CREATE TABLE "Sales"."Orders" (
    "OrderID" integer NOT NULL,
    "CustomerID" integer NOT NULL,
    "SalespersonPersonID" integer NOT NULL,
    "PickedByPersonID" integer,
    "ContactPersonID" integer NOT NULL,
    "BackorderOrderID" integer,
    "OrderDate" date NOT NULL,
    "ExpectedDeliveryDate" date NOT NULL,
    "CustomerPurchaseOrderNumber" varchar(20),
    "IsUndersupplyBackordered" boolean NOT NULL,
    "Comments" text,
    "DeliveryInstructions" text,
    "InternalComments" text,
    "PickingCompletedWhen" timestamp(6),
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_Orders" PRIMARY KEY ("OrderID")
);

CREATE TABLE "Sales"."SpecialDeals" (
    "SpecialDealID" integer NOT NULL,
    "StockItemID" integer,
    "CustomerID" integer,
    "BuyingGroupID" integer,
    "CustomerCategoryID" integer,
    "StockGroupID" integer,
    "DealDescription" varchar(30) NOT NULL,
    "StartDate" date NOT NULL,
    "EndDate" date NOT NULL,
    "DiscountAmount" numeric(18, 2),
    "DiscountPercentage" numeric(18, 3),
    "UnitPrice" numeric(18, 2),
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Sales_SpecialDeals" PRIMARY KEY ("SpecialDealID")
);

CREATE TABLE "Warehouse"."StockItemHoldings" (
    "StockItemID" integer NOT NULL,
    "QuantityOnHand" integer NOT NULL,
    "BinLocation" varchar(20) NOT NULL,
    "LastStocktakeQuantity" integer NOT NULL,
    "LastCostPrice" numeric(18, 2) NOT NULL,
    "ReorderLevel" integer NOT NULL,
    "TargetStockLevel" integer NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_StockItemHoldings" PRIMARY KEY ("StockItemID")
);

CREATE TABLE "Warehouse"."StockItemStockGroups" (
    "StockItemStockGroupID" integer NOT NULL,
    "StockItemID" integer NOT NULL,
    "StockGroupID" integer NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_StockItemStockGroups" PRIMARY KEY ("StockItemStockGroupID"),
    CONSTRAINT "UQ_StockItemStockGroups_StockGroupID_Lookup" UNIQUE ("StockGroupID", "StockItemID"),
    CONSTRAINT "UQ_StockItemStockGroups_StockItemID_Lookup" UNIQUE ("StockItemID", "StockGroupID")
);

CREATE TABLE "Warehouse"."StockItemTransactions" (
    "StockItemTransactionID" integer NOT NULL,
    "StockItemID" integer NOT NULL,
    "TransactionTypeID" integer NOT NULL,
    "CustomerID" integer,
    "InvoiceID" integer,
    "SupplierID" integer,
    "PurchaseOrderID" integer,
    "TransactionOccurredWhen" timestamp(6) NOT NULL,
    "Quantity" numeric(18, 3) NOT NULL,
    "LastEditedBy" integer NOT NULL,
    "LastEditedWhen" timestamp(6) NOT NULL,
    CONSTRAINT "PK_Warehouse_StockItemTransactions" PRIMARY KEY ("StockItemTransactionID")
);

CREATE TABLE "Warehouse"."VehicleTemperatures" (
    "VehicleTemperatureID" bigint GENERATED BY DEFAULT AS IDENTITY NOT NULL,
    "VehicleRegistration" varchar(20) NOT NULL,
    "ChillerSensorNumber" integer NOT NULL,
    "RecordedWhen" timestamp(6) NOT NULL,
    "Temperature" numeric(10, 2) NOT NULL,
    "FullSensorData" varchar(1000),
    "IsCompressed" boolean NOT NULL,
    "CompressedSensorData" bytea,
    CONSTRAINT "PK_Warehouse_VehicleTemperatures" PRIMARY KEY ("VehicleTemperatureID")
);

-- Foreign key relationships converted from WWII.sql
ALTER TABLE "Application"."Cities"
ADD CONSTRAINT "FK_Application_Cities_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."Cities"
ADD CONSTRAINT "FK_Application_Cities_StateProvinceID_Application_StateProvinces"
FOREIGN KEY ("StateProvinceID")
REFERENCES "Application"."StateProvinces" ("StateProvinceID");

ALTER TABLE "Application"."Countries"
ADD CONSTRAINT "FK_Application_Countries_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."DeliveryMethods"
ADD CONSTRAINT "FK_Application_DeliveryMethods_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."PaymentMethods"
ADD CONSTRAINT "FK_Application_PaymentMethods_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."People"
ADD CONSTRAINT "FK_Application_People_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."StateProvinces"
ADD CONSTRAINT "FK_Application_StateProvinces_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."StateProvinces"
ADD CONSTRAINT "FK_Application_StateProvinces_CountryID_Application_Countries"
FOREIGN KEY ("CountryID")
REFERENCES "Application"."Countries" ("CountryID");

ALTER TABLE "Application"."SystemParameters"
ADD CONSTRAINT "FK_Application_SystemParameters_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Application"."SystemParameters"
ADD CONSTRAINT "FK_Application_SystemParameters_DeliveryCityID_Application_Cities"
FOREIGN KEY ("DeliveryCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Application"."SystemParameters"
ADD CONSTRAINT "FK_Application_SystemParameters_PostalCityID_Application_Cities"
FOREIGN KEY ("PostalCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Application"."TransactionTypes"
ADD CONSTRAINT "FK_Application_TransactionTypes_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."PurchaseOrderLines"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrderLines_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."PurchaseOrderLines"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrderLines_PackageTypeID_Warehouse_PackageTypes"
FOREIGN KEY ("PackageTypeID")
REFERENCES "Warehouse"."PackageTypes" ("PackageTypeID");

ALTER TABLE "Purchasing"."PurchaseOrderLines"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrderLines_PurchaseOrderID_Purchasing_PurchaseOrders"
FOREIGN KEY ("PurchaseOrderID")
REFERENCES "Purchasing"."PurchaseOrders" ("PurchaseOrderID");

ALTER TABLE "Purchasing"."PurchaseOrderLines"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrderLines_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Purchasing"."PurchaseOrders"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrders_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."PurchaseOrders"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrders_ContactPersonID_Application_People"
FOREIGN KEY ("ContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."PurchaseOrders"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrders_DeliveryMethodID_Application_DeliveryMethods"
FOREIGN KEY ("DeliveryMethodID")
REFERENCES "Application"."DeliveryMethods" ("DeliveryMethodID");

ALTER TABLE "Purchasing"."PurchaseOrders"
ADD CONSTRAINT "FK_Purchasing_PurchaseOrders_SupplierID_Purchasing_Suppliers"
FOREIGN KEY ("SupplierID")
REFERENCES "Purchasing"."Suppliers" ("SupplierID");

ALTER TABLE "Purchasing"."SupplierCategories"
ADD CONSTRAINT "FK_Purchasing_SupplierCategories_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_AlternateContactPersonID_Application_People"
FOREIGN KEY ("AlternateContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_DeliveryCityID_Application_Cities"
FOREIGN KEY ("DeliveryCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_DeliveryMethodID_Application_DeliveryMethods"
FOREIGN KEY ("DeliveryMethodID")
REFERENCES "Application"."DeliveryMethods" ("DeliveryMethodID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_PostalCityID_Application_Cities"
FOREIGN KEY ("PostalCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_PrimaryContactPersonID_Application_People"
FOREIGN KEY ("PrimaryContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."Suppliers"
ADD CONSTRAINT "FK_Purchasing_Suppliers_SupplierCategoryID_Purchasing_SupplierCategories"
FOREIGN KEY ("SupplierCategoryID")
REFERENCES "Purchasing"."SupplierCategories" ("SupplierCategoryID");

ALTER TABLE "Purchasing"."SupplierTransactions"
ADD CONSTRAINT "FK_Purchasing_SupplierTransactions_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Purchasing"."SupplierTransactions"
ADD CONSTRAINT "FK_Purchasing_SupplierTransactions_PaymentMethodID_Application_PaymentMethods"
FOREIGN KEY ("PaymentMethodID")
REFERENCES "Application"."PaymentMethods" ("PaymentMethodID");

ALTER TABLE "Purchasing"."SupplierTransactions"
ADD CONSTRAINT "FK_Purchasing_SupplierTransactions_PurchaseOrderID_Purchasing_PurchaseOrders"
FOREIGN KEY ("PurchaseOrderID")
REFERENCES "Purchasing"."PurchaseOrders" ("PurchaseOrderID");

ALTER TABLE "Purchasing"."SupplierTransactions"
ADD CONSTRAINT "FK_Purchasing_SupplierTransactions_SupplierID_Purchasing_Suppliers"
FOREIGN KEY ("SupplierID")
REFERENCES "Purchasing"."Suppliers" ("SupplierID");

ALTER TABLE "Purchasing"."SupplierTransactions"
ADD CONSTRAINT "FK_Purchasing_SupplierTransactions_TransactionTypeID_Application_TransactionTypes"
FOREIGN KEY ("TransactionTypeID")
REFERENCES "Application"."TransactionTypes" ("TransactionTypeID");

ALTER TABLE "Sales"."BuyingGroups"
ADD CONSTRAINT "FK_Sales_BuyingGroups_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."CustomerCategories"
ADD CONSTRAINT "FK_Sales_CustomerCategories_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_AlternateContactPersonID_Application_People"
FOREIGN KEY ("AlternateContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_BillToCustomerID_Sales_Customers"
FOREIGN KEY ("BillToCustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_BuyingGroupID_Sales_BuyingGroups"
FOREIGN KEY ("BuyingGroupID")
REFERENCES "Sales"."BuyingGroups" ("BuyingGroupID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_CustomerCategoryID_Sales_CustomerCategories"
FOREIGN KEY ("CustomerCategoryID")
REFERENCES "Sales"."CustomerCategories" ("CustomerCategoryID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_DeliveryCityID_Application_Cities"
FOREIGN KEY ("DeliveryCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_DeliveryMethodID_Application_DeliveryMethods"
FOREIGN KEY ("DeliveryMethodID")
REFERENCES "Application"."DeliveryMethods" ("DeliveryMethodID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_PostalCityID_Application_Cities"
FOREIGN KEY ("PostalCityID")
REFERENCES "Application"."Cities" ("CityID");

ALTER TABLE "Sales"."Customers"
ADD CONSTRAINT "FK_Sales_Customers_PrimaryContactPersonID_Application_People"
FOREIGN KEY ("PrimaryContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."CustomerTransactions"
ADD CONSTRAINT "FK_Sales_CustomerTransactions_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."CustomerTransactions"
ADD CONSTRAINT "FK_Sales_CustomerTransactions_CustomerID_Sales_Customers"
FOREIGN KEY ("CustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."CustomerTransactions"
ADD CONSTRAINT "FK_Sales_CustomerTransactions_InvoiceID_Sales_Invoices"
FOREIGN KEY ("InvoiceID")
REFERENCES "Sales"."Invoices" ("InvoiceID");

ALTER TABLE "Sales"."CustomerTransactions"
ADD CONSTRAINT "FK_Sales_CustomerTransactions_PaymentMethodID_Application_PaymentMethods"
FOREIGN KEY ("PaymentMethodID")
REFERENCES "Application"."PaymentMethods" ("PaymentMethodID");

ALTER TABLE "Sales"."CustomerTransactions"
ADD CONSTRAINT "FK_Sales_CustomerTransactions_TransactionTypeID_Application_TransactionTypes"
FOREIGN KEY ("TransactionTypeID")
REFERENCES "Application"."TransactionTypes" ("TransactionTypeID");

ALTER TABLE "Sales"."InvoiceLines"
ADD CONSTRAINT "FK_Sales_InvoiceLines_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."InvoiceLines"
ADD CONSTRAINT "FK_Sales_InvoiceLines_InvoiceID_Sales_Invoices"
FOREIGN KEY ("InvoiceID")
REFERENCES "Sales"."Invoices" ("InvoiceID");

ALTER TABLE "Sales"."InvoiceLines"
ADD CONSTRAINT "FK_Sales_InvoiceLines_PackageTypeID_Warehouse_PackageTypes"
FOREIGN KEY ("PackageTypeID")
REFERENCES "Warehouse"."PackageTypes" ("PackageTypeID");

ALTER TABLE "Sales"."InvoiceLines"
ADD CONSTRAINT "FK_Sales_InvoiceLines_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_AccountsPersonID_Application_People"
FOREIGN KEY ("AccountsPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_BillToCustomerID_Sales_Customers"
FOREIGN KEY ("BillToCustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_ContactPersonID_Application_People"
FOREIGN KEY ("ContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_CustomerID_Sales_Customers"
FOREIGN KEY ("CustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_DeliveryMethodID_Application_DeliveryMethods"
FOREIGN KEY ("DeliveryMethodID")
REFERENCES "Application"."DeliveryMethods" ("DeliveryMethodID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_OrderID_Sales_Orders"
FOREIGN KEY ("OrderID")
REFERENCES "Sales"."Orders" ("OrderID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_PackedByPersonID_Application_People"
FOREIGN KEY ("PackedByPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Invoices"
ADD CONSTRAINT "FK_Sales_Invoices_SalespersonPersonID_Application_People"
FOREIGN KEY ("SalespersonPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."OrderLines"
ADD CONSTRAINT "FK_Sales_OrderLines_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."OrderLines"
ADD CONSTRAINT "FK_Sales_OrderLines_OrderID_Sales_Orders"
FOREIGN KEY ("OrderID")
REFERENCES "Sales"."Orders" ("OrderID");

ALTER TABLE "Sales"."OrderLines"
ADD CONSTRAINT "FK_Sales_OrderLines_PackageTypeID_Warehouse_PackageTypes"
FOREIGN KEY ("PackageTypeID")
REFERENCES "Warehouse"."PackageTypes" ("PackageTypeID");

ALTER TABLE "Sales"."OrderLines"
ADD CONSTRAINT "FK_Sales_OrderLines_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_BackorderOrderID_Sales_Orders"
FOREIGN KEY ("BackorderOrderID")
REFERENCES "Sales"."Orders" ("OrderID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_ContactPersonID_Application_People"
FOREIGN KEY ("ContactPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_CustomerID_Sales_Customers"
FOREIGN KEY ("CustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_PickedByPersonID_Application_People"
FOREIGN KEY ("PickedByPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."Orders"
ADD CONSTRAINT "FK_Sales_Orders_SalespersonPersonID_Application_People"
FOREIGN KEY ("SalespersonPersonID")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_BuyingGroupID_Sales_BuyingGroups"
FOREIGN KEY ("BuyingGroupID")
REFERENCES "Sales"."BuyingGroups" ("BuyingGroupID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_CustomerCategoryID_Sales_CustomerCategories"
FOREIGN KEY ("CustomerCategoryID")
REFERENCES "Sales"."CustomerCategories" ("CustomerCategoryID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_CustomerID_Sales_Customers"
FOREIGN KEY ("CustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_StockGroupID_Warehouse_StockGroups"
FOREIGN KEY ("StockGroupID")
REFERENCES "Warehouse"."StockGroups" ("StockGroupID");

ALTER TABLE "Sales"."SpecialDeals"
ADD CONSTRAINT "FK_Sales_SpecialDeals_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Warehouse"."Colors"
ADD CONSTRAINT "FK_Warehouse_Colors_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."PackageTypes"
ADD CONSTRAINT "FK_Warehouse_PackageTypes_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockGroups"
ADD CONSTRAINT "FK_Warehouse_StockGroups_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockItemHoldings"
ADD CONSTRAINT "FK_Warehouse_StockItemHoldings_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockItemHoldings"
ADD CONSTRAINT "PKFK_Warehouse_StockItemHoldings_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Warehouse"."StockItems"
ADD CONSTRAINT "FK_Warehouse_StockItems_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockItems"
ADD CONSTRAINT "FK_Warehouse_StockItems_ColorID_Warehouse_Colors"
FOREIGN KEY ("ColorID")
REFERENCES "Warehouse"."Colors" ("ColorID");

ALTER TABLE "Warehouse"."StockItems"
ADD CONSTRAINT "FK_Warehouse_StockItems_OuterPackageID_Warehouse_PackageTypes"
FOREIGN KEY ("OuterPackageID")
REFERENCES "Warehouse"."PackageTypes" ("PackageTypeID");

ALTER TABLE "Warehouse"."StockItems"
ADD CONSTRAINT "FK_Warehouse_StockItems_SupplierID_Purchasing_Suppliers"
FOREIGN KEY ("SupplierID")
REFERENCES "Purchasing"."Suppliers" ("SupplierID");

ALTER TABLE "Warehouse"."StockItems"
ADD CONSTRAINT "FK_Warehouse_StockItems_UnitPackageID_Warehouse_PackageTypes"
FOREIGN KEY ("UnitPackageID")
REFERENCES "Warehouse"."PackageTypes" ("PackageTypeID");

ALTER TABLE "Warehouse"."StockItemStockGroups"
ADD CONSTRAINT "FK_Warehouse_StockItemStockGroups_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockItemStockGroups"
ADD CONSTRAINT "FK_Warehouse_StockItemStockGroups_StockGroupID_Warehouse_StockGroups"
FOREIGN KEY ("StockGroupID")
REFERENCES "Warehouse"."StockGroups" ("StockGroupID");

ALTER TABLE "Warehouse"."StockItemStockGroups"
ADD CONSTRAINT "FK_Warehouse_StockItemStockGroups_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_Application_People"
FOREIGN KEY ("LastEditedBy")
REFERENCES "Application"."People" ("PersonID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_CustomerID_Sales_Customers"
FOREIGN KEY ("CustomerID")
REFERENCES "Sales"."Customers" ("CustomerID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_InvoiceID_Sales_Invoices"
FOREIGN KEY ("InvoiceID")
REFERENCES "Sales"."Invoices" ("InvoiceID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_PurchaseOrderID_Purchasing_PurchaseOrders"
FOREIGN KEY ("PurchaseOrderID")
REFERENCES "Purchasing"."PurchaseOrders" ("PurchaseOrderID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_StockItemID_Warehouse_StockItems"
FOREIGN KEY ("StockItemID")
REFERENCES "Warehouse"."StockItems" ("StockItemID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_SupplierID_Purchasing_Suppliers"
FOREIGN KEY ("SupplierID")
REFERENCES "Purchasing"."Suppliers" ("SupplierID");

ALTER TABLE "Warehouse"."StockItemTransactions"
ADD CONSTRAINT "FK_Warehouse_StockItemTransactions_TransactionTypeID_Application_TransactionTypes"
FOREIGN KEY ("TransactionTypeID")
REFERENCES "Application"."TransactionTypes" ("TransactionTypeID");
