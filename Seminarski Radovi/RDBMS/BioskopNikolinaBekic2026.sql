CREATE DATABASE Bioskop;
GO

ALTER DATABASE Bioskop SET COMPATIBILITY_LEVEL = 100;
GO

USE Bioskop;
GO

CREATE SCHEMA sif AUTHORIZATION dbo;
GO
CREATE SCHEMA kino AUTHORIZATION dbo;
GO
CREATE SCHEMA prodaja AUTHORIZATION dbo;
GO
CREATE SCHEMA izvjestaji AUTHORIZATION dbo;
GO
CREATE SCHEMA audit AUTHORIZATION dbo;
GO
CREATE SCHEMA etl AUTHORIZATION dbo;
GO

CREATE TABLE sif.Zanrovi (
    ZanrID INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL UNIQUE,
    Opis NVARCHAR(300)
);

CREATE TABLE sif.Kategorije (
    KategorijaID INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL UNIQUE,
    MinimalnaDob INT NOT NULL
        CHECK (MinimalnaDob BETWEEN 0 AND 21)
);

CREATE TABLE kino.Filmovi (
    FilmID INT IDENTITY PRIMARY KEY,
    ZanrID INT NOT NULL,
    KategorijaID INT NOT NULL,
    Naziv NVARCHAR(150) NOT NULL,
    OriginalniNaziv NVARCHAR(150),
    TrajanjeMin INT NOT NULL,
    Godina SMALLINT NOT NULL,
    DatumPremijere DATE,
    ProsjecnaOcjena DECIMAL(3,1),
    Aktivan BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Filmovi_Zanrovi
        FOREIGN KEY (ZanrID)
        REFERENCES sif.Zanrovi(ZanrID),

    CONSTRAINT FK_Filmovi_Kategorije
        FOREIGN KEY (KategorijaID)
        REFERENCES sif.Kategorije(KategorijaID),

    CONSTRAINT UQ_Filmovi
        UNIQUE (Naziv, Godina),

    CONSTRAINT CHK_Filmovi_Trajanje
        CHECK (TrajanjeMin BETWEEN 20 AND 400),

    CONSTRAINT CHK_Filmovi_Godina
        CHECK (Godina BETWEEN 1900 AND 2100),

    CONSTRAINT CHK_Filmovi_Ocjena
        CHECK (
            ProsjecnaOcjena IS NULL
            OR ProsjecnaOcjena BETWEEN 1 AND 10
        )
);

CREATE TABLE kino.Sale (
    SalaID INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(50) NOT NULL UNIQUE,
    TipSale NVARCHAR(20) NOT NULL,
    Kapacitet INT NOT NULL,
    DatumOtvaranja DATE,
    Aktivna BIT NOT NULL DEFAULT 1,

    CONSTRAINT CHK_Sale_Tip
        CHECK (TipSale IN (N'Standard', N'3D', N'IMAX', N'VIP')),

    CONSTRAINT CHK_Sale_Kapacitet
        CHECK (Kapacitet > 0)
);

CREATE TABLE kino.Sjedista (
    SjedisteID INT IDENTITY PRIMARY KEY,
    SalaID INT NOT NULL,
    RedOznaka NVARCHAR(5) NOT NULL,
    BrojSjedista INT NOT NULL,
    TipSjedista NVARCHAR(20) NOT NULL DEFAULT N'Standard',
    Aktivno BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Sjedista_Sale
        FOREIGN KEY (SalaID)
        REFERENCES kino.Sale(SalaID),

    CONSTRAINT UQ_Sjedista
        UNIQUE (SalaID, RedOznaka, BrojSjedista),

    CONSTRAINT CHK_Sjedista_Broj
        CHECK (BrojSjedista > 0),

    CONSTRAINT CHK_Sjedista_Tip
        CHECK (TipSjedista IN (N'Standard', N'VIP', N'Pristupacno'))
);

CREATE TABLE kino.Projekcije (
    ProjekcijaID INT IDENTITY PRIMARY KEY,
    FilmID INT NOT NULL,
    SalaID INT NOT NULL,
    DatumVrijeme DATETIME NOT NULL,
    Jezik NVARCHAR(30) NOT NULL,
    FormatProjekcije NVARCHAR(15) NOT NULL,
    OsnovnaCijena DECIMAL(10,2) NOT NULL,
    StatusProjekcije NVARCHAR(20) NOT NULL DEFAULT N'Planirana',

    CONSTRAINT FK_Projekcije_Filmovi
        FOREIGN KEY (FilmID)
        REFERENCES kino.Filmovi(FilmID),

    CONSTRAINT FK_Projekcije_Sale
        FOREIGN KEY (SalaID)
        REFERENCES kino.Sale(SalaID),

    CONSTRAINT UQ_Projekcije
        UNIQUE (SalaID, DatumVrijeme),

    CONSTRAINT CHK_Projekcije_Format
        CHECK (FormatProjekcije IN (N'2D', N'3D', N'IMAX')),

    CONSTRAINT CHK_Projekcije_Cijena
        CHECK (OsnovnaCijena > 0),

    CONSTRAINT CHK_Projekcije_Status
        CHECK (
            StatusProjekcije IN
            (N'Planirana', N'U toku', N'Zavrsena', N'Otkazana')
        )
);

CREATE TABLE prodaja.Kupci (
    KupacID INT IDENTITY PRIMARY KEY,
    Ime NVARCHAR(50) NOT NULL,
    Prezime NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Telefon NVARCHAR(25),
    DatumRegistracije DATETIME NOT NULL DEFAULT GETDATE(),
    BrojPosjeta INT NOT NULL DEFAULT 0,

    CONSTRAINT CHK_Kupci_Email
        CHECK (Email LIKE N'%_@_%._%'),

    CONSTRAINT CHK_Kupci_Posjete
        CHECK (BrojPosjeta >= 0)
);

CREATE TABLE prodaja.Rezervacije (
    RezervacijaID INT IDENTITY PRIMARY KEY,
    KupacID INT NOT NULL,
    ProjekcijaID INT NOT NULL,
    DatumRezervacije DATETIME NOT NULL DEFAULT GETDATE(),
    StatusRezervacije NVARCHAR(20) NOT NULL DEFAULT N'Potvrdjena',
    RokPotvrde DATETIME,
    Napomena NVARCHAR(300),

    CONSTRAINT FK_Rezervacije_Kupci
        FOREIGN KEY (KupacID)
        REFERENCES prodaja.Kupci(KupacID),

    CONSTRAINT FK_Rezervacije_Projekcije
        FOREIGN KEY (ProjekcijaID)
        REFERENCES kino.Projekcije(ProjekcijaID),

    CONSTRAINT CHK_Rezervacije_Status
        CHECK (
            StatusRezervacije IN
            (N'Na cekanju', N'Potvrdjena', N'Otkazana', N'Iskoristena')
        )
);

