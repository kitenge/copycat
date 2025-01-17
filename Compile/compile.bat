@echo off

cd \git\copycat

echo.
echo Compiling D7 trial...
"c:\Program Files\Borland\Delphi7\bin\dcc32" CopyCat_D7.dpk -b -Q -W -H -NTrial\D7 -LETrial\D7 -LNTrial\D7 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D7...
"c:\Program Files\Borland\Delphi7\bin\dcc32" CopyCat_D7.dpk -b -Q -W -H -ND7 -LED7 -LND7
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2005...
"c:\Program Files\Borland\BDS\3.0\bin\dcc32" CopyCat_2005.dpk -b -Q -W -H -ND2005 -LED2005 -LND2005
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2005 trial...
"c:\Program Files\Borland\BDS\3.0\bin\dcc32" CopyCat_2005.dpk -b -Q -W -H -NTrial\D2005 -LETrial\D2005 -LNTrial\D2005 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2006...
"c:\Program Files\Borland\BDS\4.0\bin\dcc32" CopyCat_2006.dpk -JPHNE -b -Q -W -H -N0D2006 -NHD2006 -NOD2006 -NBD2006 -LED2006 -LND2006
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Borland\BDS\4.0\bin\dcc32" CopyCat_2006.dpk -JL -Q -W -H -N0D2006 -NHD2006 -NOD2006 -NBD2006 -LED2006 -LND2006
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2006 trial...
"c:\Program Files\Borland\BDS\4.0\bin\dcc32" CopyCat_2006.dpk -JPHNE -b -Q -W -H -N0Trial\D2006 -NHTrial\D2006 -NOTrial\D2006 -NBTrial\D2006 -LETrial\D2006 -LNTrial\D2006 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Borland\BDS\4.0\bin\dcc32" CopyCat_2006.dpk -JL -Q -W -H -N0Trial\D2006 -NHTrial\D2006 -NOTrial\D2006 -NBTrial\D2006 -LETrial\D2006 -LNTrial\D2006 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2007...
"c:\Program Files\CodeGear\RAD Studio\5.0\bin\dcc32" CopyCat_2007.dpk -JPHNE -b -Q -W -H -N0D2007 -NHD2007 -NOD2007 -NBD2007 -LED2007 -LND2007
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\CodeGear\RAD Studio\5.0\bin\dcc32" CopyCat_2007.dpk -JL -Q -W -H -N0D2007 -NHD2007 -NOD2007 -NBD2007 -LED2007 -LND2007
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2007 trial...
"c:\Program Files\CodeGear\RAD Studio\5.0\bin\dcc32" CopyCat_2007.dpk -JPHNE -b -Q -W -H -N0Trial\D2007 -NHTrial\D2007 -NOTrial\D2007 -NBTrial\D2007 -LETrial\D2007 -LNTrial\D2007 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\CodeGear\RAD Studio\5.0\bin\dcc32" CopyCat_2007.dpk -JL -Q -W -H -N0Trial\D2007 -NHTrial\D2007 -NOTrial\D2007 -NBTrial\D2007 -LETrial\D2007 -LNTrial\D2007 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2009...
"c:\Program Files\CodeGear\RAD Studio\6.0\bin\dcc32" CopyCat_2009.dpk -JPHNE -b -Q -W -H -N0D2009 -NHD2009 -NOD2009 -NBD2009 -LED2009 -LND2009
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\CodeGear\RAD Studio\6.0\bin\dcc32" CopyCat_2009.dpk -JL -Q -W -H -N0D2009 -NHD2009 -NOD2009 -NBD2009 -LED2009 -LND2009
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2009 trial...
"c:\Program Files\CodeGear\RAD Studio\6.0\bin\dcc32" CopyCat_2009.dpk -JPHNE -b -Q -W -H -N0Trial\D2009 -NHTrial\D2009 -NOTrial\D2009 -NBTrial\D2009 -LETrial\D2009 -LNTrial\D2009 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\CodeGear\RAD Studio\6.0\bin\dcc32" CopyCat_2009.dpk -JL -Q -W -H -N0Trial\D2009 -NHTrial\D2009 -NOTrial\D2009 -NBTrial\D2009 -LETrial\D2009 -LNTrial\D2009 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2010...
"c:\Program Files\Embarcadero\RAD Studio\7.0\bin\dcc32" CopyCat_2010.dpk -JPHNE -b -Q -W -H -N0D2010 -NHD2010 -NOD2010 -NBD2010 -LED2010 -LND2010
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\7.0\bin\dcc32" CopyCat_2010.dpk -JL -Q -W -H -N0D2010 -NHD2010 -NOD2010 -NBD2010 -LED2010 -LND2010
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2010 trial...
"c:\Program Files\Embarcadero\RAD Studio\7.0\bin\dcc32" CopyCat_2010.dpk -JPHNE -b -Q -W -H -N0Trial\D2010 -NHTrial\D2010 -NOTrial\D2010 -NBTrial\D2010 -LETrial\D2010 -LNTrial\D2010 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\7.0\bin\dcc32" CopyCat_2010.dpk -JL -Q -W -H -N0Trial\D2010 -NHTrial\D2010 -NOTrial\D2010 -NBTrial\D2010 -LETrial\D2010 -LNTrial\D2010 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2011...
"c:\Program Files\Embarcadero\RAD Studio\8.0\bin\dcc32" CopyCat_2011.dpk -JPHNE -b -Q -W -H -N0D2011 -NHD2011 -NOD2011 -NBD2011 -LED2011 -LND2011
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\8.0\bin\dcc32" CopyCat_2011.dpk -JL -Q -W -H -N0D2011 -NHD2011 -NOD2011 -NBD2011 -LED2011 -LND2011
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2011 trial...
"c:\Program Files\Embarcadero\RAD Studio\8.0\bin\dcc32" CopyCat_2011.dpk -JPHNE -b -Q -W -H -N0Trial\D2011 -NHTrial\D2011 -NOTrial\D2011 -NBTrial\D2011 -LETrial\D2011 -LNTrial\D2011 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\8.0\bin\dcc32" CopyCat_2011.dpk -JL -Q -W -H -N0Trial\D2011 -NHTrial\D2011 -NOTrial\D2011 -NBTrial\D2011 -LETrial\D2011 -LNTrial\D2011 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2012...
"c:\Program Files\Embarcadero\RAD Studio\9.0\bin\dcc32" CopyCat_2012.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D2012 -NHD2012 -NOD2012 -NBD2012 -LED2012 -LND2012
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\9.0\bin\dcc32" CopyCat_2012.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D2012 -NHD2012 -NOD2012 -NBD2012 -LED2012 -LND2012
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2012 trial...
"c:\Program Files\Embarcadero\RAD Studio\9.0\bin\dcc32" CopyCat_2012.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D2012 -NHTrial\D2012 -NOTrial\D2012 -NBTrial\D2012 -LETrial\D2012 -LNTrial\D2012 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\9.0\bin\dcc32" CopyCat_2012.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D2012 -NHTrial\D2012 -NOTrial\D2012 -NBTrial\D2012 -LETrial\D2012 -LNTrial\D2012 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2013...
"c:\Program Files\Embarcadero\RAD Studio\10.0\bin\dcc32" CopyCat_2013.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D2013 -NHD2013 -NOD2013 -NBD2013 -LED2013 -LND2013
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\10.0\bin\dcc32" CopyCat_2013.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D2013 -NHD2013 -NOD2013 -NBD2013 -LED2013 -LND2013
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2013 trial...
"c:\Program Files\Embarcadero\RAD Studio\10.0\bin\dcc32" CopyCat_2013.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D2013 -NHTrial\D2013 -NOTrial\D2013 -NBTrial\D2013 -LETrial\D2013 -LNTrial\D2013 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\10.0\bin\dcc32" CopyCat_2013.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D2013 -NHTrial\D2013 -NOTrial\D2013 -NBTrial\D2013 -LETrial\D2013 -LNTrial\D2013 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2014...
"c:\Program Files\Embarcadero\RAD Studio\11.0\bin\dcc32" CopyCat_2014.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D2014 -NHD2014 -NOD2014 -NBD2014 -LED2014 -LND2014
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\11.0\bin\dcc32" CopyCat_2014.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D2014 -NHD2014 -NOD2014 -NBD2014 -LED2014 -LND2014
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2014 trial...
"c:\Program Files\Embarcadero\RAD Studio\11.0\bin\dcc32" CopyCat_2014.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D2014 -NHTrial\D2014 -NOTrial\D2014 -NBTrial\D2014 -LETrial\D2014 -LNTrial\D2014 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\11.0\bin\dcc32" CopyCat_2014.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D2014 -NHTrial\D2014 -NOTrial\D2014 -NBTrial\D2014 -LETrial\D2014 -LNTrial\D2014 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2015...
"c:\Program Files\Embarcadero\RAD Studio\12.0\bin\dcc32" CopyCat_XE5.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D2015 -NHD2015 -NOD2015 -NBD2015 -LED2015 -LND2015
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\12.0\bin\dcc32" CopyCat_XE5.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D2015 -NHD2015 -NOD2015 -NBD2015 -LED2015 -LND2015
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling D2015 trial...
"c:\Program Files\Embarcadero\RAD Studio\12.0\bin\dcc32" CopyCat_XE5.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D2015 -NHTrial\D2015 -NOTrial\D2015 -NBTrial\D2015 -LETrial\D2015 -LNTrial\D2015 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
"c:\Program Files\Embarcadero\RAD Studio\12.0\bin\dcc32" CopyCat_XE5.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D2015 -NHTrial\D2015 -NOTrial\D2015 -NBTrial\D2015 -LETrial\D2015 -LNTrial\D2015 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling XE6...
"C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\dcc32" CopyCat_XE6.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0XE6 -NHXE6 -NOXE6 -NBXE6 -LEXE6 -LNXE6
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\dcc32" CopyCat_XE6.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0XE6 -NHXE6 -NOXE6 -NBXE6 -LEXE6 -LNXE6
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling XE6 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\dcc32" CopyCat_XE6.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\XE6 -NHTrial\XE6 -NOTrial\XE6 -NBTrial\XE6 -LETrial\XE6 -LNTrial\XE6 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\14.0\bin\dcc32" CopyCat_XE6.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\XE6 -NHTrial\XE6 -NOTrial\XE6 -NBTrial\XE6 -LETrial\XE6 -LNTrial\XE6 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling XE7...
"C:\Program Files (x86)\Embarcadero\Studio\15.0\bin\dcc32" CopyCat_XE7.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0XE7 -NHXE7 -NOXE7 -NBXE7 -LEXE7 -LNXE7
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\15.0\bin\dcc32" CopyCat_XE7.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0XE7 -NHXE7 -NOXE7 -NBXE7 -LEXE7 -LNXE7
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling XE7 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\15.0\bin\dcc32" CopyCat_XE7.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\XE7 -NHTrial\XE7 -NOTrial\XE7 -NBTrial\XE7 -LETrial\XE7 -LNTrial\XE7 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\15.0\bin\dcc32" CopyCat_XE7.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\XE7 -NHTrial\XE7 -NOTrial\XE7 -NBTrial\XE7 -LETrial\XE7 -LNTrial\XE7 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling XE8...
"C:\Program Files (x86)\Embarcadero\Studio\16.0\bin\dcc32" CopyCat_XE8.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0XE8 -NHXE8 -NOXE8 -NBXE8 -LEXE8 -LNXE8
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\16.0\bin\dcc32" CopyCat_XE8.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0XE8 -NHXE8 -NOXE8 -NBXE8 -LEXE8 -LNXE8
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling XE8 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\16.0\bin\dcc32" CopyCat_XE8.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\XE8 -NHTrial\XE8 -NOTrial\XE8 -NBTrial\XE8 -LETrial\XE8 -LNTrial\XE8 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\16.0\bin\dcc32" CopyCat_XE8.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\XE8 -NHTrial\XE8 -NOTrial\XE8 -NBTrial\XE8 -LETrial\XE8 -LNTrial\XE8 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling Delphi 10...
"C:\Program Files (x86)\Embarcadero\Studio\17.0\bin\dcc32" CopyCat_D10.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D10 -NHD10 -NOD10 -NBD10 -LED10 -LND10
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\17.0\bin\dcc32" CopyCat_D10.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D10 -NHD10 -NOD10 -NBD10 -LED10 -LND10
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling Delphi 10 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\17.0\bin\dcc32" CopyCat_D10.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D10 -NHTrial\D10 -NOTrial\D10 -NBTrial\D10 -LETrial\D10 -LNTrial\D10 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\17.0\bin\dcc32" CopyCat_D10.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D10 -NHTrial\D10 -NOTrial\D10 -NBTrial\D10 -LETrial\D10 -LNTrial\D10 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error



