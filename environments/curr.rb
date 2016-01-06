name "curr"
description "curr"

override_attributes ({
    'CLM' => {
        'version' => '6.0.1',
        'zip' => 'JTS-CCM-QM-RM-JRS-RELM-repo-6.0.1.zip',
        'fix' => "CLM_601_iFix001.zip",
        'server_patch' =>  'CLM_server_patch_6.0.1.0-CALM601M-I20151217-2117.zip',
        'build_zip' => 'RTC-BuildSystem-Toolkit-repo-6.0.1.zip',
        'build_packages' => 'com.ibm.team.install.rtc.buildsystem_6.0.1000.RTC-I20151109-2045-r601',
        'rdm_zip' => 'Rhapsody-DM-Servers-6.0.1.zip',
        'rdm_packages' => 'com.ibm.team.install.jfs.app.product-rhapsody-dm_6.0.1000.CALMDM601-I20151110-0007-r601 com.ibm.team.install.jfs.app.rhapsodydm_6.0.1000.Rhapsody601-I20151112_0802',
        ,'use_rdm' => 'true',
        'packages' => 'com.ibm.team.install.jfs.app.gc_6.0.1000.RJF-I20151106-1823-r601- com.ibm.team.install.jfs.app.jrs_6.0.1000.JRS-Packaging_601-I20151106-2026 com.ibm.team.install.jfs.app.jts_6.0.1000.RJF-I20151106-1823-r601- com.ibm.team.install.jfs.app.ldx_6.0.1000.RJF-I20151106-1823-r601- com.ibm.team.install.jfs.app.product-clm_6.0.1000.CALM601-I20151110-0007-r601 com.ibm.team.install.jfs.app.rdm_6.0.1000.RDNG6_0_1-I20151106_1951 com.ibm.team.install.jfs.app.relm_6.0.1000.RELM_6_0_1-I20151106-2026 com.ibm.team.install.jfs.app.rqm_6.0.1000.RQM6_0_1-I20151109_2311 com.ibm.team.install.jfs.app.rtc_6.0.1000.RTC-I20151109-2045-r601'
	},
	'UCD' => {
	    'zip' => 'ibm-ucd-6.2.0.2.723274.zip',
	    'plugins_dir' => '/opt/ibm-ucd/server/appdata/var/plugins'
	    'engine_zip' => 'ibm-ucd-patterns-engine-6.2.0.2.723956.tgz'
	    'designer_zip' => 'ibm-ucd-patterns-web-designer-linux-x86_64-6.2.0.2.723425.tgz'
	},
	'UCR' => {
	    'zip' => 'IBM_URBANCODE_RELEASE_6.1.1.9_update.zip',
	}
	
	
})