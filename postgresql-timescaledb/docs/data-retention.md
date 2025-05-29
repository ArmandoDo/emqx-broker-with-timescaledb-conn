# Data Retention Policies in TimescaleDB 2.20

## Overview

In time-series applications, data often grows rapidly and can become costly to store indefinitely. TimescaleDB 2.20 introduces **automated data retention policies** that help manage the lifecycle of your time-series data by automatically removing old data no longer needed for analysis or compliance.

Retention policies are tightly integrated with **hypertables** and operate at the **chunk level**, enabling granular, performant, and efficient deletion of data based on time.

---

## Purpose of Retention Policies

Data retention policies are essential for:

| Goal                    | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| Storage optimization    | Prevents unnecessary storage of stale data.                |
| Performance maintenance | Reduces query and index overhead from old data.            |
| Regulatory compliance   | Helps enforce data lifecycle policies (e.g., GDPR, HIPAA). |
| Cost reduction          | Minimizes disk usage and infrastructure expenses.          |

Retention is typically applied to data that is no longer queried but still exists in storage.

---

## Relationship to Hypertables and Chunks

Retention policies operate on **hypertables**, but execution is performed at the **chunk level**:

* Each **chunk** represents a bounded time interval.
* Retention logic uses the **time dimension** to determine which chunks fall **outside the defined retention window**.
* Deletion is efficient because entire chunks (i.e., physical tables) can be dropped at once — no need for slow row-level deletions.

**Key Insight**: Since chunks are time-partitioned, deleting entire chunks is orders of magnitude faster than traditional `DELETE` operations.

---

## How Retention Policies Work

### Policy Structure

A **retention policy** defines a **cutoff interval** (e.g., 30 days, 6 months) relative to the current time. Chunks **older than this interval** are marked for deletion.

**Execution Mechanism:**

* Policies are executed via TimescaleDB’s **background job framework**.
* Jobs run on a schedule (default: hourly) and check for old chunks.
* When eligible chunks are found, they are **dropped** (i.e., the underlying tables are removed).

### System Tables and Metadata

TimescaleDB manages retention policies through internal catalog tables and job management metadata:

| Component                        | Purpose                                              |
| -------------------------------- | ---------------------------------------------------- |
| `timescaledb_information.jobs`   | Tracks job status and execution history.             |
| `timescaledb_config.bgw_job`     | Contains job configuration details.                  |
| `timescaledb_catalog.hypertable` | Metadata for hypertables, including chunk intervals. |
| `timescaledb_catalog.chunk`      | Metadata for individual chunks (timestamps, sizes).  |

---

## Policy Execution Lifecycle

Here is how a retention policy typically executes:

1. **Policy Definition**: A retention policy is associated with a hypertable and a time retention interval.
2. **Job Scheduling**: A background job is scheduled to run periodically (default: every hour).
3. **Chunk Evaluation**: The job queries TimescaleDB’s catalog to identify chunks whose time interval ends before the cutoff.
4. **Chunk Dropping**: The job drops those chunks from the database.
5. **Logging & Monitoring**: Execution results are recorded in the job logs.

---

## Key Considerations

| Consideration                 | Description                                                                                   |
| ----------------------------- | --------------------------------------------------------------------------------------------- |
| **Retention granularity**     | Operates at the chunk level, so retention precision is tied to chunk intervals.               |
| **Compression compatibility** | Works with compressed chunks. Compressed chunks can be dropped just like uncompressed ones.   |
| **Data loss**                 | Deletion is **permanent** — retention should be aligned with business requirements.           |
| **Job control**               | Retention policies can be paused, resumed, or manually executed via TimescaleDB job controls. |
| **Multinode awareness**       | Retention jobs in multinode setups coordinate across data nodes for distributed hypertables.  |

---

## Benefits of Using Retention Policies

| Benefit                  | Description                                                    |
| ------------------------ | -------------------------------------------------------------- |
| Automated lifecycle      | No manual intervention needed to remove stale data.            |
| High performance         | Chunk-level deletion avoids costly row scans.                  |
| Resource optimization    | Frees up storage and reduces memory/index bloat.               |
| Better query performance | Smaller datasets mean faster scans and index usage.            |
| Seamless integration     | Works transparently with hypertables and compression features. |

---

## Core Functions for Data Retention and Compression in TimescaleDB 2.20

In TimescaleDB 2.20, managing data lifecycle involves scheduling background jobs that automate the retention and compression of data in hypertables. The following functions are central to implementing these policies:

### `add_retention_policy`

This function schedules a background job to automatically drop chunks from a hypertable or continuous aggregate that are older than a specified interval.

* **Purpose**: Implements a data retention policy by removing outdated data.

### `add_columnstore_policy`

Introduced in TimescaleDB v2.18.0, this function replaces the deprecated `add_compression_policy` and schedules a job to automatically convert chunks of a hypertable to columnstore format after a specified interval.

* **Purpose**: Enhances storage efficiency and query performance by converting row-based chunks to columnar storage.

### `remove_retention_policy` and `remove_columnstore_policy`

These functions remove existing retention and columnstore policies from a hypertable.([Documentación de Timescale][3])

* **Purpose**: Stops the background jobs associated with the respective policies.
* **Usage**:

* `remove_retention_policy(relation)`: Removes the retention policy from the specified hypertable.
* `remove_columnstore_policy(hypertable)`: Removes the columnstore policy from the specified hypertable.

Note: Removing a policy does not affect existing data; it only halts the automated process.

---

## Summary

Data retention policies in TimescaleDB 2.20 are a powerful mechanism for managing storage efficiently in time-series databases. By leveraging the underlying chunk architecture of hypertables, TimescaleDB enables high-performance, automated, and scalable deletion of stale data. Understanding how these policies function and interact with the hypertable system is essential for maintaining both performance and compliance in time-series applications.

---

## References

* Official Documentation – Retention: [https://docs.timescale.com/use-timescale/latest/data-retention/](https://docs.timescale.com/use-timescale/latest/data-retention/)
* TimescaleDB Docs – How-to Guide: [https://docs.timescale.com/timescaledb/latest/how-to-guides/data-retention/](https://docs.timescale.com/timescaledb/latest/how-to-guides/data-retention/)
* TimescaleDB Compression: [https://docs.timescale.com/use-timescale/latest/compression/](https://docs.timescale.com/use-timescale/latest/compression/)
* TimescaleDB API Reference – Retention Functions: [https://docs.timescale.com/api/latest/](https://docs.timescale.com/api/latest/)
* GitHub Repository: [https://github.com/timescale/timescaledb](https://github.com/timescale/timescaledb)