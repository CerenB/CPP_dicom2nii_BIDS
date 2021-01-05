# to run the script, open the terminal and run:
# sh./ dicom2nii_BIDS_Step2.sh


# The following script using dcm2bids and dcm2niix to convert DICOMS
# to a BIDS compaitable format.
# To install dcm2bids: https://pypi.org/project/dcm2bids/

# BIDS outout folder
BIDSOutputFolder=/Users/battal/Cerens_files/fMRI/Processed/RhythmCateg/Pilots/RhythmFT/source/sub-011/ses-002/nii

# if BIDSOutputFolder does not exist
if [ ! -d $BIDSOutputFolder ]; then
  mkdir -p $BIDSOutputFolder;    # Create directory
fi

numDummies=0        # Number of dummies to remove
deleteOriginal=1    # Delete original after removing dummies

# Subject Names (folder names)
Subjs=("sub-011")
SubjsNumbers=("11")
group=''     # Group
Tasks=("RhythmFT" "RhythmFT_dir-reversedPhase" "PitchFT" "PitchFT_dir-reversedPhase"  "RhythmBlock" "RhythmBlock_dir-reversedPhase")
#

dicomsRootFolder=/Users/battal/Cerens_files/fMRI/Processed/RhythmCateg/Pilots/RhythmFT/source/sub-011/ses-002/ima  # DICOMS root folder

WD=$(pwd)

# Go to the BIDS output directory
cd $BIDSOutputFolder

# MAKE SURE THAT YOU HAVE THE config.json file ready at this step and filled correctly for the different
# experiment names.

