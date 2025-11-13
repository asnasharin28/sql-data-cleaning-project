
# 🧹 Data Cleaning in SQL (MySQL) — Global Layoffs Dataset

## 📌 Project Overview
This project focuses on cleaning a real-world dataset containing global layoffs from different companies.  
The cleaning was done fully in **MySQL**, using SQL techniques commonly required in data analyst roles.

The goal is to take raw, messy data and transform it into a clean, consistent, and analysis-ready dataset.

---

## 📂 Dataset
-The raw dataset is stored inside the **dataset/** folder:
- Includes:
  - Company  
  - Location  
  - Industry  
  - Total/Percentage Laid Off  
  - Layoff Date  
  - Stage  
  - Country  
  - Funds Raised  

---

## 🛠 Tools & Technologies Used
- **MySQL Database**
- MySQL Workbench
- Window Functions (`ROW_NUMBER`)
- CTEs
- `TRIM()`, `STR_TO_DATE()`, `LIKE`, JOIN updates
- Data type conversions

---

## 🔧 Cleaning Steps Performed

### **1️⃣ Create Staging Tables**
- Copied raw data into `layoffs_staging`
- Created `layoffs_staging2` for deeper cleaning

### **2️⃣ Remove Duplicates**
- Used `ROW_NUMBER()` with PARTITION BY company, location, date, etc.
- Deleted rows where `Row_num > 1`

### **3️⃣ Standardize Data**
- Trimmed spaces in company names  
- Standardized industry values (e.g., all “Crypto” variations → “Crypto”)  
- Fixed country names (e.g., “United States.” → “United States”)  
- Converted text dates to proper MySQL `DATE` format using:
  ```sql
  STR_TO_DATE(date, '%m/%d/%Y')

4️⃣ Handle Nulls and Missing Values

Replaced blank industries with NULL

Filled missing industries using self-join (matching company + location)

Deleted rows where both layoffs fields were NULL

Dropped the helper column Row_num

5️⃣ Final Output

The cleaned table is:

layoffs_staging2


This table is ready for:

analysis

visualization

dashboard creation

▶️ How to Run the Script

Run the SQL file in MySQL Workbench:

script.sql


This will:

Create staging tables

Remove duplicates

Standardize values

Fix nulls

Produce the final cleaned dataset


🌟 About Me

👩‍💻 Asna Sharin P V — Data Analyst

I’m passionate about transforming raw data into meaningful insights. Skilled in SQL, Excel, Tableau, Power BI, and data visualization, I focus on turning data into clear, actionable stories.

📬 Connect With Me

Let’s connect and collaborate!

🌐 Portfolio: https://asnasharinpv.netlify.app

💼 LinkedIn: https://linkedin.com/in/asna-sharin-b3757025a

💻 GitHub: https://github.com/asnasharin28

✉️ Email: asnasharin2003@gmail.com
