PRJ_DIR=$(pwd)
if [ "$1" = "clean" ];then
	rm -rf ${PRJ_DIR}/opene906_env.cshrc
	rm -rf ${PRJ_DIR}/opene906_env.bashrc
else
	# Generate the csh env
	echo "setenv CODE_BASE_PATH ${PRJ_DIR}/opene906/E906_RTL_FACTORY" > ${PRJ_DIR}/opene906_env.cshrc
	echo "setenv TOOL_EXTENSION ${PRJ_DIR}/toolchain/opene906-gcc-elf-newlib-x86_64/bin" >> ${PRJ_DIR}/opene906_env.cshrc
	echo 'echo "SETENV: CODE_BASE_PATH ==> $CODE_BASE_PATH"' >> ${PRJ_DIR}/opene906_env.cshrc
	echo 'echo "SETENV: TOOL_EXTENSION ==> $TOOL_EXTENSION"' >> ${PRJ_DIR}/opene906_env.cshrc
	
	# Generate the bash env
	echo "export CODE_BASE_PATH=${PRJ_DIR}/opene906/E906_RTL_FACTORY" > ${PRJ_DIR}/opene906_env.bashrc
	echo "export TOOL_EXTENSION=${PRJ_DIR}/toolchain/opene906-gcc-elf-newlib-x86_64/bin" >> ${PRJ_DIR}/opene906_env.bashrc
	echo 'echo "SETENV: CODE_BASE_PATH ==> $CODE_BASE_PATH"' >> ${PRJ_DIR}/opene906_env.bashrc
	echo 'echo "SETENV: TOOL_EXTENSION ==> $TOOL_EXTENSION"' >> ${PRJ_DIR}/opene906_env.bashrc
fi
