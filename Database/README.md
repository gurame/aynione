# Ayni MySql

## Windows Users

### Requirements

a.- Java JRE <br />
b.- [MySql](https://www.mysql.com/downloads/) (Community Server at least) <br />

### Steps

Install Java JRE, based on the requirements on https://flywaydb.org/

Install MySql server in order to have "MySql Workbench" running.

After you have installed all the required software, open MySql Workbench and create a new Ayni database
```
create database Ayni
```
Create a copy of the configuration file **Conf/flyway-sample.conf**, and rename it to  **Conf/flyway.conf**, then fill it based on your database settings (this file will not upload to source control, based on gitignore configuration)

Get flyway database information on a console or terminal with:
```
flyway info
```
Finally, execute all the remaining scripts
```
flyway migrate
```
## MAC Users
Install [MySql](https://www.mysql.com/downloads/) server in order to have "MySql Workbench" running.

After you have installed all the required software, open MySql Workbench and create a new Ayni database
```
create database Ayni
```

Install flyway with [Homebrew](https://brew.sh/)
```
brew install flyway
```

Create a copy of **flyway mac sample.conf** and rename it to **flyway.conf**, change the corresponding values for url, username and password.

Then, in a terminal execute `info` and `migrate` commands:
```
$ flyway info
$ flyway migrate
```

## Useful Commands 

backup ayni 
```
mysqldump.exe -u root -p Ayni --routines --triggers > Ayni_backup.sql
```

SHOW GLOBAL STATUS;
EXPLAIN Select ....



## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
