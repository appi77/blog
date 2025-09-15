# define required memory settings for ac on tomcat
CATALINA_OPTS="-Xmx2048m -Djava.awt.headless=true $CATALINA_OPTS"; export CATALINA_OPTS
CATALINA_PID=$CATALINA_HOME/tomcat.pid; export CATALINA_PID
# required of Archive Centre / Server
SHARED_LIB_PATH=$OTHOME/lib; export SHARED_LIB_PATH
LD_LIBRARY_PATH=$SHARED_LIB_PATH:$LIBPATH:$ORACLE_HOME/client64/lib:$LD_LIBRARY_PATH; export LD_LIBRARY_PATH
PATH=$PATH:/usr/lib64/
ECM_VAR_DIR=/opt/opentext/actemp; export ECM_VAR_DIR
AS_PREF_IP=4; export AS_PREF_IP
