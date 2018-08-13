unit uTypes;

interface

uses
  SysUtils, Variants;

type
  TDJThreadConfig = record
    KeyName: string; // 线程名称
    DBHost: string;
    DBPort: string;
    DBName: string;
    DBUser: string;
    DBPwd: string;
    // vioplcs: Integer;  违法批量保存记录数
    // kkplcs: Integer;   过车批量保存记录数
  end;

  TKKThreadConfig = record
    KKID: Integer;
    KKHOST: string;
    KKPORT: string;
    KKSID: string;
    KKUSERNAME: string;
    KKPASSWORD: string;
    KKVEH_PASSREC: string;
    KKSOURCE: string;
    KKROWNUM: Integer;
    CJJG: string;
  end;

  TDevice = class
    SBBH: string;
    BABH: string;
    BAFX: string;
    LKBH: string;
    LKMC: string;
    FXBH: string;
    FXMC: string;
    CJJG: string;
    SBDDMC: string;
    SBJD: string;
    SBWD: string;
    SBIP: string;
    SBCJ: string;
    CSLXR: string;
    LXFS: string;
    QYSJ: string;
    JDJG: string;
    JDBH: string;
    JDYXQ: TDateTime;
    QYRQ: TDateTime;
    XZSD: Integer;
    DCXZSD: Integer;
    QSSBBH: string;
    SBLX: string;
    LDBH: string;
    LHY_XZQH: string;
    LHY_WFDD: string;
    LHY_SBBH: string;
    LHY_LDDM: string;
    LHY_DDMS: string;
    LHY_CJFS: string;
    LHY_JPGH: Integer;
    LHY_JPGW: Integer;
    LHY_JPGQ: string;
    QYZT: Boolean;
    ZJZT: Boolean;
    SCJCPT: Boolean;
    TPGS: string;
    WFXW: string;
    BZ: string;
    GXSJ: TDateTime;
    tpxz: Boolean;
    XYSB: Boolean;
    AQDSB: Boolean;
    HBCZB: Boolean;
    XXZB: Boolean;
    DCXXZB: Boolean;
    YSXZB: Boolean;
    XSZB: Boolean;
    Changed: Boolean;
    ID: string;
    hikJcbk: Boolean;
  end;

  TViotemp = record
    CJJG: string;
    HPHM: string;
    HPZL: string;
    CSYS: string;
    CLPP: string;
    WFDD: string;
    WFXW: string;
    WFSJ: TDateTime;
    CD: string;
    XZSD: Integer;
    ZGXS: Integer;
    ZDXS: Integer;
    SJSD: Integer;
    PHOTOFILE1: string;
    PHOTOFILE2: string;
    PHOTOFILE3: string;
    FWQDZ: string;
    BJ: string;
    GCXH: string;
  end;

  TPass = record
    CJJG: string;
    GCXH: string;
    BABH: string;
    KKSOURCE: string;
    kdbh: string;
    FXBH: string;
    cdbh: string;
    cdlx: string;
    HPZL: string;
    gcsj: string;
    clsd: string;
    hpys: string;
    cllx: string;
    HPHM: string;
    cwhphm: string;
    cwhpys: string;
    hpyz: string;
    yrksj: string;
    CSYS: string;
    clxs: string;
    CLPP: string;
    clwx: string;
    xszt: string;
    wfbj: string;
    FWQDZ: string;
    tp1: string;
    tp2: string;
    tp3: string;
    tztp: string;
    drtp1: string;
    drtp2: string;
    rksj: string;
    fsbz: string;
    alarm_type: string;
    alarm_src: string;
    alarm_src_id: string;
    flag: string;
    GXSJ: string;
    LDBH: string;
    LKBH: String;
    WFXW: string;
    ser01: string;
    ser02: string;
    ser03: string;
    ser04: string;
    ser05: string;
    ser06: string;
    ser07: string;
    ser08: string;
    ser09: string;
    function ToString(): string;
  end;

  TFtpConfig = record
    Host: string;
    Port: string;
    User: String;
    Pwd: string;
    path: string;
    Passive: Boolean;
  end;

  THikDaoFengConfig = Record
    K08SearchURL: String;
    K08SaveUrl: String;
    DFUrl: String;
    DFUser: String;
    DFPwd: String;
  End;

  TDFVehInfo = Record
    nTagID: String;
    PlateNum: String;
    nColor: String;
    nType: String;
    nMainLogo: String;
    nSubLogo: String;
    nModel: String;
    nPilotSB: String;
    nCopilotSB: String;
    nPilotSV: String;
    nCopilotSV: String;
    nDangMark: String;
    nEnvProSign: String;
    nUPhone: String;
    nPendant: String;
  End;

implementation

{ TPass }

function TPass.ToString: string;
begin
  result := CJJG + #9 + GCXH + #9 + KKSOURCE + #9 + kdbh + #9 + FXBH + #9 + cdbh
    + #9 + cdlx + #9 + HPZL + #9 + FormatDatetime('yyyymmddhhmmss',
    VarToDatetime(gcsj)) + #9 + clsd + #9 + hpys + #9 + cllx + #9 + HPHM + #9 +
    cwhphm + #9 + cwhpys + #9 + hpyz + #9 + yrksj + #9 + CSYS + #9 + clxs + #9 +
    CLPP + #9 + clwx + #9 + xszt + #9 + WFXW + #9 + FWQDZ + #9 + tp1 + #9 + tp2
    + #9 + tp3 + #9 + tztp + #9 + drtp1 + #9 + drtp2 + #9 + rksj + #9 + fsbz +
    #9 + alarm_type + #9 + alarm_src + #9 + alarm_src_id + #9 + flag + #9 + GXSJ
    + #9 + LDBH + #9 + LKBH + #9 + ser01 + #9 + ser02 + #9 + ser03 + #9 + ser04
    + #9 + ser05 + #9 + ser06 + #9 + ser07 + #9 + ser08 + #9 + ser09;
end;

end.
