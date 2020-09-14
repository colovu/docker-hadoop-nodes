# Ver: 1.2 by Endial Fang (endial@126.com)
#

# 预处理 =========================================================================
FROM colovu/dbuilder as builder

# sources.list 可使用版本：default / tencent / ustc / aliyun / huawei
ARG apt_source=default

# 编译镜像时指定用于加速的本地服务器地址
ARG local_url=""

ENV APP_NAME=hadoop \
	APP_VERSION=3.2.1

WORKDIR /usr/local

RUN select_source ${apt_source};
#RUN install_pkg xz-utils

# 下载并解压软件包
RUN set -eux; \
	appName="${APP_NAME}-${APP_VERSION}.tar.gz"; \
	appKeys="0x07617D4968B34D8F13D56E20BE5AAA0BA210C095 \
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
	    0x8B44A05C308955D191956559A5CEE20A90348D47 \
		"; \
	[ ! -z ${local_url} ] && localURL=${local_url}/hadoop; \
	appUrls="${localURL:-} \
		'https://www.apache.org/dyn/closer.cgi?action=download&filename='${APP_NAME}/common/${APP_NAME}-${APP_VERSION} \
		https://www-us.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION} \
		https://www.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION} \
		https://archive.apache.org/dist/${APP_NAME}/common/${APP_NAME}-${APP_VERSION} \
		https://dist.apache.org/repos/dist/release/${APP_NAME}/common/${APP_NAME}-${APP_VERSION} \
		"; \
	download_pkg unpack ${appName} "${appUrls}"; \
	rm -rf /usr/local/${APP_NAME}-${APP_VERSION}/share/doc/*;

# 镜像生成 ========================================================================
FROM colovu/openjre:1.8-deb

ARG apt_source=default
ARG local_url=""

ENV APP_NAME=hadoop \
	APP_USER=hadoop \
	APP_EXEC=run.sh \
	APP_VERSION=3.2.1

ENV	APP_HOME_DIR=/usr/local/${APP_NAME} \
	APP_DEF_DIR=/etc/${APP_NAME} \
	APP_CONF_DIR=/srv/conf/${APP_NAME} \
	APP_DATA_DIR=/srv/data/${APP_NAME} \
	APP_DATA_LOG_DIR=/srv/datalog/${APP_NAME} \
	APP_CACHE_DIR=/var/cache/${APP_NAME} \
	APP_RUN_DIR=/var/run/${APP_NAME} \
	APP_LOG_DIR=/var/log/${APP_NAME} \
	APP_CERT_DIR=/srv/cert/${APP_NAME}

ENV 	PATH="${APP_HOME_DIR}/bin:${PATH}"

LABEL \
	"Version"="v${APP_VERSION}" \
	"Description"="Docker image for ${APP_NAME}(v${APP_VERSION})." \
	"Dockerfile"="https://github.com/colovu/docker-${APP_NAME}" \
	"Vendor"="Endial Fang (endial@126.com)"

COPY customer /

# 以包管理方式安装软件包(Optional)
RUN select_source ${apt_source}
RUN install_pkg net-tools netcat

RUN create_user && prepare_env

# 从预处理过程中拷贝软件包(Optional)
COPY --from=builder /usr/local/bin/ /usr/local/bin
COPY --from=builder /usr/local/${APP_NAME}-${APP_VERSION}/ /usr/local/${APP_NAME}
COPY --from=builder /usr/local/${APP_NAME}-${APP_VERSION}/etc/hadoop/ /etc/${APP_NAME}

# 执行预处理脚本，并验证安装的软件包
RUN set -eux; \
	override_file="/usr/local/overrides/overrides-${APP_VERSION}.sh"; \
	[ -e "${override_file}" ] && /bin/bash "${override_file}"; \
	:;

# 默认提供的数据卷
VOLUME ["/srv/conf", "/srv/data", "/srv/datalog", "/srv/cert", "/var/log"]

# 容器初始化命令，默认存放在：/usr/local/bin/entry.sh
ENTRYPOINT ["entry.sh"]

# 应用程序的服务命令，必须使用非守护进程方式运行。如果使用变量，则该变量必须在运行环境中存在（ENV可以获取）
CMD []

