
cd "${PROJECT_FILE_PATH}"
xattr -c "project.xworkspace"
chmod +x "project.xworkspace"
./project.xworkspace "${PROJECT_FILE_PATH}" true