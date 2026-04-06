CREATE FUNCTION fn_IzracunajPopust(@BrojDolazaka INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Popust DECIMAL(5,2);
    
    IF @BrojDolazaka >= 10
        SET @Popust = 20.00;
    ELSE IF @BrojDolazaka >= 5
        SET @Popust = 10.00;
    ELSE IF @BrojDolazaka >= 3
        SET @Popust = 5.00;
    ELSE
        SET @Popust = 0.00;
    
    RETURN @Popust;
END;
GO


CREATE FUNCTION fn_RaspoloziveSobe(@DatumOd DATE, @DatumDo DATE)
RETURNS TABLE
AS
RETURN
(
    SELECT s.*
    FROM Sobe s
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Rezervacije r
        WHERE r.SobaID = s.SobaID
        AND r.StatusRezervacije = 'Potvrđena'
        AND r.DatumPrijave < @DatumDo
        AND r.DatumOdjave > @DatumOd
    )
);
GO