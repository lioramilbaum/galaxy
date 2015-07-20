name "next"
description "next"

override_attributes ({
    'CLM' => {
        'version' => '6.0RC1',
        'zip' => 'JTS-CCM-QM-RM-JRS-RELM-repo-6.0.1M1.zip',
        'fix' => 'nil',
        'build_zip' => 'RTC-BuildSystem-Toolkit-repo-6.0.1M1.zip',
        'build_packages' => '',
        'rdm_zip' => 'Rhapsody-DM-Servers-6.0.1M1.zip',
        'rdm_packages' => 'com.ibm.team.install.jfs.app.product-rhapsody-dm_6.0.0.CALMDM60-I20150508-1803-r60-RC1 com.ibm.team.install.jfs.app.rhapsodydm_6.0.0.Rhapsody60-I20150510_1558 com.ibm.team.install.jfs.app.vvc_6.0.0.VVC60-I20150507_1500',
        'packages' => 'com.ibm.team.install.jfs.app.gc_6.0.0.RJF-I20150507-1330-r60-RC1 com.ibm.team.install.jfs.app.jrs_6.0.0.JRS-Packaging_600-I20150507-1543 com.ibm.team.install.jfs.app.jts_6.0.0.RJF-I20150507-1330-r60-RC1 com.ibm.team.install.jfs.app.ldx_6.0.0.RJF-I20150507-1330-r60-RC1 com.ibm.team.install.jfs.app.product-clm_6.0.0.CALM60-I20150508-1803-r60-RC1 com.ibm.team.install.jfs.app.rdm_6.0.0.RDNG6_0_0-I20150507_1516 com.ibm.team.install.jfs.app.relm_6.0.0.RELM_6_0_0-I20150507-1543 com.ibm.team.install.jfs.app.rqm_6.0.0.RQM6_0_0-I20150508_1652 com.ibm.team.install.jfs.app.rtc_6.0.0.RTC-I20150507-1500-r60-RC1' 
     },
	'UCD' => {
	    'fix' => 'IBM_UCD_SERVER_6.1.1.6.zip',
	    'plugins_dir' => '/opt/ibm-ucd/server/appdata/var/plugins'
	},
	'UCR' => {
	    'fix' => 'IBM_URBANCODE_RELEASE_6.1.1.9_update.zip',
	}
})