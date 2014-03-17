#!/bin/sh
#
#
#
basedir=`pwd`
### Checking maven
MVN_COMMAND=`which mvn`
echo "Using maven command as path:" $MVN_COMMAND
if [ ! -n "$MVN_COMMAND" ] || [ ! -x $MVN_COMMAND ];then
  echo "Maven not found, please install the lastest version"
  exit 1
fi
#echo " BASEDIR:" $basedir
  if [ ! -d terracotta-runtime-4.1.1 ] || [ ! -d ehcache-2.8.1 ] || [ ! -d quartz-2.2.1 ] || [ ! -d experimental ];then
    ### Checking subversion
    SVN_COMMAND=`which svn`
    echo "Using svn command as path:" $SVN_COMMAND
    if [ ! -n "$SVN_COMMAND" ] || [ ! -x $SVN_COMMAND ];then
      echo "SVN not found, please install"
      exit 1
    fi
    ### Checking github
    GIT_COMMAND=`which git`
    echo "Using github command as path:" $GIT_COMMAND
    if [ ! -n "$GIT_COMMAND" ] || [ ! -x $GIT_COMMAND ];then
      echo "GIT not found, please install the lastest version "
      exit 1
    fi

    echo "First time installation, start downloading binary packages from SVN and Subversion"
    if [ ! -d terracotta-runtime-4.1.1 ];then 
      echo "Checkout terracotta-runtime-4.1.1..."
      $SVN_COMMAND checkout http://svn.terracotta.org/svn/tc/dso/tags/4.1.1 terracotta-runtime-4.1.1
    fi
    if [ ! -d quartz-2.2.1 ];then 
      echo "Checkout quartz..."
      $SVN_COMMAND checkout http://svn.terracotta.org/svn/quartz/tags/quartz-2.2.1
    fi
    if [ ! -d ehcache-2.8.1 ];then 
      echo "Checkout ehcache..."
      $SVN_COMMAND checkout http://svn.terracotta.org/svn/ehcache/tags/ehcache-2.8.1
    fi  
    
    if [ ! -d experimental ];then 
      echo "Clone terracotta patch from github..."
      $GIT_COMMAND clone https://github.com/wiperdog/experimental.git
    fi  
    cp $basedir/experimental/terracotta/terracotta-4.1.1-build.patch $basedir
    ### Patching terracotta
    echo "Patching terracotta..."
    cd $basedir/terracotta-runtime-4.1.1
    patch -p0 < $basedir/terracotta-4.1.1-build.patch
  fi

  echo "Start Building, Installing and Running terracotta server"  
  ########################## INSTALLATION ####################################
  
  # Set HEAP and PERMGEN for Maven
  unset MAVEN_OPTS
  export MAVEN_OPTS="-Xmx512m -XX:MaxPermSize=128m"
  ### Build Ehcache ###
  echo "Building Ehcache..."
  cd $basedir/ehcache-2.8.1
  $MVN_COMMAND install -DskipTests

  ### Build quartz ###
  echo "Building Quartz..."
  cd $basedir/quartz-2.2.1
  $MVN_COMMAND install -DskipTests

  ### Build terracotta-runtime ###
  echo "Building terracotta runtime..."
  cd $basedir/terracotta-runtime-4.1.1
  $MVN_COMMAND install

  ### Start terracotta server ### 
  echo "Running terracotta server"
  cd $basedir/terracotta-runtime-4.1.1/deploy
  $MVN_COMMAND exec:exec -P start-server
  

