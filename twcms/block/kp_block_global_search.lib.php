<?php
defined('KONG_PATH') || exit;

/**
 * 搜索页模块 (比较占用资源，大站可使用sphinx做搜索引擎)
 * @param int pagenum 每页显示条数
 * @param int titlenum 标题长度
 * @param int intronum 简介长度
 * @param string dateformat 时间格式
 * @param int maxcount 允许最大内容数(数据库搜索)
 * @return array
 */
function kp_block_global_search($conf) {
	global $run, $keyword;

	// hook kp_block_global_search_before.php

	$pagenum = empty($conf['pagenum']) ? 20 : max(1, (int)$conf['pagenum']);
	$titlenum = isset($conf['titlenum']) ? (int)$conf['titlenum'] : 0;
	$intronum = isset($conf['intronum']) ? (int)$conf['intronum'] : 0;
	$dateformat = empty($conf['dateformat']) ? 'Y-m-d H:i:s' : $conf['dateformat'];

	$mid = max(2, (int)R('mid'));
	$table_arr = &$run->_cfg['table_arr'];
	$table = isset($table_arr[$mid]) ? $table_arr[$mid] : 'article';

	$kw = addslashes($keyword);
	$match = "MATCH (`title`, `intro`) AGAINST ('$kw')";
	$where = [$match];
	$run->cms_content->table = 'cms_'.$table;

	// 初始分页
	$total = $run->cms_content->find_count($where);
	$maxpage = max(1, ceil($total/$pagenum));
	$page = min($maxpage, max(1, intval(R('page'))));
	$pages = pages($page, $maxpage, 'index.php?search-index-mid-'.$mid.'-keyword-'.urlencode($keyword).'-page-{page}'.C('url_suffix'));

	// 读取内容列表
	$list_arr = $run->cms_content->list_arr($where, $match, -1, ($page-1)*$pagenum, $pagenum, $total);
	foreach($list_arr as &$v) {
		$run->cms_content->format($v, $mid, $dateformat, $titlenum, $intronum);
		$v['subject'] = str_ireplace($keyword, '<mark>'.$keyword.'</mark>', $v['subject']);
		$v['intro'] = str_ireplace($keyword, '<mark>'.$keyword.'</mark>', $v['intro']);
	}

	// hook kp_block_global_search_after.php

	return array('total'=> $total, 'pages'=> $pages, 'list'=> $list_arr);
}
