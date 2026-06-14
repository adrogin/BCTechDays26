codeunit 50700 "Locking Action"
{
    TableNo = "Session Parameters";

    trigger OnRun()
    var
        TempSessionParameters: Record "Session Parameters" temporary;
    begin
        // Reading session parameters into a temporary table to start a clean transaction and avoid polluting the test session with queries against setup tables
        // SetTransactionType doesn't work after any database query
        ReadParametersToTempTable(TempSessionParameters, Rec);
        Commit();

        SetTableMark(TempSessionParameters, Rec."Session No.");
        DoLockingAction(TempSessionParameters);
    end;

    local procedure DoLockingAction(var SessionParameters: Record "Session Parameters")
    var
        LockingTest: Record "Locking Test";
        LockingScenarios: Codeunit "Locking Scenarios";
    begin
        // "Set Table Mark" is not one of the locking actions. It is required to find the SQL connection id used by the currect transaction
        // and actually should not be in this list.
        // But the session running the transaction must know which table to mark, and this is the only way to send parameters to a background session.
        SessionParameters.Reset();
        SessionParameters.SetFilter(Action, '<>%1', Enum::"Session Action"::"Set Table Mark");
        SessionParameters.FindSet();
        repeat
            SetTransactionType(SessionParameters."Transaction Type");

            SessionEventLogger.LogWait(SessionId(), SessionParameters."Wait Time Before Locking");
            Sleep(SessionParameters."Wait Time Before Locking");
            SessionEventLogger.LogAction(SessionId(), SessionParameters);

            case SessionParameters."Lock Type" of
                SessionParameters."Lock Type"::"Read Uncommitted":
                    LockingTest.ReadIsolation := LockingTest.ReadIsolation::ReadUncommitted;
                SessionParameters."Lock Type"::"Read Committed":
                    LockingTest.ReadIsolation := LockingTest.ReadIsolation::ReadCommitted;
                SessionParameters."Lock Type"::"Repeatable Read":
                    LockingTest.ReadIsolation := LockingTest.ReadIsolation::RepeatableRead;
                SessionParameters."Lock Type"::UpdLock:
                    LockingTest.ReadIsolation := LockingTest.ReadIsolation::UpdLock;
                SessionParameters."Lock Type"::LockTable:
                    LockingTest.LockTable();
            end;

            if SessionParameters.Action in [
                SessionParameters.Action::Read,
                SessionParameters.Action::Modify,
                SessionParameters.Action::ModifyInLoop,
                SessionParameters.Action::ModifyAll,
                SessionParameters.Action::DeleteAll]
            then
                LockingTest.SetRange("Entry No.", SessionParameters."First Record No.", SessionParameters."Last Record No.");

            case SessionParameters.Action of
                SessionParameters.Action::Read:
                    begin
                        LockingTest.FindSet();
                        LockingTest.Next(SessionParameters."Last Record No.");
                    end;
                SessionParameters.Action::ReadOne:
                    LockingTest.FindFirst();
                SessionParameters.Action::Insert:
                    LockingScenarios.InsertRecords(SessionParameters."First Record No.", SessionParameters."Last Record No.");
                SessionParameters.Action::ModifyInLoop:
                    ModifyInLoop(LockingTest);
                SessionParameters.Action::Modify:
                    ModifyOne(LockingTest);
                SessionParameters.Action::ModifyAll:
                    LockingTest.ModifyAll(Description, System.CreateGuid());
                SessionParameters.Action::DeleteAll:
                    LockingTest.DeleteAll();
            end;

            SessionEventLogger.LogWait(SessionId(), SessionParameters."Wait Time After Locking");
            Sleep(SessionParameters."Wait Time After Locking");

            if SessionParameters."Commit After Action" then
                CommitTransaction();
        until SessionParameters.Next() = 0;
    end;

    local procedure ReadParametersToTempTable(var TempSessionParameters: Record "Session Parameters" temporary; var SrcSessionParameters: Record "Session Parameters")
    begin
        TempSessionParameters.Reset();
        TempSessionParameters.DeleteAll();

        SrcSessionParameters.SetRange("Session No.", SrcSessionParameters."Session No.");
        SrcSessionParameters.FindSet();
        repeat
            TempSessionParameters := SrcSessionParameters;
            TempSessionParameters.Insert();
        until SrcSessionParameters.Next() = 0;
    end;

    procedure SetLoggerInstance(SessionEventLoggerInstance: Codeunit "Session Event Logger")
    begin
        SessionEventLogger := SessionEventLoggerInstance;
    end;

    procedure GetLoggerInstance(): Codeunit "Session Event Logger"
    begin
        exit(SessionEventLogger);
    end;

    local procedure CommitTransaction()
    begin
        SessionEventLogger.LogCommit(SessionId());
        Commit();
    end;

    local procedure SetTransactionType(NewTransactionType: Enum "Session Transaction Type")
    begin
        if NewTransactionType = Enum::"Session Transaction Type"::Default then
            exit;

        case NewTransactionType of
            NewTransactionType::UpdateNoLocks:
                CurrentTransactionType := TransactionType::UpdateNoLocks;
            NewTransactionType::Update:
                CurrentTransactionType := TransactionType::Update;
            NewTransactionType::Browse:
                CurrentTransactionType := TransactionType::Browse;
            NewTransactionType::Report:
                CurrentTransactionType := TransactionType::Report;
            NewTransactionType::Snapshot:
                CurrentTransactionType := TransactionType::Snapshot;
        end;

        SessionEventLogger.LogTransactionTypeChange(SessionId(), NewTransactionType);
    end;

    local procedure ModifyInLoop(var LockingTest: Record "Locking Test")
    begin
        LockingTest.FindSet();
        repeat
            LockingTest.Description := System.CreateGuid();
            LockingTest.Modify();
        until LockingTest.Next() = 0;
    end;

    local procedure ModifyOne(var LockingTest: Record "Locking Test")
    begin
        LockingTest.Description := System.CreateGuid();
        LockingTest.Modify();
    end;

    local procedure SetTableMark(var SessionParameters: Record "Session Parameters"; SessionNo: Integer)
    var
        LockStats: Codeunit "Lock Stats";
    begin
        SessionParameters.SetRange("Session No.", SessionNo);
        SessionParameters.SetRange(Action, Enum::"Session Action"::"Set Table Mark");
        SessionParameters.FindFirst();
        LockStats.SetTableMark(SessionParameters."First Record No.");
    end;

    var
        SessionEventLogger: Codeunit "Session Event Logger";
}