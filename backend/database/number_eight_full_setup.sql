-- NUMBER EIGHT SPECIALTY COFFEE
-- Complete MySQL Database Setup & Restore Script
-- Safe to run in phpMyAdmin or MySQL CLI

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET NAMES utf8mb4;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `branches` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `location` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `working_hours` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tables` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `branch_id` bigint unsigned NOT NULL,
  `table_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `qr_token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tables_table_number_unique` (`table_number`),
  UNIQUE KEY `tables_qr_token_unique` (`qr_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `option_groups` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_multiple` tinyint(1) NOT NULL DEFAULT '0',
  `min_choices` int NOT NULL DEFAULT '0',
  `max_choices` int NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `products` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint unsigned NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `price` decimal(8,2) NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `is_bestseller` tinyint(1) NOT NULL DEFAULT '0',
  `is_new` tinyint(1) NOT NULL DEFAULT '0',
  `preparation_time` int DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `options` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `option_group_id` bigint unsigned NOT NULL,
  `name_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `additional_price` decimal(8,2) NOT NULL DEFAULT '0.00',
  `is_available` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `customers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `phone` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otp_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `otp_expires_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `customers_phone_unique` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `plate_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plate_emirate` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_model` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `vehicle_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_number` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `branch_id` bigint unsigned NOT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `table_id` bigint unsigned DEFAULT NULL,
  `vehicle_id` bigint unsigned DEFAULT NULL,
  `order_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'table',
  `subtotal` decimal(8,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(8,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(8,2) NOT NULL DEFAULT '0.00',
  `grand_total` decimal(8,2) NOT NULL DEFAULT '0.00',
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'new',
  `payment_method` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `payment_status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `expected_arrival_time` timestamp NULL DEFAULT NULL,
  `customer_arrived_at` timestamp NULL DEFAULT NULL,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `delivered_by` bigint unsigned DEFAULT NULL,
  `session_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `orders_order_number_unique` (`order_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `product_id` bigint unsigned NOT NULL,
  `quantity` int NOT NULL DEFAULT '1',
  `unit_price` decimal(8,2) NOT NULL,
  `total_price` decimal(8,2) NOT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `special_instructions` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `banners` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cta_text` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cta_link` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `sort_order` int NOT NULL DEFAULT '0',
  `start_date` timestamp NULL DEFAULT NULL,
  `end_date` timestamp NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_status_histories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint unsigned NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `notes` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_item_options` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `order_item_id` bigint unsigned NOT NULL,
  `option_id` bigint unsigned NOT NULL,
  `price` decimal(8,2) NOT NULL DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `guard_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `model_has_permissions` (
  `permission_id` bigint unsigned NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `model_has_roles` (
  `role_id` bigint unsigned NOT NULL,
  `model_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `model_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `role_has_permissions` (
  `permission_id` bigint unsigned NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `product_option_group` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned NOT NULL,
  `option_group_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `offers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title_ar` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title_en` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description_ar` text COLLATE utf8mb4_unicode_ci,
  `description_en` text COLLATE utf8mb4_unicode_ci,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `coupon_code` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `discount_type` enum('percentage','fixed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'percentage',
  `discount_value` decimal(8,2) NOT NULL DEFAULT '20.00',
  `min_order_amount` decimal(8,2) NOT NULL DEFAULT '0.00',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `expires_at` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `offers_coupon_code_unique` (`coupon_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
CREATE TABLE IF NOT EXISTS `settings` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- INITIAL CATALOG & USER DATA
-- ========================================================

-- Data for `migrations`
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('1', '0001_01_01_000000_create_users_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('2', '0001_01_01_000001_create_cache_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('3', '0001_01_01_000002_create_jobs_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('4', '2026_08_08_091503_create_branches_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('5', '2026_08_08_091503_create_tables_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('6', '2026_08_08_091504_create_categories_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('7', '2026_08_08_091504_create_option_groups_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('8', '2026_08_08_091504_create_products_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('9', '2026_08_08_091505_create_options_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('10', '2026_08_08_091514_create_customers_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('11', '2026_08_08_091514_create_vehicles_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('12', '2026_08_08_091515_create_orders_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('13', '2026_08_08_091516_create_order_items_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('14', '2026_08_08_091517_create_banners_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('15', '2026_08_08_091517_create_order_status_histories_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('16', '2026_08_08_091518_create_order_item_options_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('17', '2026_08_08_092455_create_permission_tables', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('18', '2026_08_08_105405_create_personal_access_tokens_table', '1');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('19', '2026_08_25_090344_add_otp_to_customers_table', '2');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('20', '2026_11_12_000001_create_product_option_group_table', '3');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('21', '2026_11_12_000002_add_password_to_customers_table', '4');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('22', '2026_11_12_000003_create_offers_table', '5');
INSERT IGNORE INTO `migrations` (`id`, `migration`, `batch`) VALUES ('23', '2026_11_16_000001_create_settings_table', '6');

-- Data for `settings`
INSERT IGNORE INTO `settings` (`key`, `value`, `created_at`, `updated_at`) VALUES ('loyalty_target_cups', '8', NOW(), NOW());

-- Data for `roles`
INSERT IGNORE INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('1', 'Super Admin', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT IGNORE INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('2', 'Branch Manager', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT IGNORE INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('3', 'Cashier', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT IGNORE INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('4', 'Barista', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT IGNORE INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('5', 'Handover', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');

-- Data for `users`
INSERT IGNORE INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('1', 'Admin Number Eight', 'admin@numbereight.ae', '2026-08-25 08:06:09', '$2y$12$DJ0AakREQdzIL1mUNFvo/eaVM/TwT6SMqM8KyIFPaGi1TfYTfThji', NULL, '2026-08-25 08:06:09', '2026-11-12 12:13:49');
INSERT IGNORE INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('2', 'Cashier Number Eight', 'cashier@numbereight.ae', '2026-08-25 08:06:10', '$2y$12$v/iX9l0bdXhmsacboDzia.exKawScdZ.vHISyz0fKtbwfPlJUH80G', NULL, '2026-08-25 08:06:10', '2026-11-12 10:07:41');
INSERT IGNORE INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('3', 'Admin User', 'admin@numbereight.com', NULL, '$2y$12$mAdflg7vu6cy5sIsmMaqf.ENykzYoS5N5N/6QnoUAcYQUuHORPyAm', NULL, '2026-10-16 07:49:35', '2026-10-16 07:49:35');

-- Data for `model_has_roles`
INSERT IGNORE INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES ('1', 'App\\Models\\User', '1');
INSERT IGNORE INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES ('3', 'App\\Models\\User', '2');

-- Data for `branches`
INSERT IGNORE INTO `branches` (`id`, `name_ar`, `name_en`, `location`, `working_hours`, `is_active`, `created_at`, `updated_at`) VALUES ('1', 'فرع الخبيصي', 'Al Khabisi Branch', 'Al Ain', '07:00 AM - 12:00 AM', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');

-- Data for `tables`
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('11', '1', '01', 'HJK5W7yPkISnIeE4oTmqSr7ieB5eDjco', '1', '2026-08-25 09:18:12', '2026-08-25 09:18:12');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('12', '1', '02', '78Tm6IXjulO2o1rPQxkmYGgrP1DtSGyq', '1', '2026-08-25 13:20:58', '2026-08-25 13:20:58');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('13', '1', '03', '6YLx1hQhuOPdsxT54X2g1uvgRz1zyNjF', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('14', '1', '04', 'mnx7BMQMJinEKj2CMoCOgvCX7uodDrMN', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('15', '1', '05', 'n1TL9WKxYTu0turYopqkvbbKZLUhdk16', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('16', '1', '06', 'f2uWthe8m5shtZku8SEEP7vNyWiVLQxz', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('17', '1', '07', '1pTmeUd8Lr3w8DSoG2ZGeNOEeIfSiqcu', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('18', '1', '08', 'f8iTy3B96do9rnhfg0ceRbxE52utzQW1', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('19', '1', '09', 'P4m4DP5POgoT0T42ZUfq0Ceh9Lrh8prm', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT IGNORE INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('20', '1', '10', 'brEtR2J1PwNL1sjXHFgDfB7e4nMxTtPB', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');

-- Data for `categories`
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('1', 'فطور', 'Breakfast', NULL, '1', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('2', 'كرواسون', 'Croissant', NULL, '2', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('3', 'قهوة مقطرة', 'Brewed Coffee', NULL, '3', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('4', 'مشروبات ساخنة', 'Hot Caffeinated Drinks', NULL, '4', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('5', 'مشروبات باردة', 'Cold Caffeinated Drinks', NULL, '5', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('6', 'ماتشا', 'Matcha', NULL, '6', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('7', 'مشروبات منعشة', 'Chilled & Refreshing', NULL, '7', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('8', 'أساي', 'ACAI', NULL, '8', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('9', 'حلويات', 'Desserts', NULL, '9', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('10', 'برجر', 'Burger', NULL, '10', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT IGNORE INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('11', 'باستا', 'Pasta', NULL, '11', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');

-- Data for `option_groups`
INSERT IGNORE INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('1', 'نوع حبوب البن', 'Beans Selection', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('2', 'درجة الحرارة', 'Temperature', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('3', 'نوع الحليب', 'Milk Choice', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('4', 'إضافات ونكهات', 'Extra Shots & Flavors', '0', '1', '0', '5', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('5', 'إضافات وتوبينج', 'Extra Toppings', '0', '1', '0', '6', '2026-11-12 08:45:32', '2026-11-12 08:45:32');

-- Data for `products`
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('1', '1', 'بلاليط', 'Balaleet', NULL, NULL, '35', 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '1', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('2', '1', 'فطور سجنتشر', 'Signature Breakfast', NULL, NULL, '45', 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '2', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('3', '2', 'كرواسون زبدة', 'Butter Croissant', NULL, NULL, '15', 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '3', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('4', '3', 'ايروبريس', 'Aeropress', NULL, NULL, '22', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '4', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('5', '3', 'كيمكس', 'Chemex', NULL, NULL, '25', 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '5', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('6', '3', 'كولد برو', 'Cold Brew', NULL, NULL, '28', 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '6', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('7', '3', 'في 60', 'V60', NULL, NULL, '25', 'https://images.unsplash.com/photo-1498603536246-15572faa67a6?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '7', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('8', '4', 'كابتشينو', 'Cappuccino', NULL, NULL, '20', 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '8', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('9', '4', 'فلات وايت', 'Flat White', NULL, NULL, '22', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '9', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('10', '4', 'سبانش ساخن', 'Spanish Hot', NULL, NULL, '24', 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '10', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('11', '5', 'سبانش بارد', 'Spanish Cold', NULL, NULL, '26', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '11', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('12', '5', 'بستاشيو لاتيه', 'Pistachio Latte', NULL, NULL, '28', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '12', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('13', '6', 'ماتشا لاتيه', 'Matcha Latte', NULL, NULL, '28', 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '13', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('14', '7', 'عصير برتقال طازج', 'Fresh Orange Juice', NULL, NULL, '20', 'https://images.unsplash.com/photo-1613478223719-2ab802602423?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '14', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('15', '8', 'أساي بول', 'Acai Bowl', NULL, NULL, '42', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '15', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('16', '9', 'بودنغ الشوكولاتة', 'Chocolate Pudding', NULL, NULL, '32', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '16', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('17', '10', 'برجر كلاسيك', 'Classic Burger', NULL, NULL, '45', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '17', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('18', '11', 'باستا ترافل', 'Truffle Pasta', NULL, NULL, '55', 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '18', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT IGNORE INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('19', '3', 'مظممم', 'ممم', NULL, NULL, '90', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop', '1', '0', '0', NULL, '19', '2026-08-25 10:50:09', '2026-08-25 10:50:09');

-- Data for `options`
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('1', '1', 'إثيوبي - يرقاتشيفي (نوتات زهرية وفاكهية)', 'Ethiopian Yirgacheffe (Floral & Fruity)', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('2', '1', 'كولومبي سوبريمو (شوكولاتة ومكسرات)', 'Colombian Supremo (Chocolate & Nutty)', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('3', '1', 'كوستاريكا تارازو (حمضية متوازنة وعسل)', 'Costa Rica Tarrazu (Balanced & Honey)', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('4', '1', 'خلطة نمبر 8 الخاصة', 'Number 8 Signature House Blend', '2', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('5', '1', 'منزوع الكافيين (Decaf)', 'Decaf Colombian', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('6', '2', 'ساخن (Hot)', 'Hot', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('7', '2', 'بارد مع ثلج (Iced)', 'Iced', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('8', '2', 'قليل الثلج (Less Ice)', 'Less Ice', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('9', '3', 'حليب كامل الدسم طازج', 'Fresh Whole Milk', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('10', '3', 'حليب خالي الدسم', 'Skimmed Milk', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('11', '3', 'حليب شوفان عضوي (Oat Milk)', 'Organic Oat Milk', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('12', '3', 'حليب لوز (Almond Milk)', 'Almond Milk', '5', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('13', '3', 'حليب جوز الهند (Coconut Milk)', 'Coconut Milk', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('14', '4', 'شوت إسبريسو إضافي', 'Extra Espresso Shot', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('15', '4', 'سيرب فانيلا', 'Vanilla Syrup', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('16', '4', 'سيرب كراميل مملح', 'Salted Caramel Syrup', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('17', '4', 'صوص شوكولاتة بلجيكية', 'Belgian Chocolate Drizzle', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('18', '5', 'جرانولا مقرمشة إضافية', 'Extra Crunchy Granola', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('19', '5', 'زبدة فول سوداني عضوية', 'Organic Peanut Butter', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('20', '5', 'توت مشكل وفراولة طازجة', 'Fresh Mixed Berries', '5', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('21', '5', 'شرائح موز طازجة', 'Fresh Banana Slices', '2', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('22', '5', 'بذور الشيا ورقائق جوز الهند', 'Chia Seeds & Coconut Flakes', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT IGNORE INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('23', '5', 'عسل طبيعي', 'Pure Natural Honey', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');

-- Data for `product_option_group`
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('1', '1', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('2', '1', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('3', '2', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('4', '2', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('5', '3', '5', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('6', '4', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('7', '4', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('8', '5', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('9', '5', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('10', '6', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('11', '6', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('12', '7', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('13', '7', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('14', '8', '3', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('15', '8', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('16', '8', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('17', '8', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('18', '9', '3', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('19', '9', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('20', '9', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('21', '9', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('22', '10', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('23', '10', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('24', '11', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('25', '11', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('26', '12', '3', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('27', '12', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('28', '12', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('29', '12', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('30', '13', '3', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('31', '13', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('32', '13', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('33', '13', '1', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('34', '14', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('35', '14', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('36', '15', '5', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('37', '16', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('38', '16', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('39', '17', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('40', '17', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('41', '18', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('42', '18', '4', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('43', '19', '2', NULL, NULL);
INSERT IGNORE INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('44', '19', '4', NULL, NULL);

-- Data for `offers`
INSERT IGNORE INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('1', 'خصم 20% على القهوة المختصة', '20% Off Specialty Coffee', 'استمتع بخصم 20% على جميع مشروبات الإسبريسو والفلتر طوال اليوم', 'Enjoy 20% off all espresso and handcrafted brews all day', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop', 'N8OFF20', 'percentage', '20', '0', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');
INSERT IGNORE INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('2', 'خصم 15 درهم لطلبات السيارة', '15 AED Off Car Pickup', 'كوبون خاص لخدمة استلام قهوتك من السيارة أمام الكافيه', 'Special discount on all curbside car pickup orders', 'https://images.unsplash.com/photo-1520050206274-a1ae44613e6d?q=80&w=600&auto=format&fit=crop', 'CAR15', 'fixed', '15', '40', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');
INSERT IGNORE INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('3', 'عرض بوكس القهوة والحلى', 'Dessert & Coffee Bundle', 'خصم 10 دراهم عند طلب الحلى مع قهوتك المفضلة', '10 AED discount when ordering dessert with coffee', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=600&auto=format&fit=crop', 'SWEET10', 'fixed', '10', '30', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');

SET FOREIGN_KEY_CHECKS = 1;
