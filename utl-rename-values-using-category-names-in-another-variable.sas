Rename values using category names in another variable

github
https://tinyurl.com/y7wylqu6
https://github.com/rogerjdeangelis/utl-rename-values-using-category-names-in-another-variable

SAS  Forum
https://tinyurl.com/ybkgojbm
https://communities.sas.com/t5/SAS-Programming/Rename-a-variable-the-value-of-another-variable/m-p/513641

macros
https://tinyurl.com/y9nfugth
https://github.com/rogerjdeangelis/utl-macros-used-in-many-of-rogerjdeangelis-repositories


INPUT
=====

WORK.HAVE total obs=5


 FNAM         LNAM       TEAM       VAR1     VAL1     VAR2     VAL2     VAR3     VAL3

 Allanson    Andy      Clevelan    At_bat    293     n_hits    66      n_home     1
 Ashby       Alan      Houston     At_bat    315     n_hits    81      n_home     7
 Davis       Alan      Seattle     At_bat    479     n_hits    130     n_home     18
 Dawson      Andre     Montreal    At_bat    496     n_hits    141     n_home     20
 Galarrag    Andres    Montreal    At_bat    321     n_hits    87      n_home     10


EXAMPLE OUTPUT
--------------

RULE  RENAME

         VAL1 = AT_BAT
         VAL2 = N_HITS
         VAL3 = N_HOME


 WORK WANT total obs=5

 FNAM         LNAM       TEAM      AT_BAT    N_HITS    N_HOME

 Allanson    Andy      Clevelan     293       66         1
 Ashby       Alan      Houston      315       81         7
 Davis       Alan      Seattle      479       130        18
 Dawson      Andre     Montreal     496       141        20
 Galarrag    Andres    Montreal     321       87         10


PROCESS  (you need the rename macro below or from github)
==========================================================


%symdel nams / nowarn; * just in case;
data want;

  * get new names in string nams;
  if _n_=0 then do; %let rc=%sysfunc(dosubl('
    data _null_;
     length nams $200;
     set have(obs=1);
     array vars[*] var:;
     nams=catx(' ',of vars[*]) ;
     call symputx("nams",nams);
    run;quit;
    '));
  end;

  set have(rename=(%utl_renamel(old=val1 val2 val3,new=&nams)));

  drop var:;

run;quit;

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
 input (fnam lnam Team Var1 Val1 Var2 Val2 Var3 Val3) ($);
cards4;
Allanson Andy Cleveland At_bat 293 n_hits 66 n_home 1
Ashby Alan Houston At_bat 315 n_hits 81 n_home 7
Davis Alan Seattle At_bat 479 n_hits 130 n_home 18
Dawson Andre Montreal At_bat 496 n_hits 141 n_home 20
Galarraga Andres Montreal At_bat 321 n_hits 87 n_home 10
;;;;
run;quit;

*
 _ __ ___   __ _  ___ _ __ ___
| '_ ` _ \ / _` |/ __| '__/ _ \
| | | | | | (_| | (__| | | (_) |
|_| |_| |_|\__,_|\___|_|  \___/

;

%macro utl_renamel ( old , new ) ;
    /* Take two cordinated lists &old and &new and  */
    /* return another list of corresponding pairs   */
    /* separated by equal sign for use in a rename  */
    /* statement or data set option.                */
    /*                                              */
    /*  usage:                                      */
    /*    rename = (%renamel(old=A B C, new=X Y Z)) */
    /*    rename %renamel(old=A B C, new=X Y Z);    */
    /*                                              */
    /* Ref: Ian Whitlock <whitloi1@westat.com>      */

    %local i u v warn ;
    %let warn = Warning: RENAMEL old and new lists ;
    %let i = 1 ;
    %let u = %scan ( &old , &i ) ;
    %let v = %scan ( &new , &i ) ;
    %do %while ( %quote(&u)^=%str() and %quote(&v)^=%str() ) ;
        &u = &v
        %let i = %eval ( &i + 1 ) ;
        %let u = %scan ( &old , &i ) ;
        %let v = %scan ( &new , &i ) ;
    %end ;

    %if (null&u ^= null&v) %then
        %put &warn do not have same number of elements. ;

%mend  utl_renamel ;



