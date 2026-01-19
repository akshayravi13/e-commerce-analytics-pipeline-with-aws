# AWS Event Analytics Pipeline

A production-grade data engineering project that transforms streaming e-commerce events into a query-ready analytical dataset using AWS serverless technologies.

**Course:** DATA 516 - Scalable Data Systems, University of Washington  
**Date:** December 2025

## Overview

This capstone project was the final assignment for DATA 516 - Scalable Data Systems at the University of Washington's MS Data Science program. The assignment simulated a realistic data engineering scenario: building a production-grade analytics pipeline for high-volume e-commerce event data.

### The Problem Statement

The course provided a starter CloudFormation template that simulates a real-world data ingestion system—a Lambda function that generates 500,000-750,000 e-commerce events every 5 minutes and writes them to S3 as gzipped JSON files with Hive-style partitioning. After just one hour, this generates 7-9 million events. After a day, over 200 million.

The challenge: You're a data engineer at an e-commerce company. The product analytics team has been logging user events (page views, cart additions, purchases, searches), but data scientists can't effectively query the raw logs. **Your job is to build a production-grade analytics pipeline that transforms these raw streaming events into a reliable, performant dataset suitable for experiments and analysis.**

### Technical Requirements

The project had three core requirements:

1. **Extend the provided CloudFormation template** with pipeline infrastructure (Glue jobs, databases, output buckets)
2. **Handle incremental data** - New events arrive every 5 minutes; the pipeline must process only new data without reprocessing everything
3. **Support 5 specific analytical queries** - The dataset must enable fast, cost-effective answers to key business questions


## Architecture
![flowchart.png](assets/flowchart.png)

**Stack**: S3, AWS Glue, Athena, Lambda, EventBridge, CloudFormation

### Key Features

- **Incremental Processing**: Glue job bookmarks ensure only new data is processed, scaling costs with new data rather than total volume
- **Cost-Optimized Architecture**: Direct queries on Parquet vs. pre-aggregated Gold layers (~$0.0025 per query vs. $3.60/day for hourly refreshes)
- **Infrastructure as Code**: Fully reproducible CloudFormation template
- **Production-Ready**: Handles 600K+ events per 5-minute batch, processes 100M events for ~$0.42

## Dataset Statistics

- **94.4M events** processed across 152 files
- **1.87 GB** Parquet output (Snappy compressed)
- **12.7 hours** of event data
- **Event distribution**: 50% views, 20% cart adds, 10% purchases, 10% removals, 10% searches

## Key Engineering Decisions

1. **Parquet + Snappy over JSON + GZIP**: Traded 14% larger files for 5-10x faster queries
2. **No Gold Layer**: Cost analysis showed direct Parquet queries sufficient for query patterns
3. **DynamicFrame Sandwich**: Leverages Glue bookmarks while using full PySpark capabilities
4. **Partition Discovery**: MSCK REPAIR TABLE synchronizes Glue catalog with S3 partitions


## Analytical Queries

The pipeline supports five key business questions:

1. **Conversion Funnel**: View → Cart → Purchase rates by product
2. **Hourly Revenue**: Revenue patterns and average order values throughout the day
3. **Top Products**: Most-viewed products by category
4. **Category Performance**: Daily engagement metrics per category
5. **User Activity**: Unique users, sessions, and events per session



## Running the Pipeline

1. **Deploy Infrastructure**: `aws cloudformation create-stack --template-body file://infrastructure/capstone-starter.cfn.yml`
2. **Execute Pipeline**: Run cells in `build_pipeline.ipynb` to:
   - Upload ETL script to S3
   - Discover raw data partitions (MSCK REPAIR)
   - Run Glue ETL job
   - Discover processed partitions
   - Validate with test queries

## Results

**First Run** (validation):
- 15 files, 8.5M events, 254 seconds

**Second Run** (14 hours later):
- 137 NEW files, 86M events, 1,710 seconds
- ✅ Original 15 files **not reprocessed** (bookmark success)

**Cost**: $0.42 to process 94M events

## Lessons Learned

- Simple architectures often win—don't add complexity unless numbers justify it
- Cost awareness is critical: understand pricing models before designing solutions
- Incremental processing is essential for production pipelines at scale
- Deep tool knowledge (DynamicFrames, MSCK REPAIR, SerDe configs) matters for debugging

## Technologies

AWS Glue • Amazon S3 • Amazon Athena • AWS Lambda • EventBridge • CloudFormation • PySpark • Parquet

---

*This project demonstrates production data engineering skills: cost optimization, incremental ETL, infrastructure as code, and scalable architecture design.*