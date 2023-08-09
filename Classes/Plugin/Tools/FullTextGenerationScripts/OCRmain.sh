#!/bin/bash

### Main entry script for running the OCR-Engines, starting the OCR prosses and do everthing related ###

set -euo pipefail # exit on: error, undefined variable, pipefail

# Test fuction, for manually testing the script
function test() { 
	CLR_G='\e[32m' # Green
	NC='\e[0m' # No Color

	if [ -d "typo3conf/ext/dlf/Classes/Plugin/Tools/FullTextGenerationScripts/" ]; then 
		cd typo3conf/ext/dlf/Classes/Plugin/Tools/FullTextGenerationScripts
	fi
	echo -e "Starting tests:"
	echo -e "tesseract-basc.sh:"
	./tesseract-basic.sh --test
	echo -e "${CLR_G}tesseract-basic.sh: OK${NC}"
	echo -e "kraken-basic.sh:"
	./kraken-basic.sh --test
	echo -e "${CLR_G}kraken-basic.sh: OK${NC}"
	echo -e "ocrd-basic.sh:"
	./ocrd-basic.sh --test
	echo -e "${CLR_G}ocrd-basic.sh: OK${NC}"
	echo -e "${CLR_G}All tests passed${NC}"

	exit 0;
}


# Paramaters:
while [ $# -gt 0 ] ; do
	case $1 in
		--ocrEngine)			ocrEngine="$2" ;;		# OCR-Engine to use
		--pageId)				pageId="$2" ;;			# Page number
		--imagePath)			imagePath="$2" ;;		# Image path/URL
		--outputPath)			outputPath="$2" ;;		# Fulltextfile path
		--tmpOutputPath)		tmpOutputPath="$2" ;;	# Temporary Fulltextfile path
		--tmpImagePath)			tmpImagePath="$2" ;;	# Temporary image path
		--url)					url="$2" ;;				# Alto URL (e.g http://localhost/fileadmin/fulltextFolder//URN/nbn/de/bsz/180/digosi/27/tesseract-basic/log59088_1.xml)
		--ocrUpdateMets) 		ocrUpdateMets="$2" ;;	# Update METS XML with given ALTO file (1|0)
		--ocrIndexMets) 		ocrIndexMets="$2" ;;	# Index METS XML with updated METS XML (only if ocrUpdateMets is 1) (1|0)
		--test)					test ;;
	esac
		shift
done


# Run given OCR-Engine:
$ocrEngine --pageId $pageId --imagePath $imagePath --outputPath $tmpOutputPath --tmpImagePath $tmpImagePath

# Move temporary output file to final location, if it is not already there:
if [ "$outputPath" != "$tmpOutputPath" ]; then 
	mkdir -p $(dirname $outputPath) # Create directory if it does not exist
	mv -v -f $tmpOutputPath.xml $outputPath
fi

# Update METS file:
if [ "$ocrUpdateMets" == "1" ]; then
	./typo3conf/ext/dlf/Classes/Plugin/Tools/FullTextGenerationScripts/UpdateMets.sh --pageId $pageId --outputPath $outputPath --url $url --ocrEngine $ocrEngine --ocrIndexMets $ocrIndexMets
fi

exit 0
