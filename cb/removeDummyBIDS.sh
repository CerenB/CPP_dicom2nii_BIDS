# to run the script, open the terminal and run:
# sh./ removeDummyBIDS.sh


# The following script using dcm2bids and dcm2niix lib to remove dummies

# BIDS outout folder
BIDSOutputFolder=/Users/battal/Cerens_files/fMRI/Processed/RhythmCateg/Pilots/SequenceTest/source/sub-009/ses-001/func
#working directory
WD=/Users/battal/Documents/GitHub/CPPLab/CPP_dicom2nii_BIDS

# if BIDSOutputFolder does not exist
if [ ! -d $BIDSOutputFolder ]; then
  mkdir -p $BIDSOutputFolder;
fi

numDummies=7        # Number of dummies to remove
deleteOriginal=0    # Delete original after removing dummies

# Subject Names (folder names)
Subjs=("ToLe")
SubjsNumbers=("9")
group=''     # Group
iRun=1


# Go to the BIDS output directory
cd $BIDSOutputFolder

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

    ## define task name
    taskName='RhythmCategBlock'
    echo "Output folder is: "$BIDSOutputFolder

    # remove Dummies
    runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
    echo 'runNumber: '$runNumber
    file=$BIDSOutputFolder'/sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-0'$runNumber'_bold.nii.gz'
    echo $file
    cd $WD
    python remove_dummies.py $file $numDummies $deleteOriginal
    cd $BIDSOutputFolder

# for more than 1 run use below loop
#    # remove Dummies
#    for iRun in {1..12}
#    do
#        runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
#        echo 'runNumber: '$runNumber
#        file=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-001''/func/''sub-'$group$iSubNum'_ses-001_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
#        echo $file
#        cd $WD
#        python remove_dummies.py $file $numDummies $deleteOriginal
#        cd $BIDSOutputFolder
#    done



done
