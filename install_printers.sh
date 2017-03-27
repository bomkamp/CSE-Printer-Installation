#!/bin/bash
#Script to add all printers to a linux machine using lpadmin. This will add each printer with its respective driver rather than the universal driver.
#@AUTHOR: Greg Bomkamp (The Ohio State University)
#@DATE: 7/11/16

#create arrays of printer names and drivers for printer types - new printers can be added to these arrays
blkWhtPrinters=( 'lj_dl_172' 'lj_dl_272' 'lj_dl_477' 'lj_dl_577' 'lj_dl_677' 'lj_dl_777' 'lj_dl_895' )
colorPrinters=( 'ljc_dl_677' 'ljc_dl_895' )

#variables for each driver that is necessary -> if a new printer is added with a different model than others then use command "lpinfo -m | grep "printer_model"" to find a driver for it.
debSeries600=postscript-hp:0/ppd/hplip/HP/hp-laserjet_600_m601_m602_m603-ps.ppd
debSeries4700=postscript-hp:0/ppd/hplip/HP/hp-color_laserjet_4700-ps.ppd
rpmSeries600=lsb/usr/HP/hp-laserjet_600_m601_m602_m603-ps.ppd.gz
rpmSeries4700=lsb/usr/HP/hp-color_laserjet_4700-ps.ppd.gz

#Check whether system is rpm or debian based.
if [ -f /etc/debian_version ]; then

	#Add all printers that are 600 series - 172,272,477,577,677,777,895
	echo "Adding B&W Printers..."	
	for i in ${blkWhtPrinters[@]}
	do
		lpadmin -E -p $i -v lpd://print.cse.ohio-state.edu/$i -m $debSeries600 -E
	done

	#Add 4700 color printers
	echo "Adding Color Printers..."
	for i in ${colorPrinters[@]}
	do
		lpadmin -E -p $i -v lpd://print.cse.ohio-state.edu/$i -m $debSeries4700 -E
	done

	#Make all printers default set as Duplex printers allowing two-sided printing
	echo "Setting printer options..."

	#use 'lpoptions -p <printer_name> -l' to see all available options if other options need to be changed along with default Duplex

	#if new array of printers is created, must append it to $allPrinters to apply duplex settings
	allPrinters=( "${blkWhtPrinters[@]}" "${colorPrinters[@]}" )
	for i in ${allPrinters[@]}
	do
		#use lpadmin rather than lpoptions due to where changes are made
		lpadmin -p $i -o HPOption_Duplexer=True
	done
	echo "Done."

elif [ -f /etc/redhat-release ]; then

	#mandatory package install for required drivers that aren't pre-packaged.
	yum install -y hplip

	#Add all printers that are 600 series - 172,272,477,577,677,777,895
	echo "Adding B&W Printers..."	
	for i in ${blkWhtPrinters[@]}
	do
		lpadmin -E -p $i -v lpd://print.cse.ohio-state.edu/$i -m $rpmSeries600 -E
	done
	
	#Add 4700 color printers
	echo "Adding Color Printers..."
	for i in ${colorPrinters[@]}
	do
		lpadmin -E -p $i -v lpd://print.cse.ohio-state.edu/$i -m $rpmSeries4700 -E
	done
	
	#Make all printers default set as Duplex printers allowing two-sided printing
	echo "Setting printer options..."

	#use 'lpoptions -p <printer_name> -l' to see all available options if other options need to be changed along with default Duplex

	#if new array of printers is created, must append it to $allPrinters to apply duplex settings
	allPrinters=( "${blkWhtPrinters[@]}" "${colorPrinters[@]}" )
	for i in ${allPrinters[@]}
	do
		#use lpadmin rather than lpoptions due to where changes are made
		lpadmin -p $i -o HPOption_Duplexer=True
	done
	echo "Done."

else
	echo "Operating System is not supported by this script."
fi


