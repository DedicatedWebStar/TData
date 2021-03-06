<?php
/**
 * Created by PhpStorm.
 * User: sungwhikim
 * Date: 07/08/2018
 * Time: 14:20
 */

namespace App\Import;

use Illuminate\Support\Facades\Log;


class UpdateStats
{

    public static function update()
    {
        $listings = \App\Listing::get();

        foreach ($listings as $listing) {

            /* Calculate ROI for listing */
            if ( !isset($listing->data) || $listing->data === null ) {
                //echo '/** Data object not found in UpdateStats.php for listing id: ' . $listing->id . " **/\n";
                //Log::info('/** Data object not found in UpdateStats.php for listing id: ' . $listing->id . ' **/');
                continue;
            }

            $listing->calcRoi($listing->data);
        }
    }
}