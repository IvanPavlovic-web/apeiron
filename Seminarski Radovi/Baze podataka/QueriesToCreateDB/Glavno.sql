CREATE DATABASE HotelRezervacije;
GO

USE HotelRezervacije;
GO

ALTER DATABASE HotelRezervacije
SET COMPATIBILITY_LEVEL = 120;
GO

CREATE TABLE Gosti (
    GostID INT IDENTITY(1,1) PRIMARY KEY,
    Ime NVARCHAR(50) NOT NULL,
    Prezime NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Telefon NVARCHAR(20),
    Adresa NVARCHAR(200),
    Grad NVARCHAR(50),
    Drzava NVARCHAR(50),
    DatumRegistracije DATETIME DEFAULT GETDATE(),
    BrojDolazaka INT DEFAULT 0,
    CONSTRAINT CHK_Email CHECK (Email LIKE '%_@__%.__%')
);
GO

CREATE TABLE Sobe (
    SobaID INT IDENTITY(1,1) PRIMARY KEY,
    BrojSobe NVARCHAR(10) NOT NULL UNIQUE,
    TipSobe NVARCHAR(50) NOT NULL,
    Kapacitet INT NOT NULL,
    CijenaPoNoci DECIMAL(10,2) NOT NULL,
    Sprat INT,
    Pogled NVARCHAR(50),
    StatusSobe NVARCHAR(20) DEFAULT 'Dostupna',
    CONSTRAINT CHK_Cijena CHECK (CijenaPoNoci > 0),
    CONSTRAINT CHK_Kapacitet CHECK (Kapacitet BETWEEN 1 AND 10),
    CONSTRAINT CHK_Status CHECK (StatusSobe IN ('Dostupna', 'Zauzeta', 'Rezervisana', 'Na ciscenju'))
);
GO

CREATE TABLE Rezervacije (
    RezervacijaID INT IDENTITY(1,1) PRIMARY KEY,
    GostID INT NOT NULL,
    SobaID INT NOT NULL,
    DatumPrijave DATE NOT NULL,
    DatumOdjave DATE NOT NULL,
    DatumRezervacije DATETIME DEFAULT GETDATE(),
    BrojOdraslih INT DEFAULT 1,
    BrojDjece INT DEFAULT 0,
    StatusRezervacije NVARCHAR(20) DEFAULT 'Potvrđena',
    Napomena NVARCHAR(500),
    CONSTRAINT CHK_Datum CHECK (DatumOdjave > DatumPrijave),
    CONSTRAINT CHK_BrojGostiju CHECK (BrojOdraslih + BrojDjece <= 10),
    CONSTRAINT FK_Rezervacije_Gosti FOREIGN KEY (GostID) REFERENCES Gosti(GostID),
    CONSTRAINT FK_Rezervacije_Sobe FOREIGN KEY (SobaID) REFERENCES Sobe(SobaID)
);
GO

CREATE TABLE Usluge (
    UslugaID INT IDENTITY(1,1) PRIMARY KEY,
    NazivUsluge NVARCHAR(100) NOT NULL,
    Opis NVARCHAR(500),
    Cijena DECIMAL(10,2) NOT NULL,
    Kategorija NVARCHAR(50),
    CONSTRAINT CHK_CijenaUsluge CHECK (Cijena >= 0)
);
GO

CREATE TABLE RezervacijeUsluge (
    RezervacijaUslugaID INT IDENTITY(1,1) PRIMARY KEY,
    RezervacijaID INT NOT NULL,
    UslugaID INT NOT NULL,
    Kolicina INT DEFAULT 1,
    CijenaPoJedinici DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_RezUsl_Rezervacije FOREIGN KEY (RezervacijaID) REFERENCES Rezervacije(RezervacijaID),
    CONSTRAINT FK_RezUsl_Usluge FOREIGN KEY (UslugaID) REFERENCES Usluge(UslugaID)
);
GO

CREATE TABLE Placanja (
    PlacanjeID INT IDENTITY(1,1) PRIMARY KEY,
    RezervacijaID INT NOT NULL,
    Iznos DECIMAL(10,2) NOT NULL,
    DatumPlacanja DATETIME DEFAULT GETDATE(),
    NacinPlacanja NVARCHAR(50) NOT NULL,
    StatusPlacanja NVARCHAR(20) DEFAULT 'Na čekanju',
    TransakcijaID NVARCHAR(100),
    CONSTRAINT FK_Placanja_Rezervacije FOREIGN KEY (RezervacijaID) REFERENCES Rezervacije(RezervacijaID),
    CONSTRAINT CHK_Iznos CHECK (Iznos > 0),
    CONSTRAINT CHK_NacinPlacanja CHECK (NacinPlacanja IN ('Gotovina', 'Kartica', 'PayPal'))
);
GO

CREATE INDEX IX_Gosti_Prezime ON Gosti(Prezime);
CREATE INDEX IX_Gosti_Email ON Gosti(Email);

CREATE INDEX IX_Rezervacije_DatumPrijave ON Rezervacije(DatumPrijave);
CREATE INDEX IX_Rezervacije_DatumOdjave ON Rezervacije(DatumOdjave);
CREATE INDEX IX_Rezervacije_Status ON Rezervacije(StatusRezervacije);

CREATE INDEX IX_Rezervacije_GostStatus ON Rezervacije(GostID, StatusRezervacije);

CREATE INDEX IX_Sobe_TipCijena ON Sobe(TipSobe, CijenaPoNoci);

CREATE TABLE IstorijaCijena (
    IstorijaID INT IDENTITY(1,1) PRIMARY KEY,
    SobaID INT NOT NULL,
    StaraCijena DECIMAL(10,2),
    NovaCijena DECIMAL(10,2),
    DatumPromjene DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Istorija_Sobe FOREIGN KEY (SobaID) REFERENCES Sobe(SobaID)
);
