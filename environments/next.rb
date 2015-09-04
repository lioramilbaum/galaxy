name "next"
description "next"

override_attributes ({
    'CLM' => {
        'version' => '6.0RC1',
        'zip' => 'JTS-CCM-QM-RM-JRS-RELM-repo-6.0.1M3.zip',
        'fix' => 'nil',
        'build_zip' => '',
        'build_packages' => '',
        'rdm_zip' => '',
        'rdm_packages' => '',
        'packages' => '' 
     },
	'UCD' => {
	    'fix' => 'ibm-ucd-6.1.3.0.695062.zip',
	    'plugins_dir' => '/opt/ibm-ucd/server/appdata/var/plugins'
	},
	'UCR' => {
	    'fix' => 'IBM_URBANCODE_RELEASE_6.1.1.9_update.zip',
	}
})