#!/usr/bin/env bash
# =============================================================================
# 安装本地 Gradle 发行包到 Gradle Wrapper 缓存（无需网络下载）。
#
# 工作原理：
#   Gradle Wrapper 使用 PathAssembler 将 distributionUrl 映射到缓存目录。
#   路径格式：~/.gradle/wrapper/dists/{distributionName}/{MD5(url) hash}/
#   本脚本将本地 zip 复制到对应目录并解压，模拟 Gradle Wrapper 的首次下载。
#
# 用法：
#   # 默认扫描 ~/dev/ 下的 gradle-*-zip
#   make setup-gradle
#
#   # 指定自定义目录
#   LOCAL_GRADLE_DIR=/path/to/zips make setup-gradle
# =============================================================================
set -euo pipefail

# 允许外部覆盖 LOCAL_GRADLE_DIR（存放 zip 文件的目录）
LOCAL_GRADLE_DIR="${LOCAL_GRADLE_DIR:-${HOME}/dev}"
# Gradle 用户主目录（允许外部覆盖）
GRADLE_USER_HOME="${GRADLE_USER_HOME:-${HOME}/.gradle}"
# 是否解压（1=解压，0=仅复制 zip）
UNPACK="${UNPACK:-1}"

# -----------------------------------------------------------------------------
# 计算 Gradle Wrapper 使用的 MD5 hash
# Gradle PathAssembler: MD5(url) as BigInteger -> base36
# -----------------------------------------------------------------------------
gradle_wrapper_hash() {
	python3 - "$1" <<'PY'
import hashlib, sys
url = sys.argv[1]
digest = hashlib.md5(url.encode()).digest()
n = int.from_bytes(digest, "big")
chars = "0123456789abcdefghijklmnopqrstuvwxyz"
if n == 0:
    print("0")
    sys.exit(0)
out = ""
while n:
    n, r = divmod(n, 36)
    out = chars[r] + out
print(out)
PY
}

# -----------------------------------------------------------------------------
# 安装单个 zip 到 Gradle Wrapper 缓存
# -----------------------------------------------------------------------------
install_zip() {
	local zip_file="$1"
	local base name version dist_type dist_name url hash dest extracted ok_marker

	base="$(basename "${zip_file}")"
	# 匹配 gradle-{version}-{bin|all}.zip
	if [[ ! "${base}" =~ ^gradle-(.+)-(bin|all)\.zip$ ]]; then
		echo "跳过（文件名不匹配 gradle-*-{bin,all}.zip）: ${base}" >&2
		return 0
	fi
	version="${BASH_REMATCH[1]}"
	dist_type="${BASH_REMATCH[2]}"
	dist_name="gradle-${version}-${dist_type}"
	# 构建 distributionUrl（与 gradle-wrapper.properties 中的格式保持一致）
	url="file://${zip_file}"
	hash="$(gradle_wrapper_hash "${url}")"
	dest="${GRADLE_USER_HOME}/wrapper/dists/${dist_name}/${hash}"
	extracted="${dest}/gradle-${version}"
	ok_marker="${dest}/${dist_name}.zip.ok"

	# 已安装完成则跳过
	if [[ -f "${ok_marker}" && -d "${extracted}" ]]; then
		echo "已就绪: ${dist_name} (${hash})"
		return 0
	fi

	mkdir -p "${dest}"
	# 清理可能的残留锁文件
	rm -f "${dest}/${dist_name}.zip.part" "${dest}/${dist_name}.zip.lck"
	# 复制 zip 到目标目录
	cp "${zip_file}" "${dest}/${dist_name}.zip"

	if [[ "${UNPACK}" == "1" ]]; then
		echo "解压: ${base} -> ${dest}"
		unzip -q -o "${dest}/${dist_name}.zip" -d "${dest}"
		touch "${ok_marker}"
	else
		echo "已复制 zip（未解压）: ${base} -> ${dest}"
	fi
}

# -----------------------------------------------------------------------------
# 主流程
# -----------------------------------------------------------------------------
shopt -s nullglob
zips=("${LOCAL_GRADLE_DIR}"/gradle-*-bin.zip "${LOCAL_GRADLE_DIR}"/gradle-*-all.zip)

if [[ ${#zips[@]} -eq 0 ]]; then
	echo "未在 ${LOCAL_GRADLE_DIR} 找到 gradle-*-{bin,all}.zip" >&2
	echo "可将发行包放到该目录，或设置 LOCAL_GRADLE_DIR" >&2
	exit 1
fi

echo "扫描 ${LOCAL_GRADLE_DIR}，共 ${#zips[@]} 个 Gradle 发行包..."
for zip_file in "${zips[@]}"; do
	install_zip "${zip_file}"
done
echo "完成。"