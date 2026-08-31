
CREATE DATABASE SportskaTakmicenja;
GO
USE SportskaTakmicenja;
GO

CREATE SCHEMA sif AUTHORIZATION dbo;
GO
CREATE SCHEMA sport AUTHORIZATION dbo;
GO
CREATE SCHEMA prodaja AUTHORIZATION dbo;
GO
CREATE SCHEMA izvjestaji AUTHORIZATION dbo;
GO
CREATE SCHEMA audit AUTHORIZATION dbo;
GO
CREATE SCHEMA etl AUTHORIZATION dbo;
GO

/* TABELE */
CREATE TABLE sif.Drzave(
 DrzavaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Drzave PRIMARY KEY,
 Naziv NVARCHAR(80) NOT NULL CONSTRAINT UQ_Drzave_Naziv UNIQUE,
 ISOKod NCHAR(3) NOT NULL CONSTRAINT UQ_Drzave_ISO UNIQUE
);
GO
CREATE TABLE sif.Gradovi(
 GradID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Gradovi PRIMARY KEY,
 DrzavaID INT NOT NULL,
 Naziv NVARCHAR(80) NOT NULL,
 PostanskiBroj NVARCHAR(15) NULL,
 BrojStanovnika INT NULL,
 CONSTRAINT FK_Gradovi_Drzave FOREIGN KEY(DrzavaID) REFERENCES sif.Drzave(DrzavaID),
 CONSTRAINT UQ_Gradovi UNIQUE(DrzavaID,Naziv),
 CONSTRAINT CHK_Gradovi_Stanovnici CHECK(BrojStanovnika IS NULL OR BrojStanovnika>=0)
);
GO
CREATE TABLE sif.Sportovi(
 SportID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sportovi PRIMARY KEY,
 Naziv NVARCHAR(60) NOT NULL CONSTRAINT UQ_Sportovi_Naziv UNIQUE,
 TipSporta NVARCHAR(15) NOT NULL,
 MinimalanBrojIgraca INT NOT NULL,
 MaksimalanBrojIgraca INT NOT NULL,
 CONSTRAINT CHK_Sportovi_Tip CHECK(TipSporta IN(N'Ekipni',N'Individualni')),
 CONSTRAINT CHK_Sportovi_Igraci CHECK(MinimalanBrojIgraca>0 AND MaksimalanBrojIgraca>=MinimalanBrojIgraca)
);
GO
CREATE TABLE sport.Organizatori(
 OrganizatorID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Organizatori PRIMARY KEY,
 Naziv NVARCHAR(120) NOT NULL CONSTRAINT UQ_Organizatori_Naziv UNIQUE,
 JIB NVARCHAR(20) NOT NULL CONSTRAINT UQ_Organizatori_JIB UNIQUE,
 Email NVARCHAR(100) NULL,
 Telefon NVARCHAR(25) NULL,
 DatumOsnivanja DATE NULL,
 Aktivan BIT NOT NULL CONSTRAINT DF_Organizatori_Aktivan DEFAULT 1,
 CONSTRAINT CHK_Organizatori_Email CHECK(Email IS NULL OR Email LIKE N'%_@_%._%')
);
GO
CREATE TABLE sport.Sezone(
 SezonaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sezone PRIMARY KEY,
 Naziv NVARCHAR(30) NOT NULL CONSTRAINT UQ_Sezone_Naziv UNIQUE,
 DatumPocetka DATE NOT NULL,
 DatumZavrsetka DATE NOT NULL,
 Aktivna BIT NOT NULL CONSTRAINT DF_Sezone_Aktivna DEFAULT 0,
 CONSTRAINT CHK_Sezone_Datumi CHECK(DatumZavrsetka>DatumPocetka)
);
GO
CREATE TABLE sport.Takmicenja(
 TakmicenjeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Takmicenja PRIMARY KEY,
 SportID INT NOT NULL,
 OrganizatorID INT NOT NULL,
 SezonaID INT NOT NULL,
 Naziv NVARCHAR(120) NOT NULL,
 RangTakmicenja NVARCHAR(20) NOT NULL,
 DatumPocetka DATE NOT NULL,
 DatumZavrsetka DATE NOT NULL,
 StatusTakmicenja NVARCHAR(20) NOT NULL CONSTRAINT DF_Takmicenja_Status DEFAULT N'Planirano',
 NagradniFond DECIMAL(14,2) NOT NULL CONSTRAINT DF_Takmicenja_Fond DEFAULT 0,
 CONSTRAINT FK_Takmicenja_Sport FOREIGN KEY(SportID) REFERENCES sif.Sportovi(SportID),
 CONSTRAINT FK_Takmicenja_Organizator FOREIGN KEY(OrganizatorID) REFERENCES sport.Organizatori(OrganizatorID),
 CONSTRAINT FK_Takmicenja_Sezona FOREIGN KEY(SezonaID) REFERENCES sport.Sezone(SezonaID),
 CONSTRAINT UQ_Takmicenja UNIQUE(Naziv,SezonaID),
 CONSTRAINT CHK_Takmicenja_Datumi CHECK(DatumZavrsetka>=DatumPocetka),
 CONSTRAINT CHK_Takmicenja_Status CHECK(StatusTakmicenja IN(N'Planirano',N'U toku',N'Završeno',N'Otkazano')),
 CONSTRAINT CHK_Takmicenja_Rang CHECK(RangTakmicenja IN(N'Lokalno',N'Državno',N'Regionalno',N'Međunarodno')),
 CONSTRAINT CHK_Takmicenja_Fond CHECK(NagradniFond>=0)
);
GO
CREATE TABLE sport.Faze(
 FazaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Faze PRIMARY KEY,
 TakmicenjeID INT NOT NULL,
 Naziv NVARCHAR(50) NOT NULL,
 RedniBroj INT NOT NULL,
 DatumPocetka DATE NOT NULL,
 DatumZavrsetka DATE NOT NULL,
 CONSTRAINT FK_Faze_Takmicenja FOREIGN KEY(TakmicenjeID) REFERENCES sport.Takmicenja(TakmicenjeID),
 CONSTRAINT UQ_Faze UNIQUE(TakmicenjeID,RedniBroj),
 CONSTRAINT CHK_Faze_RedniBroj CHECK(RedniBroj>0),
 CONSTRAINT CHK_Faze_Datumi CHECK(DatumZavrsetka>=DatumPocetka)
);
GO
CREATE TABLE sport.Ekipe(
 EkipaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ekipe PRIMARY KEY,
 SportID INT NOT NULL,
 GradID INT NOT NULL,
 Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_Ekipe_Naziv UNIQUE,
 SkraceniNaziv NVARCHAR(10) NOT NULL CONSTRAINT UQ_Ekipe_Skraceni UNIQUE,
 DatumOsnivanja DATE NULL,
 Budzet DECIMAL(14,2) NULL,
 Aktivan BIT NOT NULL CONSTRAINT DF_Ekipe_Aktivan DEFAULT 1,
 CONSTRAINT FK_Ekipe_Sportovi FOREIGN KEY(SportID) REFERENCES sif.Sportovi(SportID),
 CONSTRAINT FK_Ekipe_Gradovi FOREIGN KEY(GradID) REFERENCES sif.Gradovi(GradID),
 CONSTRAINT CHK_Ekipe_Budzet CHECK(Budzet IS NULL OR Budzet>=0)
);
GO
CREATE TABLE sport.Sportisti(
 SportistaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sportisti PRIMARY KEY,
 DrzavaID INT NOT NULL,
 Ime NVARCHAR(50) NOT NULL,
 Prezime NVARCHAR(50) NOT NULL,
 DatumRodjenja DATE NOT NULL,
 Pol NCHAR(1) NULL,
 Email NVARCHAR(100) NULL,
 VisinaCm DECIMAL(5,2) NULL,
 TezinaKg DECIMAL(5,2) NULL,
 DatumRegistracije DATETIME NOT NULL CONSTRAINT DF_Sportisti_Registracija DEFAULT GETDATE(),
 Aktivan BIT NOT NULL CONSTRAINT DF_Sportisti_Aktivan DEFAULT 1,
 CONSTRAINT FK_Sportisti_Drzave FOREIGN KEY(DrzavaID) REFERENCES sif.Drzave(DrzavaID),
 CONSTRAINT UQ_Sportisti_Email UNIQUE(Email),
 CONSTRAINT CHK_Sportisti_Pol CHECK(Pol IS NULL OR Pol IN(N'M',N'Z')),
 CONSTRAINT CHK_Sportisti_Email CHECK(Email IS NULL OR Email LIKE N'%_@_%._%'),
 CONSTRAINT CHK_Sportisti_Visina CHECK(VisinaCm IS NULL OR VisinaCm BETWEEN 100 AND 250),
 CONSTRAINT CHK_Sportisti_Tezina CHECK(TezinaKg IS NULL OR TezinaKg BETWEEN 30 AND 250)
);
GO
CREATE TABLE sport.ClanoviEkipa(
 ClanEkipeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ClanoviEkipa PRIMARY KEY,
 EkipaID INT NOT NULL,
 SportistaID INT NOT NULL,
 BrojDresa INT NULL,
 Pozicija NVARCHAR(40) NULL,
 DatumOd DATE NOT NULL,
 DatumDo DATE NULL,
 CONSTRAINT FK_Clanovi_Ekipe FOREIGN KEY(EkipaID) REFERENCES sport.Ekipe(EkipaID),
 CONSTRAINT FK_Clanovi_Sportisti FOREIGN KEY(SportistaID) REFERENCES sport.Sportisti(SportistaID),
 CONSTRAINT UQ_Clanovi_EkipaSportistaDatum UNIQUE(EkipaID,SportistaID,DatumOd),
 CONSTRAINT CHK_Clanovi_Dres CHECK(BrojDresa IS NULL OR BrojDresa BETWEEN 0 AND 999),
 CONSTRAINT CHK_Clanovi_Datumi CHECK(DatumDo IS NULL OR DatumDo>=DatumOd)
);
GO
CREATE TABLE sport.Objekti(
 ObjekatID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Objekti PRIMARY KEY,
 GradID INT NOT NULL,
 Naziv NVARCHAR(100) NOT NULL,
 Adresa NVARCHAR(150) NOT NULL,
 Kapacitet INT NOT NULL,
 TipObjekta NVARCHAR(30) NOT NULL,
 DatumOtvaranja DATE NULL,
 CONSTRAINT FK_Objekti_Gradovi FOREIGN KEY(GradID) REFERENCES sif.Gradovi(GradID),
 CONSTRAINT UQ_Objekti UNIQUE(GradID,Naziv),
 CONSTRAINT CHK_Objekti_Kapacitet CHECK(Kapacitet>0)
);
GO
CREATE TABLE sport.Sudije(
 SudijaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sudije PRIMARY KEY,
 DrzavaID INT NOT NULL,
 Ime NVARCHAR(50) NOT NULL,
 Prezime NVARCHAR(50) NOT NULL,
 BrojLicence NVARCHAR(30) NOT NULL CONSTRAINT UQ_Sudije_Licenca UNIQUE,
 DatumLicence DATE NOT NULL,
 Kategorija NVARCHAR(30) NOT NULL,
 Aktivan BIT NOT NULL CONSTRAINT DF_Sudije_Aktivan DEFAULT 1,
 CONSTRAINT FK_Sudije_Drzave FOREIGN KEY(DrzavaID) REFERENCES sif.Drzave(DrzavaID)
);
GO
CREATE TABLE sport.Utakmice(
 UtakmicaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Utakmice PRIMARY KEY,
 TakmicenjeID INT NOT NULL,
 FazaID INT NULL,
 ObjekatID INT NOT NULL,
 DomacaEkipaID INT NULL,
 GostujucaEkipaID INT NULL,
 SudijaID INT NULL,
 DatumVrijeme DATETIME NOT NULL,
 StatusUtakmice NVARCHAR(20) NOT NULL CONSTRAINT DF_Utakmice_Status DEFAULT N'Zakazana',
 RezultatDomaci INT NULL,
 RezultatGosti INT NULL,
 BrojGledalaca INT NULL,
 Napomena NVARCHAR(300) NULL,
 CONSTRAINT FK_Utakmice_Takmicenja FOREIGN KEY(TakmicenjeID) REFERENCES sport.Takmicenja(TakmicenjeID),
 CONSTRAINT FK_Utakmice_Faze FOREIGN KEY(FazaID) REFERENCES sport.Faze(FazaID),
 CONSTRAINT FK_Utakmice_Objekti FOREIGN KEY(ObjekatID) REFERENCES sport.Objekti(ObjekatID),
 CONSTRAINT FK_Utakmice_Domaci FOREIGN KEY(DomacaEkipaID) REFERENCES sport.Ekipe(EkipaID),
 CONSTRAINT FK_Utakmice_Gosti FOREIGN KEY(GostujucaEkipaID) REFERENCES sport.Ekipe(EkipaID),
 CONSTRAINT FK_Utakmice_Sudije FOREIGN KEY(SudijaID) REFERENCES sport.Sudije(SudijaID),
 CONSTRAINT CHK_Utakmice_Ekipe CHECK(DomacaEkipaID IS NULL OR GostujucaEkipaID IS NULL OR DomacaEkipaID<>GostujucaEkipaID),
 CONSTRAINT CHK_Utakmice_Status CHECK(StatusUtakmice IN(N'Zakazana',N'U toku',N'Završena',N'Odložena',N'Otkazana')),
 CONSTRAINT CHK_Utakmice_Rezultat CHECK((RezultatDomaci IS NULL AND RezultatGosti IS NULL) OR (RezultatDomaci>=0 AND RezultatGosti>=0)),
 CONSTRAINT CHK_Utakmice_Gledaoci CHECK(BrojGledalaca IS NULL OR BrojGledalaca>=0)
);
GO
CREATE TABLE sport.Nastupi(
 NastupID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Nastupi PRIMARY KEY,
 UtakmicaID INT NOT NULL,
 SportistaID INT NOT NULL,
 EkipaID INT NULL,
 BrojPoena DECIMAL(10,2) NOT NULL CONSTRAINT DF_Nastupi_Poeni DEFAULT 0,
 BrojAsistencija INT NOT NULL CONSTRAINT DF_Nastupi_Asistencije DEFAULT 0,
 MinutaNastupa INT NULL,
 Napomena NVARCHAR(200) NULL,
 CONSTRAINT FK_Nastupi_Utakmice FOREIGN KEY(UtakmicaID) REFERENCES sport.Utakmice(UtakmicaID),
 CONSTRAINT FK_Nastupi_Sportisti FOREIGN KEY(SportistaID) REFERENCES sport.Sportisti(SportistaID),
 CONSTRAINT FK_Nastupi_Ekipe FOREIGN KEY(EkipaID) REFERENCES sport.Ekipe(EkipaID),
 CONSTRAINT UQ_Nastupi UNIQUE(UtakmicaID,SportistaID),
 CONSTRAINT CHK_Nastupi_Vrijednosti CHECK(BrojPoena>=0 AND BrojAsistencija>=0 AND (MinutaNastupa IS NULL OR MinutaNastupa>=0))
);
GO
CREATE TABLE sport.Kazne(
 KaznaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Kazne PRIMARY KEY,
 UtakmicaID INT NOT NULL,
 SportistaID INT NULL,
 EkipaID INT NULL,
 VrstaKazne NVARCHAR(40) NOT NULL,
 MinutKazne INT NULL,
 NovcaniIznos DECIMAL(10,2) NOT NULL CONSTRAINT DF_Kazne_Iznos DEFAULT 0,
 Opis NVARCHAR(250) NULL,
 CONSTRAINT FK_Kazne_Utakmice FOREIGN KEY(UtakmicaID) REFERENCES sport.Utakmice(UtakmicaID),
 CONSTRAINT FK_Kazne_Sportisti FOREIGN KEY(SportistaID) REFERENCES sport.Sportisti(SportistaID),
 CONSTRAINT FK_Kazne_Ekipe FOREIGN KEY(EkipaID) REFERENCES sport.Ekipe(EkipaID),
 CONSTRAINT CHK_Kazne_Subjekt CHECK(SportistaID IS NOT NULL OR EkipaID IS NOT NULL),
 CONSTRAINT CHK_Kazne_Iznos CHECK(NovcaniIznos>=0)
);
GO
CREATE TABLE prodaja.Sponzori(
 SponzorID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sponzori PRIMARY KEY,
 Naziv NVARCHAR(100) NOT NULL CONSTRAINT UQ_Sponzori_Naziv UNIQUE,
 KontaktEmail NVARCHAR(100) NULL,
 Telefon NVARCHAR(25) NULL
);
GO
CREATE TABLE prodaja.TakmicenjeSponzori(
 TakmicenjeID INT NOT NULL,
 SponzorID INT NOT NULL,
 Iznos DECIMAL(14,2) NOT NULL,
 DatumUgovora DATE NOT NULL,
 CONSTRAINT PK_TakmicenjeSponzori PRIMARY KEY(TakmicenjeID,SponzorID),
 CONSTRAINT FK_TS_Takmicenja FOREIGN KEY(TakmicenjeID) REFERENCES sport.Takmicenja(TakmicenjeID),
 CONSTRAINT FK_TS_Sponzori FOREIGN KEY(SponzorID) REFERENCES prodaja.Sponzori(SponzorID),
 CONSTRAINT CHK_TS_Iznos CHECK(Iznos>0)
);
GO
CREATE TABLE prodaja.Ulaznice(
 UlaznicaID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ulaznice PRIMARY KEY,
 UtakmicaID INT NOT NULL,
 Sektor NVARCHAR(20) NOT NULL,
 RedBroj NVARCHAR(10) NOT NULL,
 SjedisteBroj INT NOT NULL,
 Cijena DECIMAL(10,2) NOT NULL,
 DatumProdaje DATETIME NULL,
 StatusUlaznice NVARCHAR(20) NOT NULL CONSTRAINT DF_Ulaznice_Status DEFAULT N'Slobodna',
 KupacEmail NVARCHAR(100) NULL,
 CONSTRAINT FK_Ulaznice_Utakmice FOREIGN KEY(UtakmicaID) REFERENCES sport.Utakmice(UtakmicaID),
 CONSTRAINT UQ_Ulaznice_Sjediste UNIQUE(UtakmicaID,Sektor,RedBroj,SjedisteBroj),
 CONSTRAINT CHK_Ulaznice_Cijena CHECK(Cijena>=0),
 CONSTRAINT CHK_Ulaznice_Status CHECK(StatusUlaznice IN(N'Slobodna',N'Rezervisana',N'Prodata',N'Ponistena'))
);
GO
CREATE TABLE prodaja.Placanja(
 PlacanjeID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Placanja PRIMARY KEY,
 UlaznicaID INT NOT NULL,
 DatumPlacanja DATETIME NOT NULL CONSTRAINT DF_Placanja_Datum DEFAULT GETDATE(),
 Iznos DECIMAL(10,2) NOT NULL,
 NacinPlacanja NVARCHAR(20) NOT NULL,
 StatusPlacanja NVARCHAR(20) NOT NULL CONSTRAINT DF_Placanja_Status DEFAULT N'Placeno',
 BrojTransakcije NVARCHAR(60) NULL,
 CONSTRAINT FK_Placanja_Ulaznice FOREIGN KEY(UlaznicaID) REFERENCES prodaja.Ulaznice(UlaznicaID),
 CONSTRAINT CHK_Placanja_Iznos CHECK(Iznos>0),
 CONSTRAINT CHK_Placanja_Nacin CHECK(NacinPlacanja IN(N'Gotovina',N'Kartica',N'Online',N'Vaucer')),
 CONSTRAINT CHK_Placanja_Status CHECK(StatusPlacanja IN(N'Na cekanju',N'Placeno',N'Odbijeno',N'Refundirano'))
);
GO
CREATE TABLE audit.UtakmiceDnevnik(
 DnevnikID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_UtakmiceDnevnik PRIMARY KEY,
 UtakmicaID INT NOT NULL,
 Akcija NVARCHAR(10) NOT NULL,
 StariStatus NVARCHAR(20) NULL,
 NoviStatus NVARCHAR(20) NULL,
 StariRezultat NVARCHAR(20) NULL,
 NoviRezultat NVARCHAR(20) NULL,
 DatumAkcije DATETIME NOT NULL CONSTRAINT DF_UD_Datum DEFAULT GETDATE(),
 Korisnik NVARCHAR(128) NOT NULL CONSTRAINT DF_UD_Korisnik DEFAULT SUSER_SNAME()
);
GO
CREATE TABLE audit.CijeneUlaznicaDnevnik(
 DnevnikID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_CijeneDnevnik PRIMARY KEY,
 UlaznicaID INT NOT NULL,
 StaraCijena DECIMAL(10,2) NOT NULL,
 NovaCijena DECIMAL(10,2) NOT NULL,
 DatumPromjene DATETIME NOT NULL CONSTRAINT DF_CUD_Datum DEFAULT GETDATE(),
 Korisnik NVARCHAR(128) NOT NULL CONSTRAINT DF_CUD_Korisnik DEFAULT SUSER_SNAME()
);
GO

