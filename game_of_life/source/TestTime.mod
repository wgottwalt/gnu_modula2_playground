(*!m2iso+gm2*)
MODULE TestTime;

FROM SYSTEM IMPORT ADR;
IMPORT C;

VAR
  Time, Time1, Time2: C.TTimeSpec;

BEGIN
  C.clock_getres(C.CLOCK_MONOTONIC_RAW, ADR(Time));
  C.printf("resolution : %lu.%09lus\n", Time.TvSec, Time.TvNSec);

  Time := C.TTimeSpec{3, 0};

  C.printf("wait 3 seconds\n");

  C.clock_gettime(C.CLOCK_MONOTONIC_RAW, ADR(Time1));
  C.nanosleep(ADR(Time));
  C.clock_gettime(C.CLOCK_MONOTONIC_RAW, ADR(Time2));

  C.printf("done waiting\n");
  C.printf("time1: %lu.%09lus\n", Time1.TvSec, Time1.TvNSec);
  C.printf("time2: %lu.%09lus\n", Time2.TvSec, Time2.TvNSec);
END TestTime.
