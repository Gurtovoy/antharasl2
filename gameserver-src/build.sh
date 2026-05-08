#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

BUILD_MODE="${1:-full}"
if [[ "${BUILD_MODE}" != "full" && "${BUILD_MODE}" != "--commons-only" ]]; then
  echo "[ERROR] Unknown mode: ${BUILD_MODE}"
  echo "Usage: ./build.sh [--commons-only]"
  exit 1
fi

MVN_LOCAL="${SCRIPT_DIR}/tools/apache-maven-3.9.9/bin/mvn"
if [[ -x "${MVN_LOCAL}" ]]; then
  MVN="${MVN_LOCAL}"
else
  MVN="mvn"
fi

if ! command -v "${MVN}" >/dev/null 2>&1; then
  echo "[ERROR] Maven not found. Install Maven or provide tools/apache-maven-3.9.9/bin/mvn"
  exit 1
fi

GS_LIB="${SCRIPT_DIR}/../gameserver/lib"
AS_LIB="${SCRIPT_DIR}/../authserver/lib"

GS_TARGET="${SCRIPT_DIR}/gameserver/target"
AS_TARGET="${SCRIPT_DIR}/authserver/target"
CM_TARGET="${SCRIPT_DIR}/commons/target"

ensure_servers_stopped() {
  if ! command -v pgrep >/dev/null 2>&1; then
    return
  fi

  if pgrep -f "l2s.gameserver.GameServer|l2s.authserver.AuthServer" >/dev/null 2>&1; then
    echo "[ERROR] GameServer/AuthServer process is running."
    echo "        Stop both servers before build to avoid locked jars in lib/."
    exit 1
  fi
}

clean_stale_runtime_jars() {
  mkdir -p "${GS_LIB}" "${AS_LIB}"
  # Remove stale jars that can shadow newer dependencies in ./lib/*
  rm -f \
    "${GS_LIB}"/l2s-*.jar \
    "${AS_LIB}"/l2s-*.jar \
    "${GS_LIB}"/commons-lang3-*.jar \
    "${AS_LIB}"/commons-lang3-*.jar \
    "${GS_LIB}"/log4j-1*.jar \
    "${AS_LIB}"/log4j-1*.jar \
    "${GS_LIB}"/slf4j-log4j12*.jar \
    "${AS_LIB}"/slf4j-log4j12*.jar \
    "${GS_LIB}"/commons-dbcp*.jar \
    "${AS_LIB}"/commons-dbcp*.jar || true
}

echo "============================================================"
echo " Build and Deploy (commons, gameserver, authserver)"
echo "============================================================"
echo

ensure_servers_stopped
clean_stale_runtime_jars

echo "[1/5] Running Maven install..."
if [[ "${BUILD_MODE}" == "--commons-only" ]]; then
  "${MVN}" -pl commons -am install -DskipTests -f "${SCRIPT_DIR}/pom.xml"
else
  "${MVN}" install -DskipTests -f "${SCRIPT_DIR}/pom.xml"
fi

echo
echo "[2/5] Locating build artifacts..."

pick_main_jar() {
  local dir="$1"
  local prefix="$2"
  local jar
  jar="$(ls -1 "${dir}/${prefix}"-*.jar 2>/dev/null | grep -Ev '(-sources|-javadoc)\.jar$' | tail -n 1 || true)"
  if [[ -z "${jar}" ]]; then
    echo "[ERROR] ${prefix} jar not found in ${dir}" >&2
    exit 1
  fi
  printf '%s' "${jar}"
}

CM_JAR="$(pick_main_jar "${CM_TARGET}" "l2s-commons")"

echo "Found:"
echo "  commons:    ${CM_JAR}"
if [[ "${BUILD_MODE}" != "--commons-only" ]]; then
  GS_JAR="$(pick_main_jar "${GS_TARGET}" "l2s-gameserver")"
  AS_JAR="$(pick_main_jar "${AS_TARGET}" "l2s-authserver")"
  echo "  gameserver: ${GS_JAR}"
  echo "  authserver: ${AS_JAR}"
fi
echo

echo "[3/5] Deploying main jars..."
mkdir -p "${GS_LIB}" "${AS_LIB}"

if [[ "${BUILD_MODE}" != "--commons-only" ]]; then
  cp -f "${GS_JAR}" "${GS_LIB}/gameserver.jar"
  cp -f "${AS_JAR}" "${AS_LIB}/authserver.jar"
fi
cp -f "${CM_JAR}" "${GS_LIB}/commons.jar"
cp -f "${CM_JAR}" "${AS_LIB}/commons.jar"

echo "[4/5] Runtime dependencies..."
echo "Runtime dependencies are copied by Maven during module package phase."

echo
echo "[5/5] Deployment results:"
if [[ "${BUILD_MODE}" == "--commons-only" ]]; then
  du -h "${GS_LIB}/commons.jar" "${AS_LIB}/commons.jar"
else
  du -h "${GS_LIB}/gameserver.jar" "${AS_LIB}/authserver.jar" "${GS_LIB}/commons.jar" "${AS_LIB}/commons.jar"
fi
echo
echo "Done. Build and deployment completed."
