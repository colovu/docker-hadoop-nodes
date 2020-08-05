# Ver: 1.0 by Endial Fang (endial@126.com)
#
# 指定原始系统镜像，常用镜像为 colovu/ubuntu:18.04、colovu/debian:10、colovu/alpine:3.12、colovu/openjdk:8u252-jre
FROM colovu/openjdk:11-jre

# ARG参数使用"--build-arg"指定，如 "--build-arg apt_source=tencent"
# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=default

# 外部指定应用版本信息，如 "--build-arg app_ver=6.0.0"
ARG app_ver=3.3.0

# 编译镜像时指定本地服务器地址，如 "--build-arg local_url=http://172.29.14.108/dist-files/"
ARG local_url=""

# 定义应用基础常量信息，该常量在容器内可使用
ENV APP_NAME=hadoop \
	APP_EXEC=run.sh 

# 定义应用基础目录信息，该常量在容器内可使用
ENV	APP_HOME_DIR=/usr/local/${APP_NAME} \
	APP_DEF_DIR=/etc/${APP_NAME} \
	APP_CONF_DIR=/srv/conf/${APP_NAME} \
	APP_DATA_DIR=/srv/data/${APP_NAME} \
	APP_DATA_LOG_DIR=/srv/datalog/${APP_NAME} \
	APP_CACHE_DIR=/var/cache/${APP_NAME} \
	APP_RUN_DIR=/var/run/${APP_NAME} \
	APP_LOG_DIR=/var/log/${APP_NAME} \
	APP_CERT_DIR=/srv/cert/${APP_NAME}

# 设置应用需要的特定环境变量
ENV \
	PATH="${APP_HOME_DIR}/bin:${PATH}"

LABEL \
	"Version"="v${app_ver}" \
	"Description"="Docker image for ${APP_NAME}(v${app_ver})." \
	"Dockerfile"="https://github.com/colovu/docker-${APP_NAME}" \
	"Vendor"="Endial Fang (endial@126.com)"

# 拷贝默认 Shell 脚本至容器相关目录中
COPY prebuilds /

# 镜像内相应应用及依赖软件包的安装脚本；以下脚本可按照不同需求拆分为多个段，但需要注意各个段在结束前需要清空缓存
RUN \
# 设置程序使用静默安装，而非交互模式；默认情况下，类似 tzdata/gnupg/ca-certificates 等程序配置需要交互
	export DEBIAN_FRONTEND=noninteractive; \
	\
# 设置 shell 执行参数，分别为 -e(命令执行错误则退出脚本) -u(变量未定义则报错) -x(打印实际待执行的命令行)
	set -eux; \
	\
# 更改源为当次编译指定的源
	cp /etc/apt/sources.list.${apt_source} /etc/apt/sources.list; \
	\
# 为应用创建对应的组、用户、相关目录
	export APP_VERSION=${app_ver}; \
	export APP_DIRS="${APP_DEF_DIR:-} ${APP_CONF_DIR:-} ${APP_DATA_DIR:-} ${APP_CACHE_DIR:-} ${APP_RUN_DIR:-} ${APP_LOG_DIR:-} ${APP_CERT_DIR:-} ${APP_DATA_LOG_DIR:-} ${APP_HOME_DIR:-${APP_DATA_DIR}}"; \
	mkdir -p ${APP_DIRS}; \
	groupadd -r -g 998 ${APP_NAME}; \
	useradd -r -g ${APP_NAME} -u 999 -s /usr/sbin/nologin -d ${APP_DATA_DIR} ${APP_NAME}; \
	\
# 应用软件包及依赖项。相关软件包在镜像创建完成时，不会被清理
	appDeps=" \
		net-tools \
		netcat \
		curl \
	"; \
	savedAptMark="$(apt-mark showmanual) ${appDeps}"; \
	\
	\
	\
# 安装临时使用的软件包及依赖项。相关软件包在镜像创建完后时，会被清理
	fetchDeps=" \
		wget \
		ca-certificates \
		\
		dirmngr \
		gnupg \
		\
		xz-utils \
	"; \
	apt-get update; \
	apt-get install -y --no-install-recommends ${fetchDeps}; \
	\
	\
	\
#	wget -O KEYS https://dist.apache.org/repos/dist/release/hadoop/common/KEYS; \
#	gpg --import KEYS; \
	\
