@echo off
setlocal
:: Wiperdog Service Startup Script for Windows

:: determine the home

set BASEDIR=%~dp0
set HAS_MVN="0"
set HAS_SVN="0"
rem for %%i in ("%BASEDIR%") do set BASEDIR=%%~fsi

svn --version >nul 2>&1 && ( 
	mvn -v >nul 2>&1 && ( 
		git --version >nul 2>&1 && ( 
			patch --version >nul 2>&1 && (
				echo Required commands are ready. Proceed.
				if not exist terracotta-runtime-4.1.1 (
					echo Check out Terracotta...
					svn checkout http://svn.terracotta.org/svn/tc/dso/tags/4.1.1 terracotta-runtime-4.1.1
				)
				if not exist quartz-2.2.1 (
					echo Check out Quartz...
					svn checkout http://svn.terracotta.org/svn/quartz/tags/quartz-2.2.1
				)
				if not exist ehcache-2.8.1 (
					echo Check out Ehcache...
					svn checkout http://svn.terracotta.org/svn/ehcache/tags/ehcache-2.8.1
				)
				if not exist experimental (
					echo Git clone experimental...
					git clone https://github.com/wiperdog/experimental.git
				)
				
				REM Script for patching and installing
				cd terracotta-runtime-4.1.1
				patch -p0 < %BASEDIR%terracotta-4.1.1-build.patch --binary
				set MAVEN_OPTS=-Xmx512m -XX:MaxPermSize=128m
				echo "Build EHCache...Press any key"
				pause > null
				cd ../ehcache-2.8.1
				mvn install -DskipTests
				echo "Build quartz...Press any key"
				pause > null
				cd ../quartz-2.2.1
				mvn install -DskipTests
				echo "Build terracotta...Press any key"
				pause > null
				cd ../terracotta-runtime-4.1.1
				mvn install -DskipTests
				echo "Start terracotta server...Press any key"
				cd deploy
				mvn exec:exec -P start-server
			) || ( 
				echo patch command not found. Please install it 
				echo Try this http://gnuwin32.sourceforge.net/packages/patch.htm
			)
		) || ( 
			echo git command not found. Please install it 
			echo Try this http://msysgit.github.io/
		)
	) || ( 
		echo mvn command not found. Please install it 
		echo Try this http://maven.apache.org/
	)
) || ( 
	echo svn command not found. Please install it 
	echo Try this http://www.collab.net/search/node/Subversion%20Command-Line%20Client
)


endlocal