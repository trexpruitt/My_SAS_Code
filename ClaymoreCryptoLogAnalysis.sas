/* Options symbolgen mlogic mrecall mprint; */
%let ETN_Pay_Ratio=0.0012366;

%macro ReadLogs;
/** BEGIN All Files Libraries Only **/
filename CLAYLOG '/folders/myfolders/My SAS Data/Claymore_FindAllFiles.txt';

data Logs;
	infile CLAYLOG dsd truncover;
	input
		@1 FileCode $18. @;
			if index(UPCASE(FileCode),"LOG")^=0 then do;
				input
					@1  FileName $18.
					;
				end;
		;
	Drop FileCode;
	if FileName^=' ' then output;
	run;

Data _Null_;
	Set Logs end=eof;
	LogCnt+1;
	if eof then Call symput('LogCnt',LogCnt);
	run;
	%put &LogCnt;
%mend ReadLogs;
%ReadLogs;

%macro CryptoLogLoop;
Data _Null_;
	Set Logs;
	%Do I=1 %TO &LogCnt;
		If _n_=&i then Call symput("Log&i",FileName);
	%End;
	Run;
	%Do I=1 %TO &LogCnt;
	%Put &&Log&i;
	%End;
%Do i=1 %TO &LogCnt;
filename IN&i "/folders/myfolders/My SAS Data/&&Log&i";
%End;

%Do i=1 %TO &LogCnt;
Data Work.CryptoLogTextIn&i;
	Infile IN&i
		missover
		recfm=v
		dlm='09'x
		lrecl=326
		pad
		firstobs=5
		;
	Input 
		LogEntryTime	$CHAR12. 
		@;
			If 
				LogEntryTime^=' '
				;
			If _n_=5 Then Call symput("LogStartTime&i",substr(LogEntryTime,1,8));
	Input
		Code $ 
		ShareFoundMsg $CHAR300.
		@;
			If Index(Upcase(ShareFoundMsg),'MAIN POOL IS')^=0
				Then Call symput("MainPool&i",Left(Trim(Substr(ShareFoundMsg,Index(ShareFoundMsg,'is')+3))));		
			If Index(ShareFoundMsg,'SHARE FOUND')^=0
				or
				Index(ShareFoundMsg,'Share rejected')^=0
				Then Output;
		;
	Run;
	
Data Work.CryptoLogTextIn&i;
	Length 
		MainPool $30.
		LogStartDateTime 8.
		SecondsToShareFound 8.
		MinutesToShareFound 8.
		ShareFoundDT $8.
		ShareFoundTM $8.
		ShareFoundHrMin $5.
		ShareFoundHour $2.		
		ShareFoundDateTimeTxt $17.
		ShareFoundDateTime 8.
		PrevShareFoundDateTime 8.
		SecondsToPrevShareFound 8.
		MinutesToPrevShareFound 8.
		LogStartTimeTxt $8.
		LogStartDateTimeTxt $17.
		;
	Set Work.CryptoLogTextIn&i;
		By ShareFoundMsg notsorted;
	
	Retain
		ShareFoundDT
		ShareFoundTM
		ShareFoundHrMin
		ShareFoundHour		
		ShareFoundDateTimeTxt
		ShareFoundDateTime
		PrevShareFoundDateTime
		;

		If Index(ShareFoundMsg,'SHARE FOUND')^=0 THEN DO;
			ShareFoundDT=Substr(ShareFoundMsg,1,8);
			ShareFoundTM=Substr(ShareFoundMsg,10,8);
			ShareFoundHrMin=Substr(ShareFoundMsg,10,5);
			ShareFoundHour=Substr(ShareFoundMsg,10,2);
			ShareFoundDateTimeTxt=Substr(ShareFoundMsg,1,17);
			ShareFoundDateTime=Input(ShareFoundDateTimeTxt,anydtdtm.);
			PrevShareFoundDateTime=lag(ShareFoundDateTime);
			END;
			
		format ShareFoundDateTime PrevShareFoundDateTime datetime.;

		If Index(ShareFoundDT,'DevFee:')^=0 Then Delete;
		
		If Index(ShareFoundMsg,'SHARE FOUND')^=0 THEN ShareFoundCnt=1;
		If Index(ShareFoundMsg,'Share rejected')^=0 THEN ShareFoundCnt=-1;
		
		LogStartTimeTxt="&&LogStartTime&i";
		If _n_=1 Then LogStartDateTimeTxt=Trim(Left(ShareFoundDT))||"-"||Trim(Left(LogStartTimeTxt));
		Retain LogStartDateTimeTxt;
		LogStartDateTime=Input(LogStartDateTimeTxt,anydtdtm.);
		format LogStartDateTime datetime.;
		Retain MainPool;
			MainPool="&&MainPool&i";
	Run;
