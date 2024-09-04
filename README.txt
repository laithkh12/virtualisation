to run the script ->
./create_container.sh -r /tmp/rootfs -p
then =>
source /container_script.sh
then =>
chmod +x /tmp/rootfs/container_script.sh
then =>
cntnr_cp testfile.txt testcopy.txt