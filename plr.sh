#!/bin/bash
# you need to run this command on this file: sudo chmod +x plr.sh
SD_PATH=~/gcode_files
HEIGHT=${1}
ADJHEIGHT=${2}
shift 2
I=${@}
cat "$I" > /tmp/plrtmpA.$$
cat /tmp/plrtmpA.$$ | sed -e '1,/Z'${ADJHEIGHT}'/ d' | sed -ne '/ Z/,$ p' | grep -m 1 ' Z' | sed -ne 's/.* Z\([^ ]*\)/SET_KINEMATIC_POSITION Z=\1/p' > ${SD_PATH}/plr.gcode
echo 'G91' >> ${SD_PATH}/plr.gcode
echo 'G1 Z5' >> ${SD_PATH}/plr.gcode
echo 'G90' >> ${SD_PATH}/plr.gcode
echo 'G28 X Y' >> ${SD_PATH}/plr.gcode
echo '_START_TEMPS' >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed '/ Z'${HEIGHT}'/q' | sed -ne '/\(M104\|M140\|M109\|M190\|M106\)/p' >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M140 S/p' | head -1 >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M104 S/p' | head -1 >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_bed_temperature | sed -ne 's/.* = /M190 S/p' | head -1 >> ${SD_PATH}/plr.gcode
cat /tmp/plrtmpA.$$ | sed -ne '/;End of Gcode/,$ p' | tr '\n' ' ' | sed -ne 's/ ;[^ ]* //gp' | sed -ne 's/\\\\n/;/gp' | tr ';' '\n' | grep material_print_temperature | sed -ne 's/.* = /M109 S/p' | head -1 >> ${SD_PATH}/plr.gcode
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${HEIGHT}'[^0-9]*$/q' | tac | tail -n+2 | sed -e '/ Z[0-9]/ q' | tac | sed -e '/ E[0-9]/ q' | sed -ne 's/.* E\([^ ]*\)/G92 E\1/p' >> ${SD_PATH}/plr.gcode
echo 'G91' >> ${SD_PATH}/plr.gcode
echo 'G1 Z-5' >> ${SD_PATH}/plr.gcode
echo 'G90' >> ${SD_PATH}/plr.gcode
tac /tmp/plrtmpA.$$ | sed -e '/ Z'${HEIGHT}'[^0-9]*$/q' | tac | tail -n+2 | sed -ne '/ Z/,$ p' >> ${SD_PATH}/plr.gcode
