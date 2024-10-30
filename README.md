## 🤔 What is it?

This Docker Compose template is based from original mage-ai

## 🙋‍♂️ Why did you create it?

We try to build ETL from end-to-end project

## First run

Rename dev.env to .env

## Make clean your environment prodction

At first run, with `docker compose up` mage-ai create two folder. 

* extractor : contains all configuration
* mage_data : contains mage-ai database

Our goal is to make this two files persitant and maintenable.
Put all sensitive variable into our `.env`

when we want to push our developement on repository, .env is not include instead we push dev.env 

dev.env must be filled according to your project


