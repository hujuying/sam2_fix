#!/bin/bash

# ==============================================================================
# 完整自动化更新与修复脚本 (最终修正版)
# 功能：
# 1. 从 Git 仓库克隆/更新所有 .fix 文件到临时工作区。
# 2. 检测本地目标文件是否存在，跳过不存在的文件。
# 3. 如果所有目标文件都不存在，则直接退出。
# 4. 对于存在的目标文件，直接使用临时工作区中的 .fix 文件进行替换。
# 5. 清理临时文件。
# 关键：此脚本完全自包含，不依赖任何外部 .sh 文件或 /workspace/temp/ 目录。
# ==============================================================================

# --- 配置常量 ---
REPO_URL="https://github.com/hujuying/sam2_fix.git"
WORKSPACE_DIR="/workspace/sam2_fix_temp_workspace"

# --- 从Git仓库下载的文件路径 ---
FIXED_SAM2_FILE="${WORKSPACE_DIR}/AILab_SAM2Segment.py.fix"
FIXED_CORE_FILE="${WORKSPACE_DIR}/core.py.fix"

# --- 本地目标文件路径 ---
TARGET_SAM2_FILE="/workspace/ComfyUI/custom_nodes/comfyui-rmbg/AILab_SAM2Segment.py"
TARGET_CORE_FILE="/workspace/ComfyUI/custom_nodes/comfyui-impact-pack/modules/impact/core.py"

# --- 函数定义 ---
log_info() { echo -e "\033[0;32m[INFO]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }
log_step() {
    echo -e "\n\033[1;34m========================================\033[0m"
    echo -e "\033[1;34m  $1 \033[0m"
    echo -e "\033[1;34m========================================\033[0m"
}

# --- 内建的替换函数 ---
# 这个函数直接复制文件，不调用任何外部脚本
perform_replace() {
    local source="$1"
    local target="$2"
    local desc="$3"

    if [ ! -f "$source" ]; then
        log_error "[逻辑错误] 源文件 '$source' 不存在。这表示Git仓库缺少对应文件。"
        return 1
    fi

    log_info "正在处理 '$desc'..."
    local target_dir=$(dirname "$target")
    local target_filename=$(basename "$target")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_file="${target_dir}/${target_filename}.bak_${timestamp}"

    if [ -f "$target" ]; then
        log_info "  -> 发现旧文件，备份至: $backup_file"
        cp "$target" "$backup_file" || { log_error "备份失败!"; return 1; }
        rm -f "$target" || { log_error "删除旧文件失败!"; return 1; }
    else
        log_info "  -> 目标文件不存在，将直接创建。"
        mkdir -p "$target_dir" || { log_error "创建目标目录 '$target_dir' 失败!"; return 1; }
    fi
    
    log_info "  -> 正在从 '$source' 复制到 '$target'..."
    cp -f "$source" "$target"
    if [ $? -eq 0 ]; then
        log_info "  -> ✅ '$desc' 替换/创建成功！"
        [ -n "$backup_file" ] && log_info "  -> 原始文件备份: $backup_file"
        return 0
    else
        log_error "  -> ❌ '$desc' 替换失败！"
        return 1
    fi
}

# --- 主程序逻辑 ---
# 0. 清理旧工作区
[ -d "$WORKSPACE_DIR" ] && { log_info "清理旧工作区..."; rm -rf "$WORKSPACE_DIR"; }

# 1. 克隆仓库
log_step "步骤 1: 克隆 Git 仓库"
git clone "$REPO_URL" "$WORKSPACE_DIR" || { log_error "克隆失败!"; exit 1; }
log_info "仓库克隆成功。"

# 2. 检查源文件
log_step "步骤 2: 检查仓库中的文件"
MISSING_FIX_FILES=0
[ ! -f "$FIXED_SAM2_FILE" ] && { log_error "缺少 '$FIXED_SAM2_FILE'"; ((MISSING_FIX_FILES++)); }
[ ! -f "$FIXED_CORE_FILE" ] && { log_error "缺少 '$FIXED_CORE_FILE'"; ((MISSING_FIX_FILES++)); }
[ "$MISSING_FIX_FILES" -gt 0 ] && log_error "仓库中缺少 $MISSING_FIX_FILES 个 .fix 文件，替换操作可能失败。"
log_info "源文件检查完毕。"

# 3. 执行替换
log_step "步骤 3: 执行文件替换"
PROCESSED_COUNT=0
[ -f "$TARGET_SAM2_FILE" ] && { perform_replace "$FIXED_SAM2_FILE" "$TARGET_SAM2_FILE" "AILab_SAM2Segment.py" && ((PROCESSED_COUNT++)); } || log_info "跳过 '$TARGET_SAM2_FILE'。"
[ -f "$TARGET_CORE_FILE" ] && { perform_replace "$FIXED_CORE_FILE" "$TARGET_CORE_FILE" "core.py" && ((PROCESSED_COUNT++)); } || log_info "跳过 '$TARGET_CORE_FILE'。"

# 4. 清理与报告
log_step "步骤 4: 完成处理"
[ "$PROCESSED_COUNT" -gt 0 ] && log_info "成功处理了 $PROCESSED_COUNT 个文件。" || log_info "没有找到需要处理的目标文件。"
log_info "清理临时工作区 '$WORKSPACE_DIR'..."
rm -rf "$WORKSPACE_DIR"
log_step "所有操作执行完毕！"
exit 0

