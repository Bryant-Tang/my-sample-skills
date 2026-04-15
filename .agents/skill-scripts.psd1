@{
    BUILD_PROJECT_PATH = 'XXXWeb/XXXWeb.csproj'
    BUILD_MSBUILD_PATH = 'C:/Program Files/Microsoft Visual Studio/2022/Community/MSBuild/Current/Bin/MSBuild.exe'
    BUILD_FRONTEND_DIR_PATH = 'XXXWeb/'
    BUILD_NODE_VERSION = 'v10.15.3'
    BUILD_FRONTEND_INSTALL_COMMAND = @('npm', 'install')
    BUILD_FRONTEND_BUILD_COMMAND = @('npm', 'run', 'build')
    RUN_IIS_EXPRESS_PATH = 'C:/Program Files/IIS Express/iisexpress.exe'
    RUN_IIS_APPLICATIONHOST_CONFIG_PATH = '.vs/XXX/config/applicationhost.config'
    TEST_LOCAL_STASH_SHA = 'fakeshaabcdefghijklmnopqrstuvwxyz0123456'
}