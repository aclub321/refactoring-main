# README
Imagine you have a piece of old code that needs to be fixed.
There is a service in your application. It is designed to export payments from the database to a set of CSV files. It also adds some logging records to the database.

Although the service works - it has some problems.
It was created a long time ago and, for some reason, doesn't have any tests.
Another problem - when there are many payments to export, the service runs for 2 hours and then kills the server without finishing.

## The challenge
You need to write tests and then refactor the service to make it process more data. Also, feel free to fix everything you find wrong!

## Files provided
You will find a rails application in the zip archive

## Setup
To setup up the application, please do the following:
```
bin/rails db:drop db:create db:migrate
bin/rails db < refactoring_development.sql
```
To run the export, you do
```
PaymentsExportService.new(Agent.first, Time.now, 'Company_1', "my_export_type").call
```
