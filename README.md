# ActiveWarehouse-ETL sample

This is a sample of ETL built on a very small data set (the rails git commit log) for educational purposes.

[![Build Status](https://secure.travis-ci.org/activewarehouse/activewarehouse-etl-sample.png)](http://travis-ci.org/activewarehouse/activewarehouse-etl-sample)

## How to run

More explanations will be added here later on. In the mean time:

* make sure to have mysql installed and running (`brew install mysql`)
* install ruby 1.9.3 (and I suggest RVM if possible)
* edit `config/database.yml` to reflect your mysql setup
* then:

```
bundle install
mysql -u root -p -e "create database aw_etl_sample_etl_execution"
mysql -u root -p -e "create database aw_etl_sample_datawarehouse CHARACTER SET utf8 COLLATE utf8_general_ci"
    
bundle exec etl etl/process_all.ebf
```

## Tests

There are a couple of specs to show how to test your dimension builders. Run with:

`rake spec`

## Contributors

* Thibaut Barrère
* Alisson Cavalcante Agiani

## Contributing

Pull-request are most-welcome! Get in touch before working on anything significant though.

## License

MIT