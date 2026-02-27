/* =====================================================
   DDL
   SPOR SALONU VERİTABANI  
   ===================================================== */

DROP DATABASE IF EXISTS spor_salonu_db;
CREATE DATABASE spor_salonu_db;
USE spor_salonu_db;

/* =========================
   1. UNIVERSITE
   ========================= */
CREATE TABLE UNIVERSITE (
    UniversiteID INT PRIMARY KEY,
    UniversiteAdi VARCHAR(100) NOT NULL UNIQUE,
    Sehir VARCHAR(50) NOT NULL
);

/* =========================
   2. SALON
   ========================= */
CREATE TABLE SALON (
    SalonID INT PRIMARY KEY,
    SalonAdi VARCHAR(100) NOT NULL,
    SalonTipi ENUM('Universite','Ozel') NOT NULL,
    UniversiteID INT,
    Kapasite INT NOT NULL CHECK (Kapasite > 0),
    FOREIGN KEY (UniversiteID) REFERENCES UNIVERSITE(UniversiteID)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

/* =========================
   3. UYE
   ========================= */
CREATE TABLE UYE (
    UyeID VARCHAR(10) PRIMARY KEY,
    UyeAdi VARCHAR(50) NOT NULL,
    UyeSoyadi VARCHAR(50) NOT NULL,
    UyeTipi ENUM('Ogrenci','Bireysel') NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    KayitTarihi DATE NOT NULL 
);

/* =========================
   4. ANTRENOR
   ========================= */
CREATE TABLE ANTRENOR (
    AntrenorID INT PRIMARY KEY,
    AdSoyad VARCHAR(100) NOT NULL,
    Uzmanlik VARCHAR(50) NOT NULL,
    Maas DECIMAL(10,2) NOT NULL CHECK (Maas > 0)
);

/* =========================
   5. YONETICI
   ========================= */
CREATE TABLE YONETICI (
    YoneticiID INT PRIMARY KEY,
    AdSoyad VARCHAR(100) NOT NULL,
    SalonID INT NOT NULL UNIQUE,
    FOREIGN KEY (SalonID) REFERENCES SALON(SalonID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* =========================
   6. PERSONEL
   ========================= */
CREATE TABLE PERSONEL (
    PersonelID INT PRIMARY KEY,
    AdSoyad VARCHAR(100) NOT NULL,
    Gorev VARCHAR(50) NOT NULL,
    SalonID INT NOT NULL,
    FOREIGN KEY (SalonID) REFERENCES SALON(SalonID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* =========================
   7. PAKET
   ========================= */
CREATE TABLE PAKET (
    PaketID INT PRIMARY KEY,
    PaketAdi VARCHAR(100) NOT NULL UNIQUE,
    Ucret DECIMAL(10,2) NOT NULL CHECK (Ucret > 0),
    SureAy INT NOT NULL CHECK (SureAy > 0)
);

/* =========================
   8. UYELIK
   ========================= */
CREATE TABLE UYELIK (
    UyelikID INT PRIMARY KEY,
    UyeID VARCHAR(10) NOT NULL,
    PaketID INT NOT NULL,
    BaslangicTarihi DATE NOT NULL,
    BitisTarihi DATE NOT NULL,
    CHECK (BitisTarihi > BaslangicTarihi),
    FOREIGN KEY (UyeID) REFERENCES UYE(UyeID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (PaketID) REFERENCES PAKET(PaketID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

/* =========================
   9. ODEME
   ========================= */
CREATE TABLE ODEME (
    OdemeID INT PRIMARY KEY,
    UyelikID INT NOT NULL,
    Tutar DECIMAL(10,2) NOT NULL CHECK (Tutar > 0),
    OdemeTarihi DATE NOT NULL,
    FOREIGN KEY (UyelikID) REFERENCES UYELIK(UyelikID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* =========================
   10. DERS
   ========================= */
CREATE TABLE DERS (
    DersID INT PRIMARY KEY,
    DersAdi VARCHAR(100) NOT NULL,
    AntrenorID INT NOT NULL,
    SalonID INT NOT NULL,
    Kontenjan INT NOT NULL CHECK (Kontenjan > 0),
    FOREIGN KEY (AntrenorID) REFERENCES ANTRENOR(AntrenorID)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    FOREIGN KEY (SalonID) REFERENCES SALON(SalonID)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

/* =========================
   11. KATILIM
   ========================= */
CREATE TABLE KATILIM (
    KatilimID INT PRIMARY KEY,
    DersID INT NOT NULL,
    UyeID VARCHAR(10) NOT NULL,
    KatilimTarihi DATE NOT NULL,
    FOREIGN KEY (DersID) REFERENCES DERS(DersID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (UyeID) REFERENCES UYE(UyeID)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    UNIQUE (DersID, UyeID)
);


/* =========================
   DML
   UNIVERSITE – 30 KAYIT
   ========================= */

INSERT INTO UNIVERSITE (UniversiteID, UniversiteAdi, Sehir) VALUES
(1,'Istanbul Teknik Universitesi','Istanbul'),
(2,'Bogazici Universitesi','Istanbul'),
(3,'Orta Dogu Teknik Universitesi','Ankara'),
(4,'Hacettepe Universitesi','Ankara'),
(5,'Ege Universitesi','Izmir'),
(6,'Dokuz Eylul Universitesi','Izmir'),
(7,'Gazi Universitesi','Ankara'),
(8,'Yildiz Teknik Universitesi','Istanbul'),
(9,'Marmara Universitesi','Istanbul'),
(10,'Ankara Universitesi','Ankara'),
(11,'Akdeniz Universitesi','Antalya'),
(12,'Pamukkale Universitesi','Denizli'),
(13,'Sakarya Universitesi','Sakarya'),
(14,'Uludag Universitesi','Bursa'),
(15,'Trakya Universitesi','Edirne'),
(16,'Erciyes Universitesi','Kayseri'),
(17,'Selcuk Universitesi','Konya'),
(18,'Ondokuz Mayis Universitesi','Samsun'),
(19,'Karadeniz Teknik Universitesi','Trabzon'),
(20,'Ataturk Universitesi','Erzurum'),
(21,'Inonu Universitesi','Malatya'),
(22,'Canakkale Onsekiz Mart Universitesi','Canakkale'),
(23,'Mersin Universitesi','Mersin'),
(24,'Cukurova Universitesi','Adana'),
(25,'Adnan Menderes Universitesi','Aydin'),
(26,'Balikesir Universitesi','Balikesir'),
(27,'Afyon Kocatepe Universitesi','Afyon'),
(28,'Kocaeli Universitesi','Kocaeli'),
(29,'Hatay Mustafa Kemal Universitesi','Hatay'),
(30,'Dumlupinar Universitesi','Kutahya');

SELECT * FROM UNIVERSITE;

/* =========================
   SALON – 30 KAYIT
   ========================= */

INSERT INTO SALON (SalonID, SalonAdi, SalonTipi, UniversiteID, Kapasite) VALUES
(1,'ITU Spor Merkezi','Universite',1,500),
(2,'Bogazici Fitness','Universite',2,400),
(3,'ODTU Spor Salonu','Universite',3,600),
(4,'Hacettepe Spor','Universite',4,450),
(5,'Ege Uni Spor','Universite',5,550),
(6,'DEU Spor Merkezi','Universite',6,480),
(7,'Gazi Spor Salonu','Universite',7,520),
(8,'YTU Fitness','Universite',8,430),
(9,'Marmara Spor','Universite',9,460),
(10,'Ankara Uni Spor','Universite',10,500),
(11,'Akdeniz Spor Merkezi','Universite',11,470),
(12,'Pamukkale Spor','Universite',12,410),
(13,'Sakarya Spor','Universite',13,390),
(14,'Uludag Spor Merkezi','Universite',14,520),
(15,'Trakya Spor','Universite',15,360),
(16,'Erciyes Spor','Universite',16,540),
(17,'Selcuk Spor Merkezi','Universite',17,580),
(18,'OMU Spor','Universite',18,430),
(19,'KTU Spor Salonu','Universite',19,490),
(20,'Ataturk Uni Spor','Universite',20,510),
(21,'Inonu Spor','Universite',21,420),
(22,'COMU Spor','Universite',22,370),
(23,'Mersin Spor','Universite',23,480),
(24,'Cukurova Spor Merkezi','Universite',24,600),
(25,'ADU Spor','Universite',25,390),
(26,'Balikesir Spor','Universite',26,410),
(27,'Afyon Spor Merkezi','Universite',27,360),
(28,'Kocaeli Spor','Universite',28,520),
(29,'Hatay Spor','Universite',29,440),
(30,'Dumlupinar Spor','Universite',30,400);

SELECT * FROM SALON;


/* =========================
   UYE – 30 KAYIT
   ========================= */
INSERT INTO UYE (UyeID, UyeAdi, UyeSoyadi, UyeTipi, Email, KayitTarihi) VALUES
('UY101','Deniz','Akin','Bireysel','deniz@mail.com','2024-01-01'),
('UY102','Ozan','Kara','Ogrenci','ozan@mail.com','2024-01-02'),
('UY103','Leyla','Can','Bireysel','leyla@mail.com','2024-01-03'),
('UY104','Baris','Tekin','Ogrenci','baris@mail.com','2024-01-04'),
('UY105','Sibel','Er','Bireysel','sibel@mail.com','2024-01-05'),
('UY106','Mert','Sen','Ogrenci','mert@mail.com','2024-01-06'),
('UY107','Ece','Gul','Bireysel','ece@mail.com','2024-01-07'),
('UY108','Ali','Veli','Ogrenci','ali@mail.com','2024-01-08'),
('UY109','Irem','Duru','Bireysel','irem@mail.com','2024-01-09'),
('UY110','Firat','Can','Bireysel','firat@mail.com','2024-01-10'),
('UY111','Gokce','Er','Ogrenci','gokce@mail.com','2024-01-11'),
('UY112','Hasan','Yilmaz','Bireysel','hasan@mail.com','2024-01-12'),
('UY113','Selin','Tek','Bireysel','selin@mail.com','2024-01-13'),
('UY114','Can','Aksoy','Ogrenci','can@mail.com','2024-01-14'),
('UY115','Melis','Aydin','Bireysel','melis@mail.com','2024-01-15'),
('UY116','Burak','Demir','Ogrenci','burak@mail.com','2024-01-16'),
('UY117','Zeynep','Koc','Bireysel','zeynep@mail.com','2024-01-17'),
('UY118','Emre','Sahin','Ogrenci','emre@mail.com','2024-01-18'),
('UY119','Elif','Yildiz','Bireysel','elif@mail.com','2024-01-19'),
('UY120','Kerem','Arslan','Ogrenci','kerem@mail.com','2024-01-20'),
('UY121','Asli','Cetin','Bireysel','asli@mail.com','2024-01-21'),
('UY122','Onur','Polat','Ogrenci','onur@mail.com','2024-01-22'),
('UY123','Buse','Kaya','Bireysel','buse@mail.com','2024-01-23'),
('UY124','Hakan','Oz','Ogrenci','hakan@mail.com','2024-01-24'),
('UY125','Derya','Uslu','Bireysel','derya@mail.com','2024-01-25'),
('UY126','Tolga','Gunes','Ogrenci','tolga@mail.com','2024-01-26'),
('UY127','Pelin','Acar','Bireysel','pelin@mail.com','2024-01-27'),
('UY128','Serkan','Bozkurt','Ogrenci','serkan@mail.com','2024-01-28'),
('UY129','Ayca','Dogan','Bireysel','ayca@mail.com','2024-01-29'),
('UY130','Kaan','Yavuz','Ogrenci','kaan@mail.com','2024-01-30');

SELECT * FROM UYE;


/* =========================
   ANTRENOR – 30 KAYIT
   ========================= */

INSERT INTO ANTRENOR (AntrenorID, AdSoyad, Uzmanlik, Maas) VALUES
(1,'Ahmet Yilmaz','Fitness',22000),
(2,'Mehmet Kaya','Pilates',21000),
(3,'Ayse Demir','Yoga',20000),
(4,'Can Aydin','Crossfit',23000),
(5,'Elif Sari','Zumba',19500),
(6,'Burak Koc','Fitness',22500),
(7,'Zeynep Arslan','Pilates',20500),
(8,'Mert Oz','Yoga',19800),
(9,'Selin Gunes','Fitness',21500),
(10,'Emre Polat','Crossfit',24000),
(11,'Derya Uslu','Zumba',19000),
(12,'Onur Cetin','Fitness',22000),
(13,'Buse Yildiz','Pilates',21000),
(14,'Hakan Dogan','Yoga',20000),
(15,'Pelin Acar','Zumba',19500),
(16,'Tolga Sen','Crossfit',23500),
(17,'Irem Korkmaz','Fitness',22500),
(18,'Serkan Aksoy','Pilates',20500),
(19,'Melis Kaplan','Yoga',19800),
(20,'Firat Eren','Crossfit',24500),
(21,'Gokce Tek','Zumba',19000),
(22,'Kerem Sahin','Fitness',23000),
(23,'Asli Yavuz','Pilates',21000),
(24,'Ozan Karaca','Yoga',20500),
(25,'Deniz Bozkurt','Crossfit',23800),
(26,'Ece Altun','Zumba',19500),
(27,'Kaan Demirel','Fitness',22000),
(28,'Sibel Akin','Pilates',20000),
(29,'Baris Cengiz','Yoga',19800),
(30,'Nilay Ozkan','Fitness',22500);

SELECT * FROM ANTRENOR;


/* =========================
   YONETICI – 30 KAYIT
   ========================= */
INSERT INTO YONETICI (YoneticiID, AdSoyad, SalonID) VALUES
(1,'Ahmet Yilmaz',1),
(2,'Mehmet Kaya',2),
(3,'Ayse Demir',3),
(4,'Can Aydin',4),
(5,'Elif Sari',5),
(6,'Burak Koc',6),
(7,'Zeynep Arslan',7),
(8,'Mert Oz',8),
(9,'Selin Gunes',9),
(10,'Emre Polat',10),
(11,'Derya Uslu',11),
(12,'Onur Cetin',12),
(13,'Buse Yildiz',13),
(14,'Hakan Dogan',14),
(15,'Pelin Acar',15),
(16,'Tolga Sen',16),
(17,'Irem Korkmaz',17),
(18,'Serkan Aksoy',18),
(19,'Melis Kaplan',19),
(20,'Firat Eren',20),
(21,'Gokce Tek',21),
(22,'Kerem Sahin',22),
(23,'Asli Yavuz',23),
(24,'Ozan Karaca',24),
(25,'Deniz Bozkurt',25),
(26,'Ece Altun',26),
(27,'Kaan Demirel',27),
(28,'Sibel Akin',28),
(29,'Baris Cengiz',29),
(30,'Nilay Ozkan',30);

SELECT * FROM YONETICI;


/* =========================
   PERSONEL – 30 KAYIT
   ========================= */
INSERT INTO PERSONEL (PersonelID, AdSoyad, Gorev, SalonID) VALUES
(1,'Ayhan Korkmaz','Resepsiyon',1),
(2,'Selma Yildirim','Temizlik',2),
(3,'Murat Ates','Guvenlik',3),
(4,'Dilek Ozdemir','Resepsiyon',4),
(5,'Serhat Demir','Temizlik',5),
(6,'Nazan Acar','Resepsiyon',6),
(7,'Erdal Polat','Guvenlik',7),
(8,'Pinar Aksoy','Temizlik',8),
(9,'Volkan Sahin','Resepsiyon',9),
(10,'Hande Koc','Temizlik',10),
(11,'Cem Karaca','Guvenlik',11),
(12,'Esra Gunes','Resepsiyon',12),
(13,'Umut Yavuz','Temizlik',13),
(14,'Burcu Kaplan','Resepsiyon',14),
(15,'Huseyin Arslan','Guvenlik',15),
(16,'Sevgi Cinar','Temizlik',16),
(17,'Oktay Er','Resepsiyon',17),
(18,'Bahar Cetin','Temizlik',18),
(19,'Ali Vural','Guvenlik',19),
(20,'Gulsen Aydin','Resepsiyon',20),
(21,'Sinan Bozkurt','Temizlik',21),
(22,'Merve Uslu','Resepsiyon',22),
(23,'Kadir Yilmaz','Guvenlik',23),
(24,'Seda Tekin','Temizlik',24),
(25,'Levent Koc','Resepsiyon',25),
(26,'Zehra Dogan','Temizlik',26),
(27,'Emrah Sari','Guvenlik',27),
(28,'Asuman Guler','Resepsiyon',28),
(29,'Yusuf Can','Temizlik',29),
(30,'Aylin Eren','Guvenlik',30);

SELECT * FROM PERSONEL;

/* =========================
   PAKET – 30 KAYIT
   ========================= */
INSERT INTO PAKET (PaketID, PaketAdi, Ucret, SureAy) VALUES
(1,'Ogrenci Aylik',500,1),
(2,'Ogrenci 3 Aylik',1350,3),
(3,'Ogrenci 6 Aylik',2500,6),
(4,'Ogrenci Yillik',4500,12),
(5,'Bireysel Aylik',800,1),
(6,'Bireysel 3 Aylik',2200,3),
(7,'Bireysel 6 Aylik',4200,6),
(8,'Bireysel Yillik',7800,12),
(9,'Gold Aylik',1200,1),
(10,'Gold 3 Aylik',3300,3),
(11,'Gold 6 Aylik',6300,6),
(12,'Gold Yillik',11500,12),
(13,'Platinum Aylik',1500,1),
(14,'Platinum 3 Aylik',4200,3),
(15,'Platinum 6 Aylik',8100,6),
(16,'Platinum Yillik',15000,12),
(17,'Sabah Paketi',600,1),
(18,'Aksam Paketi',700,1),
(19,'Hafta Sonu Paketi',550,1),
(20,'Kampanya 1',1000,2),
(21,'Kampanya 2',1800,3),
(22,'Kampanya 3',3200,6),
(23,'Kurumsal Aylik',2000,1),
(24,'Kurumsal 3 Aylik',5600,3),
(25,'Kurumsal 6 Aylik',10500,6),
(26,'Kurumsal Yillik',19500,12),
(27,'Online Paket',400,1),
(28,'Online Premium',900,3),
(29,'Aile Paketi',3000,3),
(30,'VIP Paket',25000,12);

SELECT * FROM PAKET;

/* =========================
   UYELIK – 30 KAYIT
   ========================= */
INSERT INTO UYELIK (UyelikID, UyeID, PaketID, BaslangicTarihi, BitisTarihi) VALUES
(1,'UY101',1,'2024-01-01','2024-02-01'),
(2,'UY102',2,'2024-01-02','2024-04-02'),
(3,'UY103',3,'2024-01-03','2024-07-03'),
(4,'UY104',4,'2024-01-04','2025-01-04'),
(5,'UY105',5,'2024-01-05','2024-02-05'),
(6,'UY106',6,'2024-01-06','2024-04-06'),
(7,'UY107',7,'2024-01-07','2024-07-07'),
(8,'UY108',8,'2024-01-08','2025-01-08'),
(9,'UY109',9,'2024-01-09','2024-02-09'),
(10,'UY110',10,'2024-01-10','2024-04-10'),
(11,'UY111',11,'2024-01-11','2024-07-11'),
(12,'UY112',12,'2024-01-12','2025-01-12'),
(13,'UY113',13,'2024-01-13','2024-02-13'),
(14,'UY114',14,'2024-01-14','2024-04-14'),
(15,'UY115',15,'2024-01-15','2024-07-15'),
(16,'UY116',16,'2024-01-16','2025-01-16'),
(17,'UY117',17,'2024-01-17','2024-02-17'),
(18,'UY118',18,'2024-01-18','2024-02-18'),
(19,'UY119',19,'2024-01-19','2024-02-19'),
(20,'UY120',20,'2024-01-20','2024-03-20'),
(21,'UY121',21,'2024-01-21','2024-04-21'),
(22,'UY122',22,'2024-01-22','2024-07-22'),
(23,'UY123',23,'2024-01-23','2024-02-23'),
(24,'UY124',24,'2024-01-24','2024-04-24'),
(25,'UY125',25,'2024-01-25','2024-07-25'),
(26,'UY126',26,'2024-01-26','2025-01-26'),
(27,'UY127',27,'2024-01-27','2024-02-27'),
(28,'UY128',28,'2024-01-28','2024-04-28'),
(29,'UY129',29,'2024-01-29','2024-04-29'),
(30,'UY130',30,'2024-01-30','2025-01-30');

SELECT * FROM UYELIK;

/* =========================
   ODEME – 30 KAYIT
   ========================= */
INSERT INTO ODEME (OdemeID, UyelikID, Tutar, OdemeTarihi) VALUES
(1, 1, 500.00, '2024-01-01'),
(2, 2, 750.00, '2024-01-02'),
(3, 3, 900.00, '2024-01-03'),
(4, 4, 1200.00, '2024-01-04'),
(5, 5, 800.00, '2024-01-05'),
(6, 6, 750.00, '2024-01-06'),
(7, 7, 900.00, '2024-01-07'),
(8, 8, 1200.00, '2024-01-08'),
(9, 9, 500.00, '2024-01-09'),
(10, 10, 750.00, '2024-01-10'),
(11, 11, 900.00, '2024-01-11'),
(12, 12, 1200.00, '2024-01-12'),
(13, 13, 500.00, '2024-01-13'),
(14, 14, 750.00, '2024-01-14'),
(15, 15, 900.00, '2024-01-15'),
(16, 16, 1200.00, '2024-01-16'),
(17, 17, 500.00, '2024-01-17'),
(18, 18, 750.00, '2024-01-18'),
(19, 19, 900.00, '2024-01-19'),
(20, 20, 1200.00, '2024-01-20'),
(21, 21, 500.00, '2024-01-21'),
(22, 22, 750.00, '2024-01-22'),
(23, 23, 900.00, '2024-01-23'),
(24, 24, 1200.00, '2024-01-24'),
(25, 25, 800.00, '2024-01-25'),
(26, 26, 750.00, '2024-01-26'),
(27, 27, 900.00, '2024-01-27'),
(28, 28, 1200.00, '2024-01-28'),
(29, 29, 750.00, '2024-01-29'),
(30, 30, 900.00, '2024-01-30');

SELECT * FROM ODEME;

/* =========================
   DERS – 30 KAYIT
   ========================= */
INSERT INTO DERS (DersID, DersAdi, AntrenorID, SalonID, Kontenjan) VALUES
(1,'Fitness',1,1,30),
(2,'Pilates',2,2,25),
(3,'Yoga',3,3,20),
(4,'Crossfit',4,4,15),
(5,'Zumba',5,5,30),
(6,'Fitness',6,6,30),
(7,'Pilates',7,7,25),
(8,'Yoga',8,8,20),
(9,'Crossfit',9,9,15),
(10,'Zumba',10,10,30),
(11,'Fitness',11,11,30),
(12,'Pilates',12,12,25),
(13,'Yoga',13,13,20),
(14,'Crossfit',14,14,15),
(15,'Zumba',15,15,30),
(16,'Fitness',16,16,30),
(17,'Pilates',17,17,25),
(18,'Yoga',18,18,20),
(19,'Crossfit',19,19,15),
(20,'Zumba',20,20,30),
(21,'Fitness',21,21,30),
(22,'Pilates',22,22,25),
(23,'Yoga',23,23,20),
(24,'Crossfit',24,24,15),
(25,'Zumba',25,25,30),
(26,'Fitness',26,26,30),
(27,'Pilates',27,27,25),
(28,'Yoga',28,28,20),
(29,'Crossfit',29,29,15),
(30,'Zumba',30,30,30);

SELECT * FROM DERS;


/* =========================
   KATILIM – 30 KAYIT
   ========================= */
INSERT INTO KATILIM (KatilimID, DersID, UyeID, KatilimTarihi) VALUES
(1, 1, 'UY101', '2024-02-01'),
(2, 2, 'UY102', '2024-02-02'),
(3, 3, 'UY103', '2024-02-03'),
(4, 4, 'UY104', '2024-02-04'),
(5, 5, 'UY105', '2024-02-05'),
(6, 6, 'UY106', '2024-02-06'),
(7, 7, 'UY107', '2024-02-07'),
(8, 8, 'UY108', '2024-02-08'),
(9, 9, 'UY109', '2024-02-09'),
(10, 10, 'UY110', '2024-02-10'),
(11, 11, 'UY111', '2024-02-11'),
(12, 12, 'UY112', '2024-02-12'),
(13, 13, 'UY113', '2024-02-13'),
(14, 14, 'UY114', '2024-02-14'),
(15, 15, 'UY115', '2024-02-15'),
(16, 16, 'UY116', '2024-02-16'),
(17, 17, 'UY117', '2024-02-17'),
(18, 18, 'UY118', '2024-02-18'),
(19, 19, 'UY119', '2024-02-19'),
(20, 20, 'UY120', '2024-02-20'),
(21, 21, 'UY121', '2024-02-21'),
(22, 22, 'UY122', '2024-02-22'),
(23, 23, 'UY123', '2024-02-23'),
(24, 24, 'UY124', '2024-02-24'),
(25, 25, 'UY125', '2024-02-25'),
(26, 26, 'UY126', '2024-02-26'),
(27, 27, 'UY127', '2024-02-27'),
(28, 28, 'UY128', '2024-02-28'),
(29, 29, 'UY129', '2024-02-29'),
(30, 30, 'UY130', '2024-03-01');

SELECT * FROM KATILIM;

/* =====================================================
   2. + 3. TESLİMAT – RAPORLAMA & ANALİZ
   ===================================================== */

/* =====================================================
   BASİT SORGULAR
   ===================================================== */

/* --- Farklı tablolara 3 kayıt ekleme (örnek) --- */
INSERT INTO PAKET (PaketID, PaketAdi, Ucret, SureAy)
VALUES (101,'Deneme Paket 1',300,1);

INSERT INTO PAKET (PaketID, PaketAdi, Ucret, SureAy)
VALUES (102,'Deneme Paket 2',600,2);

INSERT INTO PAKET (PaketID, PaketAdi, Ucret, SureAy)
VALUES (103,'Deneme Paket 3',900,3);

/* --- Aynı tabloya 5 kayıt ekleme --- */
INSERT INTO UNIVERSITE VALUES
(101,'Test Uni 1','Istanbul'),
(102,'Test Uni 2','Ankara'),
(103,'Test Uni 3','Izmir'),
(104,'Test Uni 4','Bursa'),
(105,'Test Uni 5','Antalya');

/* --- 3 UPDATE --- */
UPDATE PAKET SET Ucret = Ucret + 100 WHERE PaketID = 1;
SELECT * FROM PAKET WHERE PaketID = 1;
UPDATE SALON SET Kapasite = Kapasite + 20 WHERE SalonID = 3;
SELECT * FROM SALON WHERE SALONID = 3;
UPDATE ANTRENOR SET Maas = Maas + 500 WHERE AntrenorID = 1;

/* --- 3 DELETE --- */
DELETE FROM UNIVERSITE WHERE UniversiteID = 10;
SELECT * FROM UNIVERSITE;
DELETE FROM PAKET WHERE PaketID = 11;
DELETE FROM UNIVERSITE WHERE UniversiteID = 14;

/* --- WHERE (karşılaştırma) --- */
SELECT * FROM PAKET WHERE Ucret > 4500;
SELECT * FROM ANTRENOR WHERE Maas >= 23000;
SELECT * FROM SALON WHERE Kapasite < 400;

/* --- WHERE (aritmetik) --- */
SELECT * FROM PAKET WHERE Ucret * 2 > 5000;
SELECT * FROM ANTRENOR WHERE Maas + 1000 > 24000;
SELECT * FROM SALON WHERE Kapasite / 2 > 200;

/* --- WHERE (mantıksal) --- */
SELECT * FROM UYE WHERE UyeTipi='Ogrenci' AND KayitTarihi>'2024-01-10';
SELECT * FROM SALON WHERE SalonTipi='Universite' OR Kapasite>900;
SELECT * FROM PAKET WHERE NOT Ucret < 1000;

/* --- Özel operatörler --- */
SELECT * FROM PAKET WHERE Ucret BETWEEN 500 AND 3000;
SELECT * FROM UYE WHERE Email IS NOT NULL;
SELECT * FROM UYE WHERE UyeAdi LIKE 'A%';
SELECT * FROM UYE WHERE UyeID IN ('UY101','UY105','UY110');

/* --- ORDER BY --- */
SELECT * FROM PAKET ORDER BY Ucret DESC;
SELECT * FROM ANTRENOR ORDER BY Maas;
SELECT * FROM UYE ORDER BY KayitTarihi DESC;

/* --- DISTINCT --- */
SELECT DISTINCT UyeTipi FROM UYE;
SELECT DISTINCT SalonTipi FROM SALON;
SELECT DISTINCT SureAy FROM PAKET;

/* --- STRING fonksiyonları (7) --- */
SELECT UPPER(UyeAdi) FROM UYE;
SELECT LOWER(UyeSoyadi) FROM UYE;
SELECT CONCAT(UyeAdi,' ',UyeSoyadi) FROM UYE;
SELECT LENGTH(UyeAdi) FROM UYE;
SELECT SUBSTRING(UyeAdi,1,2) FROM UYE;
SELECT REPLACE(UyeAdi,'a','@') FROM UYE;
SELECT TRIM(UyeAdi) FROM UYE;

/* --- SAYISAL fonksiyonlar (7) --- */
SELECT ABS(-10);
SELECT ROUND(123.456,2);
SELECT CEILING(12.3);
SELECT FLOOR(12.9);
SELECT POWER(2,3);
SELECT SQRT(144);
SELECT MOD(10,3);

/* --- TARİH fonksiyonları (10) --- */
SELECT CURRENT_DATE;
SELECT NOW();
SELECT YEAR(OdemeTarihi) FROM ODEME;
SELECT MONTH(OdemeTarihi) FROM ODEME;
SELECT DAY(OdemeTarihi) FROM ODEME;
SELECT DATEDIFF(CURRENT_DATE, OdemeTarihi) FROM ODEME;
SELECT ADDDATE(OdemeTarihi, INTERVAL 7 DAY) FROM ODEME;
SELECT LAST_DAY(OdemeTarihi) FROM ODEME;
SELECT DATE_FORMAT(OdemeTarihi,'%d-%m-%Y') FROM ODEME;
SELECT WEEK(OdemeTarihi) FROM ODEME;

/* --- AGGREGATE --- */
SELECT COUNT(*) FROM UYE;
SELECT MIN(Ucret) FROM PAKET;
SELECT MAX(Ucret) FROM PAKET;
SELECT SUM(Tutar) FROM ODEME;
SELECT AVG(Ucret) FROM PAKET;

/* --- LIMIT --- */
SELECT * FROM UYE LIMIT 7;

/* --- ROLLUP --- */
SELECT PaketID, SUM(Tutar)
FROM ODEME O JOIN UYELIK U ON O.UyelikID=U.UyelikID
GROUP BY PaketID WITH ROLLUP;

/* =====================================================
   GRUPLAMA
   ===================================================== */

SELECT PaketID, COUNT(*) FROM UYELIK GROUP BY PaketID;
SELECT SalonID, COUNT(*) FROM PERSONEL GROUP BY SalonID;
SELECT AntrenorID, COUNT(*) FROM DERS GROUP BY AntrenorID;
SELECT PaketID, COUNT(*) FROM UYELIK GROUP BY PaketID HAVING COUNT(*)>3;
SELECT SalonID, AVG(Kapasite) FROM SALON GROUP BY SalonID HAVING AVG(Kapasite)>400;
SELECT AntrenorID, SUM(Maas) FROM ANTRENOR GROUP BY AntrenorID HAVING SUM(Maas)>20000;

/* =====================================================
    GELİŞMİŞ SORGULAR
   ===================================================== */

/* LEFT JOIN */
SELECT U.UyeAdi, Y.PaketID
FROM UYE U LEFT JOIN UYELIK Y ON U.UyeID=Y.UyeID;

/* RIGHT JOIN */
SELECT P.PaketAdi, Y.UyeID
FROM UYELIK Y RIGHT JOIN PAKET P ON Y.PaketID=P.PaketID;

/* 2 tablo JOIN */
SELECT * FROM UYE U JOIN UYELIK Y ON U.UyeID=Y.UyeID;
SELECT * FROM PAKET P JOIN UYELIK Y ON P.PaketID=Y.PaketID;
SELECT * FROM ODEME O JOIN UYELIK Y ON O.UyelikID=Y.UyelikID;

/* 3 tablo JOIN */
SELECT U.UyeAdi,P.PaketAdi,O.Tutar
FROM UYE U
JOIN UYELIK Y ON U.UyeID=Y.UyeID
JOIN PAKET P ON Y.PaketID=P.PaketID
JOIN ODEME O ON Y.UyelikID=O.UyelikID;

/* Korele alt sorgu */
SELECT * FROM UYE U
WHERE EXISTS (SELECT 1 FROM UYELIK Y WHERE Y.UyeID=U.UyeID);

/* SELECT içinde alt sorgu */
SELECT UyeAdi,
(SELECT COUNT(*) FROM UYELIK Y WHERE Y.UyeID=U.UyeID) AS UyelikSayisi
FROM UYE U;

/* Tablo kopyalama */
CREATE TABLE UYE_YEDEK AS SELECT * FROM UYE;

/* Kullanıcı değişkenleri */
SET @maxUcret := (SELECT MAX(Ucret) FROM PAKET);
SELECT * FROM PAKET WHERE Ucret=@maxUcret;

/* =====================================================
   VIEW
   ===================================================== */
CREATE OR REPLACE VIEW vw_AktifUyeler AS
SELECT UyeID, UyeAdi, UyeTipi FROM UYE;

/* =====================================================
    STORED PROCEDURE
   ===================================================== */
DELIMITER $$

CREATE PROCEDURE sp_PaketGuncelle (
    IN p_id INT,
    IN yeni_ucret DECIMAL(10,2)
)
BEGIN
    UPDATE PAKET SET Ucret=yeni_ucret WHERE PaketID=p_id;
    SELECT * FROM PAKET WHERE PaketID=p_id;
END$$

DELIMITER ;

CALL sp_PaketGuncelle(1,9999);

/* =====================================================
    TRIGGER (3 ADET)
   ===================================================== */

DELIMITER $$

/* İş kuralı */
CREATE TRIGGER trg_odeme_kontrol
BEFORE INSERT ON ODEME
FOR EACH ROW
BEGIN
    IF NEW.Tutar <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT='Odeme tutari sifirdan buyuk olmali';
    END IF;
END$$

/* Log */
CREATE TRIGGER trg_uye_insert
AFTER INSERT ON UYE
FOR EACH ROW
BEGIN
    INSERT INTO LOG_KAYIT(TabloAdi,Islem)
    VALUES('UYE','INSERT');
END$$

/* Log */
CREATE TRIGGER trg_uye_delete
AFTER DELETE ON UYE
FOR EACH ROW
BEGIN
    INSERT INTO LOG_KAYIT(TabloAdi,Islem)
    VALUES('UYE','DELETE');
END$$

DELIMITER ;

