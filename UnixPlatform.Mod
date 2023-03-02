MODULE PlatformUnix;
IMPORT
  Out,
  Platform,
  Strings,
  SYSTEM;


PROCEDURE WriteStderr*(string: ARRAY OF CHAR);
VAR
  msg : POINTER TO ARRAY OF CHAR;
  l   : LONGINT;
  m   : HUGEINT;
  r   : INTEGER;

BEGIN
  NEW(msg, 128);
  COPY(string, msg^);
  m   := SYSTEM.ADR(msg^);
  l   := LEN(msg^);
  r := Platform.Write(Platform.StdErr, m, l);
END WriteStderr;

PROCEDURE WriteStderrLn*;
BEGIN
  WriteStderr(0AX);
END WriteStderrLn;
END PlatformUnix.