# 下载需要的软件包资源。可使用 不校验、签名校验、SHA256 校验 三种方式
	DIST_NAME="${APP_NAME}-${APP_VERSION}.tar.gz"; \
	DIST_KEYIDS="0x07617D4968B34D8F13D56E20BE5AAA0BA210C095 \
	    0x2CAC83124870D88586166115220F69801F27E622 \
	    0x4B96409A098DBD511DF2BC18DBAF69BEA7239D59 \
	    0x9DD955653083EFED6171256408458C39E964B5FF \
	    0xB6B3F7EDA5BA7D1E827DE5180DFF492D8EE2F25C \
	    0x6A67379BEFC1AE4D5595770A34005598B8F47547 \
	    0x47660BC98BC433F01E5C90581209E7F13D0C92B9 \
	    0xCE83449FDC6DACF9D24174DCD1F99F6EE3CD2163 \
	    0xA11DF05DEA40DA19CE4B43C01214CF3F852ADB85 \
	    0x686E5EDF04A4830554160910DF0F5BBC30CD0996 \
	    0x5BAE7CB144D05AD1BB1C47C75C6CC6EFABE49180 \
	    0xAF7610D2E378B33AB026D7574FB955854318F669 \
	    0x6AE70A2A38F466A5D683F939255ADF56C36C5F0F \
	    0x70F7AB3B62257ABFBD0618D79FDB12767CC7352A \
	    0x842AAB2D0BC5415B4E19D429A342433A56D8D31A \
	    0x1B5D384B734F368052862EB55E43CAB9AEC77EAF \
	    0x785436A782586B71829C67A04169AA27ECB31663 \
	    0x5E49DA09E2EC9950733A4FF48F1895E97869A2FB \
	    0xA13B3869454536F1852C17D0477E02D33DD51430 \
	    0xA6220FFCC86FE81CE5AAC880E3814B59E4E11856 \
	    0xEFE2E7C571309FE00BEBA78D5E314EEF7340E1CB \
	    0xEB34498A9261F343F09F60E0A9510905F0B000F0 \
	    0x3442A6594268AC7B88F5C1D25104A731B021B57F \
	    0x6E83C32562C909D289E6C3D98B25B9B71EFF7770 \
	    0xE9216532BF11728C86A11E3132CF4BF4E72E74D3 \
	    0xE8966520DA24E9642E119A5F13971DA39475BD5D \
	    0x1D369094D4CFAC140E0EF05E992230B1EB8C6EFA \
	    0xA312CE6A1FA98892CB2C44EBA79AB712DE5868E6 \
	    0x0445B7BFC4515847C157ECD16BA72FF1C99785DE \
	    0xB74F188889D159F3D7E64A7F348C6D7A0DCED714 \
	    0x4A6AC5C675B6155682729C9E08D51A0A7501105C \
	    0x8B44A05C308955D191956559A5CEE20A90348D47"; \
	DIST_URLS=" \
		${local_url} \
		'https://www.apache.org/dyn/closer.cgi?action=download&filename='${APP_NAME}/common/${APP_NAME}-${APP_VERSION}/ \
		https://www-us.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION}/ \
		https://www.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION}/ \
		https://archive.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION}/ \
		https://dist.apache.org/repos/dist/release/${APP_NAME}/common/${APP_NAME}-${APP_VERSION}/ \
		"; \
	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}"; \
#	. /usr/local/scripts/libdownload.sh && download_dist "${DIST_NAME}" "${DIST_URLS}" --pgpkey "${DIST_KEYIDS}"; \
	\
	\
	\
#	gpg --verify ${DIST_NAME}.asc; \
	\
# 二进制解压安装，并将原始配置文件拷贝至 ${APP_DEF_DIR} 中
	tar --extract --file "${DIST_NAME}" --directory "${APP_HOME_DIR}" --strip-components 1; \
	cp -rf ${APP_HOME_DIR}/etc/hadoop/* "${APP_DEF_DIR}/"; \
	rm -rf "${DIST_NAME}" "${APP_HOME_DIR}/share/doc/hadoop"; \
	\
	\
	\
# 增加软件包特有源，并使用系统包管理方式安装软件
	apt-get install -y --no-install-recommends ${appDeps}; \
	\
	\
	\
# 设置应用关联目录的权限信息
	chown -Rf ${APP_NAME}:${APP_NAME} ${APP_DIRS}; \
	\
# 查找新安装的应用及应用依赖软件包，并标识为'manual'，防止后续自动清理时被删除
	apt-mark auto '.*' > /dev/null; \
	{ [ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; }; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual; \
	\
# 删除安装的临时依赖软件包，清理缓存
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false ${fetchDeps}; \
	apt-get autoclean -y; \
	rm -rf /var/lib/apt/lists/*; \
	:;

# 拷贝应用专用 Shell 脚本至容器相关目录中
COPY customer /

RUN set -eux; \
# 设置容器入口脚本的可执行权限
	chmod +x /usr/local/bin/entrypoint.sh; \
	\
# 检测是否存在对应版本的 overrides 脚本文件；如果存在，执行
	{ [ ! -e "/usr/local/overrides/overrides-${app_ver}.sh" ] || /bin/bash "/usr/local/overrides/overrides-${app_ver}.sh"; }; \
	\
# 验证安装的软件是否可以正常运行，常规情况下放置在命令行的最后
	gosu ${APP_NAME} true ; \
	:;

# 默认提供的数据卷
VOLUME ["/srv/conf", "/srv/data", "/srv/cert", "/srv/datalog", "/var/log"]

# 容器初始化命令，默认存放在：/usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

WORKDIR ${APP_DATA_DIR}

# 应用程序的服务命令，必须使用非守护进程方式运行。如果使用变量，则该变量必须在运行环境中存在（ENV可以获取）
CMD []