echo.
echo Compiling Delphi 10.1...
"C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\dcc32" CopyCat_D10_1.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D101 -NHD101 -NOD101 -NBD101 -LED101 -LND101
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\dcc32" CopyCat_D10_1.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D101 -NHD101 -NOD101 -NBD101 -LED101 -LND101
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling Delphi 10.1 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\dcc32" CopyCat_D10_1.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D101 -NHTrial\D101 -NOTrial\D101 -NBTrial\D101 -LETrial\D101 -LNTrial\D101 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\18.0\bin\dcc32" CopyCat_D10_1.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D101 -NHTrial\D101 -NOTrial\D101 -NBTrial\D101 -LETrial\D101 -LNTrial\D101 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling Delphi 10.2...
"C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32" CopyCat_D10_2.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0D102 -NHD102 -NOD102 -NBD102 -LED102 -LND102
IF ERRORLEVEL 1 GOTO error
"C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32" CopyCat_D10_2.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0D102 -NHD102 -NOD102 -NBD102 -LED102 -LND102
IF ERRORLEVEL 1 GOTO error


echo.
echo Compiling Delphi 10.2 trial...
 "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32" CopyCat_D10_2.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JPHNE -b -Q -W -H -N0Trial\D102 -NHTrial\D102 -NOTrial\D102 -NBTrial\D102 -LETrial\D102 -LNTrial\D102 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error
 "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\dcc32" CopyCat_D10_2.dpk -nsSystem;System.Win;Winapi;Vcl;Data;Xml -JL -Q -W -H -N0Trial\D102 -NHTrial\D102 -NOTrial\D102 -NBTrial\D102 -LETrial\D102 -LNTrial\D102 -DCC_TRIAL
IF ERRORLEVEL 1 GOTO error


cd Install

echo.
echo Compiling Trial setup...
"C:\Program Files (x86)\Inno Setup 5\iscc" trial.iss 
IF ERRORLEVEL 1 GOTO error

echo.
echo Compiling Pro setup...
"C:\Program Files (x86)\Inno Setup 5\iscc" fullsource.iss 
IF ERRORLEVEL 1 GOTO error

goto end


:error
echo.
echo *** There is an error! ***
echo.

:end
pause