MODULE Git;

IMPORT
	Out,
	Files,
	StringList,
	StrUtils := strutils,
	Strings  := ethStrings;

CONST
	commitLex  = "Commit:";
	authorLex  = "Author:";
	dateLex    = "Date:";
	sponsorLex = "Sponsored";

TYPE
	IncName*  =  ARRAY 64 OF CHAR;

	TDate = RECORD
	Year, Month, Day : LONGINT;
	END;

	Commit*  = POINTER TO CommitDesc;
	CommitDesc*  = RECORD
		Hash- : ARRAY 48 OF CHAR;
		Date- : TDate;

		Sponsor-  : StringList.TStringList;
		Obtained- : StringList.TStringList;

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
		dateptr : StrUtils.pstring;
		date    : ARRAY 4 OF CHAR;
		commit  : Commit;
		h       : HUGEINT;
BEGIN
	Files.ReadLine(log.rd, line);
	WHILE ~ log.rd.eof DO
		NEW(commit);

		(* Commit *)
		wordptr := StrUtils.ExtractWord(1, line, ' ');
		Expect(wordptr^, commitLex);
		wordptr := StrUtils.ExtractWord(2, line, ' ');
		COPY(wordptr^, commit.Hash);

		(* Author *)
		Files.ReadLine(log.rd, line);
		wordptr := StrUtils.ExtractWord(1, line, ' ');
		Expect(wordptr^, authorLex);
		wordptr := StrUtils.ExtractWord(2, line, ' ');
		COPY(wordptr^, commit.Author);

		(* Date *)
		Files.ReadLine(log.rd, line);
		wordptr := StrUtils.ExtractWord(1, line, ' ');
		Expect(wordptr^, dateLex);
		wordptr := StrUtils.ExtractWord(2, line, ' ');

		dateptr := StrUtils.ExtractWord(1, wordptr^, '-');
		COPY(dateptr^, date);
		Strings.StrToInt(date, commit.Date.Year);

		dateptr := StrUtils.ExtractWord(2, wordptr^, '-');
		COPY(dateptr^, date);
		Strings.StrToInt(date, commit.Date.Month);

		dateptr := StrUtils.ExtractWord(3, wordptr^, '-');
		COPY(dateptr^, date);
		Strings.StrToInt(date, commit.Date.Day);

		commit.Sponsor := StringList.Create();
		REPEAT
			Files.ReadLine(log.rd, line);
			IF line # "" THEN
				wordptr := StrUtils.ExtractWord(1, line, ' ');
				IF wordptr^ = sponsorLex THEN
					wordptr := StrUtils.ExtractWord(2, line, ':');
					commit.Sponsor.AppendString(commit.Sponsor, wordptr^);
				END;
			END;
		UNTIL line = "===EOC===";

		h := log.Add(log, commit);
		Files.ReadLine(log.rd, line);
	END;
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

PROCEDURE Create*(): Log;
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

	RETURN log;
END Create;

PROCEDURE CopyCommit*(VAR src, dst: Commit);
BEGIN
  NEW(dst);
	dst^.Hash := src^.Hash;
	dst^.Date := src^.Date;
	dst^.Sponsor := src^.Sponsor;
	dst^.Obtained := src^.Obtained;
	dst^.Author := src^.Author;
	dst^.Next := NIL;
	dst^.Prev := NIL;
END CopyCommit;

END Git.
