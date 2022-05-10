-- KPI  - TOP SELLING BRAND

ALTER FUNCTION [dbo].[F_TOP_SELLING_BRAND]()
RETURNS TABLE
AS RETURN
SELECT UPPER(BrandName) AS [TOP SELLING BRAND]
FROM (SELECT TOP (1) P.BrandName, ROUND(SUM(S.SalesAmount), 0) AS SALES_AMOUNT
        FROM  dbo.Sales AS S INNER JOIN dbo.Product AS P ON P.ProductKey = S.ProductKey
    GROUP BY P.BrandName
    ORDER BY SALES_AMOUNT DESC) AS Q1;

-- KPI  - SALES BY STORE TYPE

ALTER FUNCTION [dbo].[F_SALES_BY_STORE_TYPE]()
RETURNS TABLE
AS RETURN
SELECT SS.StoreType, ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM  dbo.Sales AS S INNER JOIN
      dbo.Stores AS SS ON S.StoreKey = SS.StoreKey
GROUP BY SS.StoreType;

-- KPI  - SALES BY PRODUCT CATEGORY

ALTER FUNCTION [dbo].[F_SALES_BY_PRODUCT_CATEGORY]()
RETURNS TABLE
AS RETURN
SELECT UPPER(C.ProductCategory) AS [PRODUCT CATEGORY], ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM  dbo.Sales AS S INNER JOIN
      dbo.Product AS P ON S.ProductKey = P.ProductKey INNER JOIN
      dbo.ProductSubcategory AS SC ON P.ProductSubcategoryKey = SC.ProductSubcategoryKey INNER JOIN
      dbo.ProductCategory AS C ON SC.ProductCategoryKey = C.ProductCategoryKey
GROUP BY C.ProductCategory;


-- KPI  - YEARLY SALES BY COUNTRY

ALTER FUNCTION [dbo].[F_YEARLY_SALES_BY_COUNTRY]()
RETURNS TABLE
AS RETURN
SELECT C.Year, G.RegionCountryName AS COUNTRY, ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM dbo.Sales AS S INNER JOIN
     dbo.Stores AS SS ON S.StoreKey = SS.StoreKey INNER JOIN
     dbo.Geography AS G ON G.GeographyKey = SS.GeographyKey INNER JOIN
     dbo.Calendar AS C ON S.DateKey = C.DateKey
WHERE (G.RegionCountryName IN
                  (SELECT RegionCountryName
                    FROM  dbo.Geography
                   WHERE  (GeographyType IN ('COUNTRY/REGION'))))
GROUP BY C.Year, G.RegionCountryName;

-- KPI  - RECENT YEAR SALES BY COUNTRY

ALTER FUNCTION [dbo].[F_RECENT_YEARLY_SALES_BY_COUNTRY]()
RETURNS TABLE
AS RETURN
SELECT C.Year AS [RECENT YEAR], G.RegionCountryName AS COUNTRY, ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM  dbo.Sales AS S INNER JOIN
      dbo.Stores AS SS ON S.StoreKey = SS.StoreKey INNER JOIN
      dbo.Geography AS G ON G.GeographyKey = SS.GeographyKey INNER JOIN
      dbo.Calendar AS C ON S.DateKey = C.DateKey
WHERE (G.RegionCountryName IN
            (SELECT RegionCountryName
               FROM dbo.Geography
              WHERE (GeographyType IN ('COUNTRY/REGION')))) AND (C.Year IN
                    (SELECT MAX(YEAR(DateKey)) AS Expr1
                       FROM dbo.Sales))
GROUP BY C.Year, G.RegionCountryName;

-- KPI  - RECENT YEARLY SALES BY CHANNEL

ALTER FUNCTION [dbo].[F_RECENT_YEARLY_SALES_BY_CHANNEL]()
RETURNS TABLE
AS RETURN
SELECT  C.Year AS [RECENT YEAR], C.QuarterOfYear AS QUARTER, CH.ChannelName AS [CHANNEL NAME], ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM  dbo.Sales AS S INNER JOIN
      dbo.Calendar AS C ON C.DateKey = S.DateKey INNER JOIN
      dbo.Channel AS CH ON CH.Channel = S.channelKey
WHERE (C.Year IN
              (SELECT MAX(YEAR(DateKey)) AS RECENT_YEAR
                 FROM dbo.Sales))
GROUP BY C.Year, C.QuarterOfYear, CH.ChannelName;

-- KPI  - RECENT YEAR AND QUARTER SALES BY CHANNEL

ALTER FUNCTION [dbo].[F_RECENT_YEAR_AND_QUARTER_SALES_BY_CHANNEL]()
RETURNS TABLE
AS RETURN
SELECT C.Year AS [RECENT YEAR], C.QuarterOfYear AS [RECENT QUARTER], CH.ChannelName AS [CHANNEL NAME], ROUND(SUM(S.SalesAmount), 0) AS [TOTAL SALES]
FROM  dbo.Sales AS S INNER JOIN
      dbo.Calendar AS C ON C.DateKey = S.DateKey INNER JOIN
      dbo.Channel AS CH ON CH.Channel = S.channelKey
WHERE (C.Year IN
              (SELECT MAX(YEAR(DateKey)) AS Expr1
                 FROM dbo.Sales)) AND (C.QuarterOfYear IN
                             (SELECT MAX(DATEPART(QUARTER, DateKey)) AS Expr1
                               FROM dbo.Sales AS Sales_1))
GROUP BY C.Year, C.QuarterOfYear, CH.ChannelName;
