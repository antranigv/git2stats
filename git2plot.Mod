MODULE git2plot;
IMPORT
	Args,
	Out,
	Files,
	Modules,
	Strings;

TYPE
	IncName  = ARRAY 128 OF CHAR;
	ArgV = ARRAY 64 OF CHAR;

	Counter = RECORD
		Count: INTEGER;
		Name: IncName;
	END;

	CounterArrPtr = POINTER TO ARRAY OF Counter;

VAR
	c     : CounterArrPtr;
	i     : INTEGER;
	argv  : ArgV;
	logfd : Files.File;
	logr  : Files.Rider;
	line  : ARRAY 4096 OF CHAR;
	fbsd  : HUGEINT;
	spon  : HUGEINT;
	incn  : IncName;

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

PROCEDURE Usage(VAR progname: ArgV);
BEGIN
	Out.String("Usage: "); Out.String(progname); Out.String(" git.log"); Out.Ln;
END Usage;

BEGIN
	IF Modules.ArgCount < 2 THEN
		Modules.GetArg(0, argv);
		Usage(argv);
		HALT(1);
	END;

	NEW(c, 1024);

	Modules.GetArg(1, argv);
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
END git2plot.
