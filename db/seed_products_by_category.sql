-- Batch seed products by category.
-- Run after db/database.sql. It is safe to run repeatedly; rows tagged seed-batch are replaced.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

INSERT INTO categories (category_name, sort_no, is_enabled)
VALUES
  ('教材书籍', 10, 1),
  ('数码电子', 20, 1),
  ('生活用品', 30, 1),
  ('运动户外', 40, 1),
  ('服饰鞋包', 50, 1),
  ('娱乐休闲', 60, 1),
  ('票券卡券', 70, 1)
ON DUPLICATE KEY UPDATE sort_no = VALUES(sort_no), is_enabled = VALUES(is_enabled);

INSERT INTO pickup_points (point_name, campus_area, address_detail, open_time_desc, is_enabled)
SELECT '北区宿舍门口', '北区', '北区宿舍楼下自提柜旁', '18:00-21:30', 1
WHERE NOT EXISTS (SELECT 1 FROM pickup_points WHERE point_name = '北区宿舍门口');

INSERT INTO users (
  student_or_staff_no, real_name, nickname, password_hash, gender, college,
  campus_identity_status, role_code, account_status
)
VALUES (
  'seed_seller_001', '批量上架卖家', '校园好物铺',
  '$2a$12$w8h9Eg4z2ixnJ4utkvmBDe5nK48SL6fBkpjJn75i2IN2D2GgHNCkK',
  'UNKNOWN', '示例学院', 'VERIFIED', 'STUDENT', 'ACTIVE'
)
ON DUPLICATE KEY UPDATE
  real_name = VALUES(real_name),
  nickname = VALUES(nickname),
  account_status = 'ACTIVE',
  campus_identity_status = 'VERIFIED';

SET @seed_seller_id := (SELECT user_id FROM users WHERE student_or_staff_no = 'seed_seller_001' LIMIT 1);
SET @seed_pickup_id := (SELECT pickup_point_id FROM pickup_points WHERE point_name = '北区宿舍门口' LIMIT 1);

DELETE FROM product_images
WHERE product_id IN (SELECT product_id FROM products WHERE FIND_IN_SET('seed-batch', tags));

DELETE FROM products WHERE FIND_IN_SET('seed-batch', tags);

INSERT INTO products (
  seller_id, category_id, pickup_point_id, title, product_desc, price, original_price,
  condition_level, cover_image_url, image_urls, tags, publish_status,
  is_textbook_zone, is_graduation_zone, view_count, favorite_count,
  published_at, created_at, updated_at, is_deleted
)
SELECT
  @seed_seller_id,
  c.category_id,
  @seed_pickup_id,
  seed.title,
  seed.product_desc,
  seed.price,
  seed.original_price,
  seed.condition_level,
  seed.cover_image_url,
  seed.cover_image_url,
  seed.tags,
  'ON_SALE',
  seed.is_textbook_zone,
  0,
  seed.view_count,
  seed.favorite_count,
  NOW(),
  NOW(),
  NOW(),
  0