/* INDEKSI */
CREATE INDEX IX_Gradovi_Drzava ON sif.Gradovi(DrzavaID,Naziv);
CREATE INDEX IX_Takmicenja_SportSezona ON sport.Takmicenja(SportID,SezonaID);
CREATE INDEX IX_Sportisti_PrezimeIme ON sport.Sportisti(Prezime,Ime);
CREATE INDEX IX_Clanovi_Ekipa ON sport.ClanoviEkipa(EkipaID,DatumDo);
CREATE INDEX IX_Utakmice_Datum ON sport.Utakmice(DatumVrijeme);
CREATE INDEX IX_Utakmice_TakmicenjeStatus ON sport.Utakmice(TakmicenjeID,StatusUtakmice);
CREATE INDEX IX_Nastupi_Sportista ON sport.Nastupi(SportistaID);
CREATE INDEX IX_Ulaznice_Status ON prodaja.Ulaznice(StatusUlaznice,UtakmicaID);
CREATE INDEX IX_Placanja_Datum ON prodaja.Placanja(DatumPlacanja);
CREATE UNIQUE INDEX UX_Placanja_BrojTransakcije ON prodaja.Placanja(BrojTransakcije) WHERE BrojTransakcije IS NOT NULL;
GO

/* TESTNI PODACI */
INSERT INTO sif.Drzave(Naziv,ISOKod) VALUES
(N'Bosna i Hercegovina',N'BIH'),(N'Srbija',N'SRB'),(N'Hrvatska',N'HRV'),(N'Slovenija',N'SVN'),
(N'Crna Gora',N'MNE'),(N'Austrija',N'AUT'),(N'Italija',N'ITA'),(N'Njemačka',N'DEU');
GO
INSERT INTO sif.Gradovi(DrzavaID,Naziv,PostanskiBroj,BrojStanovnika) VALUES
(1,N'Banja Luka',N'78000',185000),(1,N'Sarajevo',N'71000',275000),(1,N'Mostar',N'88000',106000),
(1,N'Tuzla',N'75000',111000),(2,N'Beograd',N'11000',1370000),(2,N'Novi Sad',N'21000',370000),
(3,N'Zagreb',N'10000',770000),(3,N'Split',N'21000',160000),(4,N'Ljubljana',N'1000',295000),
(5,N'Podgorica',N'81000',190000),(6,N'Beč',N'1010',2000000),(7,N'Milano',N'20100',1360000);
GO
INSERT INTO sif.Sportovi(Naziv,TipSporta,MinimalanBrojIgraca,MaksimalanBrojIgraca) VALUES
(N'Fudbal',N'Ekipni',11,23),(N'Košarka',N'Ekipni',5,15),(N'Rukomet',N'Ekipni',7,16),(N'Odbojka',N'Ekipni',6,14),
(N'Tenis',N'Individualni',1,2),(N'Atletika',N'Individualni',1,1),(N'Plivanje',N'Individualni',1,1),(N'Stoni tenis',N'Individualni',1,2);
GO
INSERT INTO sport.Organizatori(Naziv,JIB,Email,Telefon,DatumOsnivanja) VALUES
(N'Sportski savez BiH',N'420000000001',N'kontakt@ssbih.example',N'033100100','1992-06-01'),
(N'Fudbalski savez RS',N'440000000002',N'info@fsrs.example',N'051200200','1992-09-05'),
(N'Košarkaški savez BiH',N'420000000003',N'office@ksbih.example',N'033300300','1950-01-01'),
(N'Atletski savez BiH',N'420000000004',N'info@asbih.example',N'033400400','1946-01-01'),
(N'Tenis asocijacija regiona',N'440000000005',N'kontakt@tar.example',N'051500500','2001-04-12');
GO
INSERT INTO sport.Sezone(Naziv,DatumPocetka,DatumZavrsetka,Aktivna) VALUES
(N'2024/2025','2024-08-01','2025-07-31',0),(N'2025/2026','2025-08-01','2026-07-31',0),
(N'2026/2027','2026-08-01','2027-07-31',1),(N'Kalendarska 2026','2026-01-01','2026-12-31',1);
GO
INSERT INTO sport.Takmicenja(SportID,OrganizatorID,SezonaID,Naziv,RangTakmicenja,DatumPocetka,DatumZavrsetka,StatusTakmicenja,NagradniFond) VALUES
(1,2,3,N'Premijer liga Republike Srpske',N'Državno','2026-08-15','2027-05-30',N'U toku',150000.00),
(2,3,3,N'Košarkaška liga BiH',N'Državno','2026-09-01','2027-05-15',N'Planirano',120000.00),
(3,1,3,N'Regionalni rukometni kup',N'Regionalno','2026-10-01','2026-10-15',N'Planirano',50000.00),
(4,1,3,N'Odbojkaški kup gradova',N'Regionalno','2026-11-01','2026-11-20',N'Planirano',35000.00),
(5,5,4,N'Banja Luka Open 2026',N'Međunarodno','2026-06-10','2026-06-17',N'Završeno',80000.00),
(6,4,4,N'Atletski miting BiH 2026',N'Međunarodno','2026-09-20','2026-09-21',N'Planirano',25000.00);
GO
INSERT INTO sport.Faze(TakmicenjeID,Naziv,RedniBroj,DatumPocetka,DatumZavrsetka) VALUES
(1,N'Ligaški dio',1,'2026-08-15','2027-04-30'),(1,N'Završnica',2,'2027-05-01','2027-05-30'),
(2,N'Regularna sezona',1,'2026-09-01','2027-04-15'),(2,N'Play-off',2,'2027-04-20','2027-05-15'),
(3,N'Grupna faza',1,'2026-10-01','2026-10-08'),(3,N'Eliminacije',2,'2026-10-09','2026-10-15'),
(4,N'Grupe',1,'2026-11-01','2026-11-10'),(4,N'Finalni turnir',2,'2026-11-15','2026-11-20'),
(5,N'Kvalifikacije',1,'2026-06-10','2026-06-11'),(5,N'Glavni žrijeb',2,'2026-06-12','2026-06-17'),
(6,N'Kvalifikacije',1,'2026-09-20','2026-09-20'),(6,N'Finala',2,'2026-09-21','2026-09-21');
GO
INSERT INTO sport.Ekipe(SportID,GradID,Naziv,SkraceniNaziv,DatumOsnivanja,Budzet) VALUES
(1,1,N'FK Borac Banja Luka',N'BOR','1926-07-04',3500000),(1,2,N'FK Sarajevo',N'SAR','1946-10-24',4200000),
(1,5,N'FK Crvena zvezda',N'CZV','1945-03-04',18000000),(1,7,N'GNK Zagreb',N'ZG','1911-04-26',9000000),
(2,1,N'KK Borac',N'KKB','1947-01-01',850000),(2,2,N'KK Bosna',N'BOS','1951-01-01',1100000),
(2,5,N'KK Beograd',N'KBG','1945-01-01',1600000),(2,7,N'KK Zagreb',N'KZG','1946-01-01',1400000),
(3,1,N'RK Borac',N'RKB','1950-01-01',700000),(3,3,N'RK Mostar',N'RKM','1952-01-01',500000),
(4,4,N'OK Tuzla',N'OKT','1960-01-01',350000),(4,6,N'OK Novi Sad',N'ONS','1958-01-01',600000);
GO
INSERT INTO sport.Sportisti(DrzavaID,Ime,Prezime,DatumRodjenja,Pol,Email,VisinaCm,TezinaKg) VALUES
(2,N'Marko',N'Marković','1988-02-02',N'M',N'sportista01@example.com',171.00,61.00),
(3,N'Nikola',N'Petrović','1989-03-03',N'M',N'sportista02@example.com',172.00,62.00),
(4,N'Stefan',N'Jovanović','1990-04-04',N'M',N'sportista03@example.com',173.00,63.00),
(5,N'Luka',N'Ilić','1991-05-05',N'M',N'sportista04@example.com',174.00,64.00),
(6,N'Aleksandar',N'Savić','1992-06-06',N'M',N'sportista05@example.com',175.00,65.00),
(7,N'Milan',N'Kovačević','1993-07-07',N'M',N'sportista06@example.com',176.00,66.00),
(8,N'Nemanja',N'Pavlović','1994-08-08',N'M',N'sportista07@example.com',177.00,67.00),
(1,N'Ognjen',N'Marić','1995-09-09',N'M',N'sportista08@example.com',178.00,68.00),
(2,N'Ivan',N'Nikolić','1996-10-10',N'M',N'sportista09@example.com',179.00,69.00),
(3,N'Petar',N'Popović','1997-11-11',N'M',N'sportista10@example.com',180.00,70.00),
(4,N'Bojan',N'Radovanović','1998-12-12',N'M',N'sportista11@example.com',181.00,71.00),
(5,N'Dejan',N'Tomić','1999-01-13',N'M',N'sportista12@example.com',182.00,72.00),
(6,N'Filip',N'Ristić','2000-02-14',N'M',N'sportista13@example.com',183.00,73.00),
(7,N'Vladimir',N'Đurić','2001-03-15',N'M',N'sportista14@example.com',184.00,74.00),
(8,N'Igor',N'Knežević','1987-04-16',N'M',N'sportista15@example.com',185.00,75.00),
(1,N'Miloš',N'Lazić','1988-05-17',N'M',N'sportista16@example.com',186.00,76.00),
(2,N'Ana',N'Matić','1989-06-18',N'Z',N'sportista17@example.com',187.00,77.00),
(3,N'Jelena',N'Babić','1990-07-19',N'Z',N'sportista18@example.com',188.00,78.00),
(4,N'Milica',N'Perić','1991-08-20',N'Z',N'sportista19@example.com',189.00,79.00),
(5,N'Sara',N'Šarić','1992-09-21',N'Z',N'sportista20@example.com',190.00,80.00),
(6,N'Tamara',N'Radić','1993-10-22',N'Z',N'sportista21@example.com',191.00,81.00),
(7,N'Marija',N'Vuković','1994-11-23',N'Z',N'sportista22@example.com',192.00,82.00),
(8,N'Ivana',N'Zorić','1995-12-24',N'Z',N'sportista23@example.com',193.00,83.00),
(1,N'Nina',N'Simić','1996-01-25',N'Z',N'sportista24@example.com',194.00,84.00),
(2,N'Kristina',N'Golubović','1997-02-26',N'Z',N'sportista25@example.com',195.00,85.00),
(3,N'Maja',N'Krunic','1998-03-27',N'Z',N'sportista26@example.com',196.00,86.00),
(4,N'Andrea',N'Bašić','1999-04-01',N'Z',N'sportista27@example.com',197.00,87.00),
(5,N'Sanja',N'Hadžić','2000-05-02',N'Z',N'sportista28@example.com',198.00,88.00),
(6,N'Lejla',N'Mujkić','2001-06-03',N'Z',N'sportista29@example.com',199.00,89.00),
(7,N'Emina',N'Omerović','1987-07-04',N'Z',N'sportista30@example.com',170.00,90.00),
(8,N'Tea',N'Grgić','1988-08-05',N'Z',N'sportista31@example.com',171.00,91.00),
(1,N'Una',N'Klarić','1989-09-06',N'Z',N'sportista32@example.com',172.00,92.00);
GO
INSERT INTO sport.ClanoviEkipa(EkipaID,SportistaID,BrojDresa,Pozicija,DatumOd,DatumDo) VALUES
(1,1,4,N'Igrač','2026-08-01',NULL),
(1,2,7,N'Igrač','2026-08-01',NULL),
(2,3,10,N'Igrač','2026-08-01',NULL),
(2,4,13,N'Igrač','2026-08-01',NULL),
(3,5,16,N'Igrač','2026-08-01',NULL),
(3,6,19,N'Igrač','2026-08-01',NULL),
(4,7,22,N'Igrač','2026-08-01',NULL),
(4,8,25,N'Igrač','2026-08-01',NULL),
(5,9,28,N'Igrač','2026-08-01',NULL),
(5,10,31,N'Igrač','2026-08-01',NULL),
(6,11,34,N'Igrač','2026-08-01',NULL),
(6,12,37,N'Igrač','2026-08-01',NULL),
(7,13,40,N'Igrač','2026-08-01',NULL),
(7,14,43,N'Igrač','2026-08-01',NULL),
(8,15,46,N'Igrač','2026-08-01',NULL),
(8,16,49,N'Igrač','2026-08-01',NULL),
(9,17,52,N'Standardni član','2026-08-01',NULL),
(9,18,55,N'Standardni član','2026-08-01',NULL),
(10,19,58,N'Standardni član','2026-08-01',NULL),
(10,20,61,N'Standardni član','2026-08-01',NULL),
(11,21,64,N'Standardni član','2026-08-01',NULL),
(11,22,67,N'Standardni član','2026-08-01',NULL),
(12,23,70,N'Standardni član','2026-08-01',NULL),
(12,24,73,N'Standardni član','2026-08-01',NULL);
GO
INSERT INTO sport.Objekti(GradID,Naziv,Adresa,Kapacitet,TipObjekta,DatumOtvaranja) VALUES
(1,N'Gradski stadion Banja Luka',N'Vladike Platona 6',10030,N'Stadion','1937-09-05'),
(1,N'SD Borik',N'Aleja Svetog Save 48',3000,N'Sportska dvorana','1974-04-20'),
(2,N'Stadion Koševo',N'Patriotske lige 35',34500,N'Stadion','1947-01-01'),
(2,N'Skenderija',N'Terezija bb',6500,N'Sportska dvorana','1969-11-29'),
(3,N'Dvorana Mostar',N'Kneza Višeslava bb',3500,N'Sportska dvorana','1995-01-01'),
(4,N'Mejdan',N'Bosne Srebrene bb',5000,N'Sportska dvorana','1984-10-02'),
(5,N'Beogradska arena',N'Bulevar Arsenija Čarnojevića 58',18386,N'Arena','2004-07-31'),
(6,N'SPENS',N'Sutjeska 2',11000,N'Sportski centar','1981-04-14'),
(7,N'Arena Zagreb',N'Ulica Vice Vukova 8',15200,N'Arena','2008-12-27'),
(1,N'Teniski centar Mladost',N'Park Mladen Stojanović bb',2500,N'Teniski centar','2002-05-01');
GO
INSERT INTO sport.Sudije(DrzavaID,Ime,Prezime,BrojLicence,DatumLicence,Kategorija) VALUES
(1,N'Damir',N'Kovač',N'LIC-001','2018-01-15',N'Međunarodna'),(2,N'Miloš',N'Janković',N'LIC-002','2017-03-20',N'Nacionalna'),
(3,N'Ivan',N'Horvat',N'LIC-003','2019-06-10',N'Međunarodna'),(1,N'Adnan',N'Hodžić',N'LIC-004','2020-02-12',N'Nacionalna'),
(4,N'Matej',N'Kranjc',N'LIC-005','2016-09-01',N'Međunarodna'),(5,N'Marko',N'Vukčević',N'LIC-006','2021-04-22',N'Regionalna'),
(6,N'Johann',N'Mayer',N'LIC-007','2015-05-11',N'Međunarodna'),(7,N'Luca',N'Rossi',N'LIC-008','2014-08-19',N'Međunarodna');
GO
INSERT INTO sport.Utakmice(TakmicenjeID,FazaID,ObjekatID,DomacaEkipaID,GostujucaEkipaID,SudijaID,DatumVrijeme,StatusUtakmice,RezultatDomaci,RezultatGosti,BrojGledalaca,Napomena) VALUES
(1,1,1,1,2,1,'2026-09-01T18:00:00',N'Završena',0,1,1200,NULL),
(1,1,3,2,3,2,'2026-09-02T19:00:00',N'Završena',2,0,1373,NULL),
(1,1,7,3,4,3,'2026-09-03T20:00:00',N'Završena',4,3,1546,NULL),
(1,1,9,4,1,4,'2026-09-04T18:00:00',N'Završena',1,2,1719,NULL),
(1,1,2,1,2,5,'2026-09-05T19:00:00',N'Završena',3,1,1892,NULL),
(1,1,4,2,3,6,'2026-09-06T20:00:00',N'Završena',0,0,2065,NULL),
(1,1,8,3,4,7,'2026-09-07T18:00:00',N'Završena',2,3,2238,NULL),
(1,1,9,4,1,8,'2026-09-08T19:00:00',N'Završena',4,2,2411,NULL),
(1,1,1,1,2,1,'2026-09-09T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(1,1,3,2,3,2,'2026-09-10T18:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,7,7,8,3,'2026-09-11T19:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,9,8,5,4,'2026-09-12T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,2,5,6,5,'2026-09-13T18:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,4,6,7,6,'2026-09-14T19:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,8,7,8,7,'2026-09-15T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,9,8,5,8,'2026-09-16T18:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,1,5,6,1,'2026-09-17T19:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(2,3,3,6,7,2,'2026-09-18T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,7,9,10,3,'2026-09-19T18:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,9,10,9,4,'2026-09-20T19:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,2,9,10,5,'2026-09-21T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,4,10,9,6,'2026-09-22T18:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,8,9,10,7,'2026-09-23T19:00:00',N'Zakazana',NULL,NULL,NULL,NULL),
(3,5,9,10,9,8,'2026-09-24T20:00:00',N'Zakazana',NULL,NULL,NULL,NULL);
GO
INSERT INTO sport.Nastupi(UtakmicaID,SportistaID,EkipaID,BrojPoena,BrojAsistencija,MinutaNastupa,Napomena) VALUES
(1,1,1,2.00,1,46,NULL),
(1,2,1,4.00,2,47,NULL),
(1,3,2,6.00,3,48,NULL),
(1,4,2,8.00,4,49,NULL),
(2,5,3,10.00,5,50,NULL),
(2,6,3,12.00,6,51,NULL),
(2,7,4,14.00,0,52,NULL),
(2,8,4,16.00,1,53,NULL),
(3,9,5,0.00,2,54,NULL),
(3,10,5,2.00,3,55,NULL),
(3,11,6,4.00,4,56,NULL),
(3,12,6,6.00,5,57,NULL),
(4,13,7,8.00,6,58,NULL),
(4,14,7,10.00,0,59,NULL),
(4,15,8,12.00,1,60,NULL),
(4,16,8,14.00,2,61,NULL),
(5,17,9,16.00,3,62,NULL),
(5,18,9,0.00,4,63,NULL),
(5,19,10,2.00,5,64,NULL),
(5,20,10,4.00,6,65,NULL),
(6,21,11,6.00,0,66,NULL),
(6,22,11,8.00,1,67,NULL),
(6,23,12,10.00,2,68,NULL),
(6,24,12,12.00,3,69,NULL),
(7,25,1,14.00,4,70,NULL),
(7,26,1,16.00,5,71,NULL),
(7,27,2,0.00,6,72,NULL),
(7,28,2,2.00,0,73,NULL),
(8,29,3,4.00,1,74,NULL),
(8,30,3,6.00,2,75,NULL),
(8,31,4,8.00,3,76,NULL),
(8,32,4,10.00,4,77,NULL);
GO
INSERT INTO sport.Kazne(UtakmicaID,SportistaID,EkipaID,VrstaKazne,MinutKazne,NovcaniIznos,Opis) VALUES
(1,1,1,N'Žuti karton',34,0,N'Nesportski prekršaj'),(2,3,2,N'Žuti karton',67,0,N'Prigovor sudiji'),
(3,5,3,N'Crveni karton',82,250.00,N'Grub prekršaj'),(4,NULL,4,N'Timska kazna',NULL,500.00,N'Kašnjenje na početak'),
(5,9,5,N'Tehnička greška',22,100.00,N'Nesportsko ponašanje'),(6,11,6,N'Lična greška',15,0,N'Peta lična greška');
GO
INSERT INTO prodaja.Sponzori(Naziv,KontaktEmail,Telefon) VALUES
(N'SportPlus',N'kontakt@sportplus.example',N'051111111'),(N'Balkan Telecom',N'sponzorstva@balkantel.example',N'033222222'),
(N'Energy Drink Adria',N'marketing@energyadria.example',N'011333333'),(N'Bank Europa',N'promo@bankeuropa.example',N'01 444 444'),
(N'Auto Regional',N'info@autoregional.example',N'051555555'),(N'Tech Solutions',N'office@techsolutions.example',N'051666666');
GO
INSERT INTO prodaja.TakmicenjeSponzori(TakmicenjeID,SponzorID,Iznos,DatumUgovora) VALUES
(1,1,40000,'2026-07-01'),(1,2,60000,'2026-07-03'),(2,2,45000,'2026-07-10'),(2,3,30000,'2026-07-11'),
(3,4,25000,'2026-08-01'),(4,5,18000,'2026-08-05'),(5,1,20000,'2026-04-01'),(5,6,35000,'2026-04-05'),(6,3,15000,'2026-08-10');
GO
INSERT INTO prodaja.Ulaznice(UtakmicaID,Sektor,RedBroj,SjedisteBroj,Cijena,DatumProdaje,StatusUlaznice,KupacEmail) VALUES
(1,N'B',N'2',2,15.00,'2026-08-02T11:00:00',N'Prodata',N'kupac01@example.com'),
(2,N'C',N'3',3,20.00,'2026-08-03T12:00:00',N'Prodata',N'kupac02@example.com'),
(3,N'A',N'4',4,25.00,'2026-08-04T13:00:00',N'Prodata',N'kupac03@example.com'),
(4,N'B',N'5',5,10.00,'2026-08-05T14:00:00',N'Prodata',N'kupac04@example.com'),
(5,N'C',N'6',6,15.00,'2026-08-06T15:00:00',N'Prodata',N'kupac05@example.com'),
(6,N'A',N'7',7,20.00,'2026-08-07T16:00:00',N'Prodata',N'kupac06@example.com'),
(7,N'B',N'8',8,25.00,'2026-08-08T17:00:00',N'Prodata',N'kupac07@example.com'),
(8,N'C',N'9',9,10.00,'2026-08-09T18:00:00',N'Prodata',N'kupac08@example.com'),
(9,N'A',N'10',10,15.00,'2026-08-10T19:00:00',N'Prodata',N'kupac09@example.com'),
(10,N'B',N'1',11,20.00,'2026-08-11T10:00:00',N'Prodata',N'kupac10@example.com'),
(11,N'C',N'2',12,25.00,'2026-08-12T11:00:00',N'Prodata',N'kupac11@example.com'),
(12,N'A',N'3',13,10.00,'2026-08-13T12:00:00',N'Prodata',N'kupac12@example.com'),
(1,N'B',N'4',14,15.00,'2026-08-14T13:00:00',N'Prodata',N'kupac13@example.com'),
(2,N'C',N'5',15,20.00,'2026-08-15T14:00:00',N'Prodata',N'kupac14@example.com'),
(3,N'A',N'6',16,25.00,'2026-08-16T15:00:00',N'Prodata',N'kupac15@example.com'),
(4,N'B',N'7',17,10.00,'2026-08-17T16:00:00',N'Prodata',N'kupac16@example.com'),
(5,N'C',N'8',18,15.00,'2026-08-18T17:00:00',N'Prodata',N'kupac17@example.com'),
(6,N'A',N'9',19,20.00,'2026-08-19T18:00:00',N'Prodata',N'kupac18@example.com'),
(7,N'B',N'10',20,25.00,'2026-08-20T19:00:00',N'Prodata',N'kupac19@example.com'),
(8,N'C',N'1',21,10.00,'2026-08-21T10:00:00',N'Prodata',N'kupac20@example.com'),
(9,N'A',N'2',22,15.00,'2026-08-22T11:00:00',N'Prodata',N'kupac21@example.com'),
(10,N'B',N'3',23,20.00,'2026-08-23T12:00:00',N'Prodata',N'kupac22@example.com'),
(11,N'C',N'4',24,25.00,'2026-08-24T13:00:00',N'Prodata',N'kupac23@example.com'),
(12,N'A',N'5',25,10.00,'2026-08-25T14:00:00',N'Prodata',N'kupac24@example.com'),
(1,N'B',N'6',26,15.00,'2026-08-26T15:00:00',N'Prodata',N'kupac25@example.com'),
(2,N'C',N'7',27,20.00,'2026-08-27T16:00:00',N'Prodata',N'kupac26@example.com'),
(3,N'A',N'8',28,25.00,'2026-08-28T17:00:00',N'Prodata',N'kupac27@example.com'),
(4,N'B',N'9',29,10.00,'2026-08-01T18:00:00',N'Prodata',N'kupac28@example.com'),
(5,N'C',N'10',30,15.00,'2026-08-02T19:00:00',N'Prodata',N'kupac29@example.com'),
(6,N'A',N'1',1,20.00,'2026-08-03T10:00:00',N'Prodata',N'kupac30@example.com'),
(7,N'B',N'2',2,25.00,'2026-08-04T11:00:00',N'Prodata',N'kupac31@example.com'),
(8,N'C',N'3',3,10.00,'2026-08-05T12:00:00',N'Prodata',N'kupac32@example.com'),
(9,N'A',N'4',4,15.00,'2026-08-06T13:00:00',N'Prodata',N'kupac33@example.com'),
(10,N'B',N'5',5,20.00,'2026-08-07T14:00:00',N'Prodata',N'kupac34@example.com'),
(11,N'C',N'6',6,25.00,'2026-08-08T15:00:00',N'Prodata',N'kupac35@example.com'),
(12,N'A',N'7',7,10.00,'2026-08-09T16:00:00',N'Prodata',N'kupac36@example.com'),
(1,N'B',N'8',8,15.00,'2026-08-10T17:00:00',N'Prodata',N'kupac37@example.com'),
(2,N'C',N'9',9,20.00,'2026-08-11T18:00:00',N'Prodata',N'kupac38@example.com'),
(3,N'A',N'10',10,25.00,'2026-08-12T19:00:00',N'Prodata',N'kupac39@example.com'),
(4,N'B',N'1',11,10.00,'2026-08-13T10:00:00',N'Prodata',N'kupac40@example.com'),
(5,N'C',N'2',12,15.00,'2026-08-14T11:00:00',N'Prodata',N'kupac41@example.com'),
(6,N'A',N'3',13,20.00,'2026-08-15T12:00:00',N'Prodata',N'kupac42@example.com'),
(7,N'B',N'4',14,25.00,'2026-08-16T13:00:00',N'Prodata',N'kupac43@example.com'),
(8,N'C',N'5',15,10.00,'2026-08-17T14:00:00',N'Prodata',N'kupac44@example.com'),
(9,N'A',N'6',16,15.00,'2026-08-18T15:00:00',N'Prodata',N'kupac45@example.com'),
(10,N'B',N'7',17,20.00,NULL,N'Slobodna',NULL),
(11,N'C',N'8',18,25.00,NULL,N'Slobodna',NULL),
(12,N'A',N'9',19,10.00,NULL,N'Slobodna',NULL),
(1,N'B',N'10',20,15.00,NULL,N'Slobodna',NULL),
(2,N'C',N'1',21,20.00,NULL,N'Slobodna',NULL),
(3,N'A',N'2',22,25.00,NULL,N'Slobodna',NULL),
(4,N'B',N'3',23,10.00,NULL,N'Slobodna',NULL),
(5,N'C',N'4',24,15.00,NULL,N'Slobodna',NULL),
(6,N'A',N'5',25,20.00,NULL,N'Slobodna',NULL),
(7,N'B',N'6',26,25.00,NULL,N'Slobodna',NULL),
(8,N'C',N'7',27,10.00,NULL,N'Slobodna',NULL),
(9,N'A',N'8',28,15.00,NULL,N'Slobodna',NULL),
(10,N'B',N'9',29,20.00,NULL,N'Slobodna',NULL),
(11,N'C',N'10',30,25.00,NULL,N'Slobodna',NULL),
(12,N'A',N'1',1,10.00,NULL,N'Slobodna',NULL);
GO
INSERT INTO prodaja.Placanja(UlaznicaID,DatumPlacanja,Iznos,NacinPlacanja,StatusPlacanja,BrojTransakcije) VALUES
(1,'2026-08-02T12:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00001'),
(2,'2026-08-03T13:00:00',20.00,N'Online',N'Placeno',N'TXN-00002'),
(3,'2026-08-04T14:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00003'),
(4,'2026-08-05T15:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(5,'2026-08-06T16:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00005'),
(6,'2026-08-07T17:00:00',20.00,N'Online',N'Placeno',N'TXN-00006'),
(7,'2026-08-08T18:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00007'),
(8,'2026-08-09T19:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(9,'2026-08-10T11:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00009'),
(10,'2026-08-11T12:00:00',20.00,N'Online',N'Placeno',N'TXN-00010'),
(11,'2026-08-12T13:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00011'),
(12,'2026-08-13T14:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(13,'2026-08-14T15:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00013'),
(14,'2026-08-15T16:00:00',20.00,N'Online',N'Placeno',N'TXN-00014'),
(15,'2026-08-16T17:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00015'),
(16,'2026-08-17T18:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(17,'2026-08-18T19:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00017'),
(18,'2026-08-19T11:00:00',20.00,N'Online',N'Placeno',N'TXN-00018'),
(19,'2026-08-20T12:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00019'),
(20,'2026-08-21T13:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(21,'2026-08-22T14:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00021'),
(22,'2026-08-23T15:00:00',20.00,N'Online',N'Placeno',N'TXN-00022'),
(23,'2026-08-24T16:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00023'),
(24,'2026-08-25T17:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(25,'2026-08-26T18:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00025'),
(26,'2026-08-27T19:00:00',20.00,N'Online',N'Placeno',N'TXN-00026'),
(27,'2026-08-28T11:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00027'),
(28,'2026-08-01T12:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(29,'2026-08-02T13:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00029'),
(30,'2026-08-03T14:00:00',20.00,N'Online',N'Placeno',N'TXN-00030'),
(31,'2026-08-04T15:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00031'),
(32,'2026-08-05T16:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(33,'2026-08-06T17:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00033'),
(34,'2026-08-07T18:00:00',20.00,N'Online',N'Placeno',N'TXN-00034'),
(35,'2026-08-08T19:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00035'),
(36,'2026-08-09T11:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(37,'2026-08-10T12:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00037'),
(38,'2026-08-11T13:00:00',20.00,N'Online',N'Placeno',N'TXN-00038'),
(39,'2026-08-12T14:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00039'),
(40,'2026-08-13T15:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(41,'2026-08-14T16:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00041'),
(42,'2026-08-15T17:00:00',20.00,N'Online',N'Placeno',N'TXN-00042'),
(43,'2026-08-16T18:00:00',25.00,N'Vaucer',N'Placeno',N'TXN-00043'),
(44,'2026-08-17T19:00:00',10.00,N'Gotovina',N'Placeno',NULL),
(45,'2026-08-18T11:00:00',15.00,N'Kartica',N'Placeno',N'TXN-00045');
GO

/* POGLEDI */
CREATE VIEW izvjestaji.vw_RasporedUtakmica AS
SELECT u.UtakmicaID,t.Naziv AS Takmicenje,f.Naziv AS Faza,u.DatumVrijeme,
       ISNULL(ed.Naziv,N'Individualni nastup') AS Domacin,
       ISNULL(eg.Naziv,N'Individualni nastup') AS Gost,
       o.Naziv AS Objekat,g.Naziv AS Grad,
       s.Ime+N' '+s.Prezime AS Sudija,u.StatusUtakmice,
       CASE WHEN u.RezultatDomaci IS NULL THEN N'-'
            ELSE CAST(u.RezultatDomaci AS NVARCHAR(10))+N':'+CAST(u.RezultatGosti AS NVARCHAR(10)) END AS Rezultat
FROM sport.Utakmice u
INNER JOIN sport.Takmicenja t ON u.TakmicenjeID=t.TakmicenjeID
LEFT JOIN sport.Faze f ON u.FazaID=f.FazaID
LEFT JOIN sport.Ekipe ed ON u.DomacaEkipaID=ed.EkipaID
LEFT JOIN sport.Ekipe eg ON u.GostujucaEkipaID=eg.EkipaID
INNER JOIN sport.Objekti o ON u.ObjekatID=o.ObjekatID
INNER JOIN sif.Gradovi g ON o.GradID=g.GradID
LEFT JOIN sport.Sudije s ON u.SudijaID=s.SudijaID;
GO
CREATE VIEW izvjestaji.vw_ProdajaPoUtakmici AS
SELECT u.UtakmicaID,t.Naziv AS Takmicenje,u.DatumVrijeme,
       COUNT(ul.UlaznicaID) AS KreiranoUlaznica,
       SUM(CASE WHEN ul.StatusUlaznice=N'Prodata' THEN 1 ELSE 0 END) AS ProdatoUlaznica,
       ISNULL(SUM(CASE WHEN p.StatusPlacanja=N'Placeno' THEN p.Iznos ELSE 0 END),0) AS Prihod
FROM sport.Utakmice u
INNER JOIN sport.Takmicenja t ON u.TakmicenjeID=t.TakmicenjeID
LEFT JOIN prodaja.Ulaznice ul ON u.UtakmicaID=ul.UtakmicaID
LEFT JOIN prodaja.Placanja p ON ul.UlaznicaID=p.UlaznicaID
GROUP BY u.UtakmicaID,t.Naziv,u.DatumVrijeme;
GO
CREATE VIEW izvjestaji.vw_StatistikaSportista AS
SELECT sp.SportistaID,sp.Ime,sp.Prezime,COUNT(n.NastupID) AS BrojNastupa,
       ISNULL(SUM(n.BrojPoena),0) AS UkupnoPoena,
       ISNULL(AVG(n.BrojPoena),0) AS ProsjekPoena,
       ISNULL(SUM(n.BrojAsistencija),0) AS UkupnoAsistencija
FROM sport.Sportisti sp LEFT JOIN sport.Nastupi n ON sp.SportistaID=n.SportistaID
GROUP BY sp.SportistaID,sp.Ime,sp.Prezime;
GO

/* UDF FUNKCIJE */
CREATE FUNCTION sport.fn_Starost(@DatumRodjenja DATE)
RETURNS INT
AS
BEGIN
 DECLARE @Starost INT;
 SET @Starost=DATEDIFF(YEAR,@DatumRodjenja,GETDATE())-
 CASE WHEN DATEADD(YEAR,DATEDIFF(YEAR,@DatumRodjenja,GETDATE()),@DatumRodjenja)>GETDATE() THEN 1 ELSE 0 END;
 RETURN @Starost;
END;
GO
CREATE FUNCTION prodaja.fn_PrihodUtakmice(@UtakmicaID INT)
RETURNS DECIMAL(14,2)
AS
BEGIN
 DECLARE @Prihod DECIMAL(14,2);
 SELECT @Prihod=ISNULL(SUM(p.Iznos),0)
 FROM prodaja.Ulaznice u INNER JOIN prodaja.Placanja p ON u.UlaznicaID=p.UlaznicaID
 WHERE u.UtakmicaID=@UtakmicaID AND p.StatusPlacanja=N'Placeno';
 RETURN ISNULL(@Prihod,0);
END;
GO
CREATE FUNCTION sport.fn_UtakmiceEkipe(@EkipaID INT)
RETURNS TABLE
AS RETURN(
 SELECT u.UtakmicaID,u.DatumVrijeme,u.StatusUtakmice,
        d.Naziv AS Domacin,g.Naziv AS Gost,u.RezultatDomaci,u.RezultatGosti
 FROM sport.Utakmice u
 LEFT JOIN sport.Ekipe d ON u.DomacaEkipaID=d.EkipaID
 LEFT JOIN sport.Ekipe g ON u.GostujucaEkipaID=g.EkipaID
 WHERE u.DomacaEkipaID=@EkipaID OR u.GostujucaEkipaID=@EkipaID
);
GO

/* PROCEDURE */
CREATE PROCEDURE sport.sp_EvidentirajRezultat
 @UtakmicaID INT,@Domaci INT,@Gosti INT,@BrojGledalaca INT=NULL
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  BEGIN TRANSACTION;
  IF NOT EXISTS(SELECT 1 FROM sport.Utakmice WITH(UPDLOCK,HOLDLOCK) WHERE UtakmicaID=@UtakmicaID)
   RAISERROR(N'Utakmica ne postoji.',16,1);
  IF @Domaci<0 OR @Gosti<0 RAISERROR(N'Rezultat ne može biti negativan.',16,1);
  IF @BrojGledalaca IS NOT NULL AND @BrojGledalaca<0 RAISERROR(N'Broj gledalaca nije ispravan.',16,1);
  UPDATE sport.Utakmice SET RezultatDomaci=@Domaci,RezultatGosti=@Gosti,
         BrojGledalaca=@BrojGledalaca,StatusUtakmice=N'Završena'
  WHERE UtakmicaID=@UtakmicaID;
  COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
  DECLARE @P NVARCHAR(4000); SET @P=ERROR_MESSAGE(); RAISERROR(@P,16,1);
 END CATCH
END;
GO
CREATE PROCEDURE prodaja.sp_ProdajUlaznicu
 @UlaznicaID INT,@KupacEmail NVARCHAR(100),@NacinPlacanja NVARCHAR(20)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @Cijena DECIMAL(10,2);
  SELECT @Cijena=Cijena FROM prodaja.Ulaznice WITH(UPDLOCK,HOLDLOCK)
  WHERE UlaznicaID=@UlaznicaID AND StatusUlaznice=N'Slobodna';
  IF @Cijena IS NULL RAISERROR(N'Ulaznica ne postoji ili nije slobodna.',16,1);
  IF @NacinPlacanja NOT IN(N'Gotovina',N'Kartica',N'Online',N'Vaucer') RAISERROR(N'Nepodržan način plaćanja.',16,1);
  UPDATE prodaja.Ulaznice SET StatusUlaznice=N'Prodata',DatumProdaje=GETDATE(),KupacEmail=@KupacEmail
  WHERE UlaznicaID=@UlaznicaID;
  INSERT INTO prodaja.Placanja(UlaznicaID,Iznos,NacinPlacanja,StatusPlacanja,BrojTransakcije)
  VALUES(@UlaznicaID,@Cijena,@NacinPlacanja,N'Placeno',
         CASE WHEN @NacinPlacanja=N'Gotovina' THEN NULL ELSE N'TXN-'+REPLACE(CONVERT(NVARCHAR(36),NEWID()),N'-',N'') END);
  SELECT @UlaznicaID AS ProdataUlaznicaID,@Cijena AS PlaceniIznos;
  COMMIT TRANSACTION;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
  DECLARE @P NVARCHAR(4000); SET @P=ERROR_MESSAGE(); RAISERROR(@P,16,1);
 END CATCH
END;
GO
CREATE PROCEDURE izvjestaji.sp_RasporedZaPeriod @DatumOd DATETIME,@DatumDo DATETIME
AS
BEGIN
 SET NOCOUNT ON;
 SELECT * FROM izvjestaji.vw_RasporedUtakmica
 WHERE DatumVrijeme>=@DatumOd AND DatumVrijeme<@DatumDo ORDER BY DatumVrijeme;
END;
GO
CREATE PROCEDURE izvjestaji.sp_PrihodPoTakmicenju @DatumOd DATETIME,@DatumDo DATETIME
AS
BEGIN
 SET NOCOUNT ON;
 SELECT t.Naziv,COUNT(DISTINCT u.UtakmicaID) AS BrojUtakmica,
        COUNT(DISTINCT ul.UlaznicaID) AS BrojProdatihUlaznica,
        ISNULL(SUM(p.Iznos),0) AS Prihod
 FROM sport.Takmicenja t
 LEFT JOIN sport.Utakmice u ON t.TakmicenjeID=u.TakmicenjeID
 LEFT JOIN prodaja.Ulaznice ul ON u.UtakmicaID=ul.UtakmicaID AND ul.StatusUlaznice=N'Prodata'
 LEFT JOIN prodaja.Placanja p ON ul.UlaznicaID=p.UlaznicaID AND p.StatusPlacanja=N'Placeno'
      AND p.DatumPlacanja>=@DatumOd AND p.DatumPlacanja<@DatumDo
 GROUP BY t.Naziv ORDER BY Prihod DESC;
END;
GO

/* TRIGERI */
CREATE TRIGGER sport.trg_Utakmice_Dnevnik ON sport.Utakmice
AFTER INSERT,UPDATE,DELETE AS
BEGIN
 SET NOCOUNT ON;
 INSERT INTO audit.UtakmiceDnevnik(UtakmicaID,Akcija,StariStatus,NoviStatus,StariRezultat,NoviRezultat)
 SELECT ISNULL(i.UtakmicaID,d.UtakmicaID),
 CASE WHEN d.UtakmicaID IS NULL THEN N'INSERT' WHEN i.UtakmicaID IS NULL THEN N'DELETE' ELSE N'UPDATE' END,
 d.StatusUtakmice,i.StatusUtakmice,
 CASE WHEN d.RezultatDomaci IS NULL THEN NULL ELSE CAST(d.RezultatDomaci AS NVARCHAR(10))+N':'+CAST(d.RezultatGosti AS NVARCHAR(10)) END,
 CASE WHEN i.RezultatDomaci IS NULL THEN NULL ELSE CAST(i.RezultatDomaci AS NVARCHAR(10))+N':'+CAST(i.RezultatGosti AS NVARCHAR(10)) END
 FROM inserted i FULL OUTER JOIN deleted d ON i.UtakmicaID=d.UtakmicaID;
END;
GO
CREATE TRIGGER prodaja.trg_Ulaznice_CijenaDnevnik ON prodaja.Ulaznice
AFTER UPDATE AS
BEGIN
 SET NOCOUNT ON;
 INSERT INTO audit.CijeneUlaznicaDnevnik(UlaznicaID,StaraCijena,NovaCijena)
 SELECT i.UlaznicaID,d.Cijena,i.Cijena FROM inserted i INNER JOIN deleted d ON i.UlaznicaID=d.UlaznicaID
 WHERE i.Cijena<>d.Cijena;
END;
GO
CREATE TRIGGER sport.trg_Utakmice_Kapacitet ON sport.Utakmice
AFTER INSERT,UPDATE AS
BEGIN
 SET NOCOUNT ON;
 IF EXISTS(SELECT 1 FROM inserted i INNER JOIN sport.Objekti o ON i.ObjekatID=o.ObjekatID
           WHERE i.BrojGledalaca IS NOT NULL AND i.BrojGledalaca>o.Kapacitet)
 BEGIN RAISERROR(N'Broj gledalaca prelazi kapacitet objekta.',16,1); ROLLBACK TRANSACTION; RETURN; END;
END;
GO

/* DDL I DML */
ALTER TABLE sport.Sportisti ADD PrimaObavijesti BIT NOT NULL
 CONSTRAINT DF_Sportisti_PrimaObavijesti DEFAULT 1;
GO
INSERT INTO sport.Sportisti(DrzavaID,Ime,Prezime,DatumRodjenja,Pol,Email)
VALUES(1,N'Test',N'Sportista','2000-01-01',N'M',N'test.sportista@example.com');
UPDATE sport.Sportisti SET PrimaObavijesti=0 WHERE Email=N'test.sportista@example.com';
BEGIN TRANSACTION;
DELETE FROM sport.Sportisti WHERE Email=N'test.sportista@example.com';
ROLLBACK TRANSACTION;
GO

/* FUNKCIJE U UPITIMA */
SELECT SportistaID,UPPER(Ime) AS ImeVelikim,LOWER(Prezime) AS PrezimeMalim,
 LEN(Ime+Prezime) AS BrojZnakova,LEFT(Prezime,3) AS PrvaTri,
 sport.fn_Starost(DatumRodjenja) AS Starost,
 DATEDIFF(DAY,DatumRegistracije,GETDATE()) AS DanaOdRegistracije,
 ISNULL(Email,N'Nema email') AS EmailPrikaz
FROM sport.Sportisti;
SELECT COUNT(*) AS BrojSportista,MIN(DatumRodjenja) AS NajstarijiDatum,
 MAX(DatumRodjenja) AS NajmladjiDatum,AVG(VisinaCm) AS ProsjecnaVisina FROM sport.Sportisti;
SELECT UlaznicaID,Cijena,ROUND(Cijena*1.17,2) AS CijenaSaPDV,
 CEILING(Cijena) AS Navise,FLOOR(Cijena) AS Nanize,
 CASE WHEN Cijena<15 THEN N'Povoljna' WHEN Cijena<=20 THEN N'Srednja' ELSE N'Premium' END AS Kategorija
FROM prodaja.Ulaznice;
GO

/* JOIN SVE VARIJANTE */
SELECT u.UtakmicaID,t.Naziv,u.DatumVrijeme FROM sport.Utakmice u
INNER JOIN sport.Takmicenja t ON u.TakmicenjeID=t.TakmicenjeID;
SELECT s.SportistaID,s.Ime,s.Prezime,COUNT(n.NastupID) AS BrojNastupa
FROM sport.Sportisti s LEFT JOIN sport.Nastupi n ON s.SportistaID=n.SportistaID
GROUP BY s.SportistaID,s.Ime,s.Prezime;
SELECT u.UtakmicaID,ul.UlaznicaID,ul.StatusUlaznice FROM prodaja.Ulaznice ul
RIGHT JOIN sport.Utakmice u ON ul.UtakmicaID=u.UtakmicaID;
SELECT e.Naziv,n.NastupID,n.BrojPoena FROM sport.Ekipe e
FULL OUTER JOIN sport.Nastupi n ON e.EkipaID=n.EkipaID;
SELECT s.Naziv AS Sport,se.Naziv AS Sezona FROM sif.Sportovi s CROSS JOIN sport.Sezone se;
SELECT e1.Naziv AS Ekipa1,e2.Naziv AS Ekipa2,e1.SportID
FROM sport.Ekipe e1 INNER JOIN sport.Ekipe e2 ON e1.SportID=e2.SportID AND e1.EkipaID<e2.EkipaID;
GO

/* PODUPITI */
SELECT s.Ime,s.Prezime,SUM(n.BrojPoena) AS Poeni FROM sport.Sportisti s
INNER JOIN sport.Nastupi n ON s.SportistaID=n.SportistaID
GROUP BY s.Ime,s.Prezime
HAVING SUM(n.BrojPoena)>(SELECT AVG(x.Ukupno) FROM(SELECT SUM(BrojPoena) AS Ukupno FROM sport.Nastupi GROUP BY SportistaID)x);
SELECT u.UtakmicaID,u.DatumVrijeme FROM sport.Utakmice u
WHERE NOT EXISTS(SELECT 1 FROM prodaja.Ulaznice ul WHERE ul.UtakmicaID=u.UtakmicaID AND ul.StatusUlaznice=N'Prodata');
SELECT Naziv,NagradniFond FROM sport.Takmicenja
WHERE NagradniFond>(SELECT AVG(NagradniFond) FROM sport.Takmicenja);
SELECT e.Naziv,(SELECT COUNT(*) FROM sport.ClanoviEkipa c WHERE c.EkipaID=e.EkipaID AND c.DatumDo IS NULL) AS AktivniClanovi
FROM sport.Ekipe e;
GO

/* SKUPOVNI OPERATORI */
SELECT Ime,Prezime,N'Sportista' AS Uloga FROM sport.Sportisti
UNION SELECT Ime,Prezime,N'Sudija' FROM sport.Sudije;
SELECT Naziv,N'Ekipa' AS Tip FROM sport.Ekipe
UNION ALL SELECT Naziv,N'Organizator' FROM sport.Organizatori;
SELECT DrzavaID FROM sport.Sportisti INTERSECT SELECT DrzavaID FROM sport.Sudije;
SELECT DrzavaID FROM sport.Sportisti EXCEPT SELECT DrzavaID FROM sport.Sudije;
GO

/* DODATNI UPITI */
SELECT TOP 5 e.Naziv,COUNT(*) AS BrojUtakmica
FROM sport.Ekipe e INNER JOIN sport.Utakmice u ON e.EkipaID=u.DomacaEkipaID OR e.EkipaID=u.GostujucaEkipaID
GROUP BY e.Naziv ORDER BY BrojUtakmica DESC;
SELECT u.UtakmicaID,o.Kapacitet,ISNULL(u.BrojGledalaca,0) AS Gledalaca,
 CAST(ISNULL(u.BrojGledalaca,0)*100.0/o.Kapacitet AS DECIMAL(6,2)) AS PopunjenostProcenat
FROM sport.Utakmice u INNER JOIN sport.Objekti o ON u.ObjekatID=o.ObjekatID;
SELECT * FROM izvjestaji.vw_RasporedUtakmica;
SELECT * FROM izvjestaji.vw_ProdajaPoUtakmici;
SELECT sport.fn_Starost('2000-01-01') AS Starost;
SELECT prodaja.fn_PrihodUtakmice(1) AS Prihod;
SELECT * FROM sport.fn_UtakmiceEkipe(1);
EXEC izvjestaji.sp_RasporedZaPeriod '2026-09-01','2026-10-01';
EXEC izvjestaji.sp_PrihodPoTakmicenju '2026-08-01','2026-09-01';
GO

/* USER, ROLE I BEZBJEDNOST */
CREATE ROLE db_sportski_operater;
CREATE ROLE db_sportski_izvjestaji;
GO
GRANT SELECT,INSERT,UPDATE ON SCHEMA::sport TO db_sportski_operater;
DENY DELETE ON SCHEMA::sport TO db_sportski_operater;
GRANT SELECT ON SCHEMA::sif TO db_sportski_operater;
GRANT SELECT ON SCHEMA::izvjestaji TO db_sportski_izvjestaji;
GRANT EXECUTE ON SCHEMA::izvjestaji TO db_sportski_izvjestaji;
GO
CREATE USER SportskiOperater WITHOUT LOGIN;
CREATE USER SportskiAnaliticar WITHOUT LOGIN;
EXEC sp_addrolemember N'db_sportski_operater',N'SportskiOperater';
EXEC sp_addrolemember N'db_sportski_izvjestaji',N'SportskiAnaliticar';
GO

/* ETL PROCES : UVOZ SPORTISTA */
CREATE TABLE etl.StageSportisti(
 IzvorniID INT NOT NULL,Ime NVARCHAR(50),Prezime NVARCHAR(50),DatumRodjenja DATE,
 ISOKod NCHAR(3),Email NVARCHAR(100),VisinaCm DECIMAL(5,2),TezinaKg DECIMAL(5,2),Obradjen BIT NOT NULL DEFAULT 0
);
GO
INSERT INTO etl.StageSportisti(IzvorniID,Ime,Prezime,DatumRodjenja,ISOKod,Email,VisinaCm,TezinaKg) VALUES
(1001,N'Danilo',N'Jurić','1998-02-10',N'BIH',N'danilo.juric@example.com',184,79),
(1002,N'Petra',N'Novak','2001-07-19',N'HRV',N'petra.novak@example.com',177,65),
(1003,N'Leon',N'Kovač','1999-11-03',N'SVN',N'leon.kovac@example.com',181,76);
GO
CREATE PROCEDURE etl.sp_UveziSportiste AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRANSACTION;
 INSERT INTO sport.Sportisti(DrzavaID,Ime,Prezime,DatumRodjenja,Email,VisinaCm,TezinaKg)
 SELECT d.DrzavaID,LTRIM(RTRIM(s.Ime)),LTRIM(RTRIM(s.Prezime)),s.DatumRodjenja,LOWER(s.Email),s.VisinaCm,s.TezinaKg
 FROM etl.StageSportisti s INNER JOIN sif.Drzave d ON s.ISOKod=d.ISOKod
 WHERE s.Obradjen=0 AND NOT EXISTS(SELECT 1 FROM sport.Sportisti x WHERE x.Email=LOWER(s.Email));
 UPDATE etl.StageSportisti SET Obradjen=1 WHERE Obradjen=0;
 COMMIT TRANSACTION;
END;
GO

/* ETL PROCES 2: DNEVNI PRIHOD */
CREATE TABLE izvjestaji.DnevniPrihod(
 Datum DATE NOT NULL,TakmicenjeID INT NOT NULL,BrojUlaznica INT NOT NULL,UkupanPrihod DECIMAL(14,2) NOT NULL,
 DatumUcitavanja DATETIME NOT NULL DEFAULT GETDATE(),CONSTRAINT PK_DnevniPrihod PRIMARY KEY(Datum,TakmicenjeID)
);
GO
CREATE PROCEDURE etl.sp_UcitajDnevniPrihod @Datum DATE AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 BEGIN TRANSACTION;
 DELETE FROM izvjestaji.DnevniPrihod WHERE Datum=@Datum;
 INSERT INTO izvjestaji.DnevniPrihod(Datum,TakmicenjeID,BrojUlaznica,UkupanPrihod)
 SELECT @Datum,t.TakmicenjeID,COUNT(p.PlacanjeID),ISNULL(SUM(p.Iznos),0)
 FROM sport.Takmicenja t
 LEFT JOIN sport.Utakmice u ON t.TakmicenjeID=u.TakmicenjeID
 LEFT JOIN prodaja.Ulaznice ul ON u.UtakmicaID=ul.UtakmicaID
 LEFT JOIN prodaja.Placanja p ON ul.UlaznicaID=p.UlaznicaID AND p.StatusPlacanja=N'Placeno'
  AND p.DatumPlacanja>=@Datum AND p.DatumPlacanja<DATEADD(DAY,1,@Datum)
 GROUP BY t.TakmicenjeID;
 COMMIT TRANSACTION;
END;
GO




SELECT N'Sportovi' AS Tabela,COUNT(*) AS BrojRedova FROM sif.Sportovi
UNION ALL SELECT N'Sportisti',COUNT(*) FROM sport.Sportisti
UNION ALL SELECT N'Ekipe',COUNT(*) FROM sport.Ekipe
UNION ALL SELECT N'Utakmice',COUNT(*) FROM sport.Utakmice
UNION ALL SELECT N'Ulaznice',COUNT(*) FROM prodaja.Ulaznice
UNION ALL SELECT N'Placanja',COUNT(*) FROM prodaja.Placanja;
GO
PRINT N'Baza SportskaTakmicenja je uspjesno kreirana i popunjena.';
GO


BEGIN TRY
    SET IDENTITY_INSERT sif.Drzave ON;
    INSERT INTO sif.Drzave(DrzavaID,Naziv,ISOKod)
    VALUES(1,N'Test drzava',N'TST');
    SET IDENTITY_INSERT sif.Drzave OFF;
END TRY
BEGIN CATCH
    IF OBJECTPROPERTY(OBJECT_ID(N'sif.Drzave'),N'TableHasIdentity')=1
        SET IDENTITY_INSERT sif.Drzave OFF;
    SELECT N'Test integriteta entiteta' AS Test,ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;
GO
BEGIN TRY
    INSERT INTO sport.Takmicenja
    (SportID,OrganizatorID,SezonaID,Naziv,RangTakmicenja,DatumPocetka,DatumZavrsetka,StatusTakmicenja,NagradniFond)
    VALUES(1,1,3,N'Neispravno testno takmicenje',N'Lokalno','2026-10-01','2026-10-02',N'Planirano',-1);
END TRY
BEGIN CATCH
    SELECT N'Test domenskog integriteta' AS Test,ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;
GO
BEGIN TRY
    INSERT INTO sport.Ekipe(SportID,GradID,Naziv,SkraceniNaziv,DatumOsnivanja,Budzet)
    VALUES(999,1,N'Test ekipa sa pogresnim sportom',N'TESTFK','2020-01-01',1000);
END TRY
BEGIN CATCH
    SELECT N'Test referencijalnog integriteta' AS Test,ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;
GO
BEGIN TRANSACTION;
DECLARE @StariStatusTest NVARCHAR(20);
SELECT @StariStatusTest=StatusUtakmice FROM sport.Utakmice WHERE UtakmicaID=9;
UPDATE sport.Utakmice SET StatusUtakmice=N'U toku' WHERE UtakmicaID=9;
SELECT TOP 1 * FROM audit.UtakmiceDnevnik
WHERE UtakmicaID=9 ORDER BY DnevnikID DESC;
ROLLBACK TRANSACTION;
GO
BEGIN TRANSACTION;
UPDATE prodaja.Ulaznice SET Cijena=Cijena+5 WHERE UlaznicaID=1;
SELECT TOP 1 * FROM audit.CijeneUlaznicaDnevnik
WHERE UlaznicaID=1 ORDER BY DnevnikID DESC;
ROLLBACK TRANSACTION;
GO
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE sport.Utakmice SET BrojGledalaca=999999 WHERE UtakmicaID=1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    SELECT N'Test trigera kapaciteta' AS Test,ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;
GO
BEGIN TRANSACTION;
EXEC sport.sp_EvidentirajRezultat @UtakmicaID=9,@Domaci=2,@Gosti=1,@BrojGledalaca=2500;
SELECT UtakmicaID,StatusUtakmice,RezultatDomaci,RezultatGosti,BrojGledalaca
FROM sport.Utakmice WHERE UtakmicaID=9;
ROLLBACK TRANSACTION;
GO
BEGIN TRANSACTION;
EXEC prodaja.sp_ProdajUlaznicu
 @UlaznicaID=46,@KupacEmail=N'test.kupac@example.com',@NacinPlacanja=N'Kartica';
SELECT * FROM prodaja.Ulaznice WHERE UlaznicaID=46;
SELECT * FROM prodaja.Placanja WHERE UlaznicaID=46;
ROLLBACK TRANSACTION;
GO
SELECT TOP 10 * FROM izvjestaji.vw_RasporedUtakmica ORDER BY DatumVrijeme;
SELECT TOP 10 * FROM izvjestaji.vw_ProdajaPoUtakmici ORDER BY Prihod DESC;
SELECT TOP 10 * FROM izvjestaji.vw_StatistikaSportista ORDER BY UkupnoPoena DESC;
GO
SELECT sport.fn_Starost('2000-01-01') AS StarostSportiste;
SELECT prodaja.fn_PrihodUtakmice(1) AS PrihodPrveUtakmice;
SELECT * FROM sport.fn_UtakmiceEkipe(1) ORDER BY DatumVrijeme;
GO
SELECT N'Prije ETL-a' AS Faza,* FROM etl.StageSportisti ORDER BY IzvorniID;
EXEC etl.sp_UveziSportiste;
SELECT N'Poslije ETL-a' AS Faza,SportistaID,Ime,Prezime,Email,VisinaCm,TezinaKg
FROM sport.Sportisti
WHERE Email IN(N'danilo.juric@example.com',N'petra.novak@example.com',N'leon.kovac@example.com')
ORDER BY Email;
SELECT N'Staging nakon ETL-a' AS Faza,* FROM etl.StageSportisti ORDER BY IzvorniID;
GO
EXEC etl.sp_UcitajDnevniPrihod @Datum='2026-08-20';
SELECT * FROM izvjestaji.DnevniPrihod
WHERE Datum='2026-08-20' ORDER BY TakmicenjeID;
GO
EXECUTE AS USER=N'SportskiAnaliticar';
SELECT TOP 5 * FROM izvjestaji.vw_RasporedUtakmica;
REVERT;
GO
EXECUTE AS USER=N'SportskiOperater';
SELECT TOP 5 * FROM sport.Utakmice;
REVERT;
GO
BEGIN TRY
    EXECUTE AS USER=N'SportskiOperater';
    DELETE FROM sport.Kazne WHERE KaznaID=-1;
    REVERT;
END TRY
BEGIN CATCH
    IF USER_NAME()=N'SportskiOperater' REVERT;
    SELECT N'Test DENY DELETE' AS Test,ERROR_MESSAGE() AS OcekivanaGreska;
END CATCH;
GO
DECLARE @Prije INT,@Tokom INT,@Poslije INT;
SELECT @Prije=COUNT(*) FROM prodaja.Sponzori;
BEGIN TRANSACTION;
INSERT INTO prodaja.Sponzori(Naziv,KontaktEmail,Telefon)
VALUES(N'Privremeni testni sponzor',N'test@sponzor.example',N'000111222');
SELECT @Tokom=COUNT(*) FROM prodaja.Sponzori;
ROLLBACK TRANSACTION;
SELECT @Poslije=COUNT(*) FROM prodaja.Sponzori;
SELECT @Prije AS BrojPrije,@Tokom AS BrojTokom,@Poslije AS BrojPoslijeRollbacka;
GO
SELECT Ime,Prezime,N'Sportista' AS Uloga FROM sport.Sportisti
UNION
SELECT Ime,Prezime,N'Sudija' FROM sport.Sudije;
SELECT DrzavaID FROM sport.Sportisti
INTERSECT
SELECT DrzavaID FROM sport.Sudije;
SELECT DrzavaID FROM sport.Sportisti
EXCEPT
SELECT DrzavaID FROM sport.Sudije;
GO
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT SportistaID,Ime,Prezime FROM sport.Sportisti
WHERE Prezime=N'Pavlovic' OR Prezime=N'Pavlović';
SELECT UtakmicaID,TakmicenjeID,DatumVrijeme,StatusUtakmice
FROM sport.Utakmice
WHERE TakmicenjeID=1 AND StatusUtakmice=N'Zakazana';
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/* BACKUPI */
-- SELECT name AS LogickiNaziv,type_desc,physical_name FROM sys.database_files;
-- BACKUP DATABASE SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak' WITH INIT,CHECKSUM,COMPRESSION,NAME=N'SportskaTakmicenja - puni backup',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_DIFF.bak' WITH DIFFERENTIAL,INIT,CHECKSUM,COMPRESSION,NAME=N'SportskaTakmicenja - diferencijalni backup',STATS=10;
-- ALTER DATABASE SportskaTakmicenja SET RECOVERY FULL;
-- BACKUP DATABASE SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL_FOR_LOG.bak' WITH INIT,CHECKSUM,NAME=N'Puni backup za pocetak log lanca',STATS=10;
-- BACKUP LOG SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_LOG_001.trn' WITH INIT,CHECKSUM,NAME=N'Backup transakcijskog loga 001',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_COPY_ONLY.bak' WITH COPY_ONLY,INIT,CHECKSUM,COMPRESSION,NAME=N'Copy-only puni backup',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja FILE=N'SportskaTakmicenja' TO DISK=N'C:\SQLBackup\SportskaTakmicenja_PRIMARY_FILE.bak' WITH INIT,CHECKSUM,NAME=N'Backup primarne data datoteke',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja FILEGROUP=N'PRIMARY' TO DISK=N'C:\SQLBackup\SportskaTakmicenja_PRIMARY_FILEGROUP.bak' WITH INIT,CHECKSUM,NAME=N'Backup PRIMARY filegroup-e',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja READ_WRITE_FILEGROUPS TO DISK=N'C:\SQLBackup\SportskaTakmicenja_PARTIAL.bak' WITH INIT,CHECKSUM,NAME=N'Partial backup read-write filegroup-a',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja READ_WRITE_FILEGROUPS TO DISK=N'C:\SQLBackup\SportskaTakmicenja_PARTIAL_DIFF.bak' WITH DIFFERENTIAL,INIT,CHECKSUM,NAME=N'Diferencijalni partial backup',STATS=10;
-- BACKUP DATABASE SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_STRIPE_1.bak',DISK=N'C:\SQLBackup\SportskaTakmicenja_STRIPE_2.bak' WITH INIT,CHECKSUM,NAME=N'Striped full backup',STATS=10;
-- BACKUP LOG SportskaTakmicenja TO DISK=N'C:\SQLBackup\SportskaTakmicenja_TAIL.trn' WITH NORECOVERY,CONTINUE_AFTER_ERROR,CHECKSUM,NAME=N'Tail-log backup prije oporavka',STATS=10;
-- RESTORE HEADERONLY FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak';
-- RESTORE FILELISTONLY FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak';
-- RESTORE VERIFYONLY FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak' WITH CHECKSUM;
-- RESTORE DATABASE SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak' WITH MOVE N'SportskaTakmicenja' TO N'C:\SQLData\SportskaTakmicenja_TestRestore.mdf', MOVE N'SportskaTakmicenja_log' TO N'C:\SQLData\SportskaTakmicenja_TestRestore_log.ldf', REPLACE,RECOVERY,STATS=10;
-- RESTORE DATABASE SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL.bak' WITH MOVE N'SportskaTakmicenja' TO N'C:\SQLData\SportskaTakmicenja_TestRestore.mdf', MOVE N'SportskaTakmicenja_log' TO N'C:\SQLData\SportskaTakmicenja_TestRestore_log.ldf', REPLACE,NORECOVERY,STATS=10;
-- RESTORE DATABASE SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_DIFF.bak' WITH RECOVERY,STATS=10;
-- RESTORE DATABASE SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_FULL_FOR_LOG.bak' WITH MOVE N'SportskaTakmicenja' TO N'C:\SQLData\SportskaTakmicenja_TestRestore.mdf', MOVE N'SportskaTakmicenja_log' TO N'C:\SQLData\SportskaTakmicenja_TestRestore_log.ldf', REPLACE,NORECOVERY,STATS=10;
-- RESTORE LOG SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_LOG_001.trn' WITH STOPAT='2026-08-30T12:00:00',RECOVERY,STATS=10;
-- RESTORE LOG SportskaTakmicenja_TestRestore FROM DISK=N'C:\SQLBackup\SportskaTakmicenja_TAIL.trn' WITH RECOVERY,STATS=10;
GO

