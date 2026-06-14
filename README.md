# Demo app for my session at BC TechDays 2026

A Business Central extension demonstrating table locks acquired by various AL data access statements.

### Build

1. Build the `BcSqlClient` library
```
cd .\BcSqlClient\
dotnet build
```
2. Create a directory with the name `.netpackages` in the current project and copy `BcSqlClient.dll` into this directory.
3. Copy the compiled `BcSqlClient.dll` into the BC server's Add-Ins directory (`C:\Program Files\Microsoft Dynamics 365 Business Central\<BC Version>\Service\Add-ins`).
4. Restart the BC service.
5. Build and deploy the AL extension.

### Setup

1. Open the `Locking Test` page.
2. Navigate to `Server Setup` and configure the SQL server parameters. Currently, only SQL Server authentication with username/password is implemented. This is sufficient to run the demo in BC Docker containers, but if you run the test on a server with authentication via SSPI, connection strings must be updated in the .Net library.
3. In the `Locking Test` page, run the `Initialize Test Table` action.

### Run test

Some predefined test scenarios are available in the Actions menu. These actions initialize the test setup and start the test execution immediately. You can change the setup or configure your own test manually in the `Session Parameters`. Once setup is done, push `Run` to start the test execution.


`Refresh Locks` action selects active locks from the `sys.dm_tran_locks` management view and displays the list of locks in the factboxes.

`Refresh Events` updates the subpage which displays the background session events.

## Dev notes

I have to use some hacks behind the scene to obtain the id of the SQL session in which the current transaction is executed. First of all, there is no functionality in AL that would expose this id. Besides, Business Central uses connection pooling, and the SQL connection is retrieved from the pool at the start of a transaction and returned back to the pool once the transaction is completed. Therefore, two consecutive transaction can run in different SQL connections, even within one BC session.

To retrieve the session id, I use two dummy tables `Marker Table 1` and `Marker Table 2`. Before starting the test scenario, the `Locking Action` codeunit "marks" one of the tables - it simply invokes `FindLast` with `RepeatableRead` isolation. This way, an `IS` lock is acquired on the table and remains until the end of the transaction. This intent shared lock is the mark used by the test runner to identify the session. Once the table is marked, the `Locking Scenarios` codeunit can select active locks acquired on each of the marker tables with respective session ids (see `InitialzieSqlSessionIds` function).

> [!WARNING]
> Because of connection pooling, connection id may change between transactions, and the approach described above will not work in scenarios with `Commit After Action` option enabled.