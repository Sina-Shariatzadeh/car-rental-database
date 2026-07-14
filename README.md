# 🚗 Car Rental Database (Autovermietung)

A complete relational database design and implementation for a **car rental company**, built with **Oracle SQL** as a three-milestone university database course project (Universität Wien, DBS).

The project covers the full database design lifecycle: **conceptual modeling (ER)** → **logical design & SQL implementation** → **normalization, triggers & application connectivity (Python)**.

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Repository Structure](#-repository-structure)
- [Database Schema](#-database-schema)
- [Milestones](#-milestones)
- [Getting Started](#-getting-started)
- [Running the Demo](#-running-the-demo)
- [Python Connectivity](#-python-connectivity)
- [Tech Stack](#-tech-stack)
- [License](#-license)

---

## 🎯 Project Overview

The system models the operations of a car rental company with multiple branches:

- **Branches (Filiale)** are located in cities and can have multiple phone numbers.
- **Employees (Mitarbeiter)** work in exactly one branch; employees can manage other employees (m:n self-relationship). **Inspection staff (Inspektionsmitarbeiter)** is a specialization (IS-A) of employees who check vehicles before rental.
- **Vehicles (Fahrzeug)** carry brand, model, and year of manufacture.
- **Customers (Kunde)** are identified by their driving license number and can rent multiple vehicles from multiple employees (ternary m:n:m relationship).
- **Reservations (Reservierung)** are weak entities existentially dependent on exactly one customer.

## 📁 Repository Structure

```
car-rental-database/
├── docs/                          # Project documentation (PDF reports)
│   ├── milestone-1/               #   ER model & requirements analysis
│   ├── milestone-2/               #   Relational schema mapping
│   └── milestone-3/               #   Normalization & final design
├── sql/
│   ├── milestone-2/               # Initial implementation
│   │   ├── 01_create_schema.sql   #   DDL: tables & constraints
│   │   ├── 02_demo_data.sql       #   Sample data + constraint demos
│   │   └── 99_drop_schema.sql     #   Teardown script
│   └── milestone-3/               # Normalized implementation (recommended)
│       ├── 01_create_schema.sql   #   DDL incl. 3NF decomposition (Modellinfo)
│       ├── 02_triggers_demo.sql   #   PL/SQL triggers + demo
│       └── 99_drop_schema.sql     #   Teardown script
├── notebooks/
│   └── DBConnection.ipynb         # Python ↔ Oracle connection (oracledb)
├── .env.example                   # Template for DB credentials
├── requirements.txt               # Python dependencies
├── .gitignore
├── LICENSE
└── README.md
```

## 🗄️ Database Schema

Twelve tables implement the ER model (Milestone 3 version):

| Table | Purpose | Notable Constraints |
|---|---|---|
| `Telefonnummer` | Phone numbers (shared pool) | `CHECK` with `REGEXP_LIKE` format validation |
| `Filiale` | Rental branches | — |
| `Modellinfo` | Brand → model lookup | Added in MS3 to resolve the FD *Marke → Modell* (3NF) |
| `Fahrzeug` | Vehicles | `IDENTITY` PK, `CHECK (Baujahr >= 1950)` |
| `Kunde` | Customers | Candidate key on phone number (`UNIQUE`) |
| `Mitarbeiter` | Employees | `ON DELETE SET NULL` toward branch |
| `Inspektionsmitarbeiter` | IS-A specialization | `ON DELETE CASCADE` |
| `Ist_boss_von` | Manager relationship | `ON DELETE CASCADE` |
| `Reservierung` | Weak entity (composite PK) | `DEFAULT TRUNC(SYSDATE)`, `CHECK (EndeDatum > Reservierungsdatum)` |
| `Vermieten` | Ternary rental relationship | Composite PK over customer × employee × vehicle |
| `Ueberpruefen` | Vehicle inspections | Cascading deletes on both sides |
| `Hat_Filiale` | Branch ↔ phone numbers (m:n) | Cascading deletes |

**Referential-action showcase:** the schema deliberately demonstrates all three delete policies — `NO ACTION` (default), `ON DELETE SET NULL`, and `ON DELETE CASCADE`.

**Triggers (Milestone 3, PL/SQL):**
- `trg_auto_increment_reservierung` — simulates per-customer auto-increment of reservation numbers.
- `trg_check_reservation_length` — business rule enforcement for overly long reservations.

## 🏁 Milestones

| Milestone | Focus | Deliverables |
|---|---|---|
| **MS1** | Requirements analysis & conceptual design | ER diagram (Chen notation) with cardinalities, weak entities, IS-A hierarchy → [`docs/milestone-1`](docs/milestone-1) |
| **MS2** | Logical design & implementation | ER → relational mapping, DDL scripts, sample data, constraint demonstrations → [`docs/milestone-2`](docs/milestone-2), [`sql/milestone-2`](sql/milestone-2) |
| **MS3** | Refinement & application layer | Normalization to 3NF (`Modellinfo` decomposition), PL/SQL triggers, Python connectivity → [`docs/milestone-3`](docs/milestone-3), [`sql/milestone-3`](sql/milestone-3), [`notebooks`](notebooks) |

## 🚀 Getting Started

### Prerequisites

- Access to an **Oracle Database** (project developed against Oracle 19c)
- `sqlplus` or any Oracle-compatible SQL client (SQL Developer, DBeaver, …)
- Python ≥ 3.9 (only for the notebook)

### Setup

```bash
git clone https://github.com/<your-username>/car-rental-database.git
cd car-rental-database
```

Create the schema (use the **milestone-3** version — it is the normalized, final one):

```sql
-- in sqlplus / SQL Developer
@sql/milestone-3/01_create_schema.sql
```

## ▶️ Running the Demo

```sql
@sql/milestone-3/02_triggers_demo.sql   -- triggers + sample workflow
```

To reset everything:

```sql
@sql/milestone-3/99_drop_schema.sql
```

> **Note:** run the drop script *before* re-running the create script — the DDL scripts assume a clean schema.

## 🐍 Python Connectivity

The notebook [`notebooks/DBConnection.ipynb`](notebooks/DBConnection.ipynb) connects to Oracle via [`python-oracledb`](https://python-oracledb.readthedocs.io/).

```bash
pip install -r requirements.txt
cp .env.example .env        # then fill in your credentials
jupyter notebook notebooks/DBConnection.ipynb
```

Credentials are read from environment variables (`ORACLE_USER`, `ORACLE_PASSWORD`, `ORACLE_DSN`) — **never commit real credentials**. The university database additionally requires an active **UniVie VPN** connection.

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Database | Oracle Database 19c |
| Schema & logic | SQL (DDL/DML), PL/SQL triggers |
| Application layer | Python 3, `python-oracledb`, Jupyter |
| Design | ER modeling (Chen notation), 3NF normalization |

## 📄 License

Released under the [MIT License](LICENSE).

---

*Developed as part of the Datenbanksysteme (DBS) course, Universität Wien.*
