unit uTypes;

interface

type

  TOraConfig = record
    HOST: string;
    PORT: string;
    SID: string;
    USERNAME: string;
    PASSWORD: string;
    TableName: string;
    InsertSQL: string;
    SelectSQL: string;
    OrderField: string;
    MaxOrderFieldValue: string;
    TargetFilePath: string;
    IntervalSecond: integer;
  end;

implementation

end.
