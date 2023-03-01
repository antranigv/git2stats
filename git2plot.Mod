MODULE git2plot;
IMPORT
	Out,
	Git,
	Modules,
	lDefs,
	StringList,
	Strings;

TYPE
	ArgV = ARRAY 64 OF CHAR;

	Counter = RECORD
		Count: INTEGER;
		Name: Git.IncName;
	END;

	CounterArrPtr = POINTER TO ARRAY OF Counter;

(*
PROCEDURE FindCounter(name: IncName; VAR Counters: CounterArrPtr; VAR i: INTEGER): BOOLEAN;
BEGIN
		i   := 0;
		REPEAT
			IF name = Counters^[i].Name THEN RETURN TRUE END;
			INC(i);
		UNTIL i = LEN(Counters^) - 1;
		RETURN FALSE
END FindCounter;

PROCEDURE FindNextEmptyCounter(VAR Counters: CounterArrPtr): INTEGER;
	VAR
		i : INTEGER;
BEGIN
	LOOP
		IF i = LEN(Counters^) THEN Out.String("Counters full!"); Out.Ln; EXIT END;
		IF Counters^[i].Name = "" THEN EXIT END;
		INC(i);
	END;
	RETURN i;
END FindNextEmptyCounter;

PROCEDURE PrintSponsoredStat(VAR Counters: CounterArrPtr);
	VAR
		i : INTEGER;
BEGIN
	i := 0;
	WHILE i # LEN(Counters^) DO
		IF Counters^[i].Name # "" THEN
			Out.String(Counters^[i].Name); Out.String(":");
			Out.Int(Counters^[i].Count, 0); Out.Ln;
		END;
		INC(i)
	END;
END PrintSponsoredStat;

*)

PROCEDURE Usage(VAR progname: ArgV);
BEGIN
	Out.String("Usage: "); Out.String(progname); Out.String(" git.log"); Out.Ln;
END Usage;

(*
PROCEDURE main2;
BEGIN
	IF Modules.ArgCount < 2 THEN
		Modules.GetArg(0, argv);
		Usage(argv);
		HALT(1);
	END;

	NEW(c, 1024);

	logfd := Files.Old(argv);

	fbsd  := 0;

	IF logfd # NIL THEN
		Files.Set(logr, logfd, 0);
		WHILE ~ logr.eof DO
			Files.ReadLine(logr, line);
			IF Strings.Match(line, "Date:*") THEN
				INC(fbsd);
			ELSIF Strings.Match(line, "*Sponsored*") THEN
				INC(spon);
				Strings.Extract(
					line,
					Strings.Pos(":", line, 0) + 1,
					Strings.Length(line),
					incn
				);
				IF FindCounter(incn, c, i) THEN
					INC(c^[i].Count);
				ELSE
					i := FindNextEmptyCounter(c);
					c^[i].Name := incn;
					INC(c^[i].Count);
				END;
			END;
		END;
	END;

	Out.String("FreeBSD: "); Out.Int(fbsd, 0); Out.Ln;
	Out.String("Sponsored: "); Out.Int(spon, 0); Out.Ln;
	PrintSponsoredStat(c);
END main2;
*)

PROCEDURE main;
(*
VAR
	c     : CounterArrPtr;
	i     : INTEGER;
	line  : ARRAY 4096 OF CHAR;
	fbsd  : HUGEINT;
	spon  : HUGEINT;
	incn  : IncName;
*)

	VAR
		log   : Git.Log;
		sponsored: Git.Log;
		argv  : ArgV;
		c     : Git.Commit;
		d     : Git.Commit;
		i     : LONGINT;
		h     : HUGEINT;
		listptr : lDefs.pstring;

BEGIN
	IF Modules.ArgCount < 2 THEN
		Modules.GetArg(0, argv);
		Usage(argv);
		HALT(1);
	END;

	Modules.GetArg(1, argv);
	log := Git.CreateLog(argv);
	IF log = NIL THEN
		Out.String("File not found: "); Out.String(argv); Out.Ln;
		HALT(2)
	END;
	log.Populate(log);

	c := log.HEAD;
  sponsored := Git.Create();
	REPEAT
		Out.String(c.Hash); Out.String(" ");
		IF c.Sponsor.Count # 0 THEN
			Git.CopyCommit(c, d);
			h := sponsored.Add(sponsored, d);
			FOR i := 0 TO c.Sponsor.Count - 1 DO
				listptr := c.Sponsor.GetString(c.Sponsor, i);
				Out.String(listptr^); Out.String(" ");
			END;
		END;
		Out.Ln;
		c := c.Next;
	UNTIL c = NIL;

Out.String("number of sponsored commits "); Out.Int(sponsored.Count, 0); Out.Ln;
END main;

BEGIN
	main;
END git2plot.
