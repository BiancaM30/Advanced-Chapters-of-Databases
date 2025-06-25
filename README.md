# Advanced-Chapters-of-Databases

This repository contains my practical work during the **Advanced Chapters of Databases** course, part of my Master's studies. The course focused on advanced topics in relational database modeling, temporal databases, spatial data using PostGIS, hierarchical data structures, and change tracking through historical data modeling.

The repository is organized into the following folders:
- **Lab1**: Temporal Data Modeling
- **Lab2**: Spatial Data Analysis with PostGIS
- **Lab3**: Hierarchical Data Structures
- **Final Project**: Full Data Model with History and Temporal Analysis

---

## 🔹 Lab 1 – Temporal Data Modeling (Oracle or PostgreSQL)

### Requirements
1. **Design and implement a data model** for a chosen domain including:
   - At least **2 tables** with **transaction-time attributes**
   - At least **1 table** with **valid-time attributes**

2. **Scripts**:
   - Populate tables with at least **100 records**
     - Calendar dates must not be earlier than **September 15, 2024**
   - Perform **UPDATEs**:
     - 5 to 10 updates for at least 5 different records
   - Perform **DELETEs**:
     - At least 3 deletions from the base tables

3. **Queries**:
   - From the valid-time entity, return the **interval during which the most recently updated row had the maximum value** for a chosen numeric field
   - From a transaction-time entity, return the **number of operations (INSERT/DELETE/UPDATE) per week** in the last 4 weeks
   - At least **3 temporal queries** returning numeric results
   - At least **3 temporal queries** returning temporal (interval or date) results
   - At least **2 temporal queries** returning boolean results

---

## 🔹 Lab 2 – Spatial Data Analysis with PostGIS (PostgreSQL)

### Requirements

1. Using the `towns.sql` dataset and the `towns` table:
   - Find the **city/cities with the largest and smallest area** (single query)
   - For cities with **only increasing population**, compute the **perimeter length**
   - Check if there are any **cities with polygon geometries containing holes**
   - Compute the **minimum distance** and the **names of the two closest cities** with:
     - Area > 1500 hectares
     - Population growth > 2000 (between 2000 and 2010)

2. Create tables `streets` and `buildings`:
   - Each must include **non-spatial** and at least one **spatial (geometry)** attribute
   - Query all geometry features from the current schema

3. Insert at least **10 records** into each table and write:
   - **3 spatial join queries** (with numeric results)
   - **3 spatial join queries** (with boolean results)

---

## 🔹 Lab 3 – Hierarchical Data Structures (Oracle or PostgreSQL)

### Requirements

Using the data provided in `strArb.sql`:

1. Create a table that organizes the data as an **adjacency list**
2. Display for all nodes up to **level 5**:
   - Name
   - Parent name
   - Tree level
   - *(Recursive CTEs can be used in PostgreSQL)*
3. Implement a **procedure/function** to convert the data into **path enumeration format**
   - Use custom path encoding (e.g., with separators)
   - PostgreSQL: use `array_agg`, `array_to_string`
4. For the path enumeration model, implement a **function to delete a node** by ID
   - The tree structure must remain valid (no forest)

---

## 🔹 Final Project – Historical Data Tracking and Temporal Reports

### Requirements

Design and implement a **data model for a chosen domain**, including:

- At least one entity with a **history table** containing **temporal attributes**

### Functionalities

- **CRUD operations** on the main entities
- **Automatic reflection of changes** into history tables for temporally-tracked entities

### Reports to implement:

1. **Current state** of a temporally-tracked entity
2. **Longest period** where the entity had a **minimum or maximum value** for a numeric attribute (e.g., price, area)
3. **Historical changes** in the selected attribute over time
4. **Entity state at a specific user-provided timestamp**

### Tools
- Programming language and RDBMS are **freely chosen**

---

## 📁 Repository Structure