%End;

Data Work.CryptoLogTextALL;
	Set
	%Do i=1 %TO &LogCnt;
		Work.CryptoLogTextIn&i
		%End;
		;
	IF PrevShareFoundDateTime=. Then PrevShareFoundDateTime=ShareFoundDateTime;		
		SecondsToShareFound=ShareFoundDateTime-LogStartDateTime;
		MinutesToShareFound=Round(SecondsToShareFound/60);
		SecondsToPrevShareFound=ShareFoundDateTime-PrevShareFoundDateTime;
		MinutesToPrevShareFound=Round(SecondsToPrevShareFound/60);
		ETN_Earned=ShareFoundCnt*&ETN_Pay_Ratio;
	Run;
	
%Do i=1 %TO &LogCnt;
	Proc Delete data=Work.CryptoLogTextIn&i; Run;
	%End;
	;
%Mend CryptoLogLoop;
%CryptoLogLoop;

PROC Sort DATA=WORK.CryptoLogTextALL NODUPKEY;
	BY ShareFoundDateTimeTxt ShareFoundCnt;
	run;
	
Options Missing=' ' orientation=landscape;

Title1 "Claymore Crypto ETN Mining Log Text Analysis";

Title2 "Table of SHARES FOUND by ShareFoundDT by MainPool Where ETN_Pay_Ratio = %left(&ETN_Pay_Ratio)";
PROC Tabulate 
	DATA=WORK.CryptoLogTextALL 
/* 	(where=( */
/* 		datepart(ShareFoundDateTime)>='07mar2018'd  */
/* 		and  */
/* 		Upcase(MainPool) contains 'UCRYPTO' */
/* 		)) */
	order=Data
	; 
	Class ShareFoundDT MainPool;
	Var ShareFoundCnt ETN_Earned;
	table 
		ShareFoundDT=' ' ALL
		, MainPool*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4) 
			ALL*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4)
	/ box='ShareFoundDT';
	keylabel 
		n='Record Cnt' 
		sum=' '
		ALL='Total'
		;
	RUN;
	
Title2 "Table of SHARES FOUND by ShareFoundHour by MainPool Where ETN_Pay_Ratio = %left(&ETN_Pay_Ratio)";
PROC Tabulate 
	DATA=WORK.CryptoLogTextALL 
	order=Formatted
	; 
	Class ShareFoundHour MainPool;
	Var ShareFoundCnt ETN_Earned;
	table 
		ShareFoundHour=' ' ALL
		, MainPool*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4) 
			ALL*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4)
	/ box='ShareFoundHour';
	keylabel 
		n='Record Cnt' 
		sum=' '
		ALL='Total'
		;
	RUN;
	
Title2 "Table of SHARES FOUND by Code by MainPool Where ETN_Pay_Ratio = %left(&ETN_Pay_Ratio)";
PROC Tabulate 
	DATA=WORK.CryptoLogTextALL 
	order=Formatted
	; 
	Class Code MainPool;
	Var ShareFoundCnt ETN_Earned;
	table 
		Code=' ' ALL
		, MainPool*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4) 
			ALL*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4)
	/ box='Code';
	keylabel 
		n='Record Cnt' 
		sum=' '
		ALL='Total'
		;
	RUN;	
	
Title2 "Table of SHARES FOUND by MinutesToPrevShareFound by MainPool Where ETN_Pay_Ratio = %left(&ETN_Pay_Ratio)";
PROC Tabulate 
	DATA=WORK.CryptoLogTextALL 
	order=Formatted
	; 
	Class MinutesToPrevShareFound MainPool;
	Var ShareFoundCnt ETN_Earned;
	table 
		MinutesToPrevShareFound=' ' ALL
		, MainPool*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4) 
			ALL*(ShareFoundCnt*sum*f=comma12. ETN_Earned*sum*f=comma12.4)
	/ box='MinutesToPrevShareFound';
	keylabel 
		n='Record Cnt' 
		sum=' '
		ALL='Total'
		;
	RUN;	