CREATE TABLE prodaja.RezervisanaSjedista (
    RezervisanoSjedisteID INT IDENTITY PRIMARY KEY,
    RezervacijaID INT NOT NULL,
    SjedisteID INT NOT NULL,
    Cijena DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_RS_Rezervacije
        FOREIGN KEY (RezervacijaID)
        REFERENCES prodaja.Rezervacije(RezervacijaID),

    CONSTRAINT FK_RS_Sjedista
        FOREIGN KEY (SjedisteID)
        REFERENCES kino.Sjedista(SjedisteID),

    CONSTRAINT UQ_RS
        UNIQUE (RezervacijaID, SjedisteID),

    CONSTRAINT CHK_RS_Cijena
        CHECK (Cijena > 0)
);

CREATE TABLE prodaja.Placanja (
    PlacanjeID INT IDENTITY PRIMARY KEY,
    RezervacijaID INT NOT NULL,
    DatumPlacanja DATETIME NOT NULL DEFAULT GETDATE(),
    Iznos DECIMAL(10,2) NOT NULL,
    NacinPlacanja NVARCHAR(20) NOT NULL,
    StatusPlacanja NVARCHAR(20) NOT NULL DEFAULT N'Placeno',
    BrojTransakcije NVARCHAR(60),

    CONSTRAINT FK_Placanja_Rezervacije
        FOREIGN KEY (RezervacijaID)
        REFERENCES prodaja.Rezervacije(RezervacijaID),

    CONSTRAINT CHK_Placanja_Iznos
        CHECK (Iznos > 0),

    CONSTRAINT CHK_Placanja_Nacin
        CHECK (
            NacinPlacanja IN
            (N'Gotovina', N'Kartica', N'Online', N'Vaucer')
        ),

    CONSTRAINT CHK_Placanja_Status
        CHECK (
            StatusPlacanja IN
            (N'Na cekanju', N'Placeno', N'Odbijeno', N'Refundirano')
        )
);

CREATE TABLE prodaja.Cjenovnik (
    CjenovnikID INT IDENTITY PRIMARY KEY,
    Naziv NVARCHAR(80) NOT NULL,
    TipSale NVARCHAR(20) NOT NULL,
    DanUSedmici INT NULL,
    Cijena DECIMAL(10,2) NOT NULL,
    VaziOd DATE NOT NULL,
    VaziDo DATE,

    CONSTRAINT CHK_Cjenovnik_Cijena
        CHECK (Cijena > 0),

    CONSTRAINT CHK_Cjenovnik_Dan
        CHECK (
            DanUSedmici IS NULL
            OR DanUSedmici BETWEEN 1 AND 7
        ),

    CONSTRAINT CHK_Cjenovnik_Datumi
        CHECK (
            VaziDo IS NULL
            OR VaziDo >= VaziOd
        )
);

CREATE TABLE kino.Zaposleni (
    ZaposleniID INT IDENTITY PRIMARY KEY,
    Ime NVARCHAR(50) NOT NULL,
    Prezime NVARCHAR(50) NOT NULL,
    Pozicija NVARCHAR(40) NOT NULL,
    DatumZaposlenja DATE NOT NULL,
    Plata DECIMAL(10,2) NOT NULL,
    Aktivan BIT NOT NULL DEFAULT 1,

    CONSTRAINT CHK_Zaposleni_Plata
        CHECK (Plata > 0)
);

CREATE TABLE kino.Smjene (
    SmjenaID INT IDENTITY PRIMARY KEY,
    ZaposleniID INT NOT NULL,
    DatumSmjene DATE NOT NULL,
    Pocetak DATETIME NOT NULL,
    Kraj DATETIME NOT NULL,

    CONSTRAINT FK_Smjene_Zaposleni
        FOREIGN KEY (ZaposleniID)
        REFERENCES kino.Zaposleni(ZaposleniID),

    CONSTRAINT CHK_Smjene_Vrijeme
        CHECK (Kraj > Pocetak)
);

CREATE TABLE audit.RezervacijeDnevnik (
    DnevnikID INT IDENTITY PRIMARY KEY,
    RezervacijaID INT NOT NULL,
    Akcija NVARCHAR(10) NOT NULL,
    StariStatus NVARCHAR(20),
    NoviStatus NVARCHAR(20),
    DatumAkcije DATETIME NOT NULL DEFAULT GETDATE(),
    Korisnik NVARCHAR(128) NOT NULL DEFAULT SUSER_SNAME()
);

CREATE TABLE audit.CijeneProjekcijaDnevnik (
    DnevnikID INT IDENTITY PRIMARY KEY,
    ProjekcijaID INT NOT NULL,
    StaraCijena DECIMAL(10,2),
    NovaCijena DECIMAL(10,2),
    DatumPromjene DATETIME NOT NULL DEFAULT GETDATE(),
    Korisnik NVARCHAR(128) NOT NULL DEFAULT SUSER_SNAME()
);
GO

CREATE INDEX IX_Filmovi_Naziv ON kino.Filmovi(Naziv);
CREATE INDEX IX_Projekcije_Datum ON kino.Projekcije(DatumVrijeme);
CREATE INDEX IX_Projekcije_FilmStatus ON kino.Projekcije(FilmID, StatusProjekcije);
CREATE INDEX IX_Sjedista_Sala ON kino.Sjedista(SalaID, RedOznaka);
CREATE INDEX IX_Rezervacije_Kupac ON prodaja.Rezervacije(KupacID);
CREATE INDEX IX_Rezervacije_ProjekcijaStatus ON prodaja.Rezervacije(ProjekcijaID, StatusRezervacije);
CREATE INDEX IX_Placanja_Datum ON prodaja.Placanja(DatumPlacanja);
CREATE UNIQUE INDEX UX_Placanja_Transakcija ON prodaja.Placanja(BrojTransakcije) WHERE BrojTransakcije IS NOT NULL;
GO

INSERT INTO sif.Zanrovi (Naziv, Opis)
VALUES
    (N'Akcija', N'Dinamicni filmovi'),
    (N'Drama', N'Dramski filmovi'),
    (N'Komedija', N'Humoristicki filmovi'),
    (N'Animirani', N'Animirani filmovi'),
    (N'Triler', N'Napeti filmovi'),
    (N'Naucna fantastika', N'Futuristicki filmovi'),
    (N'Dokumentarni', N'Dokumentarni sadrzaj'),
    (N'Avantura', N'Avanturisticki filmovi');

INSERT INTO sif.Kategorije (Naziv, MinimalnaDob)
VALUES
    (N'Svi uzrasti', 0),
    (N'7+', 7),
    (N'12+', 12),
    (N'15+', 15),
    (N'18+', 18);

INSERT INTO kino.Sale (Naziv, TipSale, Kapacitet, DatumOtvaranja)
VALUES
    (N'Sala 1', N'Standard', 40, '2020-01-10'),
    (N'Sala 2', N'3D', 30, '2020-01-10'),
    (N'Sala 3', N'IMAX', 50, '2021-05-01'),
    (N'VIP salon', N'VIP', 20, '2022-09-15');

