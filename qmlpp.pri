QMLPP_PATH = $${PWD}
QMLPP_SCRIPT = "bash $${QMLPP_PATH}/qmlpp.sh"

# To process one or more individual folders, use qmlPreprocessFolder method as follows:
# qmlPreprocessFolder(test blah qml, @QtQuick2 @QtQuick1 @QtQuick3, 2.1)

# qmlPreprocessFolder(folders, defines, rewriteVersion)
defineTest(qmlPreprocessFolder) {
    !isEmpty(1) {
        qmlppCommand = $${QMLPP_SCRIPT} -i
        qmlppCommands =

        !isEmpty(3): qmlppCommand += -q $${3}
        !isEmpty(2) {
            defines = $$join(2, "|")
            qmlppCommand += -d \"$$defines\"
        }

        for(folder, 1) {
            !isEmpty(qmlppCommands): qmlppCommands += &&
            qmlppCommands += $${qmlppCommand} \"$$folder\"
        }

        #message($$qmlppCommands)

        system($$qmlppCommands)
    }
}

# Global variables that are used in simplified qmlPreprocessGlobal function below.
# Define these global variables in your .pro file:
#
# QMLPP_REWRITEVERSION = 2.1
# QMLPP_DEFINES = @QtQuick2 @QtQuick1 @QtQuick3
# QMLPP_FOLDERS = test blah qml
#
# and finally call:
# qmlPreprocessGlobal()

defineTest(qmlPreprocessGlobal) {
    qmlPreprocessFolder($$QMLPP_FOLDERS, $$QMLPP_DEFINES, $$QMLPP_REWRITEVERSION)
}
