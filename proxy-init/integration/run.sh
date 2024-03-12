#!/usr/bin/env bash

set -euxo pipefail

cd "${BASH_SOURCE[0]%/*}"

# Run kubectl with the correct context.
function k() {
  if [ -n "${TEST_CTX:-}" ]; then
    kubectl --context="$TEST_CTX" "$@"
  else
    kubectl "$@"
  fi
}

# Get the IP of a test pod.
function kip(){
    local name=$1
    k wait pod "$name" --namespace=proxy-init-test \
        --for=condition=ready --timeout=1m \
        >/dev/null

    k get pod "$name" --namespace=proxy-init-test \
        --template='{{.status.podIP}}'
}

if k get ns/proxy-init-test >/dev/null 2>&1 ; then
  echo 'ns/proxy-init-test already exists' >&2
  exit 1
fi

echo '# Creating the test lab...'
#sysctl -a | grep disable_ipv6
sudo ip6tables-save
sudo ip6tables-save -h
modprobe ipv6
