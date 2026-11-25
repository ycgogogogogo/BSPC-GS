#!/bin/bash
# ============================================================
# 多GPU并行训练脚本 (已更新 Train 参数)
# ============================================================

mkdir -p logs

TRAIN="python3 train.py"
RENDER="python3 render.py"
METRICS="python3 metrics.py"

# 新增：统一管理新增的超参数
TRAIN_OPTS="-r 2 --lambda_pearson 0.05 --lambda_local_pearson 0.15 --lambda_diffusion 0.001 --SDS_freq 0.1 --lambda_reg 0.1 --prune_perc 0.98 --prune_exp 7.5"
PRUNE_SCHED="20000" # 根据你的新指令更新为 20000
TEST_ITER="7000 15000 30000"
SAVE_ITER="7000 15000 30000"

# ============================================================
# GPU 0 → bicycle_12
# ============================================================
run_bicycle_12() {
    export CUDA_VISIBLE_DEVICES=0
    SOURCE_TRAIN="./data/bicycle_12"
    SOURCE_FULL="./data/bicycle"
    MODEL="./output/bicycle_12_improved"
    EXCLUDE="./data/bicycle_12"
    LOG="./logs/bicycle_12"

    echo "[GPU0] START train: bicycle_12" | tee ${LOG}_train.log
    nohup ${TRAIN} \
        -s ${SOURCE_TRAIN} \
        --model_path ${MODEL} \
        --iterations 30000 \
        --prune_sched ${PRUNE_SCHED} \
        --test_iterations ${TEST_ITER} \
        --save_iterations ${SAVE_ITER} \
        ${TRAIN_OPTS} \
        >> ${LOG}_train.log 2>&1

    echo "[GPU0] DONE train, start render..." | tee -a ${LOG}_train.log
    nohup ${RENDER} \
        --source_path ${SOURCE_FULL} \
        --model_path ${MODEL} \
        --no_load_depth \
        --iteration 30000 \
        >> ${LOG}_render.log 2>&1

    echo "[GPU0] DONE render, start metrics..." | tee -a ${LOG}_train.log
    nohup ${METRICS} \
        --model_path ${MODEL} \
        --exclude_path ${EXCLUDE} \
        >> ${LOG}_metrics.log 2>&1
}

# ============================================================
# GPU 1 → garden_12
# ============================================================
run_garden_12() {
    export CUDA_VISIBLE_DEVICES=1
    SOURCE_TRAIN="./data/garden_12"
    SOURCE_FULL="./data/garden"
    MODEL="./output/garden_12_improved"
    EXCLUDE="./data/garden_12"
    LOG="./logs/garden_12"

    echo "[GPU1] START train: garden_12" | tee ${LOG}_train.log
    nohup ${TRAIN} \
        -s ${SOURCE_TRAIN} \
        --model_path ${MODEL} \
        --iterations 30000 \
        --prune_sched ${PRUNE_SCHED} \
        --test_iterations ${TEST_ITER} \
        --save_iterations ${SAVE_ITER} \
        ${TRAIN_OPTS} \
        >> ${LOG}_train.log 2>&1

    echo "[GPU1] DONE train, start render..." | tee -a ${LOG}_train.log
    nohup ${RENDER} \
        --source_path ${SOURCE_FULL} \
        --model_path ${MODEL} \
        --no_load_depth \
        --iteration 30000 \
        >> ${LOG}_render.log 2>&1

    echo "[GPU1] DONE render, start metrics..." | tee -a ${LOG}_train.log
    nohup ${METRICS} \
        --model_path ${MODEL} \
        --exclude_path ${EXCLUDE} \
        >> ${LOG}_metrics.log 2>&1
}

# ============================================================
# GPU 2 → garden_24
# ============================================================
run_garden_24() {
    export CUDA_VISIBLE_DEVICES=2
    SOURCE_TRAIN="./data/garden_24"
    SOURCE_FULL="./data/garden"
    MODEL="./output/garden_24_improved"
    EXCLUDE="./data/garden_24"
    LOG="./logs/garden_24"

    echo "[GPU2] START train: garden_24" | tee ${LOG}_train.log
    nohup ${TRAIN} \
        -s ${SOURCE_TRAIN} \
        --model_path ${MODEL} \
        --iterations 30000 \
        --prune_sched ${PRUNE_SCHED} \
        --test_iterations ${TEST_ITER} \
        --save_iterations ${SAVE_ITER} \
        ${TRAIN_OPTS} \
        >> ${LOG}_train.log 2>&1

    echo "[GPU2] DONE train, start render..." | tee -a ${LOG}_train.log
    nohup ${RENDER} \
        --source_path ${SOURCE_FULL} \
        --model_path ${MODEL} \
        --no_load_depth \
        --iteration 30000 \
        >> ${LOG}_render.log 2>&1

    echo "[GPU2] DONE render, start metrics..." | tee -a ${LOG}_train.log
    nohup ${METRICS} \
        --model_path ${MODEL} \
        --exclude_path ${EXCLUDE} \
        >> ${LOG}_metrics.log 2>&1
}

# ============================================================
# GPU 3 → counter_18
# ============================================================
run_counter_18() {
    export CUDA_VISIBLE_DEVICES=3
    SOURCE_TRAIN="./data/counter_18"
    SOURCE_FULL="./data/counter"
    MODEL="./output/counter_18_improved"
    EXCLUDE="./data/counter_18"
    LOG="./logs/counter_18"

    echo "[GPU3] START train: counter_18" | tee ${LOG}_train.log
    nohup ${TRAIN} \
        -s ${SOURCE_TRAIN} \
        --model_path ${MODEL} \
        --iterations 30000 \
        --prune_sched ${PRUNE_SCHED} \
        --test_iterations ${TEST_ITER} \
        --save_iterations ${SAVE_ITER} \
        ${TRAIN_OPTS} \
        >> ${LOG}_train.log 2>&1

    echo "[GPU3] DONE train, start render..." | tee -a ${LOG}_train.log
    nohup ${RENDER} \
        --source_path ${SOURCE_FULL} \
        --model_path ${MODEL} \
        --no_load_depth \
        --iteration 30000 \
        >> ${LOG}_render.log 2>&1

    echo "[GPU3] DONE render, start metrics..." | tee -a ${LOG}_train.log
    nohup ${METRICS} \
        --model_path ${MODEL} \
        --exclude_path ${EXCLUDE} \
        >> ${LOG}_metrics.log 2>&1
}

# 并行启动
run_bicycle_12 &
run_garden_12 &
run_garden_24 &
run_counter_18 &

wait
echo "全部并行任务已执行完毕。"