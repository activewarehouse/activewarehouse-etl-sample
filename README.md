# ActiveWarehouse-ETL sample

This is a sample of ETL built on a very small data set (the rails git commit log) for educational purposes.

A work-in-progress of visualization can be seen online here:

[http://activewarehouse-etl-sample.herokuapp.com/](http://activewarehouse-etl-sample.herokuapp.com)

# How to run

More explanations will be added here later on. In the mean time:

    bundle install
    mysql -u root -p -e "create database aw_etl_sample_etl_execution"
    mysql -u root -p -e "create database aw_etl_sample_datawarehouse CHARACTER SET utf8 COLLATE utf8_general_ci"
    
    bundle exec etl etl/process_all.ebf

# Contributors

* Thibaut Barrère
* Alisson Cavalcante Agiani