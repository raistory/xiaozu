# 二手交易平台 (Minzu Secondhand)

> 基于 Java Servlet + JSP + MySQL 构建的校园二手商品交易平台，支持用户注册审核、商品发布与管理、订单交易、出价议价、站内消息、商品评论、纠纷处理、举报、通知等完整功能。

---

## 📌 项目简介

本平台面向校园用户，提供一个安全、便捷的二手物品流通渠道。用户注册后需经管理员审核方可发布商品，支持买卖双方站内沟通、出价议价、订单确认、交易完成后互评等完整交易流程。管理员可对用户、商品、纠纷及举报进行全面管理，保障平台交易环境健康有序。

---

## ✨ 功能特性

### 用户端

- **用户注册 / 登录 / 退出**：支持账号注册，注册后需等待管理员审核激活
- **个人主页**：查看和编辑个人资料、头像上传，展示在售商品数、已售数、收藏数等统计
- **卖家主页**：查看卖家信息及其发布的所有在售商品
- **商品列表浏览**：查看平台上所有在售二手商品，支持关键词搜索、分类筛选、价格区间、热门标签、排序（最新/价格/浏览量）
- **商品详情查看**：查看商品的详细信息、图片灯箱预览、卖家联系方式
- **商品评论**：在商品详情页留言评论，支持楼中楼回复
- **发布商品**：审核通过的用户可发布二手商品（含多图上传、标签、成色、原价等）
- **编辑 / 删除商品**：修改或移除已发布的商品
- **我的商品**：查看自己发布的所有商品列表
- **收藏功能**：商品列表页及详情页均可一键收藏/取消收藏（AJAX 无刷新），个人主页显示收藏统计
- **出价议价**：买家可对商品出价，卖家可接受或拒绝；支持我的出价/收到的出价双视图
- **订单系统**：下单购买、查看订单状态（待确认、已完成等）、确认收货
- **纠纷处理**：对订单发起纠纷，管理员裁决后自动退款或放款
- **站内消息**：与买家/卖家进行私信沟通，支持会话列表与聊天界面
- **商品评价**：交易完成后对商品进行评分和文字评价，查看历史评价
- **举报功能**：对违规商品或用户进行举报
- **消息通知**：接收系统通知（审核结果、订单状态变更、出价通知等）
- **取货地点**：查看平台预设的校园取货地点信息
- **校园专区**：毕业季等主题专区，按标签聚合展示商品

### 管理员端

- **管理员面板**：总览平台数据（图表统计）
- **用户审核**：查看待审核用户列表，执行通过或拒绝操作
- **用户管理**：搜索用户、封禁/解封用户账号
- **商品审核**：审核用户发布的商品是否合规
- **举报管理**：查看并处理用户举报记录
- **纠纷管理**：查看所有待处理纠纷，裁决退款或释放货款

---

## 🛠️ 技术栈

| 层次 | 技术 |
|------|------|
| 后端 | Java 21 + Servlet 4.0 |
| 前端 | JSP 2.3 + JSTL 1.2 |
| 数据库 | MySQL 8.x |
| 密码安全 | jBCrypt 0.4（密码哈希） |
| 构建工具 | Maven 3.x |
| 部署容器 | Apache Tomcat 9.0（WAR 包部署） |

---

## 📁 项目结构

