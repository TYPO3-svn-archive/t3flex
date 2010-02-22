<?php

require_once(t3lib_extMgm::extPath('t3flex').'lib/class.tx_t3flex_XmlSerializer.php');
require_once(t3lib_extMgm::extPath('cms').'tslib/media/scripts/fe_adminLib.inc');


class tx_t3flex_DataProcessor {


  function process($pObj) {

    // CONFIG: plugin.t3flex.pidList=30
    //
    // ?id=143&tx_t3flex_pi1[table]=tx_wwscloedata_project&tx_t3flex_pi1[action]=SELECT&tx_t3flex_pi1[count]=20&tx_t3flex_pi1[pointer]=0

    $action = $pObj->piVars['action'];

    if (!$pObj->conf['pidList']) {
      $ret = array(
        'data' => array('error' => 'Configuration incomplete! Please set \'plugin.'.$pObj->prefixId.'.pidList\'!'),
        'metadata' => array());
    } else {
      if ($action == 'SELECT') {
        $ret = $this->doSelect($pObj);
      } elseif ($action == 'SELECT_MM') {
        $ret = $this->doSelectMM($pObj);
      } elseif ($action == 'STORED_QUERY') {
        $ret = $this->doStoredQuery($pObj);
      } elseif ($action == 'INSERT') {
        $ret = $this->doInsert($pObj);
      } elseif ($action == 'UPDATE') {
        $ret = $this->doUpdate($pObj);
      } elseif ($action == 'DELETE') {
        $ret = $this->doDelete($pObj);
      } else {
        $ret = array(
          'data' => array('error' => 'Unknown action "'.$action.'"'),
          'metadata' => array());
      }
    }

    $serializer = t3lib_div::makeInstance('tx_t3flex_XmlSerializer');
    return $serializer->serialize($ret);
  }


  function doStoredQuery($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    if (!isset($pObj->piVars['qid'])) {
      return array(
        'data' => array('error' => 'Stored query id expected!'),
        'metadata' => array());
    }

    $storedQuery = $pObj->pi_getRecord('tx_t3flex_storedqueries', $pObj->piVars['qid']);
    if (!$storedQuery) {
      return array(
        'data' => array('error' => 'No stored query with id '.$pObj->piVars['qid'].' found!'),
        'metadata' => array());
    }

    $query = $storedQuery['query'];
    $params = t3lib_div::trimExplode(',', $storedQuery['parameters'], 1);

    foreach ($params as $param) {
      $value = $TYPO3_DB->fullQuoteStr($pObj->piVars[$param], '');
      $query = str_replace('###'.$param.'###', $value, $query);
    }

    $query = str_replace('###sys_language_uid###', $this->getSysLanguageId(), $query);

    $res = $TYPO3_DB->sql_query($query);
    while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
      $rows[] = $row;
    }

    $this->languageOverlay($rows, $res);
    $this->cleanupResult($rows);

