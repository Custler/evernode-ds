#!/bin/bash -eEx

echo "INFO: ever-node startup..."

echo "INFO: NETWORK_TYPE = ${NETWORK_TYPE}"
echo "INFO: CONFIGS_PATH = ${CONFIGS_PATH}"
echo "INFO: \$1 = $1"

curl -sS "https://raw.githubusercontent.com/tonlabs/${NETWORK_TYPE}/master/configs/ton-global.config.json" \
    -o "${CONFIGS_PATH}/ton-global.config.json"

if [ "$1" = "bash" ]; then
    tail -f /dev/null
else
    cd /ever-node
    Curr_Timestamp="$(date +%Y-%m-%d_%H-%M-%S)"
    echo -e "\n$Curr_Timestamp" | tee -a ${NODE_LOGS_DIR}/stdout.log ${NODE_LOGS_DIR}/stderr.log > /dev/null
    export RUST_BACKTRACE=full
    exec /ever-node/ton_node --configs "${CONFIGS_PATH}" >> ${NODE_LOGS_DIR}/stdout.log \
        2>>${NODE_LOGS_DIR}/stderr.log
fi

echo "INFO: ever-node startup... DONE"
