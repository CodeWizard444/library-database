# 📚 Proiect Bază de Date: Librărie

Acest proiect reprezintă o bază de date complet funcțională pentru gestiunea unei librării, realizată în PostgreSQL. Include tabele relaționale, secvențe, vederi, funcții, proceduri stocate, triggere, interogări complexe și indexuri.

---

## 📦 Conținut

library-database
/
├── README.md # Acest fișier
├── library_export.sql # Dump complet cu toate obiectele (tabele, secvențe, funcții, proceduri)
├── triggere.sql # Declarațiile de CREATE TRIGGER
├── indexuri.sql # Indexuri create
└── schema_diagram.png # Diagrama bazei de date

---

## 🗃️ Obiective

- Gestiunea comenzilor, autorilor, cărților, editurilor și clienților
- Calculul autom. al valorii unei comenzi (funcție)
- Adăugarea simultană a unei cărți și legarea la autor (procedură)
- Monitorizarea modificărilor (trigger)
- Optimizarea interogărilor prin indexuri

---

## 📐 Structura bazei de date

Include entități precum:

- `carti`, `autori`, `edituri`, `clienti`, `comenzi`, `comenzi_produse`
- Relații many-to-many (ex: `carti_autori`)
- Secvențe pentru ID-uri auto-increment

---

## ⚙️ Importul bazei de date

1. Deschide terminalul și conectează-te la PostgreSQL:
```bash
psql -U postgres -d nume_baza
\i baza_export.sql

🔧 Funcții și proceduri utile
Exemple:
-tota_comanda(p_id_comanda INT) – returnează suma totală a unei comenzi
-adauga_carte_si_autor(...) – adaugă o carte și o leagă de autorul ei

🧠 Interogări complexe
-Găsești în interogari_complexe.sql:
-Subinterogări corelate
-CTE-uri (WITH)
-RANK(), ROW_NUMBER() etc.
-EXISTS, INTERSECT, ALL, ANY

🔒 Trigger-e implementate
(ex: în triggere.sql)
-Trigger pentru logarea modificărilor de preț
-Trigger pentru verificarea disponibilității comenzilor

🚀 Indexuri
(ex: în indexuri.sql)
-Indexuri pe coloane frecvent căutate (ex: id_client, isbn)
-Optimizări pentru JOIN și WHERE

📝 Autor
Lacatus Eduard – proiect, PostgreSQL
