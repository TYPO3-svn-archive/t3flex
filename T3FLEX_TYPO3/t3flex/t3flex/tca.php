<?php
if (!defined ('TYPO3_MODE')) 	die ('Access denied.');

$TCA['tx_t3flex_storedqueries'] = array (
	'ctrl' => $TCA['tx_t3flex_storedqueries']['ctrl'],
	'interface' => array (
		'showRecordFieldList' => 'title,parameters,query,description'
	),
	'feInterface' => $TCA['tx_t3flex_storedqueries']['feInterface'],
	'columns' => array (
		'title' => array (		
			'exclude' => 0,		
			'label' => 'LLL:EXT:t3flex/locallang_db.xml:tx_t3flex_storedqueries.title',		
			'config' => array (
				'type' => 'input',	
				'size' => '30',
			)
		),
		'parameters' => array (		
			'exclude' => 0,		
			'label' => 'LLL:EXT:t3flex/locallang_db.xml:tx_t3flex_storedqueries.parameters',		
			'config' => array (
				'type' => 'input',	
				'size' => '30',
			)
		),
		'query' => array (		
			'exclude' => 0,		
			'label' => 'LLL:EXT:t3flex/locallang_db.xml:tx_t3flex_storedqueries.query',		
			'config' => array (
				'type' => 'text',
				'cols' => '30',	
				'rows' => '5',
			)
		),
		'description' => array (		
			'exclude' => 0,		
			'label' => 'LLL:EXT:t3flex/locallang_db.xml:tx_t3flex_storedqueries.description',		
			'config' => array (
				'type' => 'text',
				'cols' => '30',	
				'rows' => '5',
			)
		),
	),
	'types' => array (
		'0' => array('showitem' => 'title;;;;2-2-2, parameters;;;;3-3-3, query, description')
	),
	'palettes' => array (
		'1' => array('showitem' => '')
	)
);
?>