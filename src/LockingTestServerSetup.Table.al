table 50707 "Locking Test Server Setup"
{
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Server Name"; Text[50])
        {
            Caption = 'Server Name';
        }
        field(3; "Database Name"; Text[50])
        {
            Caption = 'Database Name';
        }
        field(4; "User Name"; Text[50])
        {
            Caption = 'User Name';
        }
        field(5; Password; Text[50])
        {
            Caption = 'Password';
            ExtendedDatatype = Masked;
        }
    }
    
    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}