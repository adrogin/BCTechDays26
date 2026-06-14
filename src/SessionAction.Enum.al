enum 50701 "Session Action"
{
    Extensible = false;

    value(0; Read)
    {
        Caption = 'FindSet';
    }
    value(1; Insert)
    {
        Caption = 'Insert';
    }
    value(2; ModifyAll)
    {
        Caption = 'ModifyAll';
    }
    value(3; DeleteAll)
    {
        Caption = 'DeleteAll';
    }
    value(4; "Modify")
    {
        Caption = 'Modify';
    }
    value(5; "ModifyInLoop")
    {
        Caption = 'Modify In Loop';
    }
    value(6; ReadOne)
    {
        Caption = 'FindFirst';
    }
    value(999; "Set Table Mark")
    {
        Caption = 'Set Table Mark';
    }
}