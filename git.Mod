MODULE Git;

IMPORT
	Out,
	Files,
	StrUtils := strutils,
	Strings;

CONST
	commitLex = "commit";
	sponsoredLes = "Sponsored";

TYPE
	IncName*  =  ARRAY 64 OF CHAR;

	TDate = RECORD
	Year, Month, Day : INTEGER;
	END;

	Commit*  = POINTER TO CommitDesc;
	CommitDesc*  = RECORD
		Hash- : ARRAY 48 OF CHAR;
		Date- : TDate;

		Sponsor-  : POINTER TO ARRAY OF IncName;
		Obtained- : POINTER TO ARRAY OF IncName;

		Author-   : ARRAY 64 OF CHAR;
		Next- : Commit;
		Prev- : Commit;
	END;

	Log* = POINTER TO LogDesc;
	LogDesc* = RECORD
		Add-     : PROCEDURE(VAR log: Log; commit: Commit): HUGEINT;
		Get-     : PROCEDURE(VAR log: Log; id: HUGEINT): Commit;
		Populate-: PROCEDURE(VAR log: Log);

		HEAD-    : Commit;
		TAIL-    : Commit;
		Count-   : HUGEINT;

		fd : Files.File;
		rd : Files.Rider;
	END;

PROCEDURE AddCommit(VAR log: Log; commit: Commit): HUGEINT;
BEGIN
	IF log.HEAD = NIL THEN
		log.HEAD := commit;
		log.TAIL := commit;
	ELSE
		log.TAIL.Next := commit;
		commit.Prev   := log.TAIL;
		log.TAIL      := commit;
	END;
	INC(log.Count);
	log.TAIL.Next := NIL;
	RETURN log.Count
END AddCommit;

PROCEDURE GetCommit(VAR log: Log; id: HUGEINT): Commit;
BEGIN
END GetCommit;

PROCEDURE Expect(VAR line: ARRAY OF CHAR; pattern: ARRAY OF CHAR);
BEGIN
	IF line # pattern THEN
		Out.String("expected `");
		Out.String(pattern);
		Out.String("` ; got `");
		Out.String(line);
		Out.String("`");
		Out.Ln;
		HALT(6);
	END;
END Expect;

PROCEDURE PopulateLog(VAR log: Log);
	VAR
		line    : StrUtils.string;
		wordptr : StrUtils.pstring;
		commit  : Commit;
		h       : HUGEINT;
BEGIN
(*
	WHILE ~ log.rd.eof DO
*)
		Files.ReadLine(log.rd, line);
		wordptr := StrUtils.ExtractWord(1, line, ' ');
		Expect(wordptr^, commitLex);
		wordptr := StrUtils.ExtractWord(2, line, ' ');

		NEW(commit);
		COPY(wordptr^, commit.Hash);
		h := log.Add(log, commit);
		NEW(commit);
		COPY("HUMMUS KIMCHI", commit.Hash);
		NEW(commit.Sponsor, 2);
		COPY("antranigv", commit.Sponsor^[0]);
		COPY("norayr"   , commit.Sponsor^[1]);
		h := log.Add(log, commit);
		NEW(commit);
		COPY("FOOBARBAZ", commit.Hash);
		h := log.Add(log, commit);

(*
	END;
*)
END PopulateLog;

PROCEDURE CreateLog*(VAR fpath: ARRAY OF CHAR): Log;
	VAR
		log : Log;

BEGIN
	NEW(log);
	log.Add      := AddCommit;
	log.Get      := GetCommit;
	log.Populate := PopulateLog;

	log.HEAD := NIL;
	log.TAIL := NIL;
	log.Count := 0;

	log.fd := Files.Old(fpath);

	IF log.fd # NIL THEN
		Files.Set(log.rd, log.fd, 0);
	ELSE
		log := NIL;
	END;



	RETURN log;
END CreateLog;

END Git.
