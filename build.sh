#!/usr/bin/env bash

# Note: the following license applies only to this file.
#
# Copyright (c) 2015, Rahul AG
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

set -e -u

DATADIR=data
TEMPDIR=work
OUTDIR=out

opoo() { echo >&2 ${@}; }
build-usage() {
	local me=$(basename ${0})
	opoo "${me} <instance_id> [local_hostname]"
}
trap build-usage ERR

instance_id=${1:-help}
local_hostname=${2:-${instance_id}}

ISO=${OUTDIR}/${instance_id}.iso

binexists() {
	type ${1} >/dev/null 2>&1
}

build() {
	mkdir -p ${TEMPDIR}
	rsync -a --exclude meta-data ${DATADIR}/* ${TEMPDIR}
	sed -Ee "s/\\\${INSTANCE_ID}/${instance_id}/g" -e "s/\\\${LOCAL_HOSTNAME}/${local_hostname}/g" ${DATADIR}/meta-data >${TEMPDIR}/meta-data

	mkdir -p ${OUTDIR}
	[[ -f ${ISO} ]] && opoo "${ISO} exists, not overwriting." && return 1
	binexists hdiutil && hdiutil makehybrid -iso -joliet -default-volume-name cidata -o ${ISO} ${TEMPDIR} && return $?
	binexists genisoimage && genisoimage -output ${ISO} -volid cidata -joliet -rock	${TEMPDIR} && return $?
}

case ${instance_id} in
	help|--help|-h)
		build-usage
		;;
	*)
		build
		[[ -d ${TEMPDIR} ]] && rm -rf ${TEMPDIR}
		;;
esac
