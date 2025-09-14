#!/bin/bash

# ==============================================================================
# 脚本：fix_core.py.sh
# 功能：替换指定路径下的 core.py 文件，并在替换前创建备份。
# 设计为独立脚本，接受目标路径作为参数。
# ==============================================================================

# --- 1. 参数检查与帮助信息 ---
if [ -z "$1" ]; then
    echo -e "\033[0;31m[错误] 用法: $0 <目标文件的完整路径>\033[0m"
    echo ""
    echo "示例:"
    echo "  $0 /workspace/ComfyUI/custom_nodes/comfyui-impact-pack/modules/impact/core.py"
    echo ""
    echo "此脚本会尝试将 '/workspace/temp/core.py.fix' 复制到指定的目标路径。"
    echo "如果目标文件已存在，会先将其备份为 '.bak_时间戳' 文件。"
    exit 1
fi

TARGET_FILE="$1"
SOURCE_FILE="/workspace/temp/core.py.fix"

# --- 2. 基础检查 ---
# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "\033[0;31m[致命错误] 源文件不存在: $SOURCE_FILE\033[0m"
    echo "请确保修复文件已放置在正确的位置。"
    exit 1
fi

# 检查目标文件的目录是否存在，如果不存在则创建
TARGET_DIR=$(dirname "$TARGET_FILE")
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "\033[0;33m[提示] 目标目录 '$TARGET_DIR' 不存在，正在创建...\033[0m"
    mkdir -p "$TARGET_DIR"
    if [ $? -ne 0 ]; then
        echo -e "\033[0;31m[错误] 无法创建目标目录 '$TARGET_DIR'。\033[0m"
        exit 1
    fi
fi

# --- 3. 备份逻辑 ---
if [ -f "$TARGET_FILE" ]; then
    echo -e "\033[0;33m[信息] 目标文件 '$TARGET_FILE' 已存在。\033[0m"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="${TARGET_FILE}.bak_${TIMESTAMP}"
    
    echo -e "\033[0;34m[操作] 正在创建备份: $BACKUP_FILE\033[0m"
    cp "$TARGET_FILE" "$BACKUP_FILE"
    
    if [ $? -ne 0 ]; then
        echo -e "\033[0;31m[错误] 备份失败！操作中止。\033[0m"
        exit 1
    fi
    echo -e "\033[0;32m[成功] 备份已完成。\033[0m"

    # 删除旧文件
    echo -e "\033[0;34m[操作] 正在删除旧文件...\033[0m"
    rm -f "$TARGET_FILE"
    if [ $? -ne 0 ]; then
        echo -e "\033[0;31m[警告] 删除旧文件失败，请手动检查权限或文件是否被占用。\033[0m"
        echo "但将继续尝试复制新文件。"
    else
        echo -e "\033[0;32m[成功] 旧文件已删除。\033[0m"
    fi
else
    echo -e "\033[0;33m[信息] 目标文件 '$TARGET_FILE' 不存在，将直接创建。\033[0m"
fi

# --- 4. 执行替换 ---
echo -e "\033[0;34m[操作] 正在从 '$SOURCE_FILE' 复制到 '$TARGET_FILE'...\033[0m"
cp -f "$SOURCE_FILE" "$TARGET_FILE"

# --- 5. 验证结果 ---
if [ $? -eq 0 ] && [ -f "$TARGET_FILE" ]; then
    echo ""
    echo -e "\033[1;32m================================================\033[0m"
    echo -e "  ✅ 文件替换成功完成!"
    echo -e "    新文件位置: $TARGET_FILE"
    if [ -n "$BACKUP_FILE" ]; then
        echo -e "    原始文件备份: $BACKUP_FILE"
    fi
    echo -e "\033[1;32m================================================\033[0m"
    exit 0
else
    echo ""
    echo -e "\033[1;31m================================================\033[0m"
    echo -e "  ❌ 文件替换失败!"
    echo -e "    请检查源文件路径、目标目录的写入权限以及磁盘空间。"
    echo -e "\033[1;31m================================================\033[0m"
    exit 1
fi
