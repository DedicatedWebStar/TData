<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class RemoveOldListings extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'tickets:clean';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Soft delete all listings from previous week, update sale dates & move new onsales into current week.';

    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }

    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        \App\Import\RemoveOldListings::remove();
    }
}