    return array(
      'data' => $rows,
      'metadata' => array(
        'totalRows' => count($rows),
        'get_URL_ID' => $TSFE->fe_user->get_URL_ID));
  }


  function doSelect($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    $table = $pObj->piVars['table'];
    if (!isset($table, $TCA[$table])) {
      return array(
        'data' => array('error' => 'No entry in the $TCA-array for the table "'.$table.'"'),
        'metadata' => array());
    }
    if (!$this->isTableReadable($pObj, $table)) {
      return array(
        'data' => array('error' => 'Table "'.$table.'" is not configured for read access.'),
        'metadata' => array());
    }

    $TSFE->includeTCA(1);
    t3lib_div::loadTCA($table);

    $rows = array();
    if (isset($pObj->piVars['uid'])) {
      $row = $pObj->pi_getRecord($table, $pObj->piVars['uid']);
      if (isset($row)) {
        $rows[] = $row;
      }
    } else {
      $addWhere = '';

      if ($pObj->piVars['fFld']) {
        $fFld = $pObj->piVars['fFld'];
        if (!in_array($fFld, array_keys($TCA[$table]['columns']))) {
          return array(
            'data' => array('error' => 'No column "'.$fFld.'" in the $TCA-array for the table "'.$table.'"'),
            'metadata' => array());
        }
        $fldConfig = $TCA[$table]['columns'][$fFld];
        $fldType = $fldConfig['config']['type'];
        $value = $pObj->piVars['fVal'];
        $op = '=';
        if (($fldType == 'input' || $fldType == 'text') && (strpos($value, '%') !== false || strpos($value, '_') !== false)) {
          $op = ' LIKE ';
        }
        $addWhere .= ' AND '.$fFld.$op.$TYPO3_DB->fullQuoteStr($value, $table);
      }

      $orderBy='';
      if ($pObj->piVars['oFld']) {
        $arr = explode(':', $pObj->piVars['oFld'], 2);
        $oFld = $arr[0];
        if (!in_array($oFld, array_keys($TCA[$table]['columns']))) {
          return array(
            'data' => array('error' => 'No column "'.$oFld.'" in the $TCA-array for the table "'.$table.'"'),
            'metadata' => array());
        }
        $desc = 1 < count($arr) && $arr[1];
        $orderBy = $oFld . ' ' . ($desc ? 'DESC' : 'ASC');
      }

      // Check if the user is viewing a different language
      $sys_language_uid = $this->getSysLanguageId();
      $ctrl = $TCA[$table]['ctrl'];

      if (array_key_exists('languageField', $ctrl))
        $addWhere .= ' AND '.$table.'.'.$ctrl['languageField'].'='.$sys_language_uid;

      if ($sys_language_uid && array_key_exists('languageField', $ctrl)) {
        $res = $pObj->pi_exec_query($table, 0, $addWhere, '', '', $orderBy, $limit);
        while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
          $rows[] = $pObj->pi_getRecord($table, $row[$ctrl['transOrigPointerField']]);
        }
      } else {
        $res = $pObj->pi_exec_query($table, 0, $addWhere, '', '', $orderBy, $limit);
        while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
          $rows[] = $row;
        }
      }
    }

    $this->languageOverlay($rows, $table);
    $this->cleanupResult($rows);

    return array(
      'data' => $rows,
      'metadata' => array(
        'totalRows' => count($rows),
        'get_URL_ID' => $TSFE->fe_user->get_URL_ID));
  }


  function doSelectMM($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    $TSFE->includeTCA(1);

    $pointer = intval($pObj->piVars['pointer']);
    $results_at_a_time = t3lib_div::intInRange($pObj->internal['results_at_a_time'], 1, 1000);
    $limit = ($pointer * $results_at_a_time) . ',' . $results_at_a_time;

    $mode = 0;

    // Check if the user is viewing a different language
    $sys_language_uid = $this->getSysLanguageId();

    if ($pObj->piVars['foreign_table']) {
      $foreign_table = $pObj->piVars['foreign_table'];
      if (!isset($foreign_table, $TCA[$foreign_table])) {
        return array(
          'data' => array('error' => 'No entry in the $TCA-array for the table "'.$foreign_table.'"'),
          'metadata' => array());
      }
      if (!$this->isTableReadable($pObj, $foreign_table)) {
        return array(
          'data' => array('error' => 'Foreign table "'.$foreign_table.'" is not configured for read access.'),
          'metadata' => array());
      }

      $rows = array();

      t3lib_div::loadTCA($foreign_table);

      $column = $pObj->piVars['column'];
      if (isset($pObj->piVars['uid'], $column)) {

        $ctrl = $TCA[$foreign_table]['ctrl'];
        $columns = $TCA[$foreign_table]['columns'];
        $tcaFieldConf = $columns[$column]['config'];

        if (isset($tcaFieldConf['MM'])) {
          $mm_table = $tcaFieldConf['MM'];
          $table = $tcaFieldConf['allowed'];
          if ($table && !$this->isTableReadable($pObj, $table)) {
            return array(
              'data' => array('error' => 'Table "'.$table.'" is not configured for read access.'),
              'metadata' => array());
          }

          $whereClause = ' AND '.$mm_table.'.uid_foreign='.intval($pObj->piVars['uid']);
          $whereClause .= $pObj->cObj->enableFields($foreign_table);

          if (array_key_exists('languageField', $ctrl))
            $whereClause .= ' AND '.$foreign_table.'.'.$ctrl['languageField'].'='.$sys_language_uid;

          if ($sys_language_uid && array_key_exists('languageField', $ctrl)) {
            $res = $TYPO3_DB->exec_SELECT_mm_query($foreign_table.'.*',$foreign_table, $mm_table, $table, $whereClause, null, $mm_table.'.sorting', $limit);
            while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
              $rows[] = $pObj->pi_getRecord($foreign_table, $row[$ctrl['transOrigPointerField']]);
            }
          } else {
            $res = $TYPO3_DB->exec_SELECT_mm_query($foreign_table.'.*',$foreign_table, $mm_table, $table, $whereClause, null, $mm_table.'.sorting', $limit);
            while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
              $rows[] = $row;
            }
          }
        } elseif ($tcaFieldConf['type'] == 'group' && $tcaFieldConf['internal_type'] == 'db') {
         $table = $tcaFieldConf['allowed'];
          if (!$this->isTableReadable($pObj, $table)) {
            return array(
              'data' => array('error' => 'Table "'.$table.'" is not configured for read access.'),
              'metadata' => array());
          }

          $whereClause = $column.'='.intval($pObj->piVars['uid']);
          $whereClause .= $pObj->cObj->enableFields($foreign_table);

          if (array_key_exists('languageField', $ctrl))
            $whereClause .= ' AND '.$foreign_table.'.'.$ctrl['languageField'].'='.$sys_language_uid;

          if ($sys_language_uid && array_key_exists('languageField', $ctrl)) {
            $res = $TYPO3_DB->exec_SELECTquery('*', $foreign_table, $whereClause, '', '', $limit);
            while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
              $rows[] = $pObj->pi_getRecord($foreign_table, $row[$ctrl['transOrigPointerField']]);
            }
          } else {
            $res = $TYPO3_DB->exec_SELECTquery('*', $foreign_table, $whereClause, '', '', $limit);
            while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
              $rows[] = $row;
            }
          }
        }
      }
    } else {
      $table = $pObj->piVars['table'];
      if (!isset($table, $TCA[$table])) {
        return array(
          'data' => array('error' => 'No entry in the $TCA-array for the table "'.$table.'"'),
          'metadata' => array());
      }
      if (!$this->isTableReadable($pObj, $table)) {
        return array(
          'data' => array('error' => 'Table "'.$table.'" is not configured for read access.'),
          'metadata' => array());
      }

      $rows = array();

      t3lib_div::loadTCA($table);

      $column = $pObj->piVars['column'];
      if (isset($pObj->piVars['uid'], $column)) {
        $tcaFieldConf = $TCA[$table]['columns'][$column]['config'];

        $mm_table = $tcaFieldConf['MM'];
        $foreign_table = $tcaFieldConf['allowed'];
        if (!$this->isTableReadable($pObj, $foreign_table)) {
          return array(
            'data' => array('error' => 'Foreign table "'.$foreign_table.'" is not configured for read access.'),
            'metadata' => array());
        }

        $ctrl = $TCA[$foreign_table]['ctrl'];

        $whereClause = ' AND '.$mm_table.'.uid_local='.intval($pObj->piVars['uid']);
        $whereClause .= $pObj->cObj->enableFields($foreign_table);

        if (array_key_exists('languageField', $ctrl))
          $whereClause .= ' AND '.$foreign_table.'.'.$ctrl['languageField'].'='.$sys_language_uid;

        if ($sys_language_uid && array_key_exists('languageField', $ctrl)) {
          $res = $TYPO3_DB->exec_SELECT_mm_query($foreign_table.'.*', '', $mm_table, $foreign_table, $whereClause, null, $mm_table.'.sorting', $limit);
          while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
              $rows[] = $pObj->pi_getRecord($foreign_table, $row[$ctrl['transOrigPointerField']]);
          }
        } else {
          $res = $TYPO3_DB->exec_SELECT_mm_query($foreign_table.'.*', '', $mm_table, $foreign_table, $whereClause, null, $mm_table.'.sorting', $limit);
          while ($row = $TYPO3_DB->sql_fetch_assoc($res)) {
            $rows[] = $row;
          }
        }
      }
    }

    $this->languageOverlay($rows, $foreign_table);
    $this->cleanupResult($rows);

    return array(
      'data' => $rows,
      'metadata' => array(
        'totalRows' => count($rows),
        'mode' => $mode,
        'get_URL_ID' => $TSFE->fe_user->get_URL_ID));
  }


  function doDelete($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    $table = $pObj->piVars['table'];
    if (!isset($table, $TCA[$table])) {
      return array(
        'data' => array('error' => 'No entry in the $TCA-array for the table "'.$table.'"'),
        'metadata' => array());
    }
    if (!$this->isTableWriteable($pObj, $table)) {
      return array(
        'data' => array('error' => 'Table "'.$table.'" is not configured for write access.'),
        'metadata' => array());
    }

    $uid = $pObj->piVars['uid'];
    if (isset($uid)) {
      if ($pObj->cObj->DBgetDelete($table, $uid, TRUE)) {
        $ret = array(
          'data' => array('Row deleted'),
          'metadata' => array());
      } else {
        $ret = array(
          'data' => array('error' => 'No row deleted'),
          'metadata' => array());
      }
    } else {
      $ret = array(
        'data' => array('error' => 'No row specified'),
        'metadata' => array());
    }

    return $ret;
  }


  function doUpdate($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    $table = $pObj->piVars['table'];
    if (!isset($table, $TCA[$table])) {
      return array(
        'data' => array('error' => 'No entry in the $TCA-array for the table "'.$table.'"'),
        'metadata' => array());
    }
    if (!$this->isTableWriteable($pObj, $table)) {
      return array(
        'data' => array('error' => 'Table "'.$table.'" is not configured for write access.'),
        'metadata' => array());
    }

    $TSFE->includeTCA(1);
    t3lib_div::loadTCA($table);

    $uid = $pObj->piVars['uid'];
    $writeableColumns = array_merge(array_keys($TCA[$table]['columns']), array('sorting'));
    $dataArr = isset($pObj->piVars['FE']) ? array_intersect_key($pObj->piVars['FE'], array_flip($writeableColumns)) : array();
    $filesArr = isset($_FILES[$pObj->prefixId]) ? array_intersect_key($this->getFilesArray($_FILES[$pObj->prefixId], 'FS'), $TCA[$table]['columns']) : array();

    $fileColumns = $this->getFileColumns($dataArr, $filesArr, $TCA[$table]);
    if ($fileColumns && $row = $pObj->pi_getRecord($table, $uid)) {
      foreach ($fileColumns as $column => $tcaFieldConf) {
        $fieldValue = isset($dataArr[$column]) ? $dataArr[$column] : $row[$column];

        // Dateien ermitteln, die später gelöscht werden sollen
        $unneededFiles = array_diff(
          t3lib_div::trimExplode(',', $row[$column], 1),
          t3lib_div::trimExplode(',', $fieldValue, 1));

        // Neue Dateien in upload-Verzeichnis verschieben
        if (isset($filesArr[$column]) && !$filesArr[$column]['error']) {
          $newFileName = $this->moveUplodedFile($filesArr[$column], $tcaFieldConf);
          if ($newFileName) {
            $fileNames = t3lib_div::trimExplode(',', $fieldValue, 1);
            $fileNames[] = $newFileName;
            $dataArr[$column] = implode(',', $fileNames);
          }
        }

        foreach($unneededFiles as $unneddedFile) {
          $unneddedFilePath = PATH_site.$tcaFieldConf['uploadfolder'].'/'.$unneddedFile;
          if (file_exists($unneddedFilePath)) {
            unlink($unneddedFilePath);
          }
        }
      }
    }

    $mmColumns = $this->getMMColumns($dataArr, $TCA[$table]);
    $dataArrMM = array();
    foreach ($mmColumns as $column => $tcaFieldConf) {
      $dataArrMM[$column] = $dataArr[$column];
      unset($dataArr[$column]);
    }

    $pObj->cObj->DBgetUpdate($table, $uid, $dataArr, implode(',', array_keys($dataArr)), TRUE);

    $this->handleMMData($uid, $mmColumns, $dataArrMM, $pObj);

    $rows = array($pObj->pi_getRecord($table, $uid));
    $this->languageOverlay($rows, $table);
    $this->cleanupResult($rows);

    $ret = array(
      'data' => $rows,
      'metadata' => array(
        'totalRows' => 1));

    return $ret;
  }


  function doInsert($pObj) {
    global $TYPO3_DB, $TCA, $TSFE;

    $table = $pObj->piVars['table'];
    if (!isset($table, $TCA[$table])) {
      return array(
        'data' => array('error' => 'No entry in the $TCA-array for the table "'.$table.'"'),
        'metadata' => array());
    }
    if (!$this->isTableWriteable($pObj, $table)) {
      return array(
        'data' => array('error' => 'Table "'.$table.'" is not configured for write access.'),
        'metadata' => array());
    }

    $TSFE->includeTCA(1);
    t3lib_div::loadTCA($table);

    $writeableColumns = array_merge(array_keys($TCA[$table]['columns']), array('sorting'));
    $dataArr = isset($pObj->piVars['FE']) ? array_intersect_key($pObj->piVars['FE'], array_flip($writeableColumns)) : array();
    $filesArr = isset($_FILES[$pObj->prefixId]) ? array_intersect_key($this->getFilesArray($_FILES[$pObj->prefixId], 'FS'), $TCA[$table]['columns']) : array();

    $fileColumns = $this->getFileColumns($dataArr, $filesArr, $TCA[$table]);
    if ($fileColumns) {
      foreach ($fileColumns as $column => $tcaFieldConf) {
        // Dateien in upload-Verzeichnis verschieben
        if (isset($filesArr[$column]) && !$filesArr[$column]['error']) {
          $newFileName = $this->moveUplodedFile($filesArr[$column], $tcaFieldConf);
          if ($newFileName) {
            $dataArr[$column] = $newFileName;
          }
        }
      }
    }

    $mmColumns = $this->getMMColumns($dataArr, $TCA[$table]);
    $dataArrMM = array();
    foreach ($mmColumns as $column => $tcaFieldConf) {
      $dataArrMM[$column] = $dataArr[$column];
      unset($dataArr[$column]);
    }

    if ($pObj->cObj->DBgetInsert($table, $pObj->piVars['FE']['pid'], $dataArr, implode(',', array_keys($dataArr)), TRUE)) {
      $uid = $TYPO3_DB->sql_insert_id();

      $this->handleMMData($uid, $mmColumns, $dataArrMM, $pObj);

      $rows = array($pObj->pi_getRecord($table, $uid));
      $this->languageOverlay($rows, $table);
      $this->cleanupResult($rows);

      $ret = array(
        'data' => $rows,
        'metadata' => array(
          'totalRows' => 1));
    } else {
      $ret = array(
        'data' => array('error' => 'No data inserted'),
        'metadata' => array());
    }

    return $ret;
  }


  function cleanupResult(&$rows) {
    for ($i = 0; $i < count($rows); $i++) {
      unset($rows[$i]['l18n_diffsource']);
      unset($rows[$i]['l10n_diffsource']);
      unset($rows[$i]['password']);
    }
  }


  function languageOverlay(&$rows, $table) {
    global $TYPO3_DB, $TCA, $TSFE;

    // Check if the user is viewing a different language
    $sys_language_uid = $this->getSysLanguageId();
    if ($sys_language_uid == 0)
      return;

    $tables = array();
    if (is_string($table)) {
      $tables[$table] = array_keys($TCA[$table]['columns']);
    } else {
      $res = $table;
      for ($i = 0; $i < mysql_num_fields($res); ++$i) {
        $info = mysql_fetch_field($res, $i);
        $tables[$info->table][] = $info->name;
      }
    }

    foreach ($tables as $table => $fields) {
      $ctrl = $TCA[$table]['ctrl'];
      if ($ctrl && array_key_exists('languageField', $ctrl)) {
        continue;
      }
      unset($tables[$table]);
    }

    if ($tables) {
      $OLmode = ($sys_language_mode == 'strict' ? 'hideNonTranslated' : '');
      for ($i = 0; $i < count($rows); $i++) {
        foreach ($tables as $table => $fields) {
          $row = $TSFE->sys_page->getRecordOverlay($table, $rows[$i], $sys_language_uid, $OLmode);

          $prefix = $table.'_';
          $subrow = array();
          foreach ($fields as $field) {
            if (strncmp($field, $prefix, strlen($prefix)) == 0) {
              $subrow[substr($field, strlen($prefix))] = $row[$field];
            }
          }

          if ($subrow) {
            $subrow = $TSFE->sys_page->getRecordOverlay($table, $subrow, $sys_language_uid, $OLmode);
            foreach ($subrow as $key => $value) {
              $row[$prefix.$key] = $value;
            }
          }
          
          $rows[$i] = $row;
        }
      }
    }
  }

  function getSysLanguageId() {
    global $TSFE;

    // Check if the user is viewing a different language
    $sys_language_uid = $TSFE->sys_language_uid;
    if ($sys_language_uid == 0 && isset($_REQUEST['L'])) {
      $sys_language_uid = intval($_REQUEST['L']);
    }

    return $sys_language_uid;
  }

  function isTableReadable($pObj, $table) {
    $readableTables = t3lib_div::trimExplode(',', $pObj->conf['readableTables'], 1);
    return $readableTables && in_array($table, $readableTables);
  }


  function isTableWriteable($pObj, $table) {
    $writeableTables = t3lib_div::trimExplode(',', $pObj->conf['writeableTables'], 1);
    return $writeableTables && in_array($table, $writeableTables);
  }


  function getFileColumns($dataArr, $filesArr, $tcaTableConf) {
    $fileColumns = array();
    foreach (array_merge(array_keys($dataArr), array_keys($filesArr)) as $column) {
      $tcaFieldConf = $tcaTableConf['columns'][$column]['config'];
      if ($tcaFieldConf['type'] == 'group' && $tcaFieldConf['internal_type'] == 'file') {
        $fileColumns[$column] = $tcaFieldConf;
      }
    }
    return $fileColumns;
  }


  function getMMColumns($dataArr, $tcaTableConf) {
    $mmColumns = array();
    foreach (array_keys($dataArr) as $column) {
      $tcaFieldConf = $tcaTableConf['columns'][$column]['config'];
      if ($tcaFieldConf['type'] == 'group' && $tcaFieldConf['MM']) {
        $mmColumns[$column] = $tcaFieldConf;
      }
    }
    return $mmColumns;
  }


  function handleMMData($uid, $mmColumns, $dataArrMM, $pObj) {
    global $TYPO3_DB;

    $dataArr = array();
    foreach ($mmColumns as $column => $tcaFieldConf) {
      $values = t3lib_div::trimExplode(',', $dataArrMM[$column], 1);
      $mm_table = $tcaFieldConf['MM'];
      $TYPO3_DB->exec_DELETEquery($mm_table, 'uid_local='.intval($uid));
      $sorting = 0;
      foreach ($values as $value) {
        $sorting++;
        $TYPO3_DB->exec_INSERTquery($mm_table,
          array('uid_local' => intval($uid), 'uid_foreign' => intval($value), 'sorting' => $sorting));
      }
      $dataArr[$column] = $sorting;
    }

    $pObj->cObj->DBgetUpdate($table, $uid, $dataArr, implode(',', array_keys($dataArr)), TRUE);
  }


  function getFilesArray($files, $prefix) {
    $filesArray = array();
    foreach($files as $attr => $section) {
      if (isset($section[$prefix])) {
        $columns = $section[$prefix];
        foreach ($columns as $column => $value) {
          $filesArray[$column][$attr] = $value;
        }
      }
    }
    return $filesArray;
  }


  function moveUplodedFile($fileDescr, $tcaFieldConf) {
    $all_files = Array();
    $all_files['webspace']['allow'] = $tcaFieldConf['allowed'];
    $all_files['webspace']['deny'] = $tcaFieldConf['disallowed'] ? $tcaFieldConf['disallowed'] : '*';
    $all_files['ftpspace'] = $all_files['webspace'];

    $ffObj = t3lib_div::makeInstance('t3lib_basicFileFunctions');
    $ffObj->init('', $all_files);

    $theFile = $fileDescr['tmp_name'];        // filename of the uploaded file
    $theFileSize = $fileDescr['size'];        // filesize of the uploaded file
    $theName = $ffObj->cleanFileName(stripslashes($fileDescr['name']));  // The original filename

    if (is_uploaded_file($theFile) && $theName && $theFileSize<$tcaFieldConf['max_size']*1024) { // Check the file
      $fI = t3lib_div::split_fileref($theName);
      $theTarget = $ffObj->is_directory(PATH_site.$tcaFieldConf['uploadfolder']);  // Check the target dir
      if ($theTarget && $ffObj->checkIfAllowed($fI['fileext'], $theTarget, $fI['file'])) {
        $theNewFile = $ffObj->getUniqueName($theName, $theTarget);
        if ($theNewFile)  {
          t3lib_div::upload_copy_move($theFile, $theNewFile);
          if (@is_file($theNewFile)) {
            $info = t3lib_div::split_fileref($theNewFile);
            return $info['file'];
          }
        }
      }
    }
    return null;
  }

}



if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/lib/class.tx_t3flex_DataProcessor.php']) {
  include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/lib/class.tx_t3flex_DataProcessor.php']);
}

?>