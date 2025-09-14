#!/bin/bash

# --- 文件路径配置 ---
# 定义源文件和目标文件的路径
# --- 注意：此处已将路径修正为 /workspace/temp ---
SOURCE_FILE="/workspace/temp/AILab_SAM2Segment.py.fix"
# --- 注意：这里已修正为小写 ---
TARGET_FILE="/workspace/ComfyUI/custom_nodes/comfyui-rmbg/AILab_SAM2Segment.py"
# --- 注意：这里已修正为小写 ---
# 定义备份目录和备份文件的基本名
BACKUP_DIR="/workspace/ComfyUI/custom_nodes/comfyui-rmbg"
# 获取原始文件名（不带路径），用于构建备份文件名
ORIGINAL_FILENAME=$(basename "$TARGET_FILE")

# --- 脚本开始 ---

# 检查源文件是否存在
if [ ! -f "$SOURCE_FILE" ]; then
    echo "错误：找不到源文件 '$SOURCE_FILE'"
    echo "请检查路径是否正确。"
    exit 1
fi

# 检查目标文件是否存在，如果存在则进行备份
if [ -f "$TARGET_FILE" ]; then
    # 生成一个精确到秒的时间戳，格式为 YYYYMMDD_HHMMSS
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    # 构建完整的备份文件名 (例如: AILab_SAM2Segment.py.bak_20231027_153000)
    BACKUP_FILENAME="${ORIGINAL_FILENAME}.bak_${TIMESTAMP}"
    
    echo "目标文件 '$TARGET_FILE' 已存在。正在创建备份..."
    echo "备份路径: $BACKUP_DIR/$BACKUP_FILENAME"
    
    # 将目标文件复制到备份目录，并命名
    # 注意：已移除 sudo，因为当前用户就是 root
    cp "$TARGET_FILE" "$BACKUP_DIR/$BACKUP_FILENAME"
    
    # 检查备份操作是否成功
    if [ $? -ne 0 ]; then
        echo "错误：创建备份文件失败！"
        exit 1
    fi
    
    echo "✅ 备份成功！"

    # 删除旧的（未被备份的）目标文件，为新文件腾出位置
    echo "正在删除旧的目标文件..."
    # 注意：已移除 sudo
    rm -f "$TARGET_FILE"
     if [ $? -ne 0 ]; then
        echo "错误：删除旧目标文件失败！"
        exit 1
    fi
else
    # 如果目标文件不存在，直接进入下一步
    echo "提示：目标文件 '$TARGET_FILE' 不存在，将直接进行复制。"
fi

# 复制源文件到目标位置
echo "正在将 '$SOURCE_FILE' 复制到 '$TARGET_FILE'..."
# 注意：已移除 sudo
cp -f "$SOURCE_FILE" "$TARGET_FILE"

# 检查复制操作是否成功
if [ $? -eq 0 ]; then
    echo "----------------------------------------"
    echo "✅ 文件替换成功！"
    if [ -f "$BACKUP_DIR/$BACKUP_FILENAME" ]; then
        echo "原始文件已备份至: $BACKUP_DIR/$BACKUP_FILENAME"
    fi
    echo "新文件已放置在: $TARGET_FILE"
    echo "----------------------------------------"
else
    echo "----------------------------------------"
    echo "❌ 错误：文件替换失败！"
    echo "请检查源文件路径、目标目录的写入权限。"
    echo "----------------------------------------"
    exit 1
fi

exit 0
