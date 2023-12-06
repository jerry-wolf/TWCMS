# 用户表，可根据 uid 范围进行分区
DROP TABLE IF EXISTS pre_user;
CREATE TABLE pre_user (
  `uid` int unsigned NOT NULL AUTO_INCREMENT,		# 用户ID
  `username` char(16) NOT NULL DEFAULT '',		# 用户名
  `password` char(32) NOT NULL DEFAULT '',		# 密码	md5(md5() + salt)
  `salt` char(16) NOT NULL DEFAULT '',			# 随机干扰字符，用来混淆密码
  `groupid` smallint unsigned NOT NULL DEFAULT '0',	# 用户组
  `email` char(40) NOT NULL DEFAULT '',			# EMAIL
  `homepage` char(40) NOT NULL DEFAULT '',		# 主页的URL（外链）
  `intro` text NOT NULL,					# 个人介绍
  `regip` varbinary(16) NOT NULL DEFAULT '0',			# 注册IP
  `regdate` int unsigned NOT NULL DEFAULT '0',	# 注册日期
  `loginip` varbinary(16) NOT NULL DEFAULT '0',			# 登录IP
  `logindate` int unsigned NOT NULL DEFAULT '0',	# 登录日期
  `lastip` varbinary(16) NOT NULL DEFAULT '0',			# 上次登录IP
  `lastdate` int unsigned NOT NULL DEFAULT '0',	# 上次登录日期
  `contents` int unsigned NOT NULL DEFAULT '0',	# 内容数
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `logins` int unsigned NOT NULL DEFAULT '0',		# 登录数
  PRIMARY KEY (uid),
  UNIQUE KEY username(username),
  KEY email(email)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 后台管理用户组表
DROP TABLE IF EXISTS pre_user_group;
CREATE TABLE pre_user_group (
  `groupid` smallint unsigned NOT NULL AUTO_INCREMENT,		# 用户组ID
  `groupname` char(20) NOT NULL DEFAULT '',			# 用户组名
  `system` tinyint unsigned NOT NULL DEFAULT '0',		# 是否由系统定义 (1为系统定义，0为自定义)
  `purviews` text NOT NULL,					# 后台权限 (为空时不限制)
  PRIMARY KEY (groupid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 分类栏目表
DROP TABLE IF EXISTS pre_category;
CREATE TABLE pre_category (
  `cid` smallint unsigned NOT NULL AUTO_INCREMENT,	# 分类ID
  `mid` tinyint unsigned NOT NULL DEFAULT '0',		# 内容模型ID
  `type` tinyint unsigned NOT NULL DEFAULT '0',	# 分类类型 (0为列表，1为频道)
  `upid` int NOT NULL DEFAULT '0',			# 上级ID
  `name` char(30) NOT NULL DEFAULT '',			# 分类名称
  `alias` char(50) NOT NULL DEFAULT '',			# 唯一别名 (必填，只能是英文、数字、下划线，并且不超过50个字符，用于伪静态)
  `intro` char(255) NOT NULL DEFAULT '',			# 分类介绍
  `cate_tpl` char(80) NOT NULL DEFAULT '',		# 分类页模板
  `show_tpl` char(80) NOT NULL DEFAULT '',		# 内容页模板
  `count` int unsigned NOT NULL DEFAULT '0',		# 内容数
  `orderby` smallint NOT NULL DEFAULT '0',		# 排序
  `seo_title` char(80) NOT NULL DEFAULT '',		# SEO标题
  `seo_keywords` char(80) NOT NULL DEFAULT '',		# SEO关键词
  `seo_description` char(150) NOT NULL DEFAULT '',	# SEO描述
  PRIMARY KEY (cid),
  UNIQUE KEY alias (alias)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 内容模型表
DROP TABLE IF EXISTS pre_models;
CREATE TABLE pre_models (
  `mid` tinyint unsigned NOT NULL AUTO_INCREMENT,	# 模型ID (正常情况，全站不应该超过255个模型)
  `name` char(10) NOT NULL DEFAULT '',			# 模型名称
  `tablename` char(20) NOT NULL DEFAULT '',		# 模型表名 (如: tw_cms_xxx)
  `index_tpl` char(80) NOT NULL DEFAULT '',		# 默认频道页模板
  `cate_tpl` char(80) NOT NULL DEFAULT '',		# 默认列表页模板
  `show_tpl` char(80) NOT NULL DEFAULT '',		# 默认内容页模板
  `system` tinyint unsigned NOT NULL DEFAULT '0',	# 是否由系统定义 (1为系统定义，0为自定义)
  PRIMARY KEY (mid),
  UNIQUE KEY tablename (tablename)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 唯一别名表，用于伪静态 (只储存内容的别名，分类和其他别名放 kv 表)
DROP TABLE IF EXISTS pre_only_alias;
CREATE TABLE pre_only_alias (
  `alias` char(50) NOT NULL,				# 唯一别名 (只能是英文、数字、下划线)
  `mid` tinyint unsigned NOT NULL DEFAULT '0',		# 模型ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY (alias),
  KEY mid_id (mid,id)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 单页表
DROP TABLE IF EXISTS pre_cms_page;
CREATE TABLE pre_cms_page (
  `cid` smallint unsigned NOT NULL,			# 分类ID
  `content` mediumtext NOT NULL,				# 单页内容
  PRIMARY KEY (cid)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章表 (可根据 id 范围分区, 审核/定时发布等考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_article;
CREATE TABLE pre_cms_article (
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `id` int unsigned NOT NULL AUTO_INCREMENT,		# 内容ID
  `title` char(80) NOT NULL DEFAULT '',			# 标题
  `color` char(6) NOT NULL DEFAULT '',			# 标题颜色
  `alias` char(50) NOT NULL DEFAULT '',			# 英文别名 (用于伪静态，判断唯一在 only_alias 表，此字段做备份)
  `tags` json NOT NULL DEFAULT '',		# 标签 (json数组)
  `intro` varchar(255) NOT NULL DEFAULT '',		# 内容介绍
  `pic` varchar(255) NOT NULL DEFAULT '',			# 图片地址
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` varchar(20) NOT NULL DEFAULT '',		# 作者
  `source` varchar(150) NOT NULL DEFAULT '',		# 来源
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  `lasttime` int unsigned NOT NULL DEFAULT '0',	# 更新时间
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `iscomment` tinyint unsigned NOT NULL DEFAULT '0',	# 是否禁止评论 (1为禁止 0为允许)
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `imagenum` int unsigned NOT NULL DEFAULT '0',	# 图片附件数
  `filenum` int unsigned NOT NULL DEFAULT '0',	# 文件附件数
  `flags` varchar(20) NOT NULL DEFAULT '',		# 所有属性 (,号分割，用于内容管理显示属性)
  `seo_title` varchar(80) NOT NULL DEFAULT '',		# SEO标题/副标题
  `seo_keywords` varchar(80) NOT NULL DEFAULT '',		# SEO关键词 (没填写时读取标题)
  `seo_description` varchar(255) NOT NULL DEFAULT '',	# SEO描述 (没填写时读取内容摘要)
  PRIMARY KEY  (id),
  KEY cid_id (cid,id),
  KEY cid_dateline (cid,dateline)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章数据表 (大内容字段表，可根据 id 范围分区)
DROP TABLE IF EXISTS pre_cms_article_data;
CREATE TABLE pre_cms_article_data (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `content` mediumtext NOT NULL,				# 内容
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章属性标记表
DROP TABLE IF EXISTS pre_cms_article_flag;
CREATE TABLE pre_cms_article_flag (
  `flag` tinyint unsigned NOT NULL DEFAULT '0',	# 属性标记
  `cid` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (flag,id),
  KEY flag_cid (flag,cid,id),
  KEY id (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章附件表
DROP TABLE IF EXISTS pre_cms_article_attach;
CREATE TABLE pre_cms_article_attach (
  `aid` int unsigned NOT NULL AUTO_INCREMENT,		# 附件ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `filename` char(80) NOT NULL DEFAULT '',		# 文件原名
  `filetype` char(10) NOT NULL DEFAULT '',		# 文件后缀
  `filesize` int unsigned NOT NULL DEFAULT '0',	# 文件大小
  `filepath` char(150) NOT NULL DEFAULT '',		# 文件路径
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 上传时间
  `downloads` int unsigned NOT NULL DEFAULT '0',	# 下载次数
  `isimage` tinyint unsigned NOT NULL DEFAULT '0',	# 是否是图片 (1为图片，0为文件)
  PRIMARY KEY (aid),
  KEY id (id, aid),
  KEY uid (uid, aid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章查看数表，用来分离主表的写压力
DROP TABLE IF EXISTS pre_cms_article_views;
CREATE TABLE pre_cms_article_views (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `views` int unsigned NOT NULL DEFAULT '0',		# 查看次数
  PRIMARY KEY  (id),
  KEY cid (cid,views),
  KEY views (views)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章评论排序表，用来减小主表索引 (有评论时才写入)
DROP TABLE IF EXISTS pre_cms_article_comment_sort;
CREATE TABLE pre_cms_article_comment_sort (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `lastdate` int unsigned NOT NULL DEFAULT '0',	# 回复时间
  PRIMARY KEY  (id),
  KEY cid_comments (cid,comments),
  KEY comments (comments),
  KEY cid_lastdate (cid,lastdate),
  KEY lastdate (lastdate)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章评论表 (审核机制考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_article_comment;
CREATE TABLE pre_cms_article_comment (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `commentid` int unsigned NOT NULL AUTO_INCREMENT,	# 评论ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` char(30) NOT NULL DEFAULT '',			# 作者，可能不等于 username
  `content` text NOT NULL,				# 评论内容
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  PRIMARY KEY  (commentid),
  KEY id (id,commentid),
  KEY ip (ip,commentid)	# 用来做防灌水插件
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章标签表
DROP TABLE IF EXISTS pre_cms_article_tag;
CREATE TABLE pre_cms_article_tag (
  `tagid` int unsigned NOT NULL AUTO_INCREMENT,	# tagID
  `name` char(10) NOT NULL DEFAULT '',			# tag名称
  `count` int unsigned NOT NULL DEFAULT '0',		# tag数量
  `content` text NOT NULL,				# tag内容
  PRIMARY KEY  (tagid),
  UNIQUE KEY name (name),
  KEY count (count)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 文章标签数据表
DROP TABLE IF EXISTS pre_cms_article_tag_data;
CREATE TABLE pre_cms_article_tag_data (
  `tagid` int unsigned NOT NULL,			# tagID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (tagid,id)				# 排序要用id
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品表 (可根据 id 范围分区, 审核/定时发布等考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_product;
CREATE TABLE pre_cms_product (
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `id` int unsigned NOT NULL AUTO_INCREMENT,		# 内容ID
  `title` char(80) NOT NULL DEFAULT '',			# 标题
  `color` char(6) NOT NULL DEFAULT '',			# 标题颜色
  `alias` char(50) NOT NULL DEFAULT '',			# 英文别名 (用于伪静态，判断唯一在 only_alias 表，此字段做备份)
  `tags` json NOT NULL DEFAULT '',		# 标签 (json数组)
  `intro` varchar(255) NOT NULL DEFAULT '',		# 内容介绍
  `pic` varchar(255) NOT NULL DEFAULT '',			# 图片地址
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` varchar(20) NOT NULL DEFAULT '',		# 作者
  `source` varchar(150) NOT NULL DEFAULT '',		# 来源
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  `lasttime` int unsigned NOT NULL DEFAULT '0',	# 更新时间
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `iscomment` tinyint unsigned NOT NULL DEFAULT '0',	# 是否禁止评论 (1为禁止 0为允许)
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `imagenum` int unsigned NOT NULL DEFAULT '0',	# 图片附件数 (编辑器中的图片+图集)
  `filenum` int unsigned NOT NULL DEFAULT '0',	# 文件附件数
  `flags` varchar(20) NOT NULL DEFAULT '',		# 所有属性 (,号分割，用于内容管理显示属性)
  `seo_title` varchar(80) NOT NULL DEFAULT '',		# SEO标题/副标题
  `seo_keywords` varchar(80) NOT NULL DEFAULT '',		# SEO关键词 (没填写时读取标题)
  `seo_description` varchar(255) NOT NULL DEFAULT '',	# SEO描述 (没填写时读取内容摘要)
  PRIMARY KEY  (id),
  KEY cid_id (cid,id),
  KEY cid_dateline (cid,dateline)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品数据表 (大内容字段表，可根据 id 范围分区)
DROP TABLE IF EXISTS pre_cms_product_data;
CREATE TABLE pre_cms_product_data (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `images` mediumtext NOT NULL,				# 图集 (json储存)
  `content` mediumtext NOT NULL,				# 内容
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品属性标记表
DROP TABLE IF EXISTS pre_cms_product_flag;
CREATE TABLE pre_cms_product_flag (
  `flag` tinyint unsigned NOT NULL DEFAULT '0',	# 属性标记
  `cid` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (flag,id),
  KEY flag_cid (flag,cid,id),
  KEY id (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品附件表
DROP TABLE IF EXISTS pre_cms_product_attach;
CREATE TABLE pre_cms_product_attach (
  `aid` int unsigned NOT NULL AUTO_INCREMENT,		# 附件ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `filename` char(80) NOT NULL DEFAULT '',		# 文件原名
  `filetype` char(10) NOT NULL DEFAULT '',		# 文件后缀
  `filesize` int unsigned NOT NULL DEFAULT '0',	# 文件大小
  `filepath` char(150) NOT NULL DEFAULT '',		# 文件路径
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 上传时间
  `downloads` int unsigned NOT NULL DEFAULT '0',	# 下载次数
  `isimage` tinyint unsigned NOT NULL DEFAULT '0',	# 是否是图片 (1为图片，0为文件)
  PRIMARY KEY (aid),
  KEY id (id, aid),
  KEY uid (uid, aid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品查看数表，用来分离主表的写压力
DROP TABLE IF EXISTS pre_cms_product_views;
CREATE TABLE pre_cms_product_views (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `views` int unsigned NOT NULL DEFAULT '0',		# 查看次数
  PRIMARY KEY  (id),
  KEY cid (cid,views),
  KEY views (views)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品评论排序表，用来减小主表索引 (有评论时才写入)
DROP TABLE IF EXISTS pre_cms_product_comment_sort;
CREATE TABLE pre_cms_product_comment_sort (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `lastdate` int unsigned NOT NULL DEFAULT '0',	# 回复时间
  PRIMARY KEY  (id),
  KEY cid_comments (cid,comments),
  KEY comments (comments),
  KEY cid_lastdate (cid,lastdate),
  KEY lastdate (lastdate)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品评论表 (审核机制考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_product_comment;
CREATE TABLE pre_cms_product_comment (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `commentid` int unsigned NOT NULL AUTO_INCREMENT,	# 评论ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` char(30) NOT NULL DEFAULT '',			# 作者，可能不等于 username
  `content` text NOT NULL,				# 评论内容
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  PRIMARY KEY  (commentid),
  KEY id (id,commentid),
  KEY ip (ip,commentid)	# 用来做防灌水插件
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品标签表
DROP TABLE IF EXISTS pre_cms_product_tag;
CREATE TABLE pre_cms_product_tag (
  `tagid` int unsigned NOT NULL AUTO_INCREMENT,	# tagID
  `name` char(10) NOT NULL DEFAULT '',			# tag名称
  `count` int unsigned NOT NULL DEFAULT '0',		# tag数量
  `content` text NOT NULL,				# tag内容
  PRIMARY KEY  (tagid),
  UNIQUE KEY name (name),
  KEY count (count)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 产品标签数据表
DROP TABLE IF EXISTS pre_cms_product_tag_data;
CREATE TABLE pre_cms_product_tag_data (
  `tagid` int unsigned NOT NULL,			# tagID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (tagid,id)				# 排序要用id
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集表 (可根据 id 范围分区, 审核/定时发布等考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_photo;
CREATE TABLE pre_cms_photo (
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `id` int unsigned NOT NULL AUTO_INCREMENT,		# 内容ID
  `title` char(80) NOT NULL DEFAULT '',			# 标题
  `color` char(6) NOT NULL DEFAULT '',			# 标题颜色
  `alias` char(50) NOT NULL DEFAULT '',			# 英文别名 (用于伪静态，判断唯一在 only_alias 表，此字段做备份)
  `tags` json NOT NULL DEFAULT '',		# 标签 (json数组)
  `intro` varchar(255) NOT NULL DEFAULT '',		# 内容介绍
  `pic` varchar(255) NOT NULL DEFAULT '',			# 图片地址
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` varchar(20) NOT NULL DEFAULT '',		# 作者
  `source` varchar(150) NOT NULL DEFAULT '',		# 来源
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  `lasttime` int unsigned NOT NULL DEFAULT '0',	# 更新时间
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `iscomment` tinyint unsigned NOT NULL DEFAULT '0',	# 是否禁止评论 (1为禁止 0为允许)
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `imagenum` int unsigned NOT NULL DEFAULT '0',	# 图片附件数 (编辑器中的图片+图集)
  `filenum` int unsigned NOT NULL DEFAULT '0',	# 文件附件数
  `flags` varchar(20) NOT NULL DEFAULT '',		# 所有属性 (,号分割，用于内容管理显示属性)
  `seo_title` varchar(80) NOT NULL DEFAULT '',		# SEO标题/副标题
  `seo_keywords` varchar(80) NOT NULL DEFAULT '',		# SEO关键词 (没填写时读取标题)
  `seo_description` varchar(255) NOT NULL DEFAULT '',	# SEO描述 (没填写时读取内容摘要)
  PRIMARY KEY  (id),
  KEY cid_id (cid,id),
  KEY cid_dateline (cid,dateline)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集数据表 (大内容字段表，可根据 id 范围分区)
DROP TABLE IF EXISTS pre_cms_photo_data;
CREATE TABLE pre_cms_photo_data (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `images` mediumtext NOT NULL,				# 图集 (json储存)
  `content` mediumtext NOT NULL,				# 内容
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集属性标记表
DROP TABLE IF EXISTS pre_cms_photo_flag;
CREATE TABLE pre_cms_photo_flag (
  `flag` tinyint unsigned NOT NULL DEFAULT '0',	# 属性标记
  `cid` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (flag,id),
  KEY flag_cid (flag,cid,id),
  KEY id (id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集附件表
DROP TABLE IF EXISTS pre_cms_photo_attach;
CREATE TABLE pre_cms_photo_attach (
  `aid` int unsigned NOT NULL AUTO_INCREMENT,		# 附件ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `filename` char(80) NOT NULL DEFAULT '',		# 文件原名
  `filetype` char(10) NOT NULL DEFAULT '',		# 文件后缀
  `filesize` int unsigned NOT NULL DEFAULT '0',	# 文件大小
  `filepath` char(150) NOT NULL DEFAULT '',		# 文件路径
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 上传时间
  `downloads` int unsigned NOT NULL DEFAULT '0',	# 下载次数
  `isimage` tinyint unsigned NOT NULL DEFAULT '0',	# 是否是图片 (1为图片，0为文件)
  PRIMARY KEY (aid),
  KEY id (id, aid),
  KEY uid (uid, aid)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集查看数表，用来分离主表的写压力
DROP TABLE IF EXISTS pre_cms_photo_views;
CREATE TABLE pre_cms_photo_views (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `views` int unsigned NOT NULL DEFAULT '0',		# 查看次数
  PRIMARY KEY  (id),
  KEY cid (cid,views),
  KEY views (views)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集评论排序表，用来减小主表索引 (有评论时才写入)
DROP TABLE IF EXISTS pre_cms_photo_comment_sort;
CREATE TABLE pre_cms_photo_comment_sort (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `cid` smallint unsigned NOT NULL DEFAULT '0',	# 分类ID
  `comments` int unsigned NOT NULL DEFAULT '0',	# 评论数
  `lastdate` int unsigned NOT NULL DEFAULT '0',	# 回复时间
  PRIMARY KEY  (id),
  KEY cid_comments (cid,comments),
  KEY comments (comments),
  KEY cid_lastdate (cid,lastdate),
  KEY lastdate (lastdate)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集评论表 (审核机制考虑单独设计一张表)
DROP TABLE IF EXISTS pre_cms_photo_comment;
CREATE TABLE pre_cms_photo_comment (
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  `commentid` int unsigned NOT NULL AUTO_INCREMENT,	# 评论ID
  `uid` int unsigned NOT NULL DEFAULT '0',		# 用户ID
  `author` char(30) NOT NULL DEFAULT '',			# 作者，可能不等于 username
  `content` text NOT NULL,				# 评论内容
  `ip` varbinary(16) NOT NULL DEFAULT '0',			# IP
  `dateline` int unsigned NOT NULL DEFAULT '0',	# 发表时间
  PRIMARY KEY  (commentid),
  KEY id (id,commentid),
  KEY ip (ip,commentid)	# 用来做防灌水插件
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集标签表
DROP TABLE IF EXISTS pre_cms_photo_tag;
CREATE TABLE pre_cms_photo_tag (
  `tagid` int unsigned NOT NULL AUTO_INCREMENT,	# tagID
  `name` char(10) NOT NULL DEFAULT '',			# tag名称
  `count` int unsigned NOT NULL DEFAULT '0',		# tag数量
  `content` text NOT NULL,				# tag内容
  PRIMARY KEY  (tagid),
  UNIQUE KEY name (name),
  KEY count (count)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 图集标签数据表
DROP TABLE IF EXISTS pre_cms_photo_tag_data;
CREATE TABLE pre_cms_photo_tag_data (
  `tagid` int unsigned NOT NULL,			# tagID
  `id` int unsigned NOT NULL DEFAULT '0',		# 内容ID
  PRIMARY KEY  (tagid,id)				# 排序要用id
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 持久保存的 key value 数据 (包括设置信息)
DROP TABLE IF EXISTS pre_kv;
CREATE TABLE pre_kv (
  `k` char(32) NOT NULL DEFAULT '',			# 键名
  `v` text NOT NULL DEFAULT '',				# 数据
  `expiry` int unsigned NOT NULL DEFAULT '0',		# 过期时间
  PRIMARY KEY(k)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 缓存表
DROP TABLE IF EXISTS pre_runtime;
CREATE TABLE pre_runtime (
  `k` char(32) NOT NULL DEFAULT '',			# 键名
  `v` text NOT NULL DEFAULT '',				# 数据
  `expiry` int unsigned NOT NULL DEFAULT '0',		# 过期时间
  PRIMARY KEY(k)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 记录其它表的总行数
DROP TABLE IF EXISTS pre_framework_count;
CREATE TABLE pre_framework_count (
  `name` char(32) NOT NULL DEFAULT '',			# 表名
  `count` int unsigned NOT NULL DEFAULT '0',		# 总行数
  PRIMARY KEY (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

# 记录其它表的最大ID
DROP TABLE IF EXISTS pre_framework_maxid;
CREATE TABLE pre_framework_maxid (
  `name` char(32) NOT NULL DEFAULT '',			# 表名
  `maxid` int unsigned NOT NULL DEFAULT '0',		# 最大ID
  PRIMARY KEY (name)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
