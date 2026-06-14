codeunit 50705 "Background Session Logger"
{
    TableNo = "Locking Session Event";

    trigger OnRun()
    var
        LockingSessionEvent: Record "Locking Session Event";
    begin
        LockingSessionEvent.ReadIsolation := IsolationLevel::UpdLock;
        LockingSessionEvent.SetRange("Session ID", Rec."Session ID");
        if LockingSessionEvent.FindLast() then
            LockingSessionEvent."Event ID" += 1
        else
            LockingSessionEvent."Event ID" := 1;

        LockingSessionEvent.TransferFields(Rec);
        LockingSessionEvent.Insert();
    end;
}