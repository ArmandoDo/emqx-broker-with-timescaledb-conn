# Hypertables in TimescaleDB 2.20

## Overview

TimescaleDB 2.20 extends PostgreSQL to natively support time-series data. A **hypertable** is the foundational abstraction provided by TimescaleDB for working with time-series datasets. From a developer's perspective, it behaves like a regular PostgreSQL table. However, under the hood, it offers optimized storage, partitioning, and query performance for large-scale time-based data.

Understanding hypertables is essential for building efficient, maintainable, and scalable time-series applications.

---

## What Is a Hypertable?

A **hypertable** is a logical abstraction of multiple PostgreSQL tables (called **chunks**) partitioned across time (and optionally space). Think of it as a virtual table that hides the complexity of underlying storage layout while giving you high performance on inserts and queries.

Key properties:

* Behaves like a standard PostgreSQL table in queries.
* Automatically partitions data across time.
* Can also partition across space (e.g., device ID, location).
* Supports indexes, constraints, and compression features.

---

## What Are Chunks?

**Chunks** are the actual physical PostgreSQL tables that store the data. TimescaleDB automatically creates and manages these chunks based on the time range and optionally space.

### Key Characteristics:

| Property            | Description                                                      |
| ------------------- | ---------------------------------------------------------------- |
| Partitioned by      | Time (always) and optional space (e.g., tenant ID).              |
| Auto-created        | Chunks are created dynamically during insert operations.         |
| Independent objects | Each chunk is a standalone PostgreSQL table.                     |
| Optimized queries   | TimescaleDB automatically routes queries to the relevant chunks. |

Each chunk typically covers a specific time interval and is the fundamental unit of data retention, compression, and index management.

![Example](https://assets.timescale.com/docs/images/getting-started/hypertables-chunks.webp)

---

## Time and Space Dimensions

Hypertables are partitioned based on **dimensions**:

### 1. **Time Dimension** (required)

* Divides the hypertable into chunks based on a time interval (e.g., daily, hourly).
* Enables efficient pruning of irrelevant data during queries.
* Supports configurable chunk intervals.

### 2. **Space Dimension** (optional)

* Adds an additional level of partitioning (e.g., by sensor ID, region).
* Useful for sharding and scaling out.
* Enhances write parallelism and reduces contention.

A hypertable can have **one time dimension** and **one or more space dimensions**.

---

## Query Behavior

TimescaleDB transparently optimizes queries across chunks:

* **Query Routing**: When querying a hypertable, TimescaleDB determines which chunks contain relevant data.
* **Constraint Exclusion**: Only relevant chunks are scanned, improving performance.
* **Parallel Execution**: Queries can be parallelized across chunks, improving speed.

The query planner takes into account indexes, chunk constraints, and data locality to provide performance improvements over traditional table scans.

---

## Chunk Management

Chunks are automatically managed, but some aspects are configurable:

* **Chunk Time Interval**: Determines the size of each chunk. It affects performance, number of tables, and storage utilization.
* **Chunk Indexes**: Inherited from the hypertable or created specifically per chunk.
* **Metadata Catalog**: TimescaleDB tracks chunks and hypertable info in its internal catalog.

Each chunk can be independently compressed, indexed, or even dropped (in retention policies).

---

## Benefits of Using Hypertables

| Feature                    | Benefit                                                   |
| -------------------------- | --------------------------------------------------------- |
| Automatic partitioning     | Reduces manual sharding complexity.                       |
| Transparent querying       | Keeps developer experience simple.                        |
| Efficient storage          | Fine-grained control over data layout.                    |
| Scalable ingestion         | Handles millions of inserts per second.                   |
| Index optimization         | Chunk-level indexes speed up queries.                     |
| Native compression support | Reduces disk usage without sacrificing performance.       |
| Integration with policies  | Enables automated retention, reordering, and compression. |

---

## Summary

Hypertables in TimescaleDB 2.20 provide an abstraction layer that allows you to treat large, time-series datasets as a single logical table while gaining the performance and scalability benefits of time/space partitioning. Understanding how hypertables and chunks interact is foundational to building robust time-series applications.

---

## References

* [https://docs.timescale.com/use-timescale/latest/hypertables/](https://docs.timescale.com/use-timescale/latest/hypertables/)
* [https://docs.timescale.com/timescaledb/latest/how-to-guides/hypertables/](https://docs.timescale.com/timescaledb/latest/how-to-guides/hypertables/)
* TimescaleDB GitHub: [https://github.com/timescale/timescaledb](https://github.com/timescale/timescaledb)
