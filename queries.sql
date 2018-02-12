-- Insert data into Location Table
INSERT INTO public."Location"("City", "State")
SELECT DISTINCT "City", "State"
FROM public."RawTable";

-- Insert data into ReportedDate table
INSERT INTO public."ReportedDate"("Date", "Week", "Month", "Year")
SELECT DISTINCT "EventDate", EXTRACT(week from "EventDate"), EXTRACT(month from "EventDate"), EXTRACT(year from "EventDate")
FROM public."RawTable";

INSERT INTO public."ReportedDate"("Weekend")
SELECT
CASE  
    WHEN EXTRACT(dow FROM R."EventDate") = '0' THEN 'Y'
    WHEN EXTRACT(dow FROM R."EventDate") = '6' THEN 'Y'
    ELSE 'N'
END
FROM public."RawTable" R;

-- Insert Data into Shape table
INSERT INTO public."Shape"("Name", "Summary")
SELECT DISTINCT "Shape", "Summary"
FROM public."RawTable";

-- Insert into UFOFACTS table
ALTER TABLE public."UFOFACTS" ADD COLUMN "ReportedDateKey" INTEGER REFERENCES public."ReportedDate"("Key");
ALTER TABLE public."UFOFACTS" ADD COLUMN "ShapeKey" INTEGER REFERENCES public."Shape"("Key");
ALTER TABLE public."UFOFACTS" ADD COLUMN "LocationKey" INTEGER REFERENCES public."Location"("Key");

INSERT INTO public."UFOFACTS"("ReportedDateKey", "ShapeKey", "LocationKey", "Duration")
SELECT RD."Key", S."Key", L."Key", R."Duration"
FROM public."ReportedDate" RD, public."Shape" S, public."Location" L, public."RawTable" R
WHERE RD."Date" = R."EventDate"
    AND S."Name" = R."Shape"
    AND S."Summary" = R."Summary"
    AND L."City" = R."City"
    AND L."State" = R."State";

-- number of sightings per month
SELECT RD."Month", COUNT(U."*")
FROM public."ReportedDate" RD, public."UFOFACTS" U
WHERE U."ReportedDateKey" = RD."Key"
GROUP BY RD."Month";

-- number of sightings per month and state
SELECT RD."Month", L."State", COUNT(U."Key")
FROM public."UFOFACTS" U, public."ReportedDate" RD, public."Location" L
WHERE U."ReportedDateKey" = RD."Key" 
    AND U."LocationKey" = L."Key"
GROUP BY RD."Month", L."State";

-- names and avg durations of the 5 shapes that have the most sightings
SELECT S."Name", AVG(U."Duration")
FROM public."Shape" S, public."UFOFACTS" U
WHERE U."ShapeKey" = S."Key"
    AND S."Key" IN (
        SELECT "ShapeKey", COUNT(*) as C
        FROM public."UFOFACTS"
        GROUP BY "ShapeKey"
        ORDER BY C
        LIMIT 5
    )
GROUP BY S."Name";

-- Q14 (too long)
SELECT S."Name", L."State" as maxS
FROM public."Shape" S, public."Location" L, public."UFOFACTS" U
WHERE U."ShapeKey" = S."Key"
    AND U."LocationKey" = L."Key"
    AND U."Duration" = MAX(
        SELECT "Duration"
        FROM public."UFOFACTS"
        WHERE "ShapeKey" = S."Key"
    )
GROUP BY S."Name"
INNER JOIN (
    SELECT SS."Name", AVG(UU."Duration")
    FROM public."Shape" SS, public."UFOFACTS" UU
    WHERE SS."Key" = UU."ShapeKey"
) as T
ON S."Name" = T."Name";

-- Q15 california
WITH T1 AS (
    SELECT N1 = S."Name", S1 = SUM(U."*")
    FROM public."Shape" S, public."UFOFACTS" U, public."ReportedDate" RD, public."Location" L
    WHERE U."ShapeKey" = S."ShapeKey" 
        AND U."LocationKey" = L."Key"
        AND L."State" = "CA"
        AND U."ReportedDateKey" = RD."Key"
        AND RD."Weekend" = "Y"
    GROUP BY S."Name"
), T2 AS (
    SELECT N2 = SS."Name", S2 = SUM(UU."*")
    FROM public."Shape" SS, public."UFOFACTS" UU, public."ReportedDate" RDD, public."Location" LL
    WHERE UU."ShapeKey" = SS."ShapeKey" 
        AND UU."LocationKey" = LL."Key"
        AND LL."State" = "FL"
        AND UU."ReportedDateKey" = RDD."Key"
        AND RDD."Weekend" = "Y"
    GROUP BY SS."Name"
) 
SELECT T1.N1 AS shapeName, T1.S1 AS CATotal, T2.S2 AS FLTotal
FROM T1 INNER JOIN T2
ON T1.N1 = T2.N2;
