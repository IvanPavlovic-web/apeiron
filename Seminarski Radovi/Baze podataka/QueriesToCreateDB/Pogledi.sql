CREATE VIEW vw_RezervacijeDetalji AS
SELECT 
    r.RezervacijaID,
    g.Ime + ' ' + g.Prezime AS ImeGosta,
    g.Email,
    g.Telefon,
    s.BrojSobe,
    s.TipSobe,
    s.CijenaPoNoci,
    r.DatumPrijave,
    r.DatumOdjave,
    DATEDIFF(DAY, r.DatumPrijave, r.DatumOdjave) AS BrojNoci,
    r.StatusRezervacije,
    (DATEDIFF(DAY, r.DatumPrijave, r.DatumOdjave) * s.CijenaPoNoci) AS OsnovnaCijena
FROM Rezervacije r
INNER JOIN Gosti g ON r.GostID = g.GostID
INNER JOIN Sobe s ON r.SobaID = s.SobaID;
GO

CREATE VIEW vw_PrihodiPoSobama AS
SELECT 
    s.BrojSobe,
    s.TipSobe,
    COUNT(r.RezervacijaID) AS BrojRezervacija,
    ISNULL(SUM(p.Iznos), 0) AS UkupniPrihod,
    ISNULL(AVG(p.Iznos), 0) AS ProsijecnaUplata
FROM Sobe s
LEFT JOIN Rezervacije r ON s.SobaID = r.SobaID
LEFT JOIN Placanja p ON r.RezervacijaID = p.RezervacijaID
GROUP BY s.BrojSobe, s.TipSobe;
GO

CREATE VIEW vw_AktivneRezervacije AS
SELECT 
    r.RezervacijaID,
    g.Ime + ' ' + g.Prezime AS Gost,
    s.BrojSobe,
    r.DatumPrijave,
    r.DatumOdjave,
    DATEDIFF(DAY, GETDATE(), r.DatumOdjave) AS PreostaloDana
FROM Rezervacije r
INNER JOIN Gosti g ON r.GostID = g.GostID
INNER JOIN Sobe s ON r.SobaID = s.SobaID
WHERE r.DatumPrijave <= GETDATE() 
AND r.DatumOdjave >= GETDATE()
AND r.StatusRezervacije = 'Potvrđena';
GO