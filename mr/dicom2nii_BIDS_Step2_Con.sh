# to run the script, open the terminal and run:
# sh./ dicom2nii_BIDS_Step2.sh


# The following script using dcm2bids and dcm2niix to convert DICOMS
# to a BIDS compaitable format.
# To install dcm2bids: https://pypi.org/project/dcm2bids/

# BIDS outout folder
BIDSOutputFolder=/Volumes/SanDisk/Oli_Data/CatMot_BIDS

# if BIDSOutputFolder does not exist
if [ ! -d $BIDSOutputFolder ]; then
  mkdir -p $BIDSOutputFolder;    # Create directory
fi

numDummies=4        # Number of dummies to remove
deleteOriginal=1    # Delete original after removing dummies
########################################
##############   GROUP 1   #############
########################################
# Subject Names (folder names)
Subjs=("AlSo" "CoLi" 	"FlFe"	"JoAb"	"MaTv"	"MoKa"	"OlCo"	"StMa"	"XiGa" "BrCh"	"EsEn"	"HeTr"	"LuNg"	"MoJa"	"MoRe"	"ShZh"	"ThBa")
SubjsNumbers=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15" "16" "17")
group='con'     # Group
groupFolderName='Control'
dicomsRootFolder=/Volumes/SanDisk/Oli_Data/CatMot_BIDS/sourcedata/    # DICOMS root folder

WD=$(pwd)
########################################
##############   GROUP 2   #############
########################################
# Subjs=("AdCa"	"CaBa"	"JeBr"	"JeSu"	"MiDo"	"NaAs"	"ViOn"	"ZaCr" "AlBo"	"CaPi"	"JeOn"	"JoSn"	"MiMo"	"SaAt"	"WiSn")
# SubjsNumbers=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "13" "14" "15")
# group='cat'
# groupFolderName='Cataract'
# dicomsRootFolder=/Volumes/SanDisk/Oli_Data/CatMot_BIDS/sourcedata/    # DICOMS root folder

########################################

# Go to the BIDS output directory
cd $BIDSOutputFolder

# dcm2bids_scaffold creates the neccessary folders and files for the BIDS structure
#dcm2bids_scaffold

# Run the dcm2bids_helper -d $dicomsRootFolder on a couple of subjects to get the information regarding
# the name of the conditions and files.
# This information will used in the config.json file
#dcm2bids_helper -d $dicomsRootFolder

#echo "##############################################################"
#echo "Create the config.json in the BIDS output directory."
#echo "and add the required information before running step 2 "
#echo "The information is available in tmp_dcm2bids json files"
#echo "##############################################################"

# MAKE SURE THAT YOU HAVE THE config.json file ready at this step and filled correctly for the different
# experiment names.

# Get the number of the subjects in the group
NrSubjs=${#Subjs[@]}
echo 'Number of Subjects: '$NrSubjs

## loop through the different subjects
# for loop that iterates over each element in arr
# for iSub in "${!Subjs[@]}" #{1..$NrSubjs}
# do
#    iSubNum="$(printf "%02d" $(($iSub+1)))"  # Get the subject Number
#    SubName="${Subjs[iSub]}"                 # Get the subject Name
for iSub in "${!Subjs[@]}" #{1..$NrSubjs}
do
    iSubName="${Subjs[$iSub]}"
    iSubNum="${SubjsNumbers[$iSub]}"
    iSubNum="$(printf "%02d" $iSubNum)"  # Get the subject Number
    echo 'Subject Name:' $iSubName " - ID:"$iSubNum
# For every condition you have, add the following block of code to get the DICOM location

## 1. ANATOMICAL
    # the directory to the dicom files (needs to be changed according to your dicom location and name)
    subDicomFolder=$dicomsRootFolder'Anatomical/'$groupFolderName'/'$iSubName           ## <---------- CHANGE THE LOCATION
    #subOutputFolder=$BIDSOutputFolder
    #echo $SubName $iSubNum $subOutputFolder
    echo "DICOMS folder is: "$subDicomFolder
    echo "Output folder is: "$BIDSOutputFolder
    dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder

################################################################################
# dcm2bids inputs:
# dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
# -d : DICOM PATH
# -p Partipiant name/number and the (group)
# -s Session number
# -o output directory for the nifti files
# -c Configuration json file that should be present in the output directory
################################################################################

    ## 2. Functional data - Name of the experiment: VIS MOTION
    subDicomFolder=$dicomsRootFolder'LocalizerVisual/'$groupFolderName'/'$iSubName ## <---------- CHANGE THE LOCATION
    taskName='visMotion'                                                ## <---------- CHANGE THE TASK NAME
    echo "DICOMS folder is: "$subDicomFolder
    echo "Output folder is: "$BIDSOutputFolder
    dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
    # remove Dummies
    file=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-01''/func/''sub-'$group$iSubNum'_ses-01_task-'$taskName'_bold.nii.gz'
    echo $file
    cd $WD
    python removeDummies.py $file $numDummies $deleteOriginal
    cd $BIDSOutputFolder

    ## 3. Functional data - Name of the experiment: AUD MOTION
    subDicomFolder=$dicomsRootFolder'LocalizerAuditory/'$groupFolderName'/'$iSubName ## <---------- CHANGE THE LOCATION
    taskName='audMotion'                                                ## <---------- CHANGE THE TASK NAME
    echo "DICOMS folder is: "$subDicomFolder
    echo "Output folder is: "$BIDSOutputFolder
    dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
    # remove Dummies
    file=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-01''/func/''sub-'$group$iSubNum'_ses-01_task-'$taskName'_bold.nii.gz'
    echo $file
    cd $WD
    python removeDummies.py $file $numDummies $deleteOriginal
    cd $BIDSOutputFolder

    ## 4. Functional data - Name of the experiment: MOTION DECODING
    subDicomFolder=$dicomsRootFolder'CrossMot/'$groupFolderName'/'$iSubName ## <---------- CHANGE THE LOCATION
    taskName='motionDecoding'                                    ## <---------- CHANGE THE TASK NAME
    echo "DICOMS folder is: "$subDicomFolder
    echo "Output folder is: "$BIDSOutputFolder
    dcm2bids -d $subDicomFolder -p $group$iSubNum -s 01 -c config.json -o $BIDSOutputFolder
    # remove Dummies
    for iRun in {1..10}
    do
        runNumber="$(printf "%02d" $iRun)"  # Get the subject Number
        echo 'runNumber: '$runNumber
        file=$BIDSOutputFolder'/sub-'$group$iSubNum'/ses-01''/func/''sub-'$group$iSubNum'_ses-01_task-'$taskName'_run-'$runNumber'_bold.nii.gz'
        echo $file
        cd $WD
        python removeDummies.py $file $numDummies $deleteOriginal
        cd $BIDSOutputFolder
    done

  ## 3. ADD OTHER EXPERIMENTS IF NEEDED BY COPYING ONE OF THE ABOVE


done
