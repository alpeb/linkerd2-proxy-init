#!/usr/bin/env bash

set -euo pipefail

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
cat /proc/net/if_inet6
modinfo ipv6
lsmod | grep -i ipv6
k create ns proxy-init-test
k create -f iptables/iptablestest-lab.yaml

POD_WITH_NO_RULES_IP=$(kip pod-with-no-rules)
echo "POD_WITH_NO_RULES_IP=${POD_WITH_NO_RULES_IP}"

POD_WITH_EXISTING_RULES_IP=$(kip pod-with-existing-rules)
echo "POD_WITH_EXISTING_RULES_IP=${POD_WITH_EXISTING_RULES_IP}"

k get po -A -owide
k -n proxy-init-test describe po pod-with-existing-rules
k -n proxy-init-test logs pod-with-existing-rules iptables-test
