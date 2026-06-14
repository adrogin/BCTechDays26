using System.Collections.ObjectModel;
using System.ComponentModel.DataAnnotations.Schema;
using System.Data;
using Microsoft.Data.SqlClient;

namespace BcSqlClient.DBCC
{
    public class BcSqlClient
    {
        public void DropCleanBuffers(string serverName, string databaseName, string userName, string password)
        {
            string connString = string.Format(
                "Server={0};Database={1};User ID={2};Password={3};Encrypt=false", serverName, databaseName, userName, password);
            RunDbccCommand("DBCC DROPCLEANBUFFERS", connString);
        }

        public void DropCleanBuffers(string serverName, string databaseName)
        {
            string connString = string.Format("Server={0};Database={1};Trusted_Connection=True;Encrypt=false", serverName, databaseName);
            RunDbccCommand("DBCC DROPCLEANBUFFERS", connString);
        }

		public int RunScalarCommand(string command, string serverName, string databaseName, string userName, string password)
		{
            string connString = string.Format(
                "Server={0};Database={1};User ID={2};Password={3};Encrypt=false", serverName, databaseName, userName, password);
			return RunScalarCommand(command, connString);
		}

		public DataTable SelectLocks(string serverName, string databaseName, string userName, string password)
		{
            string sqlCommandText = @"select
                sess.session_id,
                sess.row_count,
                locks.resource_type,
                locks.request_mode,
                locks.request_type,
                locks.request_status,
                count(*) as locks_count
            from sys.dm_exec_sessions sess
                join sys.dm_tran_locks locks on sess.session_id = locks.request_session_id
                left outer join sys.objects obj on locks.resource_associated_entity_id = obj.object_id
                left outer join sys.partitions parts on locks.resource_associated_entity_id = parts.hobt_id
            where sess.program_name = 'Microsoft Dynamics 365 Business Central Server'
                and resource_type != 'DATABASE'
                and (obj.name like '%Locking Test%' or object_name(parts.object_id) like '%Locking Test%')
            group by
                sess.session_id, sess.row_count,
                locks.resource_type, locks.request_mode,
                locks.request_type, locks.request_status";

            string connString = string.Format(
                "Server={0};Database={1};User ID={2};Password={3};Encrypt=false", serverName, databaseName, userName, password);
			return SelectLocks(sqlCommandText, connString);
		}

		public DataTable SelectLocks(string serverName, string databaseName, string userName, string password, int sessionId)
		{
            string sqlCommandText = @"
                select
                    sess.session_id,
                    sess.row_count,
                    locks.resource_type,
                    locks.request_mode,
                    locks.request_type,
                    locks.request_status,
                    count(*) as locks_count
                from sys.dm_exec_sessions sess
                    join sys.dm_tran_locks locks on sess.session_id = locks.request_session_id
                    left outer join sys.objects obj on locks.resource_associated_entity_id = obj.object_id
                    left outer join sys.partitions parts on locks.resource_associated_entity_id = parts.hobt_id
                where sess.program_name = 'Microsoft Dynamics 365 Business Central Server'
                    and resource_type != 'DATABASE'
                    and (obj.name like '%Locking Test%' or object_name(parts.object_id) like '%Locking Test%')
                    and sess.session_id = {0}
                group by
                    sess.session_id, sess.row_count,
                    locks.resource_type, locks.request_mode,
                    locks.request_type, locks.request_status";

            string connString = string.Format(
                "Server={0};Database={1};User ID={2};Password={3};Encrypt=false", serverName, databaseName, userName, password);
			return SelectLocks(string.Format(sqlCommandText, sessionId), connString);
		}

        public DataTable SelectLocks(string sqlCommand, string connectionString)
        {
            DataTable dataTable = CreateDataTable();
            DataRow dataRow;
            int i = 1;

            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sqlCommand, connection);
                SqlDataReader reader = command.ExecuteReader();

                while (reader.Read())
                {
                    dataRow = dataTable.NewRow();
                    dataRow["id"] = i++;
                    dataRow["session_id"] = reader["session_id"];
                    dataRow["row_count"] = reader["row_count"];
                    dataRow["resource_type"] = reader["resource_type"];
                    dataRow["request_mode"] = reader["request_mode"];
                    dataRow["request_type"] = reader["request_type"];
                    dataRow["request_status"] = reader["request_status"];
                    dataRow["locks_count"] = reader["locks_count"];

                    dataTable.Rows.Add(dataRow);                    
                }
            }

            return dataTable;
        }
        public int RunScalarCommand(string sqlCommand, string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sqlCommand, connection);
                return (int)command.ExecuteScalar();
            }
        }
        public void RunDbccCommand(string sqlCommand, string connectionString)
        {
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                SqlCommand command = new SqlCommand(sqlCommand, connection);
                command.ExecuteNonQuery();
            }
        }

        private DataTable CreateDataTable()
        {
            DataTable table = new DataTable("DBLocks");

            table.Columns.Add(CreateDataColumn("id", "System.Int32", true));
            table.Columns.Add(CreateDataColumn("session_id", "System.Int32"));
            table.Columns.Add(CreateDataColumn("row_count", "System.Int32"));
            table.Columns.Add(CreateDataColumn("resource_type", "System.String"));
            table.Columns.Add(CreateDataColumn("request_mode", "System.String"));
            table.Columns.Add(CreateDataColumn("request_type", "System.String"));
            table.Columns.Add(CreateDataColumn("request_status", "System.String"));
            table.Columns.Add(CreateDataColumn("locks_count", "System.Int32"));

            DataColumn[] PrimaryKeyColumns = [table.Columns["id"]];
            table.PrimaryKey = PrimaryKeyColumns;

            return table;
        }

        private DataColumn CreateDataColumn(string name, string dataType)
        {
            return CreateDataColumn(name, dataType, false);
        }
        private DataColumn CreateDataColumn(string name, string dataType, bool isUnique)
        {
            DataColumn column = new DataColumn
            {
                DataType = System.Type.GetType(dataType),
                ColumnName = name,
                ReadOnly = true,
                Unique = isUnique
            };
            return column;
        }
    }
}