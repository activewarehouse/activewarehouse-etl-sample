## How to run

* make sure to have mysql installed and running (`brew install mysql`)
* install ruby 1.9.3 (and I suggest RVM if possible)
* edit `config/database.yml` to reflect your mysql setup
* then:

```
bundle install
mysql -u root -p -e "create database aw_etl_simple_etl_execution"
mysql -u root -p -e "create database aw_etl_simple_datawarehouse CHARACTER SET utf8 COLLATE utf8_general_ci"
    
bundle exec etl etl/process_all.ebf
```
