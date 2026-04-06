CREATE TRIGGER trg_ProvjeraDuplihRezervacija
ON Rezervacije
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Rezervacije r
        INNER JOIN inserted i ON r.SobaID = i.SobaID
        WHERE r.StatusRezervacije = 'Potvrđena'
        AND r.DatumPrijave < i.DatumOdjave
        AND r.DatumOdjave > i.DatumPrijave
    )
    BEGIN
        RAISERROR('Soba je već rezervisana u tom periodu!', 16, 1);
        RETURN;
    END

    INSERT INTO Rezervacije (
        GostID, SobaID, DatumPrijave, DatumOdjave,
        BrojOdraslih, BrojDjece, Napomena,
        DatumRezervacije, StatusRezervacije
    )
    SELECT 
        GostID, SobaID, DatumPrijave, DatumOdjave,
        BrojOdraslih, BrojDjece, Napomena,
        GETDATE(), 'Potvrđena'
    FROM inserted;
END;
GO


CREATE TRIGGER trg_OtkaziRezervaciju
ON Rezervacije
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(StatusRezervacije)
    BEGIN
        UPDATE s
        SET s.StatusSobe = 'Dostupna'
        FROM Sobe s
        INNER JOIN inserted i ON s.SobaID = i.SobaID
        INNER JOIN deleted d ON i.RezervacijaID = d.RezervacijaID
        WHERE i.StatusRezervacije = 'Otkazana' 
        AND d.StatusRezervacije != 'Otkazana'
        AND NOT EXISTS (
            SELECT 1 
            FROM Rezervacije r
            WHERE r.SobaID = s.SobaID
            AND r.StatusRezervacije = 'Potvrđena'
            AND r.RezervacijaID != i.RezervacijaID
            AND r.DatumOdjave >= GETDATE()
        );
    END
END;
GO


CREATE TRIGGER trg_LogCijeneSoba
ON Sobe
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(CijenaPoNoci)
    BEGIN
        INSERT INTO SobeCijeneLog (SobaID, StaraCijena, NovaCijena)
        SELECT i.SobaID, d.CijenaPoNoci, i.CijenaPoNoci
        FROM inserted i
        INNER JOIN deleted d ON i.SobaID = d.SobaID
        WHERE i.CijenaPoNoci != d.CijenaPoNoci;
    END
END;
GO