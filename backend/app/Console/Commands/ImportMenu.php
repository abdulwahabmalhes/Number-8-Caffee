<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\Category;
use App\Models\Product;

class ImportMenu extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:import-menu {--file= : Path to the JSON file containing menu data}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Import menu data from a JSON file or external API';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $file = $this->option('file');

        if ($file) {
            $this->info("Importing from file: {$file}");
            if (!file_exists($file)) {
                $this->error("File not found!");
                return Command::FAILURE;
            }
            $json = file_get_contents($file);
            $data = json_decode($json, true);
        } else {
            $this->info("No file provided. You would normally fetch from external API here.");
            // e.g. $data = Http::get('https://api.astro-menu.com/...')->json();
            $this->warn("Skipping real API fetch as endpoint is obfuscated. Use --file to import from JSON.");
            return Command::SUCCESS;
        }

        // Example parsing logic (adjust based on actual JSON structure)
        if (isset($data['categories'])) {
            foreach ($data['categories'] as $catData) {
                $category = Category::updateOrCreate(
                    ['name_en' => $catData['name_en']],
                    [
                        'name_ar' => $catData['name_ar'] ?? $catData['name_en'],
                        'sort_order' => $catData['sort_order'] ?? 0,
                        'is_active' => true,
                    ]
                );
                
                $this->info("Imported category: {$category->name_en}");

                if (isset($catData['products'])) {
                    foreach ($catData['products'] as $prodData) {
                        Product::updateOrCreate(
                            ['name_en' => $prodData['name_en']],
                            [
                                'category_id' => $category->id,
                                'name_ar' => $prodData['name_ar'] ?? $prodData['name_en'],
                                'price' => $prodData['price'] ?? 0,
                                'is_available' => true,
                            ]
                        );
                        $this->info("Imported product: {$prodData['name_en']}");
                    }
                }
            }
        }

        $this->info("Import completed successfully.");
        return Command::SUCCESS;
    }
}
