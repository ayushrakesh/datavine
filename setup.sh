#!/bin/bash

# Prompt for MySQL root password securely
read -sp "Enter MySQL root password: " MYSQL_PASS
MYSQL_USER="root"
MYSQL_HOST="localhost"
DB_NAME="datavine"

# Enable error handling
set -e

# 0. Enable local_infile on the MySQL server
mysql -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST -e "SET GLOBAL local_infile = 1;"
echo "local_infile enabled on MySQL server."

# 1. Create database and tables
mysql --local-infile=1 -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST < scripts/00_init_database.sql

echo "Database and tables created."

# 2. Import CSV files into tables
# Import dim_customers
mysql --local-infile=1 -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $DB_NAME -e "
LOAD DATA LOCAL INFILE '$(pwd)/csv-files/dim_customers.csv'
INTO TABLE dim_customers
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;"
echo "dim_customers imported."

# Import dim_products
mysql --local-infile=1 -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $DB_NAME -e "
LOAD DATA LOCAL INFILE '$(pwd)/csv-files/dim_products.csv'
INTO TABLE dim_products
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;"
echo "dim_products imported."

# Import fact_sales
mysql --local-infile=1 -u $MYSQL_USER -p$MYSQL_PASS -h $MYSQL_HOST $DB_NAME -e "
LOAD DATA LOCAL INFILE '$(pwd)/csv-files/fact_sales.csv'
INTO TABLE fact_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;"
echo "fact_sales imported."

echo "All tables populated successfully!" 