INSERT INTO kino.Filmovi (
    ZanrID,
    KategorijaID,
    Naziv,
    OriginalniNaziv,
    TrajanjeMin,
    Godina,
    DatumPremijere,
    ProsjecnaOcjena
)
VALUES
    (1, 3, N'Posljednja misija', N'The Last Mission', 125, 2026, '2026-07-10', 8.2),
    (2, 3, N'Tihi grad', N'Silent City', 112, 2026, '2026-06-15', 7.9),
    (3, 2, N'Vikend bez plana', N'Weekend Unplanned', 98, 2026, '2026-08-01', 7.4),
    (4, 1, N'Zvjezdani prijatelji', N'Star Friends', 91, 2026, '2026-05-20', 8.5),
    (5, 4, N'Sjena u prolazu', N'Passing Shadow', 118, 2026, '2026-07-25', 8.0),
    (6, 3, N'Nova orbita', N'New Orbit', 140, 2026, '2026-08-12', 8.7),
    (7, 1, N'Planeta voda', N'Water Planet', 88, 2025, '2025-11-11', 8.3),
    (8, 2, N'Izgubljena mapa', N'The Lost Map', 110, 2026, '2026-04-03', 7.8),
    (1, 4, N'Brzina odluke', N'Speed of Choice', 132, 2025, '2025-09-09', 7.6),
    (3, 3, N'Komšije na odmoru', N'Neighbors Away', 101, 2026, '2026-08-20', 7.1);

INSERT INTO kino.Sjedista (SalaID, RedOznaka, BrojSjedista, TipSjedista)
VALUES
    (1, N'A', 1, N'Pristupacno'), (1, N'A', 2, N'Pristupacno'),
    (1, N'A', 3, N'Standard'), (1, N'A', 4, N'Standard'),
    (1, N'A', 5, N'Standard'), (1, N'A', 6, N'Standard'),
    (1, N'A', 7, N'Standard'), (1, N'A', 8, N'Standard'),
    (1, N'A', 9, N'Standard'), (1, N'A', 10, N'Standard'),
    (1, N'B', 1, N'Standard'), (1, N'B', 2, N'Standard'),
    (1, N'B', 3, N'Standard'), (1, N'B', 4, N'Standard'),
    (1, N'B', 5, N'Standard'), (1, N'B', 6, N'Standard'),
    (1, N'B', 7, N'Standard'), (1, N'B', 8, N'Standard'),
    (1, N'B', 9, N'Standard'), (1, N'B', 10, N'Standard'),
    (1, N'C', 1, N'Standard'), (1, N'C', 2, N'Standard'),
    (1, N'C', 3, N'Standard'), (1, N'C', 4, N'Standard'),
    (1, N'C', 5, N'Standard'), (1, N'C', 6, N'Standard'),
    (1, N'C', 7, N'Standard'), (1, N'C', 8, N'Standard'),
    (1, N'C', 9, N'Standard'), (1, N'C', 10, N'Standard'),
    (1, N'D', 1, N'Standard'), (1, N'D', 2, N'Standard'),
    (1, N'D', 3, N'Standard'), (1, N'D', 4, N'Standard'),
    (1, N'D', 5, N'Standard'), (1, N'D', 6, N'Standard'),
    (1, N'D', 7, N'Standard'), (1, N'D', 8, N'Standard'),
    (1, N'D', 9, N'Standard'), (1, N'D', 10, N'Standard'),
    (2, N'A', 1, N'Pristupacno'), (2, N'A', 2, N'Pristupacno'),
    (2, N'A', 3, N'Standard'), (2, N'A', 4, N'Standard'),
    (2, N'A', 5, N'Standard'), (2, N'A', 6, N'Standard'),
    (2, N'A', 7, N'Standard'), (2, N'A', 8, N'Standard'),
    (2, N'A', 9, N'Standard'), (2, N'A', 10, N'Standard'),
    (2, N'B', 1, N'Standard'), (2, N'B', 2, N'Standard'),
    (2, N'B', 3, N'Standard'), (2, N'B', 4, N'Standard'),
    (2, N'B', 5, N'Standard'), (2, N'B', 6, N'Standard'),
    (2, N'B', 7, N'Standard'), (2, N'B', 8, N'Standard'),
    (2, N'B', 9, N'Standard'), (2, N'B', 10, N'Standard'),
    (2, N'C', 1, N'Standard'), (2, N'C', 2, N'Standard'),
    (2, N'C', 3, N'Standard'), (2, N'C', 4, N'Standard'),
    (2, N'C', 5, N'Standard'), (2, N'C', 6, N'Standard'),
    (2, N'C', 7, N'Standard'), (2, N'C', 8, N'Standard'),
    (2, N'C', 9, N'Standard'), (2, N'C', 10, N'Standard'),
    (3, N'A', 1, N'Pristupacno'), (3, N'A', 2, N'Pristupacno'),
    (3, N'A', 3, N'Standard'), (3, N'A', 4, N'Standard'),
    (3, N'A', 5, N'Standard'), (3, N'A', 6, N'Standard'),
    (3, N'A', 7, N'Standard'), (3, N'A', 8, N'Standard'),
    (3, N'A', 9, N'Standard'), (3, N'A', 10, N'Standard'),
    (3, N'B', 1, N'Standard'), (3, N'B', 2, N'Standard'),
    (3, N'B', 3, N'Standard'), (3, N'B', 4, N'Standard'),
    (3, N'B', 5, N'Standard'), (3, N'B', 6, N'Standard'),
    (3, N'B', 7, N'Standard'), (3, N'B', 8, N'Standard'),
    (3, N'B', 9, N'Standard'), (3, N'B', 10, N'Standard'),
    (3, N'C', 1, N'Standard'), (3, N'C', 2, N'Standard'),
    (3, N'C', 3, N'Standard'), (3, N'C', 4, N'Standard'),
    (3, N'C', 5, N'Standard'), (3, N'C', 6, N'Standard'),
    (3, N'C', 7, N'Standard'), (3, N'C', 8, N'Standard'),
    (3, N'C', 9, N'Standard'), (3, N'C', 10, N'Standard'),
    (3, N'D', 1, N'Standard'), (3, N'D', 2, N'Standard'),
    (3, N'D', 3, N'Standard'), (3, N'D', 4, N'Standard'),
    (3, N'D', 5, N'Standard'), (3, N'D', 6, N'Standard'),
    (3, N'D', 7, N'Standard'), (3, N'D', 8, N'Standard'),
    (3, N'D', 9, N'Standard'), (3, N'D', 10, N'Standard'),
    (3, N'E', 1, N'Standard'), (3, N'E', 2, N'Standard'),
    (3, N'E', 3, N'Standard'), (3, N'E', 4, N'Standard'),
    (3, N'E', 5, N'Standard'), (3, N'E', 6, N'Standard'),
    (3, N'E', 7, N'Standard'), (3, N'E', 8, N'Standard'),
    (3, N'E', 9, N'Standard'), (3, N'E', 10, N'Standard'),
    (4, N'A', 1, N'VIP'), (4, N'A', 2, N'VIP'),
    (4, N'A', 3, N'VIP'), (4, N'A', 4, N'VIP'),
    (4, N'A', 5, N'VIP'), (4, N'A', 6, N'VIP'),
    (4, N'A', 7, N'VIP'), (4, N'A', 8, N'VIP'),
    (4, N'A', 9, N'VIP'), (4, N'A', 10, N'VIP'),
    (4, N'B', 1, N'VIP'), (4, N'B', 2, N'VIP'),
    (4, N'B', 3, N'VIP'), (4, N'B', 4, N'VIP'),
    (4, N'B', 5, N'VIP'), (4, N'B', 6, N'VIP'),
    (4, N'B', 7, N'VIP'), (4, N'B', 8, N'VIP'),
    (4, N'B', 9, N'VIP'), (4, N'B', 10, N'VIP');
