<?php

require_once(t3lib_extMgm::extPath('t3flex').'lib/class.tx_t3flex_XmlSerializer.php');

class tx_t3flex_ImageProcessor {

  function process($pObj) {
    global $TSFE;

    $fname = $pObj->piVars['img'];
    $relPath = 'uploads/'.$fname;

    if ($fname && file_exists(PATH_site.$file)) {
      $width = $pObj->piVars['w'];
      $height = $pObj->piVars['h'];

      if ($width || $height) {
        if ($width) { $conf['width'] = $width; }
        if ($height) { $conf['height'] = $height; }

        //$conf['ext'] = 'jpg';
        $conf['params'] = '-quality 100';
        $info = $pObj->cObj->getImgResource($relPath, $conf);

        $absPath = PATH_site.$info[3];
      } else {
        $absPath = PATH_site.$relPath;
      }

      header('Content-type: '. mime_content_type($absPath));
      readfile($absPath);

      return null;
    } else {
      $ret = array(
        'data' => array('error' => 'File \''. $fname .'\' don\'t exists on this server.'),
        'metadata' => array()
      );
    }

    $serializer = t3lib_div::makeInstance('tx_t3flex_XmlSerializer');
    return $serializer->serialize($ret);
  }

}



if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/lib/class.tx_t3flex_ImageProcessor.php']) {
  include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/lib/class.tx_t3flex_ImageProcessor.php']);
}

?>