FROM (
  SELECT '教材书籍' category_name, '高等数学同济第七版' title, '课堂使用过，重点章节有少量铅笔标注，适合期末复习和补课自学。' product_desc, 18.00 price, 48.00 original_price, 'EIGHTY_NEW' condition_level, 'assets/product-seeds/books-cn.jpg' cover_image_url, 'seed-batch,教材,考研' tags, 1 is_textbook_zone, 36 view_count, 4 favorite_count
  UNION ALL SELECT '教材书籍', '英语四六级真题套装', '近三年真题册，听力二维码可用，附作文模板笔记。', 15.00, 39.00, 'NINETY_NEW', 'assets/product-seeds/books-cn.jpg', 'seed-batch,四六级,真题', 1, 24, 3
  UNION ALL SELECT '教材书籍', '中国民族理论课程教材', '公共课教材，封面完整，适合补教材或备考。', 12.00, 32.00, 'EIGHTY_NEW', 'assets/product-seeds/books-cn.jpg', 'seed-batch,公共课,教材', 1, 18, 2
  UNION ALL SELECT '数码电子', '蓝牙降噪耳机', '续航正常，耳罩干净，配充电线，适合自习室使用。', 89.00, 199.00, 'EIGHTY_NEW', 'assets/product-seeds/digital-cn.jpg', 'seed-batch,耳机,数码', 0, 51, 7
  UNION ALL SELECT '数码电子', '便携机械键盘', '84 键布局，青轴，键帽无明显磨损，带收纳线。', 99.00, 239.00, 'NINETY_NEW', 'assets/product-seeds/digital-cn.jpg', 'seed-batch,键盘,电脑配件', 0, 44, 5
  UNION ALL SELECT '数码电子', '平板电脑保护壳', '适配 10-11 英寸平板，带笔槽，边角无裂痕。', 25.00, 68.00, 'NINETY_NEW', 'assets/product-seeds/digital-cn.jpg', 'seed-batch,平板,保护壳', 0, 20, 2
  UNION ALL SELECT '生活用品', '宿舍小台灯', '三档亮度，USB 供电，适合床上学习。', 22.00, 59.00, 'EIGHTY_NEW', 'assets/product-seeds/home-cn.jpg', 'seed-batch,台灯,宿舍', 0, 33, 4
  UNION ALL SELECT '生活用品', '折叠收纳箱两只', '容量大，宿舍搬家整理好用，边角完好。', 28.00, 70.00, 'EIGHTY_NEW', 'assets/product-seeds/home-cn.jpg', 'seed-batch,收纳,宿舍', 0, 29, 3
  UNION ALL SELECT '生活用品', '迷你电热水壶', '0.8L 容量，烧水正常，适合宿舍公共区使用。', 35.00, 89.00, 'SEVENTY_NEW', 'assets/product-seeds/home-cn.jpg', 'seed-batch,水壶,生活', 0, 25, 2
  UNION ALL SELECT '运动户外', '羽毛球拍单支', '轻量拍，拍线弹性正常，适合日常运动。', 45.00, 129.00, 'EIGHTY_NEW', 'assets/product-seeds/sports-cn.jpg', 'seed-batch,羽毛球,运动', 0, 40, 6
  UNION ALL SELECT '运动户外', '瑜伽垫加厚款', '厚度约 8mm，表面清洁，适合寝室或操场锻炼。', 32.00, 88.00, 'NINETY_NEW', 'assets/product-seeds/sports-cn.jpg', 'seed-batch,瑜伽垫,健身', 0, 19, 2
  UNION ALL SELECT '运动户外', '篮球 7 号球', '手感正常，气密性好，操场约球可用。', 39.00, 99.00, 'EIGHTY_NEW', 'assets/product-seeds/sports-cn.jpg', 'seed-batch,篮球,户外', 0, 37, 5
  UNION ALL SELECT '服饰鞋包', '学院风双肩包', '容量适中，可放 14 寸电脑，肩带完好。', 58.00, 159.00, 'EIGHTY_NEW', 'assets/product-seeds/fashion-cn.jpg', 'seed-batch,书包,通勤', 0, 30, 4
  UNION ALL SELECT '服饰鞋包', '秋季连帽卫衣', 'M 码，洗护良好，颜色百搭。', 49.00, 139.00, 'NINETY_NEW', 'assets/product-seeds/fashion-cn.jpg', 'seed-batch,卫衣,秋装', 0, 26, 3
  UNION ALL SELECT '服饰鞋包', '运动鞋 42 码', '鞋底磨损轻，已清洁，适合日常通勤。', 69.00, 299.00, 'EIGHTY_NEW', 'assets/product-seeds/fashion-cn.jpg', 'seed-batch,鞋子,运动鞋', 0, 34, 5
  UNION ALL SELECT '娱乐休闲', 'Switch 游戏卡带', '热门休闲游戏卡带，读取正常，可现场验卡。', 168.00, 299.00, 'NINETY_NEW', 'assets/product-seeds/leisure-cn.jpg', 'seed-batch,游戏,卡带', 0, 62, 9
  UNION ALL SELECT '娱乐休闲', '桌游狼人杀套装', '卡牌齐全，适合社团活动和宿舍聚会。', 24.00, 69.00, 'EIGHTY_NEW', 'assets/product-seeds/leisure-cn.jpg', 'seed-batch,桌游,聚会', 0, 27, 4
  UNION ALL SELECT '娱乐休闲', '尤克里里入门款', '四弦音准稳定，附简易调音器，适合入门练习。', 88.00, 199.00, 'EIGHTY_NEW', 'assets/product-seeds/leisure-cn.jpg', 'seed-batch,乐器,休闲', 0, 31, 4
  UNION ALL SELECT '票券卡券', '校园咖啡券 5 张', '校内咖啡店通用券，月底前可用，支持当面核验。', 45.00, 60.00, 'NEW', 'assets/product-seeds/tickets-cn.jpg', 'seed-batch,咖啡券,校园', 0, 22, 3
  UNION ALL SELECT '票券卡券', '电影票兑换券', '双人兑换券一张，支持校外影院，具体场次自选。', 52.00, 80.00, 'NEW', 'assets/product-seeds/tickets-cn.jpg', 'seed-batch,电影票,兑换券', 0, 39, 6
  UNION ALL SELECT '票券卡券', '打印店代金券', '校内打印店 30 元代金券，可拆分使用。', 22.00, 30.00, 'NEW', 'assets/product-seeds/tickets-cn.jpg', 'seed-batch,打印,代金券', 0, 16, 2
) seed
JOIN categories c ON c.category_name = seed.category_name;

INSERT INTO product_images (product_id, image_url, sort_order, is_cover, created_at)
SELECT product_id, cover_image_url, 1, 1, NOW()
FROM products
WHERE FIND_IN_SET('seed-batch', tags);

SET FOREIGN_KEY_CHECKS = 1;