GO

INSERT INTO prodaja.Kupci (Ime, Prezime, Email, Telefon, BrojPosjeta)
VALUES
    (N'Marko', N'Markovic', N'marko01@example.com', N'065111111', 5),
    (N'Ana', N'Jovanovic', N'ana02@example.com', N'066222222', 3),
    (N'Nikola', N'Petrovic', N'nikola03@example.com', N'067333333', 8),
    (N'Jelena', N'Ilic', N'jelena04@example.com', N'065444444', 1),
    (N'Stefan', N'Savic', N'stefan05@example.com', N'066555555', 4),
    (N'Milica', N'Kovacevic', N'milica06@example.com', N'067666666', 6),
    (N'Dejan', N'Popovic', N'dejan07@example.com', N'065777777', 9),
    (N'Ivana', N'Nikolic', N'ivana08@example.com', N'066888888', 2),
    (N'Bojan', N'Peric', N'bojan09@example.com', N'067999999', 7),
    (N'Tamara', N'Radic', N'tamara10@example.com', N'065101010', 0),
    (N'Goran', N'Maric', N'goran11@example.com', N'066202020', 11),
    (N'Sanja', N'Babic', N'sanja12@example.com', N'067303030', 4),
    (N'Luka', N'Vukovic', N'luka13@example.com', N'065404040', 2),
    (N'Maja', N'Knezevic', N'maja14@example.com', N'066505050', 5),
    (N'Nemanja', N'Pavlovic', N'nemanja15@example.com', N'067606060', 10),
    (N'Kristina', N'Simic', N'kristina16@example.com', N'065707070', 1),
    (N'Igor', N'Tomic', N'igor17@example.com', N'066808080', 3),
    (N'Marija', N'Lazic', N'marija18@example.com', N'067909090', 6),
    (N'Ognjen', N'Krunic', N'ognjen19@example.com', N'065121212', 2),
    (N'Andrea', N'Basic', N'andrea20@example.com', N'066131313', 0);

INSERT INTO kino.Zaposleni (Ime, Prezime, Pozicija, DatumZaposlenja, Plata)
VALUES
    (N'Milan', N'Jovic', N'Blagajnik', '2022-01-10', 1400),
    (N'Sara', N'Kostic', N'Menadzer', '2020-03-01', 2200),
    (N'Petar', N'Vasic', N'Operater projekcije', '2021-06-15', 1700),
    (N'Lejla', N'Hadzic', N'Blagajnik', '2023-02-20', 1350),
    (N'Ivan', N'Grgic', N'Operater projekcije', '2019-11-05', 1800),
    (N'Maja', N'Coric', N'Kontrolor', '2024-01-12', 1250);

INSERT INTO kino.Smjene (ZaposleniID, DatumSmjene, Pocetak, Kraj)
VALUES
    (1, '2026-09-01', '2026-09-01 14:00:00', '2026-09-01 22:00:00'),
    (2, '2026-09-01', '2026-09-01 12:00:00', '2026-09-01 20:00:00'),
    (3, '2026-09-01', '2026-09-01 16:00:00', '2026-09-02 00:00:00'),
    (4, '2026-09-02', '2026-09-02 14:00:00', '2026-09-02 22:00:00'),
    (5, '2026-09-02', '2026-09-02 16:00:00', '2026-09-03 00:00:00'),
    (6, '2026-09-02', '2026-09-02 15:00:00', '2026-09-02 23:00:00');

INSERT INTO prodaja.Cjenovnik (Naziv, TipSale, DanUSedmici, Cijena, VaziOd, VaziDo)
VALUES
    (N'Standard radni dan', N'Standard', NULL, 8, '2026-01-01', NULL),
    (N'3D karta', N'3D', NULL, 11, '2026-01-01', NULL),
    (N'IMAX karta', N'IMAX', NULL, 15, '2026-01-01', NULL),
    (N'VIP karta', N'VIP', NULL, 20, '2026-01-01', NULL),
    (N'Utorak popust', N'Standard', 3, 6, '2026-01-01', NULL);

