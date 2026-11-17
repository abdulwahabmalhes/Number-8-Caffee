-- ========================================================
-- NUMBER EIGHT SPECIALTY COFFEE - ONE-CLICK RESTORE DATA
-- Safe MySQL Import Script (Clears old data & restores full catalog)
-- ========================================================

SET FOREIGN_KEY_CHECKS = 0;
SET NAMES utf8mb4;

-- --------------------------------------------------------
-- Table: `branches`
-- --------------------------------------------------------
TRUNCATE TABLE `branches`;
INSERT INTO `branches` (`id`, `name_ar`, `name_en`, `location`, `working_hours`, `is_active`, `created_at`, `updated_at`) VALUES ('1', 'فرع الخبيصي', 'Al Khabisi Branch', 'Al Ain', '07:00 AM - 12:00 AM', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');

-- --------------------------------------------------------
-- Table: `tables`
-- --------------------------------------------------------
TRUNCATE TABLE `tables`;
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('11', '1', '01', 'HJK5W7yPkISnIeE4oTmqSr7ieB5eDjco', '1', '2026-08-25 09:18:12', '2026-08-25 09:18:12');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('12', '1', '02', '78Tm6IXjulO2o1rPQxkmYGgrP1DtSGyq', '1', '2026-08-25 13:20:58', '2026-08-25 13:20:58');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('13', '1', '03', '6YLx1hQhuOPdsxT54X2g1uvgRz1zyNjF', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('14', '1', '04', 'mnx7BMQMJinEKj2CMoCOgvCX7uodDrMN', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('15', '1', '05', 'n1TL9WKxYTu0turYopqkvbbKZLUhdk16', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('16', '1', '06', 'f2uWthe8m5shtZku8SEEP7vNyWiVLQxz', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('17', '1', '07', '1pTmeUd8Lr3w8DSoG2ZGeNOEeIfSiqcu', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('18', '1', '08', 'f8iTy3B96do9rnhfg0ceRbxE52utzQW1', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('19', '1', '09', 'P4m4DP5POgoT0T42ZUfq0Ceh9Lrh8prm', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');
INSERT INTO `tables` (`id`, `branch_id`, `table_number`, `qr_token`, `is_active`, `created_at`, `updated_at`) VALUES ('20', '1', '10', 'brEtR2J1PwNL1sjXHFgDfB7e4nMxTtPB', '1', '2026-11-15 16:56:47', '2026-11-15 16:56:47');

-- --------------------------------------------------------
-- Table: `categories`
-- --------------------------------------------------------
TRUNCATE TABLE `categories`;
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('1', 'فطور', 'Breakfast', NULL, '1', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('2', 'كرواسون', 'Croissant', NULL, '2', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('3', 'قهوة مقطرة', 'Brewed Coffee', NULL, '3', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('4', 'مشروبات ساخنة', 'Hot Caffeinated Drinks', NULL, '4', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('5', 'مشروبات باردة', 'Cold Caffeinated Drinks', NULL, '5', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('6', 'ماتشا', 'Matcha', NULL, '6', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('7', 'مشروبات منعشة', 'Chilled & Refreshing', NULL, '7', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('8', 'أساي', 'ACAI', NULL, '8', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('9', 'حلويات', 'Desserts', NULL, '9', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('10', 'برجر', 'Burger', NULL, '10', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');
INSERT INTO `categories` (`id`, `name_ar`, `name_en`, `image`, `sort_order`, `is_active`, `created_at`, `updated_at`) VALUES ('11', 'باستا', 'Pasta', NULL, '11', '1', '2026-08-25 08:06:10', '2026-08-25 08:06:10');

-- --------------------------------------------------------
-- Table: `option_groups`
-- --------------------------------------------------------
TRUNCATE TABLE `option_groups`;
INSERT INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('1', 'نوع حبوب البن', 'Beans Selection', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('2', 'درجة الحرارة', 'Temperature', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('3', 'نوع الحليب', 'Milk Choice', '0', '0', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('4', 'إضافات ونكهات', 'Extra Shots & Flavors', '0', '1', '0', '5', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `option_groups` (`id`, `name_ar`, `name_en`, `is_required`, `is_multiple`, `min_choices`, `max_choices`, `created_at`, `updated_at`) VALUES ('5', 'إضافات وتوبينج', 'Extra Toppings', '0', '1', '0', '6', '2026-11-12 08:45:32', '2026-11-12 08:45:32');

-- --------------------------------------------------------
-- Table: `products`
-- --------------------------------------------------------
TRUNCATE TABLE `products`;
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('1', '1', 'بلاليط', 'Balaleet', NULL, NULL, '35', 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '1', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('2', '1', 'فطور سجنتشر', 'Signature Breakfast', NULL, NULL, '45', 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '2', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('3', '2', 'كرواسون زبدة', 'Butter Croissant', NULL, NULL, '15', 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '3', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('4', '3', 'ايروبريس', 'Aeropress', NULL, NULL, '22', 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '4', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('5', '3', 'كيمكس', 'Chemex', NULL, NULL, '25', 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '5', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('6', '3', 'كولد برو', 'Cold Brew', NULL, NULL, '28', 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '6', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('7', '3', 'في 60', 'V60', NULL, NULL, '25', 'https://images.unsplash.com/photo-1498603536246-15572faa67a6?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '7', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('8', '4', 'كابتشينو', 'Cappuccino', NULL, NULL, '20', 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '8', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('9', '4', 'فلات وايت', 'Flat White', NULL, NULL, '22', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '9', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('10', '4', 'سبانش ساخن', 'Spanish Hot', NULL, NULL, '24', 'https://images.unsplash.com/photo-1517256064527-09c73fc73e38?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '10', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('11', '5', 'سبانش بارد', 'Spanish Cold', NULL, NULL, '26', 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '11', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('12', '5', 'بستاشيو لاتيه', 'Pistachio Latte', NULL, NULL, '28', 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '12', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('13', '6', 'ماتشا لاتيه', 'Matcha Latte', NULL, NULL, '28', 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '13', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('14', '7', 'عصير برتقال طازج', 'Fresh Orange Juice', NULL, NULL, '20', 'https://images.unsplash.com/photo-1613478223719-2ab802602423?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '14', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('15', '8', 'أساي بول', 'Acai Bowl', NULL, NULL, '42', 'https://images.unsplash.com/photo-1590301157890-4810ed352733?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '15', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('16', '9', 'بودنغ الشوكولاتة', 'Chocolate Pudding', NULL, NULL, '32', 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '16', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('17', '10', 'برجر كلاسيك', 'Classic Burger', NULL, NULL, '45', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '17', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('18', '11', 'باستا ترافل', 'Truffle Pasta', NULL, NULL, '55', 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=400&auto=format&fit=crop', '1', '0', '0', '10', '18', '2026-08-25 08:06:10', '2026-11-15 16:56:47');
INSERT INTO `products` (`id`, `category_id`, `name_ar`, `name_en`, `description_ar`, `description_en`, `price`, `image`, `is_available`, `is_bestseller`, `is_new`, `preparation_time`, `sort_order`, `created_at`, `updated_at`) VALUES ('19', '3', 'مظممم', 'ممم', NULL, NULL, '90', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=400&auto=format&fit=crop', '1', '0', '0', NULL, '19', '2026-08-25 10:50:09', '2026-08-25 10:50:09');

-- --------------------------------------------------------
-- Table: `options`
-- --------------------------------------------------------
TRUNCATE TABLE `options`;
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('1', '1', 'إثيوبي - يرقاتشيفي (نوتات زهرية وفاكهية)', 'Ethiopian Yirgacheffe (Floral & Fruity)', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('2', '1', 'كولومبي سوبريمو (شوكولاتة ومكسرات)', 'Colombian Supremo (Chocolate & Nutty)', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('3', '1', 'كوستاريكا تارازو (حمضية متوازنة وعسل)', 'Costa Rica Tarrazu (Balanced & Honey)', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('4', '1', 'خلطة نمبر 8 الخاصة', 'Number 8 Signature House Blend', '2', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('5', '1', 'منزوع الكافيين (Decaf)', 'Decaf Colombian', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('6', '2', 'ساخن (Hot)', 'Hot', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('7', '2', 'بارد مع ثلج (Iced)', 'Iced', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('8', '2', 'قليل الثلج (Less Ice)', 'Less Ice', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('9', '3', 'حليب كامل الدسم طازج', 'Fresh Whole Milk', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('10', '3', 'حليب خالي الدسم', 'Skimmed Milk', '0', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('11', '3', 'حليب شوفان عضوي (Oat Milk)', 'Organic Oat Milk', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('12', '3', 'حليب لوز (Almond Milk)', 'Almond Milk', '5', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('13', '3', 'حليب جوز الهند (Coconut Milk)', 'Coconut Milk', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('14', '4', 'شوت إسبريسو إضافي', 'Extra Espresso Shot', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('15', '4', 'سيرب فانيلا', 'Vanilla Syrup', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('16', '4', 'سيرب كراميل مملح', 'Salted Caramel Syrup', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('17', '4', 'صوص شوكولاتة بلجيكية', 'Belgian Chocolate Drizzle', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('18', '5', 'جرانولا مقرمشة إضافية', 'Extra Crunchy Granola', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('19', '5', 'زبدة فول سوداني عضوية', 'Organic Peanut Butter', '4', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('20', '5', 'توت مشكل وفراولة طازجة', 'Fresh Mixed Berries', '5', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('21', '5', 'شرائح موز طازجة', 'Fresh Banana Slices', '2', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('22', '5', 'بذور الشيا ورقائق جوز الهند', 'Chia Seeds & Coconut Flakes', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');
INSERT INTO `options` (`id`, `option_group_id`, `name_ar`, `name_en`, `additional_price`, `is_available`, `created_at`, `updated_at`) VALUES ('23', '5', 'عسل طبيعي', 'Pure Natural Honey', '3', '1', '2026-11-12 08:45:32', '2026-11-12 08:45:32');

-- --------------------------------------------------------
-- Table: `product_option_group`
-- --------------------------------------------------------
TRUNCATE TABLE `product_option_group`;
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('1', '1', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('2', '1', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('3', '2', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('4', '2', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('5', '3', '5', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('6', '4', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('7', '4', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('8', '5', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('9', '5', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('10', '6', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('11', '6', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('12', '7', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('13', '7', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('14', '8', '3', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('15', '8', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('16', '8', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('17', '8', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('18', '9', '3', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('19', '9', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('20', '9', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('21', '9', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('22', '10', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('23', '10', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('24', '11', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('25', '11', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('26', '12', '3', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('27', '12', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('28', '12', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('29', '12', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('30', '13', '3', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('31', '13', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('32', '13', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('33', '13', '1', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('34', '14', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('35', '14', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('36', '15', '5', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('37', '16', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('38', '16', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('39', '17', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('40', '17', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('41', '18', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('42', '18', '4', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('43', '19', '2', NULL, NULL);
INSERT INTO `product_option_group` (`id`, `product_id`, `option_group_id`, `created_at`, `updated_at`) VALUES ('44', '19', '4', NULL, NULL);

-- --------------------------------------------------------
-- Table: `offers`
-- --------------------------------------------------------
TRUNCATE TABLE `offers`;
INSERT INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('1', 'خصم 20% على القهوة المختصة', '20% Off Specialty Coffee', 'استمتع بخصم 20% على جميع مشروبات الإسبريسو والفلتر طوال اليوم', 'Enjoy 20% off all espresso and handcrafted brews all day', 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=600&auto=format&fit=crop', 'N8OFF20', 'percentage', '20', '0', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');
INSERT INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('2', 'خصم 15 درهم لطلبات السيارة', '15 AED Off Car Pickup', 'كوبون خاص لخدمة استلام قهوتك من السيارة أمام الكافيه', 'Special discount on all curbside car pickup orders', 'https://images.unsplash.com/photo-1520050206274-a1ae44613e6d?q=80&w=600&auto=format&fit=crop', 'CAR15', 'fixed', '15', '40', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');
INSERT INTO `offers` (`id`, `title_ar`, `title_en`, `description_ar`, `description_en`, `image`, `coupon_code`, `discount_type`, `discount_value`, `min_order_amount`, `is_active`, `expires_at`, `created_at`, `updated_at`) VALUES ('3', 'عرض بوكس القهوة والحلى', 'Dessert & Coffee Bundle', 'خصم 10 دراهم عند طلب الحلى مع قهوتك المفضلة', '10 AED discount when ordering dessert with coffee', 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?q=80&w=600&auto=format&fit=crop', 'SWEET10', 'fixed', '10', '30', '1', NULL, '2026-11-12 10:27:15', '2026-11-12 10:27:15');

-- --------------------------------------------------------
-- Table: `users`
-- --------------------------------------------------------
TRUNCATE TABLE `users`;
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('1', 'Admin Number Eight', 'admin@numbereight.ae', '2026-08-25 08:06:09', '$2y$12$DJ0AakREQdzIL1mUNFvo/eaVM/TwT6SMqM8KyIFPaGi1TfYTfThji', NULL, '2026-08-25 08:06:09', '2026-11-12 12:13:49');
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('2', 'Cashier Number Eight', 'cashier@numbereight.ae', '2026-08-25 08:06:10', '$2y$12$v/iX9l0bdXhmsacboDzia.exKawScdZ.vHISyz0fKtbwfPlJUH80G', NULL, '2026-08-25 08:06:10', '2026-11-12 10:07:41');
INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES ('3', 'Admin User', 'admin@numbereight.com', NULL, '$2y$12$mAdflg7vu6cy5sIsmMaqf.ENykzYoS5N5N/6QnoUAcYQUuHORPyAm', NULL, '2026-10-16 07:49:35', '2026-10-16 07:49:35');

-- --------------------------------------------------------
-- Table: `roles`
-- --------------------------------------------------------
TRUNCATE TABLE `roles`;
INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('1', 'Super Admin', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('2', 'Branch Manager', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('3', 'Cashier', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('4', 'Barista', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');
INSERT INTO `roles` (`id`, `name`, `guard_name`, `created_at`, `updated_at`) VALUES ('5', 'Handover', 'web', '2026-08-25 08:06:09', '2026-08-25 08:06:09');

-- --------------------------------------------------------
-- Table: `model_has_roles`
-- --------------------------------------------------------
TRUNCATE TABLE `model_has_roles`;
INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES ('1', 'App\\Models\\User', '1');
INSERT INTO `model_has_roles` (`role_id`, `model_type`, `model_id`) VALUES ('3', 'App\\Models\\User', '2');

SET FOREIGN_KEY_CHECKS = 1;
-- ========================================================
-- RESTORATION COMPLETED SUCCESSFULLY
-- ========================================================
