#!/bin/bash
# ---------------------------------------------------------
# 自动化执行剩余任务脚本 - 强制使用 GPU 2
# ---------------------------------------------------------

PYTHON="/public/home/sunqiucheng/.conda/envs/SparseGS/bin/python"
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_ROOT="${PROJECT_DIR}/data"
OUTPUT_ROOT="${PROJECT_DIR}/output"
LOG_ROOT="${PROJECT_DIR}/logs"
FAKE_EXCLUDE="${PROJECT_DIR}/fake_exclude"

mkdir -p "${LOG_ROOT}"
mkdir -p "${FAKE_EXCLUDE}/images"

# 基础参数
BASELINE_COMMON="--beta 5.0 --lambda_pearson 0.05 --lambda_local_pearson 0.15 --box_p 128 --p_corr 0.5 --lambda_diffusion 0.001 --SDS_freq 0.1 --step_ratio 0.99 --lambda_reg 0.1 --prune_sched 20000 --prune_perc 0.98 --prune_exp 7.5 --iterations 30000 --save_iterations 30000 --test_iterations 30000 -r 2"
# 改进参数
IMPROVED_EXTRA="--densify_with_depth 1 --prune_range 3.0 --pts_iter 2500 --pts_dist 10000 --pts_N_intpl 4 --pts_N_pts 100000"

run_experiment() {
    local GPU_ID=$1
    local SCENE=$2
    local TAG=$3
    local EXTRA_ARGS=$4

    local MODEL_PATH="${OUTPUT_ROOT}/${SCENE}_${TAG}"
    local LOG_FILE="${LOG_ROOT}/${SCENE}_${TAG}.log"

    # 如果已经有 results.json 且不是 NaN，则跳过
    if [ -f "${MODEL_PATH}/results.json" ] && ! grep -q "NaN" "${MODEL_PATH}/results.json"; then
        echo "[SKIP] ${SCENE}_${TAG} 已完成且指标正常，跳过。"
        return
    fi

    echo "========================================================"
    echo "[START] $(date '+%Y-%m-%d %H:%M:%S') | GPU ${GPU_ID} | ${SCENE} | ${TAG}"
    echo "========================================================"

    # 1. TRAIN
    CUDA_VISIBLE_DEVICES=${GPU_ID} ${PYTHON} train.py --source_path "${DATA_ROOT}/${SCENE}" --model_path "${MODEL_PATH}" ${BASELINE_COMMON} ${EXTRA_ARGS} >> "${LOG_FILE}" 2>&1

    # 2. RENDER
    CUDA_VISIBLE_DEVICES=${GPU_ID} ${PYTHON} render.py --source_path "${DATA_ROOT}/${SCENE}" --model_path "${MODEL_PATH}" --no_load_depth --iteration 30000 >> "${LOG_FILE}" 2>&1

    # 3. METRICS (关键修复：使用 fake_exclude)
    CUDA_VISIBLE_DEVICES=${GPU_ID} ${PYTHON} metrics.py --model_paths "${MODEL_PATH}" --exclude_path "${FAKE_EXCLUDE}" >> "${LOG_FILE}" 2>&1

    echo "[FINISH] ${SCENE}_${TAG} ✓"
}

# 使用 GPU 2 跑剩下的任务（GPU 2 目前是空闲的）
# 之前没跑完或需要重跑的任务：
run_experiment 2 "garden_24"  "improved" "${IMPROVED_EXTRA}"
run_experiment 2 "counter_18" "baseline" ""
run_experiment 2 "counter_18" "improved" "${IMPROVED_EXTRA}"
run_experiment 2 "garden_12"  "baseline" ""
run_experiment 2 "garden_12"  "improved" "${IMPROVED_EXTRA}"

echo "所有任务已加入队列。查看进度请用: tail -f logs/<scene>_<tag>.log"