#!/bin/sh
#
# ***************************************************************************
# Copyright (c) 2010 Qcadoo Limited
# Project: Qcadoo Framework
# Version: 1.2.0
#
# This file is part of Qcadoo.
#
# Qcadoo is free software; you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation; either version 3 of the License,
# or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# ***************************************************************************
#


# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# -----------------------------------------------------------------------------
# Wrapper script for command line tools
#
# Environment Variable Prequisites
#
#   CATALINA_HOME May point at your Catalina "build" directory.
#
#   TOOL_OPTS     (Optional) Java runtime options used when the "start",
#                 "stop", or "run" command is executed.
#
#   JAVA_HOME     Must point at your Java Development Kit installation.
#
#   JAVA_OPTS     (Optional) Java runtime options used when the "start",
#                 "stop", or "run" command is executed.
#
# $Id: tool-wrapper.sh 947596 2010-05-24 10:50:27Z kkolinko $
# -----------------------------------------------------------------------------

# OS specific support.  $var _must_ be set to either true or false.
cygwin=false
case "`uname`" in
CYGWIN*) cygwin=true;;
esac

# resolve links - $0 may be a softlink
PRG="$0"

while [ -h "$PRG" ]; do
  ls=`ls -ld "$PRG"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    PRG="$link"
  else
    PRG=`dirname "$PRG"`/"$link"
  fi
done

# Get standard environment variables
PRGDIR=`dirname "$PRG"`
CATALINA_HOME=`cd "$PRGDIR/.." >/dev/null; pwd`

# Ensure that any user defined CLASSPATH variables are not used on startup,
# but allow them to be specified in setenv.sh, in rare case when it is needed.
CLASSPATH=

if [ -r "$CATALINA_HOME"/bin/setenv.sh ]; then
  . "$CATALINA_HOME"/bin/setenv.sh
fi

# For Cygwin, ensure paths are in UNIX format before anything is touched
if $cygwin; then
  [ -n "$JAVA_HOME" ] && JAVA_HOME=`cygpath --unix "$JAVA_HOME"`
  [ -n "$CATALINA_HOME" ] && CATALINA_HOME=`cygpath --unix "$CATALINA_HOME"`
  [ -n "$CLASSPATH" ] && CLASSPATH=`cygpath --path --unix "$CLASSPATH"`
fi

# Get standard Java environment variables
if [ -r "$CATALINA_HOME"/bin/setclasspath.sh ]; then
  BASEDIR="$CATALINA_HOME"
  . "$CATALINA_HOME"/bin/setclasspath.sh
else
  echo "Cannot find $CATALINA_HOME/bin/setclasspath.sh"
  echo "This file is needed to run this program"
  exit 1
fi

# Add on extra jar files to CLASSPATH
CLASSPATH="$CLASSPATH":"$CATALINA_HOME"/bin/bootstrap.jar:"$BASEDIR"/lib/servlet-api.jar

# For Cygwin, switch paths to Windows format before running java
if $cygwin; then
  JAVA_HOME=`cygpath --path --windows "$JAVA_HOME"`
  CATALINA_HOME=`cygpath --path --windows "$CATALINA_HOME"`
  CLASSPATH=`cygpath --path --windows "$CLASSPATH"`
fi

# ----- Execute The Requested Command -----------------------------------------

exec "$_RUNJAVA" $JAVA_OPTS $TOOL_OPTS \
  -Djava.endorsed.dirs="$JAVA_ENDORSED_DIRS" -classpath "$CLASSPATH" \
  -Dcatalina.home="$CATALINA_HOME" \
  org.apache.catalina.startup.Tool "$@"
