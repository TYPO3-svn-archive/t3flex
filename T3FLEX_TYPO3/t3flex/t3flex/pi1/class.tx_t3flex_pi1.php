<?php
/***************************************************************
*  Copyright notice
*
*  (c) 2009 Maik Preuss / wwsc <typo3-dev@wwsc.de>
*  All rights reserved
*
*  This script is part of the TYPO3 project. The TYPO3 project is
*  free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  The GNU General Public License can be found at
*  http://www.gnu.org/copyleft/gpl.html.
*
*  This script is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  This copyright notice MUST APPEAR in all copies of the script!
***************************************************************/

require_once(PATH_tslib.'class.tslib_pibase.php');

require_once(t3lib_extMgm::extPath('t3flex').'lib/class.tx_t3flex_DataProcessor.php');
require_once(t3lib_extMgm::extPath('t3flex').'lib/class.tx_t3flex_ImageProcessor.php');


/**
 * Plugin 'T3Flex' for the 't3flex' extension.
 *
 * @author  Maik Preuss / wwsc <typo3-dev@wwsc.de>
 * @package TYPO3
 * @subpackage  tx_t3flex
 */
class tx_t3flex_pi1 extends tslib_pibase {
  var $prefixId      = 'tx_t3flex_pi1';   // Same as class name
  var $scriptRelPath = 'pi1/class.tx_t3flex_pi1.php'; // Path to this script relative to the extension dir.
  var $extKey        = 't3flex';  // The extension key.

  /**
   * The main method of the PlugIn
   *
   * @param string    $content: The PlugIn content
   * @param array   $conf: The PlugIn configuration
   * @return  The content that is displayed on the website
   */
  function main($content,$conf) {
    $this->conf = $conf;
    $this->pi_setPiVarDefaults();
    $this->pi_loadLL();
    $this->pi_USER_INT_obj = 1; // Configuring so caching is not expected. This value means that no cHash params are ever set. We do this, because it's a USER_INT object!

    $generator = null;

    switch ($GLOBALS['TSFE']->type) {
    case 0:
      $this->internal['results_at_a_time'] = 1000;
      if ($this->piVars['count']) {
        $this->internal['results_at_a_time'] = $this->piVars['count'];
      }
      $generator = t3lib_div::makeInstance('tx_t3flex_DataProcessor');
      break;

    case 9031:
      $generator = t3lib_div::makeInstance('tx_t3flex_ImageProcessor');
      break;

    }

    return $generator ? $generator->process($this) : '';
  }
}



if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/pi1/class.tx_t3flex_pi1.php'])  {
  include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['ext/t3flex/pi1/class.tx_t3flex_pi1.php']);
}

?>