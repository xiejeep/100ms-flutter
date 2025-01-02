#!/bin/bash

# 设置项目相关变量
PROJECT_NAME="Runner"
SCHEME_NAME="Runner"
WORKSPACE_PATH="Runner.xcworkspace"
OUTPUT_DIR="build"
CONFIGURATION="Release"

# 创建输出目录
mkdir -p "${OUTPUT_DIR}"

# 清理旧的构建文件
xcodebuild clean -workspace "${WORKSPACE_PATH}" -scheme "${SCHEME_NAME}" -configuration "${CONFIGURATION}"

# 构建项目
xcodebuild archive \
    -workspace "${WORKSPACE_PATH}" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${OUTPUT_DIR}/${PROJECT_NAME}.xcarchive" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# 创建 Payload 目录
mkdir -p "${OUTPUT_DIR}/Payload"

# 复制 .app 到 Payload 目录
cp -r "${OUTPUT_DIR}/${PROJECT_NAME}.xcarchive/Products/Applications/${PROJECT_NAME}.app" "${OUTPUT_DIR}/Payload"

# 创建 IPA
cd "${OUTPUT_DIR}"
zip -r "${PROJECT_NAME}_unsigned.ipa" Payload

# 清理临时文件
rm -rf Payload
rm -rf "${PROJECT_NAME}.xcarchive"

echo "未签名的 IPA 已生成在 ${OUTPUT_DIR}/${PROJECT_NAME}_unsigned.ipa"