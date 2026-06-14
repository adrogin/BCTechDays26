page 50701 "Locking Test"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(Configuration)
            {
                Caption = 'Configuration';

                grid(SessionsConfig)
                {
                    group(Config1)
                    {
                        Caption = 'Session 1 Setup';

                        part(SessionParameters1; "Session Parameters")
                        {
                            ApplicationArea = All;
                            SubPageView = where("Session No." = const(1));
                        }
                    }
                    group(Config2)
                    {
                        Caption = 'Session 2 Setup';

                        part(SessionParameters2; "Session Parameters")
                        {
                            ApplicationArea = All;
                            SubPageView = where("Session No." = const(2));
                        }
                    }
                }
            }

            group(Activity)
            {
                Caption = 'Activity';

                grid(Sessions)
                {
                    group(Session1)
                    {
                        Caption = 'Session 1';

                        part(LockingSessionEvents1; "Locking Session Events")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(Session2)
                    {
                        Caption = 'Session 2';

                        part(LockingSessionEvents2; "Locking Session Events")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
            }
        }
        area(FactBoxes)
        {
            part(LockStatsView1; "Lock Stats")
            {
                Caption = 'Locks: Session 1';
            }
            part(LockStatsView2; "Lock Stats")
            {
                Caption = 'Locks: Session 2';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(TestExecution)
            {
                action(Run)
                {
                    ApplicationArea = All;
                    Image = Continue;

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunScenario());
                    end;
                }
            }
            group(TestScenarios)
            {
                Caption = 'Test Scenarios';
                Image = Lock;

                action(ModifyOneFirst)
                {
                    ApplicationArea = All;
                    Caption = 'Modify - One record first';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying one record, an the second session modifying a range.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyOneBeforeRange());
                    end;
                }
                action(ModifyRangeFirst)
                {
                    ApplicationArea = All;
                    Caption = 'Modify - Range first';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying a range, and the second session modifying one record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyRangeBeforeOne());
                    end;
                }
                action(ModifyRangeAndReadCommitted)
                {
                    ApplicationArea = All;
                    Caption = 'Modify range and ReadCommitted';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying a range, and the second session modifying one record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyRangeBeforeReadCommitted());
                    end;
                }
                action(ModifyOneFirstReadRangeRepeatableRead)
                {
                    ApplicationArea = All;
                    Caption = 'Read - One record first';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying one record, and the second session reading a range with RepeatableRead isolation.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyOneBeforeReadingRangeRepeatableRead());
                    end;
                }
                action(ReadRangeFirstRepeatableRead)
                {
                    ApplicationArea = All;
                    Caption = 'Read - Range first';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session reading a range with RepeatableRead isolation, and the second session modifying one record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioReadRangeRepeatableReadBeforeModifyOne());
                    end;
                }
                action(ModifyRangeInLoopFirst)
                {
                    ApplicationArea = All;
                    Caption = 'Modify range in loop';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying a range, and the second session modifying one record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyRangeLoopBeforeOne());
                    end;
                }
                action(ModifySmallerRangesBeforeOne)
                {
                    ApplicationArea = All;
                    Caption = 'Modify multiple smaller ranges';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying a range, and the second session modifying one record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyMultipleRangesBeforeOne());
                    end;
                }
                action(ModifyRangeNoEscalationModifyNone)
                {
                    ApplicationArea = All;
                    Caption = 'Modify rangle, Another Modify Nothing in range';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session modifying a range of value without lock escalation, and the second session attempting to modify non-existing record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyRangeNoEscalationBeforeModifyNone());
                    end;
                }
                action(ReadRangeFirstRepeatableReadModifyNone)
                {
                    ApplicationArea = All;
                    Caption = 'Read and modify wider range - Nothing in range in second tran.';
                    Image = UpdateDescription;
                    ToolTip = 'Run the locking test with the first session reading a range with RepeatableRead isolation, and the second session attempting to modify.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioReadRangeRepeatableReadBeforeModifyNone());
                    end;
                }
                action(DeadlockLockingTwoRecordsInReverse)
                {
                    ApplicationArea = All;
                    Caption = 'Deadlock: locking two records in reverse';
                    Image = UpdateDescription;
                    ToolTip = 'Session 1 locks record 1, then 2; session 2 locks in reverse order which leads to a deadlock.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioTwoRecordsDeadlock());
                    end;
                }
                action(DeadlockLockingOneRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Deadlock: locking and updating one record';
                    Image = UpdateDescription;
                    ToolTip = 'Both sessions read record 1 with Repeatable Read isolation and after 2 seconds attempt to update it.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioOneRecordDeadlock());
                    end;
                }
                action(ReadAndModifyOverlappingRangesDeadlock)
                {
                    ApplicationArea = All;
                    Caption = 'Read and modify overlapping ranges - Deadlock';
                    Image = UpdateDescription;
                    ToolTip = 'Read and modify overlapping ranges. Session 2 reads with RepeatableRead resulting in deadlock.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioOverlappingRangesDeadlock());
                    end;
                }
                action(ReadAndModifyOneStaleRecord)
                {
                    ApplicationArea = All;
                    Caption = 'Read and modify one - Stale record';
                    Image = UpdateDescription;
                    ToolTip = 'Read and modify overlapping ranges. Session 2 reads with RepeatableRead and tries to modify one resulting in stale record.';

                    trigger OnAction()
                    begin
                        FilterSessionEventViews(LockingMgt.RunLockingScenarioModifyOneStaleRecord());
                    end;
                }
            }
            group(UpdateViews)
            {
                Caption = 'Update Views';
                Image = UpdateDescription;
                
                action(RefreshEvents)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Events';
                    Image = Refresh;
                    ToolTip = 'Refresh the events from the background sessions.';

                    trigger OnAction()
                    begin
                        RefreshEventViews();
                    end;
                }
                action(RefreshLocks)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Locks';
                    Image = Lock;
                    ToolTip = 'Refresh the active database locks.';

                    trigger OnAction()
                    begin
                        RefreshLockStatsViews();
                    end;
                }
            }
            group(TestManagement)
            {
                Caption = 'Test Management';
                Image = Setup;

                action(StopTestSessions)
                {
                    ApplicationArea = All;
                    Caption = 'Stop Test Sessions';
                    Image = Stop;
                    ToolTip = 'Stop test session that are currently running';

                    trigger OnAction()
                    begin
                        LockingMgt.StopActiveSessions();
                    end;
                }
                action(InitializeTable)
                {
                    ApplicationArea = All;
                    Caption = 'Initialize Test Table';
                    Image = New;
                    ToolTip = 'Initialize the demo data. This action deletes all records from the Locking Test table and generates a new recordset.';

                    trigger OnAction()
                    begin
                        LockingMgt.InitializeTestTable();
                        Message('Ready to run test scenarios.');
                    end;
                }
            }
        }
        area(Navigation)
        {
            action(ServerSetup)
            {
                Caption = 'Server Setup';
                Image = Server;
                RunObject = page "Locking Test Server Setup";
            }
        }
        area(Promoted)
        {
            actionref(RunPromoted; Run) { }
            actionref(PromotedRefreshEvents; RefreshEvents) { }
            actionref(PromotedRefreshLocks; RefreshLocks) { }
        }
    }

    trigger OnOpenPage()
    begin
        SetSessionViewFilters(LockingMgt.GetLastSessionIDs());
    end;

    local procedure FilterSessionEventViews(SessionIds: List of [Integer])
    begin
        SetSessionViewFilters(SessionIds);
        ActiveSessionIds := SessionIds;
    end;

    local procedure RefreshEventViews()
    begin
        CurrPage.LockingSessionEvents1.Page.Update(false);
        CurrPage.LockingSessionEvents2.Page.Update(false);
    end;

    local procedure RefreshLockStatsViews()
    var
        ActiveTestSession: Record "Active Test Session";
        TempLockStats: Record "Lock Stats";
        LockStats: Codeunit "Lock Stats";
    begin
        TempLockStats.DeleteAll();
        LockStats.GetSessionLocks(ActiveSessionIds.Get(1), TempLockStats);
        CurrPage.LockStatsView1.Page.SetSource(TempLockStats);

        ActiveTestSession.Get(ActiveSessionIds.Get(1));
        TempLockStats.SetRange("Session ID", ActiveTestSession."SQL Session ID");
        CurrPage.LockStatsView1.Page.SetTableView(TempLockStats);
        CurrPage.LockStatsView1.Page.Update(false);

        TempLockStats.Reset();
        TempLockStats.DeleteAll();
        LockStats.GetSessionLocks(ActiveSessionIds.Get(2), TempLockStats);
        CurrPage.LockStatsView2.Page.SetSource(TempLockStats);

        ActiveTestSession.Get(ActiveSessionIds.Get(2));
        TempLockStats.SetRange("Session ID", ActiveTestSession."SQL Session ID");
        CurrPage.LockStatsView2.Page.SetTableView(TempLockStats);
        CurrPage.LockStatsView2.Page.Update(false);
    end;

    local procedure SetSessionViewFilters(SessionIds: List of [Integer])
    begin
        CurrPage.LockingSessionEvents1.Page.SetSessionIdFilter(SessionIds.Get(1));
        CurrPage.LockingSessionEvents2.Page.SetSessionIdFilter(SessionIds.Get(2));
        RefreshEventViews();
    end;

    var
        LockingMgt: Codeunit "Locking Scenarios";
        ActiveSessionIds: List of [Integer];
}
