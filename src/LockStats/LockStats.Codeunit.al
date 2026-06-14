codeunit 50704 "Lock Stats"
{
    procedure SetTableMark(MarkerTableNo: Integer)
    var
        RecRef: RecordRef;
    begin
        SelectLatestVersion();
        RecRef.Open(MarkerTableNo);
        RecRef.ReadIsolation := IsolationLevel::RepeatableRead;
        if RecRef.FindLast() then;
    end;

    procedure InitSessionId(BgSessionId: Integer; MarkerTableName: Text)
    var
        ServerSetup: Record "Locking Test Server Setup";
        ActiveTestSession: Record "Active Test Session";
        BcSqlClient: DotNet BcSqlClient;
        MySqlSessionId: Integer;
        QueryText: Label @'select lock.request_session_id from sys.dm_tran_locks lock
            join sys.objects obj on lock.resource_associated_entity_id = obj.object_id
            where request_mode = ''IS''
            and request_status = ''GRANT''
            and obj.name like ''%%1%''';
    begin
        ServerSetup.Get();
        BcSqlClient := BcSqlClient.BcSqlClient();
        MySqlSessionId :=
            BcSqlClient.RunScalarCommand(
                StrSubstNo(QueryText, MarkerTableName),
                ServerSetup."Server Name",
                ServerSetup."Database Name",
                ServerSetup."User Name",
                ServerSetup.Password);

        if ActiveTestSession.Get(BgSessionId) then
            ActiveTestSession.Delete();

        ActiveTestSession."BC Session ID" := BgSessionId;
        ActiveTestSession."SQL Session ID" := MySqlSessionId;
        ActiveTestSession.Insert();

        Commit();
    end;

    procedure GetSessionLocks(BcSessionId: Integer; var TempLockStats: Record "Lock Stats")
    var
        ActiveTestSession: Record "Active Test Session";
        ResultDataTable: DotNet DataTable;
        Row: DotNet DataRow;
        I: Integer;
    begin
        ActiveTestSession.Get(BcSessionId);

        if TrySelectLocks(ResultDataTable, ActiveTestSession."SQL Session ID") then
            for I := 0 to ResultDataTable.Rows.Count - 1 do begin
                Row := ResultDataTable.Rows.Item(I);
                TempLockStats.ID := Row.Item('id');
                TempLockStats."Session ID" := Row.Item('session_id');
                TempLockStats."Session Row Count" := Row.Item('row_count');
                TempLockStats."Request Mode" := Row.Item('request_mode');
                TempLockStats."Request Type" := Row.Item('request_type');
                TempLockStats."Request Status" := Row.Item('request_status');
                TempLockStats."Resource Type" := Row.Item('resource_type');
                TempLockStats."Locks Count" := Row.Item('locks_count');
                TempLockStats.Insert();
            end;
    end;

    [TryFunction]
    local procedure TrySelectLocks(var ResultDataTable: DotNet DataTable; SqlSessionId: Integer)
    var
        ServerSetup: Record "Locking Test Server Setup";
        BcSqlClient: DotNet BcSqlClient;
    begin
        ServerSetup.Get();
        BcSqlClient := BcSqlClient.BcSqlClient();
        ResultDataTable :=
            BcSqlClient.SelectLocks(
                ServerSetup."Server Name",
                ServerSetup."Database Name",
                ServerSetup."User Name",
                ServerSetup.Password,
                SqlSessionId);
    end;
}
