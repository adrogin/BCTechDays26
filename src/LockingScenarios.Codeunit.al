codeunit 50701 "Locking Scenarios"
{
    procedure RunScenario(): List of [Integer]
    begin
        InitializeSession(false);
        exit(StartTwoSessionsWithParameters())
    end;

    #region Preset scenarios
    procedure RunLockingScenarioModifyOneBeforeRange(): List of [Integer]
    var
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ModifyRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 1, 0, 25000));
        SessionIds.Add(ModifyRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 15000, 2000, 10000));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioModifyRangeLoopBeforeOne(): List of [Integer]
    var
        SessionParameters: Record "Session Parameters";
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();

        SessionParameters := InitSessionParameters(1, Enum::"Session Action"::ModifyInLoop, 1, 15000, 0, 25000);
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 1", SessionParameters));

        SessionIds.Add(ModifyRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 1, 3000, 0));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioModifyMultipleRangesBeforeOne(): List of [Integer]
    var
        SessionParameters: Record "Session Parameters";
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();

        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 4000, 0, 0, Enum::"Session Lock Type"::Default);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 4001, 8000, 0, 0, Enum::"Session Lock Type"::Default);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 8001, 12000, 0, 0, Enum::"Session Lock Type"::Default);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 12001, 15000, 0, 15000, Enum::"Session Lock Type"::Default);

        InitSessionParameters(2, Enum::"Session Action"::ModifyAll, 20000, 20000, 3000, 5000, Enum::"Session Lock Type"::Default);

        exit(StartTwoSessionsWithParameters());
    end;

    procedure RunLockingScenarioModifyRangeBeforeOne(): List of [Integer]
    var
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ModifyRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 15000, 0, 25000));
        SessionIds.Add(ModifyRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 1, 3000, 0));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioModifyRangeBeforeReadCommitted(): List of [Integer]
    var
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ModifyRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 15000, 0, 25000));
        SessionIds.Add(ReadRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 1, 3000, 0, Enum::"Session Lock Type"::"Read Committed"));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioModifyOneBeforeReadingRangeRepeatableRead(): List of [Integer]
    var
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ModifyRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 1, 0, 15000));
        SessionIds.Add(ReadRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 15000, 2000, 5000, Enum::"Session Lock Type"::"Repeatable Read"));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioReadRangeRepeatableReadBeforeModifyOne(): List of [Integer]
    var
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ReadRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 15000, 0, 35000, Enum::"Session Lock Type"::"Repeatable Read"));
        SessionIds.Add(ModifyRecordsFromBottom(Codeunit::"Locking Session Wrapper 2", 2, 1, 2000, 0));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioModifyRangeNoEscalationBeforeModifyNone(): List of [Integer]
    var
        SessionParameters: Record "Session Parameters";
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionParameters := InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 4000, 0, 25000);
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 1", SessionParameters));

        // Setting the first and the last entry no. to -1, so that Modify does not find anything to update
        SessionParameters := InitSessionParameters(2, Enum::"Session Action"::ModifyAll, -1, -1, 2000, 0);
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 2", SessionParameters));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioReadRangeRepeatableReadBeforeModifyNone(): List of [Integer]
    var
        SessionParameters: Record "Session Parameters";
        SessionIds: List of [Integer];
    begin
        InitializeTestScenario();
        SessionIds.Add(ReadRecordsFromTop(Codeunit::"Locking Session Wrapper 1", 1, 15000, 0, 35000, Enum::"Session Lock Type"::"Repeatable Read"));

        // Setting the first and the last entry no. to -1, so that Modify does not find anything to update
        SessionParameters := InitSessionParameters(2, Enum::"Session Action"::ModifyAll, -1, -1, 2000, 0);
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 2", SessionParameters));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure RunLockingScenarioTwoRecordsDeadlock(): List of [Integer]
    begin
        InitializeTestScenario();

        // Session 1: Acquire IU lock on record 1, wait for 5 seconds, then request IU lock on record 2
        InitSessionParameters(1, Enum::"Session Action"::Read, 1, 1, 0, 5000, Enum::"Session Lock Type"::UpdLock);
        InitSessionParameters(1, Enum::"Session Action"::Read, 2, 2, 0, 10000, Enum::"Session Lock Type"::UpdLock);

        // Session 2: Acquire IU lock on record 2, wait for 3 seconds, then request IU lock on record 1
        InitSessionParameters(2, Enum::"Session Action"::Read, 2, 2, 0, 3000, Enum::"Session Lock Type"::UpdLock);
        InitSessionParameters(2, Enum::"Session Action"::Read, 1, 1, 0, 10000, Enum::"Session Lock Type"::UpdLock);

        exit(StartTwoSessionsWithParameters());
    end;

    procedure RunLockingScenarioOneRecordDeadlock(): List of [Integer]
    begin
        InitializeTestScenario();

        // Both sessions do the same scenario: Acquire S lock on record 1, wait for 2 seconds, then attempt to update this record
        InitSessionParameters(1, Enum::"Session Action"::Read, 1, 1, 0, 2000, Enum::"Session Lock Type"::"Repeatable Read");
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 1, 0, 10000);

        InitSessionParameters(2, Enum::"Session Action"::Read, 1, 1, 0, 2000, Enum::"Session Lock Type"::"Repeatable Read");
        InitSessionParameters(2, Enum::"Session Action"::ModifyAll, 1, 1, 0, 10000);

        exit(StartTwoSessionsWithParameters());
    end;

    procedure RunLockingScenarioOverlappingRangesDeadlock(): List of [Integer]
    begin
        InitializeTestScenario();

        InitSessionParameters(1, Enum::"Session Action"::Read, 1, 1000, 0, 2000, Enum::"Session Lock Type"::UpdLock);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 1000, 0, 10000);

        InitSessionParameters(2, Enum::"Session Action"::Read, 800, 1500, 1000, 2000, Enum::"Session Lock Type"::"Repeatable Read");
        InitSessionParameters(2, Enum::"Session Action"::ModifyAll, 800, 1500, 0, 10000);

        exit(StartTwoSessionsWithParameters());
    end;

    procedure RunLockingScenarioModifyOneStaleRecord(): List of [Integer]
    begin
        InitializeTestScenario();

        InitSessionParameters(1, Enum::"Session Action"::Read, 1, 1000, 0, 2000, Enum::"Session Lock Type"::UpdLock);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 1000, 0, 5000);

        InitSessionParameters(2, Enum::"Session Action"::Read, 800, 800, 1000, 2000, Enum::"Session Lock Type"::"Read Committed");
        InitSessionParameters(2, Enum::"Session Action"::Modify, 800, 800, 0, 5000);

        exit(StartTwoSessionsWithParameters());
    end;

    procedure RunLockingScenarioModifyAllLostUpdate(): List of [Integer]
    begin
        InitializeTestScenario();

        InitSessionParameters(1, Enum::"Session Action"::Read, 1, 1000, 0, 2000, Enum::"Session Lock Type"::UpdLock);
        InitSessionParameters(1, Enum::"Session Action"::ModifyAll, 1, 1000, 0, 5000);

        InitSessionParameters(2, Enum::"Session Action"::Read, 800, 1500, 1000, 2000, Enum::"Session Lock Type"::"Repeatable Read");
        InitSessionParameters(2, Enum::"Session Action"::ModifyAll, 800, 1500, 0, 5000);

        exit(StartTwoSessionsWithParameters());
    end;

    #endregion

    procedure InitializeTestTable()
    var
        LockingTest: Record "Locking Test";
        I: Integer;
    begin
        LockingTest.DeleteAll();

        for I := 1 to GetMaxEntryNo() do
            InsertOneRecord(I);
    end;

    procedure InsertOneRecord(EntryNo: Integer)
    var
        LockingTest: Record "Locking Test";
    begin
        LockingTest."Entry No." := EntryNo;
        LockingTest.Description := System.CreateGuid();
        LockingTest.Insert();
    end;

    procedure InsertRecords(FirstEntryNo: Integer; LastEntryNo: Integer)
    var
        I: Integer;
    begin
        for I := FirstEntryNo to LastEntryNo do
            InsertOneRecord(I);
    end;

    procedure GetMaxEntryNo(): Integer
    begin
        exit(20000);
    end;

    procedure ModifyRecordsFromTop(CodeunitNo: Integer; SessionNo: Integer; NoOfRecords: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer): Integer
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters := InitSessionParameters(SessionNo, Enum::"Session Action"::ModifyAll, 1, NoOfRecords, WaitTimeBefore, WaitTimeAfter);
        exit(StartSessionWithParameters(CodeunitNo, SessionParameters));
    end;

    procedure ModifyRecordsFromBottom(CodeunitNo: Integer; SessionNo: Integer; NoOfRecords: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer): Integer
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters := InitSessionParameters(
            SessionNo, Enum::"Session Action"::ModifyAll, GetMaxEntryNo() - NoOfRecords + 1, GetMaxEntryNo(), WaitTimeBefore, WaitTimeAfter);
        exit(StartSessionWithParameters(CodeunitNo, SessionParameters));
    end;

    procedure ReadRecordsFromTop(CodeunitNo: Integer; SessionNo: Integer; NoOfRecords: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer; LockType: Enum "Session Lock Type"): Integer
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters := InitSessionParameters(SessionNo, Enum::"Session Action"::Read, 1, NoOfRecords, WaitTimeBefore, WaitTimeAfter, LockType);
        exit(StartSessionWithParameters(CodeunitNo, SessionParameters));
    end;

    procedure ReadRecordsFromBottom(CodeunitNo: Integer; SessionNo: Integer; NoOfRecords: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer; LockType: Enum "Session Lock Type"): Integer
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters := InitSessionParameters(
            SessionNo, Enum::"Session Action"::Read, GetMaxEntryNo() - NoOfRecords + 1, GetMaxEntryNo(), WaitTimeBefore, WaitTimeAfter, LockType);
        exit(StartSessionWithParameters(CodeunitNo, SessionParameters));
    end;

    procedure GetLastSessionIDs(): List of [Integer]
    var
        LockingSessionEvent: Record "Locking Session Event";
        SessionIDs: List of [Integer];
    begin
        if LockingSessionEvent.FindSet() then
            repeat
                if not SessionIDs.Contains(LockingSessionEvent."Session ID") then
                    SessionIDs.Add(LockingSessionEvent."Session ID");
            until LockingSessionEvent.Next() = 0;

        // If no active sessions, add dummy values for sessions IDs for page filters
        if SessionIDs.Count < 1 then
            SessionIDs.Add(-1);
        if SessionIDs.Count < 2 then
            SessionIDs.Add(-1);

        exit(SessionIDs);
    end;

    procedure IsSessionActive(SessionID: Integer): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SetRange("Session ID", SessionID);
        exit(not ActiveSession.IsEmpty());
    end;

    local procedure InitializeSession(ClearParams: Boolean)
    var
        LockingTest: Record "Locking Test";
    begin
        if LockingTest.IsEmpty() then
            Error('Test table must be initialized before running test scenarios. Run the Initialize Table action to prepare demo data.');

        VerifyTestNotRunning();
        ClearTables(ClearParams);
    end;

    procedure InitializeTestScenario()
    begin
        InitializeSession(true);
    end;

    local procedure InitSessionParameters(
        SessionNo: Integer; Action: Enum "Session Action"; FirstRecordNo: Integer; LastRecordNo: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer; LockType: Enum "Session Lock Type"): Record "Session Parameters"
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters."Session No." := SessionNo;
        SessionParameters."Action No." := GetLastActionNoForSession(SessionNo) + 1;
        SessionParameters.Action := Action;
        SessionParameters."First Record No." := FirstRecordNo;
        SessionParameters."Last Record No." := LastRecordNo;
        SessionParameters."Wait Time Before Locking" := WaitTimeBefore;
        SessionParameters."Wait Time After Locking" := WaitTimeAfter;
        SessionParameters."Lock Type" := LockType;
        SessionParameters.Insert();
        Commit();

        exit(SessionParameters);
    end;

    local procedure GetLastActionNoForSession(SessionNo: Integer): Integer
    var
        SessionParameters: Record "Session Parameters";
    begin
        SessionParameters.SetRange("Session No.", SessionNo);
        if SessionParameters.FindLast() then
            exit(SessionParameters."Action No.");

        exit(0);
    end;

    local procedure InitSessionParameters(
        SessionNo: Integer; Action: Enum "Session Action"; FirstRecorsNo: Integer; LastRecordNo: Integer; WaitTimeBefore: Integer; WaitTimeAfter: Integer): Record "Session Parameters"
    begin
        exit(InitSessionParameters(SessionNo, Action, FirstRecorsNo, LastRecordNo, WaitTimeBefore, WaitTimeAfter, Enum::"Session Lock Type"::Default));
    end;

    local procedure StartSessionWithParameters(CodeunitNo: Integer; SessionParameters: Record "Session Parameters"): Integer
    var
        SessionId: Integer;
    begin
        // StartSession(SessionId, Codeunit::"Locking Session Controller", CompanyName, SessionParameters);
        StartSession(SessionId, CodeunitNo, CompanyName, SessionParameters);
        exit(SessionId);
    end;

    local procedure StartTwoSessionsWithParameters(): List of [Integer]
    var
        SessionParameters: Record "Session Parameters";
        SessionIds: List of [Integer];
    begin
        SessionParameters.SetRange("Session No.", 1);
        SessionParameters.FindFirst();
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 1", SessionParameters));

        SessionParameters.SetRange("Session No.", 2);
        SessionParameters.FindFirst();
        SessionIds.Add(StartSessionWithParameters(Codeunit::"Locking Session Wrapper 2", SessionParameters));

        InitialzieSqlSessionIds(SessionIds);
        exit(SessionIds);
    end;

    procedure InitialzieSqlSessionIds(SessionIds: List of [Integer])
    var
        LockStats: Codeunit "Lock Stats";
    begin
        // A short nap to make sure that the background session had enough time to start and acquire marker locks.
        Sleep(100);
        LockStats.InitSessionId(SessionIds.Get(1), 'Marker Table 1');
        LockStats.InitSessionId(SessionIds.Get(2), 'Marker Table 2');
    end;

    procedure ClearTables(ClearParams: Boolean)
    var
        SessionParameters: Record "Session Parameters";
        LockingSessionEvent: Record "Locking Session Event";
        ActiveTestSession: Record "Active Test Session";
    begin
        if ClearParams then
            SessionParameters.DeleteAll();
        LockingSessionEvent.DeleteAll();
        ActiveTestSession.DeleteAll();
    end;

    procedure StopActiveSessions()
    var
        SessionEventLogger: Codeunit "Session Event Logger";
        SessionIDs: List of [Integer];
        SessionId: Integer;
    begin
        SessionIDs := GetLastSessionIDs();
        foreach SessionId in SessionIDs do
            if IsSessionActive(SessionId) then begin
                StopSession(SessionId);
                SessionEventLogger.LogEvent(SessionId, Enum::"Session Event Type"::Stopped, 'Session was stopped by the user');
            end;
    end;

    local procedure VerifyTestNotRunning()
    var
        SessionIDs: List of [Integer];
        SessionId: Integer;
        TestSessionActiveErr: Label 'Test session is currently active. Wait for the current test to complete or stop it before starting a new test.';
    begin
        SessionIDs := GetLastSessionIDs();
        if SessionIDs.Count = 0 then
            exit;

        foreach SessionId in SessionIDs do
            if IsSessionActive(SessionId) then
                Error(TestSessionActiveErr);
    end;
}