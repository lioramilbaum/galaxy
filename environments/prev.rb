name "prev"
description "prev"

override_attributes ({
    'CLM' => {
        'version' => '5.0.2',
        'zip' => 'JTS-CCM-QM-RM-repo-5.0.2.zip',
        'fix' => 'CLM_502_iFix006.zip',
        'build_zip' => 'RTC-BuildSystem-Toolkit-repo-5.0.2.zip',
        'build_packages' => 'com.ibm.team.install.rtc.buildsystem_5.0.2000.RTC-I20141031-0926-r502',
        'rdm_zip' => 'Rhapsody-DM-Servers-5.0.2.zip',
        'rdm_packages' => 'com.ibm.team.install.jfs.app.product-rhapsody-dm_5.0.2000.CALMDM502-I20141031-1820-r502 com.ibm.team.install.jfs.app.rhapsodydm_5.0.2000.Rhapsody502-I20141031_1828 com.ibm.team.install.jfs.app.vvc_5.0.2000.VVCvvc-502-I20141028_1747',
        'packages' => 'com.ibm.team.install.jfs.app.jts_5.0.2000.RJF-I20141028-1603-r502- com.ibm.team.install.jfs.app.product-clm_5.0.2000.CALM502-I20141031-1820-r502 com.ibm.team.install.jfs.app.rdm_5.0.2000.RDNG5_0_2-I20141028_1800 com.ibm.team.install.jfs.app.rqm_5.0.2000.RQM5_0_2-I20141031_1744 com.ibm.team.install.jfs.app.rtc_5.0.2000.RTC-I20141031-0926-r502'
        
	},
	'UCD' => {
	    'fix' => 'IBM_UCD_SERVER_6.1.1.4.zip',
	    'plugins_dir' => "/opt/ibm-ucd/server/var/plugins"
	},
	'UCR' => {
	    'fix' => 'IBM_URBANCODE_RELEASE_6.1.1.9_update.zip',
	}
})