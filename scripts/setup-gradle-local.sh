#!/usr/bin/env bash
# =============================================================================
# 使用本地 Gradle 发行包预热 Gradle Wrapper 缓存（无需修改 Wrapper URL）。
#
# Wrapper 配置是唯一事实来源：脚本读取 distributionUrl 和
# distributionSha256Sum，只接受与 URL 文件名完全一致的本地 zip，并使用该
# 官方 URL 计算 Wrapper 缓存目录。这样不同操作系统和用户目录会命中同一缓存身份。
#
# 用法：
#   # 默认在 ~/dev 查找 Wrapper 精确要求的 zip
#   make setup-gradle
#
#   # 指定本地发行包目录
#   LOCAL_GRADLE_DIR=/path/to/zips make setup-gradle
#
# 找不到精确匹配时脚本退出成功，由 Gradle Wrapper 按配置的 HTTPS URL 下载。
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
WRAPPER_PROPERTIES="${WRAPPER_PROPERTIES:-${PROJECT_DIR}/gradle/wrapper/gradle-wrapper.properties}"
LOCAL_GRADLE_DIR="${LOCAL_GRADLE_DIR:-${HOME}/dev}"
GRADLE_USER_HOME="${GRADLE_USER_HOME:-${HOME}/.gradle}"
UNPACK="${UNPACK:-1}"

read_property() {
	local key="$1"
	local value
	value="$(sed -n "s/^${key}=//p" "${WRAPPER_PROPERTIES}" | tail -n 1)"
	# Gradle Wrapper properties commonly escape the URL scheme as https\://.
	printf '%s\n' "${value}" | sed 's/\\:/:/g; s/\\=/=/g'
}

gradle_wrapper_hash() {
	python3 - "$1" <<'PY'
import hashlib
import sys

digest = hashlib.md5(sys.argv[1].encode()).digest()
number = int.from_bytes(digest, "big")
chars = "0123456789abcdefghijklmnopqrstuvwxyz"
result = ""
while number:
    number, remainder = divmod(number, 36)
    result = chars[remainder] + result
print(result or "0")
PY
}

file_sha256() {
	python3 - "$1" <<'PY'
import hashlib
import sys

digest = hashlib.sha256()
with open(sys.argv[1], "rb") as archive:
    for chunk in iter(lambda: archive.read(1024 * 1024), b""):
        digest.update(chunk)
print(digest.hexdigest())
PY
}

if [[ ! -f "${WRAPPER_PROPERTIES}" ]]; then
	echo "Gradle Wrapper 配置不存在: ${WRAPPER_PROPERTIES}" >&2
	exit 1
fi

distribution_url="$(read_property distributionUrl)"
expected_sha256="$(read_property distributionSha256Sum | tr 'A-F' 'a-f')"

if [[ -z "${distribution_url}" ]]; then
	echo "Gradle Wrapper 配置缺少 distributionUrl: ${WRAPPER_PROPERTIES}" >&2
	exit 1
fi
if [[ ! "${distribution_url}" =~ ^https:// ]]; then
	echo "distributionUrl 必须是可移植的 HTTPS URL: ${distribution_url}" >&2
	exit 1
fi
if [[ ! "${expected_sha256}" =~ ^[0-9a-f]{64}$ ]]; then
	echo "Gradle Wrapper 配置缺少有效的 distributionSha256Sum" >&2
	exit 1
fi
if [[ "${UNPACK}" != "0" && "${UNPACK}" != "1" ]]; then
	echo "UNPACK 只能是 0 或 1，当前值: ${UNPACK}" >&2
	exit 1
fi

archive_name="${distribution_url##*/}"
case "${archive_name}" in
	gradle-*-bin.zip|gradle-*-all.zip) ;;
	*)
		echo "无法从 distributionUrl 识别 Gradle 发行包: ${distribution_url}" >&2
		exit 1
		;;
esac

dist_name="${archive_name%.zip}"
version_and_type="${dist_name#gradle-}"
version="${version_and_type%-bin}"
version="${version%-all}"
hash="$(gradle_wrapper_hash "${distribution_url}")"
dest="${GRADLE_USER_HOME}/wrapper/dists/${dist_name}/${hash}"
extracted="${dest}/gradle-${version}"
ok_marker="${dest}/${archive_name}.ok"
cached_archive="${dest}/${archive_name}"
local_archive="${LOCAL_GRADLE_DIR}/${archive_name}"

if [[ -f "${ok_marker}" && -d "${extracted}" ]]; then
	echo "已就绪: ${dist_name} (${hash})"
	exit 0
fi

if [[ ! -f "${local_archive}" ]]; then
	echo "未在 ${LOCAL_GRADLE_DIR} 找到 Wrapper 要求的 ${archive_name}" >&2
	shopt -s nullglob
	other_archives=("${LOCAL_GRADLE_DIR}"/gradle-*-bin.zip "${LOCAL_GRADLE_DIR}"/gradle-*-all.zip)
	if [[ ${#other_archives[@]} -gt 0 ]]; then
		echo "检测到其它 Gradle 发行包（不会用于替代 ${archive_name}）:" >&2
		for other_archive in "${other_archives[@]}"; do
			echo "  - $(basename "${other_archive}")" >&2
		done
	fi
	echo "跳过本地缓存预热：Gradle Wrapper 将按 ${distribution_url} 下载。" >&2
	exit 0
fi

actual_sha256="$(file_sha256 "${local_archive}")"
if [[ "${actual_sha256}" != "${expected_sha256}" ]]; then
	echo "Gradle 发行包 SHA-256 校验失败: ${local_archive}" >&2
	echo "期望: ${expected_sha256}" >&2
	echo "实际: ${actual_sha256}" >&2
	exit 1
fi

mkdir -p "${dest}"
rm -f "${cached_archive}.part" "${cached_archive}.lck"
cp "${local_archive}" "${cached_archive}"

if [[ "${UNPACK}" == "1" ]]; then
	echo "解压: ${archive_name} -> ${dest}"
	unzip -q -o "${cached_archive}" -d "${dest}"
	touch "${ok_marker}"
	echo "已就绪: ${dist_name} (${hash})"
else
	echo "已校验并复制（未解压）: ${archive_name} -> ${dest}"
fi