```
Seconde-hand-trading-platform/
├── db/
│   ├── database.sql                  # 数据库建表脚本
│   └── seed_products_by_category.sql # 分类商品示例数据
├── src/
│   └── main/
│       ├── java/
│       │   └── com/minzu/
│       │       ├── entity/            # 实体类
│       │       │   ├── User.java
│       │       │   ├── Product.java
│       │       │   ├── Offer.java
│       │       │   ├── Comment.java
│       │       │   ├── Review.java
│       │       │   └── Message.java
│       │       ├── servlet/           # 业务 Servlet
│       │       │   ├── LoginServlet.java / RegisterServlet.java / LogoutServlet.java
│       │       │   ├── IndexServlet.java
│       │       │   ├── ProductListServlet.java / ProductDetailServlet.java
│       │       │   ├── PublishProductServlet.java / EditProductServlet.java / DeleteProductServlet.java
│       │       │   ├── MyProductsServlet.java
│       │       │   ├── FavoriteServlet.java
│       │       │   ├── OfferServlet.java
│       │       │   ├── OrderServlet.java
│       │       │   ├── MessageServlet.java
│       │       │   ├── CommentServlet.java
│       │       │   ├── ReviewServlet.java
│       │       │   ├── ReportServlet.java
│       │       │   ├── DisputeServlet.java
│       │       │   ├── NotificationServlet.java
│       │       │   ├── ProfileServlet.java / SellerProfileServlet.java
│       │       │   ├── PickupLocationServlet.java
│       │       │   ├── ZoneServlet.java
│       │       │   ├── ImageServlet.java
│       │       │   ├── AdminDashboardServlet.java
│       │       │   ├── AdminUserReviewServlet.java / ApproveUserServlet.java / RejectUserServlet.java
│       │       │   ├── AdminUserManageServlet.java
│       │       │   └── AdminProductReviewServlet.java
│       │       ├── filter/            # 过滤器（LoginFilter 登录校验）
│       │       └── util/              # 工具类（DBUtil 数据库连接等）
│       └── webapp/                    # JSP 页面 & 静态资源
│           ├── index.jsp
│           ├── login.jsp / register.jsp
│           ├── product-list.jsp / product-detail.jsp
│           ├── publish-product.jsp / edit-product.jsp
│           ├── my-products.jsp / my-orders.jsp / my-offers.jsp
│           ├── my-favorites.jsp / my-reviews.jsp / my-disputes.jsp
│           ├── messages.jsp / message-chat.jsp
│           ├── notifications.jsp
│           ├── seller-profile.jsp / profile.jsp
│           ├── pickup-locations.jsp
│           ├── zone.jsp
│           ├── review.jsp
│           ├── error.jsp
│           ├── admin-dashboard.jsp
│           ├── admin-user-review.jsp / admin-users.jsp
│           ├── admin-product-review.jsp
│           ├── admin-reports.jsp / admin-disputes.jsp
│           └── WEB-INF/
├── src/test/                         # Servlet 集成测试与 H2 测试库脚本
├── pom.xml
└── README.md
```

---

## 🚀 快速开始

### 环境要求

- JDK 21+
- Apache Tomcat 9.0+
- MySQL 8.x
- Maven 3.6+

### 部署步骤

**1. 克隆仓库**

```bash
git clone https://github.com/gandipeng/Seconde-hand-trading-platform.git
cd Seconde-hand-trading-platform
```

**2. 初始化数据库**

在 MySQL 中创建数据库并导入 `db/` 目录下的初始化 SQL：

```sql
CREATE DATABASE minzu_secondhand DEFAULT CHARACTER SET utf8mb4;
USE minzu_secondhand;
SOURCE db/database.sql;
SOURCE db/seed_products_by_category.sql;
```

**3. 配置数据库连接**

修改 `src/main/java/com/minzu/util/DBUtil.java`，填写数据库连接信息：

```java
private static final String URL = "jdbc:mysql://localhost:3306/minzu_secondhand?useSSL=false&serverTimezone=Asia/Shanghai";
private static final String USERNAME = "your_username";
private static final String PASSWORD = "your_password";
```

> ⚠️ **安全提示**：生产部署时建议将数据库凭据迁移至 Tomcat 的 `context.xml` 或通过环境变量注入，避免敏感信息提交到版本库。

**4. Maven 打包**

```bash
mvn clean package
```

**5. 部署到 Tomcat**

将生成的 `target/minzu-secondhand.war` 复制到 Tomcat 9.0 的 `webapps/` 目录，启动 Tomcat 后访问：

```
http://localhost:8080/minzu-secondhand/
```

---

## 🔑 默认账户

| 角色 | 说明 |
|------|------|
| 管理员 | 需在数据库中手动插入管理员账户（`role_code` 字段设为 `ADMIN`） |
| 普通用户 | 注册后由管理员审核激活 |

手动创建管理员账户示例（密码须为 BCrypt 哈希值）：

```sql
-- 以下 password_hash 需替换为实际 BCrypt 哈希，可用在线工具或程序生成
INSERT INTO users (student_or_staff_no, real_name, password_hash, role_code, account_status)
VALUES ('admin001', '管理员', '$2a$12$xxxxx...', 'ADMIN', 'ACTIVE');
```

---

## 🔒 安全说明

- **密码存储**：所有用户密码均使用 [jBCrypt](https://github.com/jeremyh/jBCrypt) 进行哈希处理，不以明文存储
- **SQL 注入防护**：数据库操作全部使用 `PreparedStatement`，防止 SQL 注入攻击
- **登录校验**：通过 `LoginFilter` 对受保护页面进行统一权限校验
- **图片上传**：对上传文件类型及大小进行校验（仅允许 jpg/png/gif/webp，限制最大 5MB）

---

## 📄 许可证

本项目为学习用途开发，暂未设置开源许可证。如需使用，请联系项目作者。