INSERT INTO kino.Projekcije (FilmID, SalaID, DatumVrijeme, Jezik, FormatProjekcije, OsnovnaCijena, StatusProjekcije)
VALUES
    (1, 1, '2026-09-01 16:00:00', N'BHS', N'2D', 8.00, N'Zavrsena'),
    (2, 2, '2026-09-01 18:00:00', N'BHS', N'3D', 11.00, N'Zavrsena'),
    (3, 3, '2026-09-01 20:00:00', N'BHS', N'IMAX', 15.00, N'Zavrsena'),
    (4, 4, '2026-09-01 22:00:00', N'BHS', N'2D', 20.00, N'Zavrsena'),
    (5, 1, '2026-09-02 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (6, 2, '2026-09-02 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (7, 3, '2026-09-02 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (8, 4, '2026-09-02 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (9, 1, '2026-09-03 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (10, 2, '2026-09-03 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (1, 3, '2026-09-03 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (2, 4, '2026-09-03 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (3, 1, '2026-09-04 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (4, 2, '2026-09-04 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (5, 3, '2026-09-04 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (6, 4, '2026-09-04 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (7, 1, '2026-09-05 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (8, 2, '2026-09-05 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (9, 3, '2026-09-05 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (10, 4, '2026-09-05 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (1, 1, '2026-09-06 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (2, 2, '2026-09-06 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (3, 3, '2026-09-06 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (4, 4, '2026-09-06 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (5, 1, '2026-09-07 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (6, 2, '2026-09-07 18:00:00', N'BHS', N'3D', 11.00, N'Planirana'),
    (7, 3, '2026-09-07 20:00:00', N'BHS', N'IMAX', 15.00, N'Planirana'),
    (8, 4, '2026-09-07 22:00:00', N'BHS', N'2D', 20.00, N'Planirana'),
    (9, 1, '2026-09-08 16:00:00', N'BHS', N'2D', 8.00, N'Planirana'),
    (10, 2, '2026-09-08 18:00:00', N'BHS', N'3D', 11.00, N'Planirana');
GO

INSERT INTO prodaja.Rezervacije (KupacID, ProjekcijaID, DatumRezervacije, StatusRezervacije, RokPotvrde)
VALUES
    (1, 1, '2026-08-02', N'Potvrdjena', '2026-09-02 12:00:00'),
    (2, 2, '2026-08-03', N'Potvrdjena', '2026-09-03 12:00:00'),
    (3, 3, '2026-08-04', N'Potvrdjena', '2026-09-04 12:00:00'),
    (4, 4, '2026-08-05', N'Potvrdjena', '2026-09-05 12:00:00'),
    (5, 5, '2026-08-06', N'Potvrdjena', '2026-09-06 12:00:00'),
    (6, 6, '2026-08-07', N'Potvrdjena', '2026-09-07 12:00:00'),
    (7, 7, '2026-08-08', N'Potvrdjena', '2026-09-08 12:00:00'),
    (8, 8, '2026-08-09', N'Potvrdjena', '2026-09-09 12:00:00'),
    (9, 9, '2026-08-10', N'Potvrdjena', '2026-09-10 12:00:00'),
    (10, 10, '2026-08-11', N'Potvrdjena', '2026-09-11 12:00:00'),
    (11, 11, '2026-08-12', N'Potvrdjena', '2026-09-12 12:00:00'),
    (12, 12, '2026-08-13', N'Potvrdjena', '2026-09-13 12:00:00'),
    (13, 13, '2026-08-14', N'Potvrdjena', '2026-09-14 12:00:00'),
    (14, 14, '2026-08-15', N'Potvrdjena', '2026-09-15 12:00:00'),
    (15, 15, '2026-08-16', N'Potvrdjena', '2026-09-16 12:00:00'),
    (16, 16, '2026-08-17', N'Potvrdjena', '2026-09-17 12:00:00'),
    (17, 17, '2026-08-18', N'Potvrdjena', '2026-09-18 12:00:00'),
    (18, 18, '2026-08-19', N'Potvrdjena', '2026-09-19 12:00:00'),
    (19, 19, '2026-08-20', N'Potvrdjena', '2026-09-20 12:00:00'),
    (20, 20, '2026-08-21', N'Potvrdjena', '2026-09-01 12:00:00'),
    (1, 1, '2026-08-22', N'Potvrdjena', '2026-09-02 12:00:00'),
    (2, 2, '2026-08-23', N'Potvrdjena', '2026-09-03 12:00:00'),
    (3, 3, '2026-08-24', N'Potvrdjena', '2026-09-04 12:00:00'),
    (4, 4, '2026-08-25', N'Potvrdjena', '2026-09-05 12:00:00'),
    (5, 5, '2026-08-26', N'Potvrdjena', '2026-09-06 12:00:00'),
    (6, 6, '2026-08-27', N'Potvrdjena', '2026-09-07 12:00:00'),
    (7, 7, '2026-08-28', N'Potvrdjena', '2026-09-08 12:00:00'),
    (8, 8, '2026-08-01', N'Potvrdjena', '2026-09-09 12:00:00'),
    (9, 9, '2026-08-02', N'Potvrdjena', '2026-09-10 12:00:00'),
    (10, 10, '2026-08-03', N'Potvrdjena', '2026-09-11 12:00:00'),
    (11, 11, '2026-08-04', N'Potvrdjena', '2026-09-12 12:00:00'),
    (12, 12, '2026-08-05', N'Potvrdjena', '2026-09-13 12:00:00'),
    (13, 13, '2026-08-06', N'Potvrdjena', '2026-09-14 12:00:00'),
    (14, 14, '2026-08-07', N'Potvrdjena', '2026-09-15 12:00:00'),
    (15, 15, '2026-08-08', N'Potvrdjena', '2026-09-16 12:00:00');
GO

INSERT INTO prodaja.RezervisanaSjedista (RezervacijaID, SjedisteID, Cijena)
VALUES
    (1, 1, 8.00), (2, 41, 11.00), (3, 71, 15.00),
    (4, 121, 20.00), (5, 2, 8.00), (6, 42, 11.00),
    (7, 72, 15.00), (8, 122, 20.00), (9, 3, 8.00),
    (10, 43, 11.00), (11, 73, 15.00), (12, 123, 20.00),
    (13, 4, 8.00), (14, 44, 11.00), (15, 74, 15.00),
    (16, 124, 20.00), (17, 5, 8.00), (18, 45, 11.00),
    (19, 75, 15.00), (20, 125, 20.00), (21, 6, 8.00),
    (22, 46, 11.00), (23, 76, 15.00), (24, 126, 20.00),
    (25, 7, 8.00), (26, 47, 11.00), (27, 77, 15.00),
    (28, 127, 20.00), (29, 8, 8.00), (30, 48, 11.00),
    (31, 78, 15.00), (32, 128, 20.00), (33, 9, 8.00),
    (34, 49, 11.00), (35, 79, 15.00);
GO

INSERT INTO prodaja.Placanja (RezervacijaID, DatumPlacanja, Iznos, NacinPlacanja, StatusPlacanja, BrojTransakcije)
VALUES
    (1, '2026-08-02', 8.00, N'Gotovina', N'Placeno', NULL),
    (2, '2026-08-03', 11.00, N'Kartica', N'Placeno', N'TXN-00002'),
    (3, '2026-08-04', 15.00, N'Online', N'Placeno', N'TXN-00003'),
    (4, '2026-08-05', 20.00, N'Vaucer', N'Placeno', N'TXN-00004'),
    (5, '2026-08-06', 8.00, N'Gotovina', N'Placeno', NULL),
    (6, '2026-08-07', 11.00, N'Kartica', N'Placeno', N'TXN-00006'),
    (7, '2026-08-08', 15.00, N'Online', N'Placeno', N'TXN-00007'),
    (8, '2026-08-09', 20.00, N'Vaucer', N'Placeno', N'TXN-00008'),
    (9, '2026-08-10', 8.00, N'Gotovina', N'Placeno', NULL),
    (10, '2026-08-11', 11.00, N'Kartica', N'Placeno', N'TXN-00010'),
    (11, '2026-08-12', 15.00, N'Online', N'Placeno', N'TXN-00011'),
    (12, '2026-08-13', 20.00, N'Vaucer', N'Placeno', N'TXN-00012'),
    (13, '2026-08-14', 8.00, N'Gotovina', N'Placeno', NULL),
    (14, '2026-08-15', 11.00, N'Kartica', N'Placeno', N'TXN-00014'),
    (15, '2026-08-16', 15.00, N'Online', N'Placeno', N'TXN-00015'),
    (16, '2026-08-17', 20.00, N'Vaucer', N'Placeno', N'TXN-00016'),
    (17, '2026-08-18', 8.00, N'Gotovina', N'Placeno', NULL),
    (18, '2026-08-19', 11.00, N'Kartica', N'Placeno', N'TXN-00018'),
    (19, '2026-08-20', 15.00, N'Online', N'Placeno', N'TXN-00019'),
    (20, '2026-08-21', 20.00, N'Vaucer', N'Placeno', N'TXN-00020'),
    (21, '2026-08-22', 8.00, N'Gotovina', N'Placeno', NULL),
    (22, '2026-08-23', 11.00, N'Kartica', N'Placeno', N'TXN-00022'),
    (23, '2026-08-24', 15.00, N'Online', N'Placeno', N'TXN-00023'),
    (24, '2026-08-25', 20.00, N'Vaucer', N'Placeno', N'TXN-00024'),
    (25, '2026-08-26', 8.00, N'Gotovina', N'Placeno', NULL),
    (26, '2026-08-27', 11.00, N'Kartica', N'Placeno', N'TXN-00026'),
    (27, '2026-08-28', 15.00, N'Online', N'Placeno', N'TXN-00027'),
    (28, '2026-08-01', 20.00, N'Vaucer', N'Placeno', N'TXN-00028'),
    (29, '2026-08-02', 8.00, N'Gotovina', N'Placeno', NULL),
    (30, '2026-08-03', 11.00, N'Kartica', N'Placeno', N'TXN-00030'),
    (31, '2026-08-04', 15.00, N'Online', N'Placeno', N'TXN-00031'),
    (32, '2026-08-05', 20.00, N'Vaucer', N'Placeno', N'TXN-00032'),
    (33, '2026-08-06', 8.00, N'Gotovina', N'Placeno', NULL),
    (34, '2026-08-07', 11.00, N'Kartica', N'Placeno', N'TXN-00034'),
    (35, '2026-08-08', 15.00, N'Online', N'Placeno', N'TXN-00035');
GO

CREATE VIEW izvjestaji.vw_RasporedProjekcija AS
SELECT
    p.ProjekcijaID,
    f.Naziv AS Film,
    z.Naziv AS Zanr,
    k.Naziv AS Kategorija,
    s.Naziv AS Sala,
    s.TipSale,
    p.DatumVrijeme,
    p.Jezik,
    p.FormatProjekcije,
    p.OsnovnaCijena,
    p.StatusProjekcije
FROM kino.Projekcije p
INNER JOIN kino.Filmovi f ON p.FilmID = f.FilmID
INNER JOIN sif.Zanrovi z ON f.ZanrID = z.ZanrID
INNER JOIN sif.Kategorije k ON f.KategorijaID = k.KategorijaID
INNER JOIN kino.Sale s ON p.SalaID = s.SalaID;
GO

CREATE VIEW izvjestaji.vw_RezervacijeDetalji AS
SELECT
    r.RezervacijaID,
    k.Ime + N' ' + k.Prezime AS Kupac,
    f.Naziv AS Film,
    p.DatumVrijeme,
    s.Naziv AS Sala,
    COUNT(rs.RezervisanoSjedisteID) AS BrojKarata,
    SUM(rs.Cijena) AS UkupnaCijena,
    r.StatusRezervacije
FROM prodaja.Rezervacije r
INNER JOIN prodaja.Kupci k ON r.KupacID = k.KupacID
INNER JOIN kino.Projekcije p ON r.ProjekcijaID = p.ProjekcijaID
INNER JOIN kino.Filmovi f ON p.FilmID = f.FilmID
INNER JOIN kino.Sale s ON p.SalaID = s.SalaID
LEFT JOIN prodaja.RezervisanaSjedista rs ON r.RezervacijaID = rs.RezervacijaID
GROUP BY r.RezervacijaID, k.Ime, k.Prezime, f.Naziv, p.DatumVrijeme, s.Naziv, r.StatusRezervacije;
GO

CREATE VIEW izvjestaji.vw_PrihodPoFilmu AS
SELECT
    f.FilmID,
    f.Naziv,
    COUNT(DISTINCT p.ProjekcijaID) AS BrojProjekcija,
    COUNT(DISTINCT pl.PlacanjeID) AS BrojUplata,
    ISNULL(SUM(pl.Iznos), 0) AS Prihod
FROM kino.Filmovi f
LEFT JOIN kino.Projekcije p ON f.FilmID = p.FilmID
LEFT JOIN prodaja.Rezervacije r ON p.ProjekcijaID = r.ProjekcijaID
LEFT JOIN prodaja.Placanja pl ON r.RezervacijaID = pl.RezervacijaID AND pl.StatusPlacanja = N'Placeno'
GROUP BY f.FilmID, f.Naziv;
GO

CREATE FUNCTION prodaja.fn_PopustKupca
(
    @BrojPosjeta INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    RETURN
    CASE
        WHEN @BrojPosjeta >= 10 THEN 20
        WHEN @BrojPosjeta >= 5 THEN 10
        WHEN @BrojPosjeta >= 3 THEN 5
        ELSE 0
    END;
END;
GO

CREATE FUNCTION kino.fn_SlobodnaSjedista
(
    @ProjekcijaID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        sj.SjedisteID,
        sj.RedOznaka,
        sj.BrojSjedista,
        sj.TipSjedista
    FROM kino.Projekcije p
    INNER JOIN kino.Sjedista sj ON p.SalaID = sj.SalaID
    WHERE
        p.ProjekcijaID = @ProjekcijaID
        AND sj.Aktivno = 1
        AND NOT EXISTS
        (
            SELECT 1
            FROM prodaja.RezervisanaSjedista rs
            INNER JOIN prodaja.Rezervacije r ON rs.RezervacijaID = r.RezervacijaID
            WHERE
                r.ProjekcijaID = @ProjekcijaID
                AND rs.SjedisteID = sj.SjedisteID
                AND r.StatusRezervacije IN (N'Na cekanju', N'Potvrdjena')
        )
);
GO

CREATE FUNCTION prodaja.fn_PrihodProjekcije
(
    @ProjekcijaID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @x DECIMAL(12,2);

    SELECT @x = ISNULL(SUM(pl.Iznos), 0)
    FROM prodaja.Rezervacije r
    INNER JOIN prodaja.Placanja pl ON r.RezervacijaID = pl.RezervacijaID
    WHERE
        r.ProjekcijaID = @ProjekcijaID
        AND pl.StatusPlacanja = N'Placeno';

    RETURN ISNULL(@x, 0);
END;
GO

CREATE PROCEDURE prodaja.sp_KreirajRezervaciju
    @KupacID INT,
    @ProjekcijaID INT,
    @SjedisteID INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM prodaja.Kupci WHERE KupacID = @KupacID)
            RAISERROR(N'Kupac ne postoji.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM kino.fn_SlobodnaSjedista(@ProjekcijaID) WHERE SjedisteID = @SjedisteID)
            RAISERROR(N'Sjediste nije slobodno ili ne pripada sali.', 16, 1);

        DECLARE @c DECIMAL(10,2), @b INT, @pop DECIMAL(5,2), @rid INT;

        SELECT @c = OsnovnaCijena
        FROM kino.Projekcije
        WHERE ProjekcijaID = @ProjekcijaID AND StatusProjekcije = N'Planirana';

        IF @c IS NULL
            RAISERROR(N'Projekcija nije dostupna.', 16, 1);

        SELECT @b = BrojPosjeta FROM prodaja.Kupci WHERE KupacID = @KupacID;

        SET @pop = prodaja.fn_PopustKupca(@b);

        INSERT INTO prodaja.Rezervacije (KupacID, ProjekcijaID, StatusRezervacije, RokPotvrde)
        VALUES (@KupacID, @ProjekcijaID, N'Potvrdjena', DATEADD(MINUTE, 30, GETDATE()));

        SET @rid = SCOPE_IDENTITY();

        INSERT INTO prodaja.RezervisanaSjedista (RezervacijaID, SjedisteID, Cijena)
        VALUES (@rid, @SjedisteID, @c * (1 - @pop / 100));

        UPDATE prodaja.Kupci SET BrojPosjeta = BrojPosjeta + 1 WHERE KupacID = @KupacID;

        SELECT @rid AS RezervacijaID;

        COMMIT;
    END TRY

    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK;

        DECLARE @m NVARCHAR(4000);
        SET @m = ERROR_MESSAGE();
        RAISERROR(@m, 16, 1);
    END CATCH
END;
GO

CREATE PROCEDURE prodaja.sp_OtkaziRezervaciju
    @RezervacijaID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE prodaja.Rezervacije
    SET StatusRezervacije = N'Otkazana'
    WHERE RezervacijaID = @RezervacijaID;

    UPDATE prodaja.Placanja
    SET StatusPlacanja = N'Refundirano'
    WHERE RezervacijaID = @RezervacijaID AND StatusPlacanja = N'Placeno';
END;
GO

CREATE PROCEDURE izvjestaji.sp_ProjekcijeZaPeriod
    @Od DATETIME,
    @Do DATETIME
AS
SELECT *
FROM izvjestaji.vw_RasporedProjekcija
WHERE DatumVrijeme >= @Od AND DatumVrijeme < @Do
ORDER BY DatumVrijeme;
GO

CREATE PROCEDURE izvjestaji.sp_PrihodPeriod
    @Od DATETIME,
    @Do DATETIME
AS
SELECT
    f.Naziv,
    COUNT(pl.PlacanjeID) AS BrojUplata,
    SUM(pl.Iznos) AS Prihod,
    AVG(pl.Iznos) AS ProsjecnaUplata
FROM prodaja.Placanja pl
INNER JOIN prodaja.Rezervacije r ON pl.RezervacijaID = r.RezervacijaID
INNER JOIN kino.Projekcije p ON r.ProjekcijaID = p.ProjekcijaID
INNER JOIN kino.Filmovi f ON p.FilmID = f.FilmID
WHERE pl.StatusPlacanja = N'Placeno' AND pl.DatumPlacanja >= @Od AND pl.DatumPlacanja < @Do
GROUP BY f.Naziv
ORDER BY Prihod DESC;
GO

CREATE TRIGGER prodaja.trg_Rezervacije_Dnevnik
ON prodaja.Rezervacije
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.RezervacijeDnevnik (RezervacijaID, Akcija, StariStatus, NoviStatus)
    SELECT
        ISNULL(i.RezervacijaID, d.RezervacijaID),
        CASE
            WHEN d.RezervacijaID IS NULL THEN N'INSERT'
            WHEN i.RezervacijaID IS NULL THEN N'DELETE'
            ELSE N'UPDATE'
        END,
        d.StatusRezervacije,
        i.StatusRezervacije
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.RezervacijaID = d.RezervacijaID;
END;
GO

CREATE TRIGGER kino.trg_Projekcije_Cijena
ON kino.Projekcije
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.CijeneProjekcijaDnevnik (ProjekcijaID, StaraCijena, NovaCijena)
    SELECT
        i.ProjekcijaID,
        d.OsnovnaCijena,
        i.OsnovnaCijena
    FROM inserted i
    INNER JOIN deleted d ON i.ProjekcijaID = d.ProjekcijaID
    WHERE i.OsnovnaCijena <> d.OsnovnaCijena;
END;
GO

CREATE TRIGGER prodaja.trg_RS_ProvjeraSale
ON prodaja.RezervisanaSjedista
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted i
        INNER JOIN prodaja.Rezervacije r ON i.RezervacijaID = r.RezervacijaID
        INNER JOIN kino.Projekcije p ON r.ProjekcijaID = p.ProjekcijaID
        INNER JOIN kino.Sjedista s ON i.SjedisteID = s.SjedisteID
        WHERE p.SalaID <> s.SalaID
    )
    BEGIN
        RAISERROR(N'Sjediste ne pripada sali projekcije.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

ALTER TABLE prodaja.Kupci ADD PrimaObavijesti BIT NOT NULL DEFAULT 1;
GO

SELECT
    KupacID,
    UPPER(Ime),
    LOWER(Prezime),
    LEN(Ime + Prezime),
    LEFT(Prezime, 3),
    DATEDIFF(DAY, DatumRegistracije, GETDATE()),
    ISNULL(Telefon, N'Nema')
FROM prodaja.Kupci;

SELECT
    COUNT(*) AS BrojFilmova,
    MIN(TrajanjeMin) AS Najkraci,
    MAX(TrajanjeMin) AS Najduzi,
    AVG(CAST(TrajanjeMin AS DECIMAL(10,2))) AS Prosjek
FROM kino.Filmovi;

SELECT
    ProjekcijaID,
    OsnovnaCijena,
    ROUND(OsnovnaCijena * 1.17, 2),
    CEILING(OsnovnaCijena),
    FLOOR(OsnovnaCijena),
    CASE
        WHEN OsnovnaCijena < 10 THEN N'Povoljna'
        WHEN OsnovnaCijena <= 15 THEN N'Srednja'
        ELSE N'Premium'
    END AS Kategorija
FROM kino.Projekcije;

SELECT
    f.Naziv,
    p.DatumVrijeme,
    s.Naziv AS Sala
FROM kino.Projekcije p
INNER JOIN kino.Filmovi f ON p.FilmID = f.FilmID
INNER JOIN kino.Sale s ON p.SalaID = s.SalaID;

SELECT
    k.KupacID,
    k.Ime,
    k.Prezime,
    COUNT(r.RezervacijaID) AS BrojRezervacija
FROM prodaja.Kupci k
LEFT JOIN prodaja.Rezervacije r ON k.KupacID = r.KupacID
GROUP BY k.KupacID, k.Ime, k.Prezime;

SELECT
    p.ProjekcijaID,
    r.RezervacijaID
FROM prodaja.Rezervacije r
RIGHT JOIN kino.Projekcije p ON r.ProjekcijaID = p.ProjekcijaID;

SELECT
    k.Ime,
    r.RezervacijaID
FROM prodaja.Kupci k
FULL OUTER JOIN prodaja.Rezervacije r ON k.KupacID = r.KupacID;

SELECT
    f.Naziv,
    s.Naziv
FROM kino.Filmovi f
CROSS JOIN kino.Sale s;

SELECT
    f1.Naziv AS Film1,
    f2.Naziv AS Film2,
    f1.ZanrID
FROM kino.Filmovi f1
INNER JOIN kino.Filmovi f2 ON f1.ZanrID = f2.ZanrID AND f1.FilmID < f2.FilmID;

SELECT
    Naziv,
    TrajanjeMin
FROM kino.Filmovi
WHERE TrajanjeMin > (SELECT AVG(TrajanjeMin) FROM kino.Filmovi);

SELECT
    p.ProjekcijaID,
    p.DatumVrijeme
FROM kino.Projekcije p
WHERE NOT EXISTS
(
    SELECT 1
    FROM prodaja.Rezervacije r
    WHERE r.ProjekcijaID = p.ProjekcijaID
);

SELECT
    Ime,
    Prezime,
    BrojPosjeta
FROM prodaja.Kupci
WHERE BrojPosjeta > (SELECT AVG(CAST(BrojPosjeta AS DECIMAL(10,2))) FROM prodaja.Kupci);

SELECT Ime, Prezime, N'Kupac' AS Uloga
FROM prodaja.Kupci
UNION
SELECT Ime, Prezime, N'Zaposleni'
FROM kino.Zaposleni;

SELECT Naziv, N'Film' AS Tip
FROM kino.Filmovi
UNION ALL
SELECT Naziv, N'Sala'
FROM kino.Sale;

SELECT KupacID
FROM prodaja.Rezervacije
INTERSECT
SELECT KupacID
FROM prodaja.Kupci;

SELECT KupacID
FROM prodaja.Kupci
EXCEPT
SELECT KupacID
FROM prodaja.Rezervacije;
GO

CREATE ROLE db_bioskop_operater;
CREATE ROLE db_bioskop_izvjestaji;

GRANT SELECT, INSERT, UPDATE ON SCHEMA::prodaja TO db_bioskop_operater;
DENY DELETE ON SCHEMA::prodaja TO db_bioskop_operater;
GRANT SELECT ON SCHEMA::kino TO db_bioskop_operater;
GRANT SELECT, EXECUTE ON SCHEMA::izvjestaji TO db_bioskop_izvjestaji;

CREATE USER BioskopOperater WITHOUT LOGIN;
CREATE USER BioskopAnaliticar WITHOUT LOGIN;
EXEC sp_addrolemember N'db_bioskop_operater', N'BioskopOperater';
EXEC sp_addrolemember N'db_bioskop_izvjestaji', N'BioskopAnaliticar';
GO

CREATE TABLE etl.StageFilmovi
(
    IzvorniID INT,
    Naziv NVARCHAR(150),
    Zanr NVARCHAR(50),
    Kategorija NVARCHAR(50),
    TrajanjeMin INT,
    Godina SMALLINT,
    Obradjen BIT NOT NULL DEFAULT 0
);

INSERT INTO etl.StageFilmovi (IzvorniID, Naziv, Zanr, Kategorija, TrajanjeMin, Godina, Obradjen)
VALUES
    (1001, N'  Povratak kući  ', N'Drama', N'12+', 109, 2026, 0),
    (1002, N'Mali hero', N'Animirani', N'Svi uzrasti', 87, 2026, 0);
GO

CREATE PROCEDURE etl.sp_UveziFilmove
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    INSERT INTO kino.Filmovi (ZanrID, KategorijaID, Naziv, TrajanjeMin, Godina)
    SELECT
        z.ZanrID,
        k.KategorijaID,
        LTRIM(RTRIM(s.Naziv)),
        s.TrajanjeMin,
        s.Godina
    FROM etl.StageFilmovi s
    INNER JOIN sif.Zanrovi z ON s.Zanr = z.Naziv
    INNER JOIN sif.Kategorije k ON s.Kategorija = k.Naziv
    WHERE
        s.Obradjen = 0
        AND NOT EXISTS
        (
            SELECT 1
            FROM kino.Filmovi f
            WHERE f.Naziv = LTRIM(RTRIM(s.Naziv)) AND f.Godina = s.Godina
        );

    UPDATE etl.StageFilmovi SET Obradjen = 1 WHERE Obradjen = 0;

    COMMIT;
END;
GO

CREATE TABLE izvjestaji.DnevniPrihod
(
    Datum DATE NOT NULL,
    FilmID INT NOT NULL,
    BrojKarata INT NOT NULL,
    Prihod DECIMAL(12,2) NOT NULL,
    DatumUcitavanja DATETIME NOT NULL DEFAULT GETDATE(),
    PRIMARY KEY(Datum, FilmID)
);
GO

CREATE PROCEDURE etl.sp_UcitajDnevniPrihod
    @Datum DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRAN;

    DELETE FROM izvjestaji.DnevniPrihod WHERE Datum = @Datum;

    INSERT INTO izvjestaji.DnevniPrihod (Datum, FilmID, BrojKarata, Prihod)
    SELECT
        @Datum,
        f.FilmID,
        COUNT(pl.PlacanjeID),
        ISNULL(SUM(pl.Iznos), 0)
    FROM kino.Filmovi f
    LEFT JOIN kino.Projekcije p ON f.FilmID = p.FilmID
    LEFT JOIN prodaja.Rezervacije r ON p.ProjekcijaID = r.ProjekcijaID
    LEFT JOIN prodaja.Placanja pl ON r.RezervacijaID = pl.RezervacijaID
        AND pl.DatumPlacanja >= @Datum
        AND pl.DatumPlacanja < DATEADD(DAY, 1, @Datum)
        AND pl.StatusPlacanja = N'Placeno'
    GROUP BY f.FilmID;

    COMMIT;
END;
GO

BEGIN TRY
    INSERT INTO kino.Filmovi (ZanrID, KategorijaID, Naziv, TrajanjeMin, Godina)
    VALUES (999, 1, N'Neispravan FK', 100, 2026);
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;

BEGIN TRY
    UPDATE kino.Projekcije SET OsnovnaCijena = -1 WHERE ProjekcijaID = 1;
END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;

BEGIN TRAN;
    UPDATE prodaja.Rezervacije SET StatusRezervacije = N'Otkazana' WHERE RezervacijaID = 1;
    SELECT TOP 1 * FROM audit.RezervacijeDnevnik ORDER BY DnevnikID DESC;
ROLLBACK;

BEGIN TRAN;
    UPDATE kino.Projekcije SET OsnovnaCijena = OsnovnaCijena + 2 WHERE ProjekcijaID = 1;
    SELECT TOP 1 * FROM audit.CijeneProjekcijaDnevnik ORDER BY DnevnikID DESC;
ROLLBACK;

SELECT TOP 10 * FROM izvjestaji.vw_RasporedProjekcija;
SELECT TOP 10 * FROM izvjestaji.vw_RezervacijeDetalji;
SELECT TOP 10 * FROM izvjestaji.vw_PrihodPoFilmu ORDER BY Prihod DESC;

SELECT prodaja.fn_PopustKupca(12) AS Popust;
SELECT TOP 10 * FROM kino.fn_SlobodnaSjedista(1);
SELECT prodaja.fn_PrihodProjekcije(1) AS Prihod;

EXEC etl.sp_UveziFilmove;
SELECT * FROM etl.StageFilmovi;
EXEC etl.sp_UcitajDnevniPrihod '2026-08-20';
SELECT * FROM izvjestaji.DnevniPrihod WHERE Datum = '2026-08-20';

EXECUTE AS USER = N'BioskopAnaliticar';
    SELECT TOP 5 * FROM izvjestaji.vw_RasporedProjekcija;
REVERT;

BEGIN TRAN;
    INSERT INTO prodaja.Kupci (Ime, Prezime, Email) VALUES (N'Test', N'Kupac', N'test.kupac@primjer.com');
ROLLBACK;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT * FROM kino.Projekcije WHERE FilmID = 1 AND StatusProjekcije = N'Planirana';
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

SELECT N'Filmovi' AS Tabela, COUNT(*) AS Broj FROM kino.Filmovi
UNION ALL
SELECT N'Sale', COUNT(*) FROM kino.Sale
UNION ALL
SELECT N'Sjedista', COUNT(*) FROM kino.Sjedista
UNION ALL
SELECT N'Projekcije', COUNT(*) FROM kino.Projekcije
UNION ALL
SELECT N'Rezervacije', COUNT(*) FROM prodaja.Rezervacije
UNION ALL
SELECT N'Placanja', COUNT(*) FROM prodaja.Placanja;
GO