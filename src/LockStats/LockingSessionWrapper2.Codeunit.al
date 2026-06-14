codeunit 50707 "Locking Session Wrapper 2"
{
    TableNo = "Session Parameters";

    trigger OnRun()
    var
        SessionParameters: Record "Session Parameters";
        LockingSessionController: Codeunit "Locking Session Controller";
    begin
        SessionParameters.SetRange("Session No.", Rec."Session No.");
        SessionParameters.SetRange("Action No.", 9999);
        SessionParameters.DeleteAll();

        SessionParameters."Session No." := Rec."Session No.";
        SessionParameters."Action No." := 9999;
        SessionParameters.Action := Enum::"Session Action"::"Set Table Mark";
        SessionParameters."First Record No." := Database::"Marker Table 2";
        SessionParameters.Insert();
        Commit();

        LockingSessionController.Run(SessionParameters);
    end;
}