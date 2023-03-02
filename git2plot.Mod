MODULE git2plot;
IMPORT
  Out,
  Git,
  Modules,
  lDefs,
  StringList,
  Strings,
  PlatformUnix;

TYPE
  ArgV = ARRAY 64 OF CHAR;

PROCEDURE Usage(VAR progname: ArgV);
BEGIN
  Out.String("Usage: "); Out.String(progname); Out.String(" git.log"); Out.Ln;
END Usage;

PROCEDURE main;
  VAR
    log       : Git.Log;
    sponsored : POINTER TO ARRAY OF Git.Log;
    argv      : ArgV;
    c         : Git.Commit;
    d         : Git.Commit;
    i         : LONGINT;
    h         : HUGEINT;
    listptr   : lDefs.pstring;

BEGIN
  IF Modules.ArgCount < 2 THEN
    Modules.GetArg(0, argv);
    Usage(argv);
    HALT(1);
  END;

  Modules.GetArg(1, argv);
  log := Git.CreateLogFromFile(argv);
  IF log = NIL THEN
    PlatformUnix.WriteStderr("File not found: "); PlatformUnix.WriteStderr(argv);
    PlatformUnix.WriteStderrLn;
    HALT(2)
  END;

  log.Populate(log);

  c := log.HEAD;
  REPEAT
    Out.String(c.Hash); Out.String(" ");
    IF c.Sponsor.Count # 0 THEN
      FOR i := 0 TO c.Sponsor.Count - 1 DO
        listptr := c.Sponsor.GetString(c.Sponsor, i);
        Out.String(listptr^); Out.String(" ");
      END;
    END;
    Out.Ln;
    c := c.Next;
  UNTIL c = NIL;
END main;

BEGIN
  main;
END git2plot.
