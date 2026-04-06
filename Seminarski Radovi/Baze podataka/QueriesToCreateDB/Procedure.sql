CREATE PROCEDURE sp_KreirajRezervaciju
    @GostID INT,
    @SobaID INT,
    @DatumPrijave DATE,
    @DatumOdjave DATE,
    @BrojOdraslih INT = 1,
    @BrojDjece INT = 0,
    @Napomena NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Sobe WHERE SobaID = @SobaID AND StatusSobe = 'Dostupna')
        BEGIN
            RAISERROR('Soba nije dostupna za rezervaciju!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Gosti WHERE GostID = @GostID)
        BEGIN
            RAISERROR('Gost ne postoji u bazi!', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END
        
        INSERT INTO Rezervacije (GostID, SobaID, DatumPrijave, DatumOdjave, BrojOdraslih, BrojDjece, Napomena)
        VALUES (@GostID, @SobaID, @DatumPrijave, @DatumOdjave, @BrojOdraslih, @BrojDjece, @Napomena);

        UPDATE Sobe SET StatusSobe = 'Rezervisana' WHERE SobaID = @SobaID;

        UPDATE Gosti SET BrojDolazaka = BrojDolazaka + 1 WHERE GostID = @GostID;
        
        COMMIT TRANSACTION;
        
        SELECT SCOPE_IDENTITY() AS RezervacijaID;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO



CREATE PROCEDURE sp_IzracunajUkupnuCijenu
    @RezervacijaID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @OsnovnaCijena DECIMAL(10,2);
    DECLARE @CijenaUsluga DECIMAL(10,2);
    DECLARE @UkupnaCijena DECIMAL(10,2);
    
    -- Izračunavanje osnovne cijene smještaja
    SELECT @OsnovnaCijena = DATEDIFF(DAY, r.DatumPrijave, r.DatumOdjave) * s.CijenaPoNoci
    FROM Rezervacije r
    INNER JOIN Sobe s ON r.SobaID = s.SobaID
    WHERE r.RezervacijaID = @RezervacijaID;
    
    -- Izračunavanje cijene usluga
    SELECT @CijenaUsluga = ISNULL(SUM(ru.Kolicina * ru.CijenaPoJedinici), 0)
    FROM RezervacijeUsluge ru
    WHERE ru.RezervacijaID = @RezervacijaID;
    
    SET @UkupnaCijena = @OsnovnaCijena + @CijenaUsluga;
    
    -- Prikaz rezultata
    SELECT 
        @RezervacijaID AS RezervacijaID,
        @OsnovnaCijena AS OsnovnaCijenaSmjestaja,
        @CijenaUsluga AS CijenaUsluga,
        @UkupnaCijena AS UkupnaCijena;
END;
GO


CREATE PROCEDURE sp_IzvjestajPopunjenosti
    @Mjesec INT,
    @Godina INT
AS
BEGIN
    SELECT 
        s.BrojSobe,
        s.TipSobe,
        COUNT(r.RezervacijaID) AS BrojRezervacija,
        SUM(DATEDIFF(DAY, r.DatumPrijave, r.DatumOdjave)) AS UkupnoNoci
    FROM Sobe s
    LEFT JOIN Rezervacije r ON s.SobaID = r.SobaID
        AND MONTH(r.DatumPrijave) = @Mjesec
        AND YEAR(r.DatumPrijave) = @Godina
    GROUP BY s.BrojSobe, s.TipSobe;
END;
GO