# Get the number of the subjects in the group
NrSubjs=${#Subjs[@]}
echo 'Number of Subjects: '$NrSubjs

## loop through the different subjects
for iSub in "${!Subjs[@]}" #{1..$NrSubjs}
do
  iSubName="${Subjs[$iSub]}"
  iSubNum="${SubjsNumbers[$iSub]}"
  iSubNum="$(printf "%03d" $iSubNum)"  # Get the subject Number
  echo 'Subject Name:' $iSubName " - ID:"$iSubNum



  # Does all the work - dicom to .nii
      subDicomFolder=$dicomsRootFolder         ## <---------- CHANGE THE LOCATION
      #subOutputFolder=$BIDSOutputFolder
      #echo $SubName $iSubNum $subOutputFolder
      echo "DICOMS folder is: "$subDicomFolder
      echo "Output folder is: "$BIDSOutputFolder
      # dcm2bids -d $subDicomFolder -p $group$iSubNum -s 001 -c config.json -o $BIDSOutputFolder

  ################################################################################
  # dcm2bids inputs:
  # dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
  # -d : DICOM PATH
  # -p Partipiant name/number and the (group)
  # -s Session number
  # -o output directory for the nifti files
  # -c Configuration json file that should be present in the output directory
  ################################################################################

  #### RHYTHM CATEG  PROJECT #####

  ################################################################################
  for iTask in "${!Tasks[@]}"
  do

    # taskName=${#Tasks[@]}
    taskName="${Tasks[$iTask]}"
    echo 'Task Name : '$taskName

    ## Functional data - 1
    # remove Dummies
    for iRun in {1..5}
    do
      num=$((iRun + 4)) # 
      increaserunNumber="$(printf "%02d" $num)"

      runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
      echo 'runNumber: '$runNumber

      #change file names with correct zero-padding for runNumber
      fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
      fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$increaserunNumber'_bold.nii.gz'

      mv "$fileOLD" "$fileRENAME"

      fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
      fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$increaserunNumber'_bold.json'

      mv "$fileJSON" "$fileRENAMEJSON"

      #remove dummies
      echo $fileRENAME
      cd $WD
      python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
      cd $BIDSOutputFolder

      ### matlab script for correctly renaming the .nii and .json runs
      # matlab -nodesktop -nosplash
      ###

    done
done
  ################################################################################
  ##### MOEBIUS PROJECT #####
  ################################################################################


#   ## 2.1. Geometric Distortion data - 1
#   #rename the run-0x to run-00x
#   # remove Dummies
#   taskName='FEexe_dir-reversedPhase'                     ## <---------- CHANGE THE TASK NAME
#   for iRun in {4..4}
#   do
#     runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#     echo 'runNumber: '$runNumber
#
#     #change file names with correct zero-padding for runNumber
#     #fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#     fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.nii.gz'
#     fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#     mv "$fileOLD" "$fileRENAME"
#     #fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#     fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.json'
#     fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#     mv "$fileJSON" "$fileRENAMEJSON"
#
#     echo $fileRENAME
#     cd $WD
#     python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#     cd $BIDSOutputFolder
#   done
#
#
#   ################################################################################
#
#
#   ## 3.1. Functional data - 1
#   # remove Dummies
#   taskName='FEexe'                     ## <---------- CHANGE THE TASK NAME
#   for iRun in {1..4}
#   do
#     runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#     echo 'runNumber: '$runNumber
#
#     #change file names with correct zero-padding for runNumber
#     fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#     fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#     mv "$fileOLD" "$fileRENAME"
#
#     fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#     fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#     mv "$fileJSON" "$fileRENAMEJSON"
#
#     #remove dummies
#     echo $fileRENAME
#     cd $WD
#     python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#     cd $BIDSOutputFolder
#   done
#
#   ################################################################################
#
#   ## 4.1. Geometric Distortion data - 2
#   #rename the run-0x to run-00x
#   # remove Dummies
#   taskName='FEobserv_dir-reversedPhase'                     ## <---------- CHANGE THE TASK NAME
#   for iRun in {4..4}
#   do
#     runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#     echo 'runNumber: '$runNumber
#
#     #change file names with correct zero-padding for runNumber
#     #fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#     fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.nii.gz'
#     fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#     mv "$fileOLD" "$fileRENAME"
#     #fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#     fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.json'
#     fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#     mv "$fileJSON" "$fileRENAMEJSON"
#
#     echo $fileRENAME
#     cd $WD
#     python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#     cd $BIDSOutputFolder
#   done
#
#
# ################################################################################
#   #
#   ## 5.1. Functional data - 2
#   # remove Dummies
#   taskName='FEobserv'                     ## <---------- CHANGE THE TASK NAME
#   for iRun in {1..4}
#   do
#        runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#        echo 'runNumber: '$runNumber
#
#        #change file names with correct zero-padding for runNumber
#        fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#        fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#        mv "$fileOLD" "$fileRENAME"
#
#        fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#        fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#        mv "$fileJSON" "$fileRENAMEJSON"
#
#        #remove dummies
#        echo $fileRENAME
#        cd $WD
#        python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#        cd $BIDSOutputFolder
#    done
#
# ################################################################################
#
#   ## 5.1. Functional data - 3
#   # remove Dummies
#   taskName='LipReading'                     ## <---------- CHANGE THE TASK NAME
#   for iRun in {1..4}
#   do
#        runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#        echo 'runNumber: '$runNumber
#
#        #change file names with correct zero-padding for runNumber
#        fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#        fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#        mv "$fileOLD" "$fileRENAME"
#
#        fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#        fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#        mv "$fileJSON" "$fileRENAMEJSON"
#
#        #remove dummies
#        echo $fileRENAME
#        cd $WD
#        python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#        cd $BIDSOutputFolder
#    done
#
#
#    ## 4.1. Geometric Distortion data - 3
#    #rename the run-0x to run-00x
#    # remove Dummies
#    taskName='LipReading_dir-reversedPhase'                     ## <---------- CHANGE THE TASK NAME
#    for iRun in {4..4}
#    do
#      runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#      echo 'runNumber: '$runNumber
#
#      #change file names with correct zero-padding for runNumber
#      #fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#      fileOLD=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.nii.gz'
#      fileRENAME=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
#
#      mv "$fileOLD" "$fileRENAME"
#      #fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.json'
#      fileJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.json'
#      fileRENAMEJSON=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.json'
#
#      mv "$fileJSON" "$fileRENAMEJSON"
#
#      echo $fileRENAME
#      cd $WD
#      python remove_dummies.py $fileRENAME $numDummies $deleteOriginal
#      cd $BIDSOutputFolder
#    done

  ################################################################################
  # ## if you have 1 run use below:
  #    #file=$BIDSOutputFolder'/sub-'$group$iSubNum'_ses-001_task-'$taskName'_bold.nii.gz'
  #   file=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001''/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-001_bold.nii.gz'
  #    echo $file
  #    cd $WD
  #    python remove_dummies.py $file $numDummies $deleteOriginal
  #    cd $BIDSOutputFolder



  ## you might have an error:
  # ModuleNotFoundError: No module named 'nibabel'
  # then you need to install the module by
  # pip install nibabel

  ## 3. ADD OTHER EXPERIMENTS IF NEEDED BY COPYING ONE OF THE ABOVE


done
