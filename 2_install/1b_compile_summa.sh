# Compile SUMMA on USASK's Copernicus
# export variables are used in the makefile. 

#---------------------------------
# Specify settings
#---------------------------------

# --- Location of source code
# Find the path to the source code in 'control_active.txt'
dest_line=$(grep -m 1 "^install_path_summa" ../0_control_files/control_active.txt) # full settings line
summa_path=$(echo ${dest_line##*|})   # removing the leading text up to '|'
summa_path=$(echo ${summa_path%%#*}) # removing the trailing comments, if any are present

# Specify the default path if needed
if [ "$summa_path" = "default" ]; then
  
 # Get the root path and append the appropriate install directories
 root_line=$(grep -m 1 "^root_path" ../0_control_files/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%%#*}) 
 summa_path="${root_path}/installs/summa"
fi

# Specify home directory of 'summa/build'
export F_MASTER=$summa_path


# --- Specify a name for the executable 
# Find the desired executable name in 'control_active.txt'
exe_line=$(grep -m 1 "^exe_name_summa" ../0_control_files/control_active.txt) 
summa_exe=$(echo ${exe_line##*|}) 
summa_exe=$(echo ${summa_exe%%#*}) 
export EXE_NAME=$summa_exe


# --- Compiler settings 
# Compiler (ifort // gfortran)
export FC=gfortran 

# Compiler .exe
export FC_EXE='gfortran'


# --- Library settings
# Load the required libraries
module load nixpkgs/16.09
module load gcc/7.3.0
module load openblas
module load netcdf-fortran/4.4.4

# Specify the necessary paths for the compiler
export INCLUDES="-I$EBROOTNETCDFMINFORTRAN/include"
export LIBRARIES="-L$EBROOTNETCDFMINFORTRAN/lib64 -L$EBROOTOPENBLAS/lib -lnetcdff -lopenblas"

#---------------------------------
# Print the settings
#---------------------------------
echo 'build directory: ' $F_MASTER
echo 'executable name: ' $EXE_NAME
echo 'compiler name:   ' $FC
echo 'compiler .exe:   ' $FC_EXE
echo 'libraries:       ' $LIBRARIES
echo 'includes:        ' $INCLUDES 
echo # empty line

#---------------------------------
# Compile
#---------------------------------
# Compile
make -f ${F_MASTER}/build/Makefile

# Rename the executable if needed
if [ "$EXE_NAME" != "summa.exe" ]; then
 mv ${F_MASTER}/bin/summa.exe ${F_MASTER}/bin/${EXE_NAME}
fi 


#---------------------------------
# Code provenance
#---------------------------------
# Generates a basic log file in the domain folder and copies the control file and itself there.
# Make a log directory if it doesn't exist
log_path="${summa_path}/_workflow_log"
mkdir -p $log_path

# Log filename
today=`date '+%F'`
log_file="${today}_compile_log.txt"

# Make the log
this_file='1b_compile_summa.sh'
echo "Log generated by ${this_file} on `date '+%F %H:%M:%S'`"  > $log_path/$log_file # 1st line, store in new file
echo 'Compiled SUMMA into parent directory' >> $log_path/$log_file # 2nd line, append to existing file

# Copy this file to log directory
cp $this_file $log_path



