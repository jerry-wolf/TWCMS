<?php
defined('KONG_PATH') || exit;

/**
 * 评论模块 (内容页使用)
 * @param int pagenum 每页显示条数
 * @param int firstnum 首次显示条数 (有利于SEO)
 * @param string dateformat 时间格式
 * @param int humandate 人性化时间显示 默认开启 (开启: 1 关闭: 0)
 * @param int orderway 降序(-1),升序(1)
 * @return array
 */
function kp_block_comment($conf) {
	global $run;

	// hook kp_block_comment_before.php

	$pagenum = empty($conf['pagenum']) ? 20 : max(1, (int)$conf['pagenum']);
	$firstnum = empty($conf['firstnum']) ? $pagenum : max(1, (int)$conf['firstnum']);
	$dateformat = empty($conf['dateformat']) ? 'Y-m-d H:i:s' : $conf['dateformat'];
	$humandate = isset($conf['humandate']) ? ($conf['humandate'] == 1 ? TRUE : FALSE) : TRUE;
	$orderway = isset($conf['orderway']) && $conf['orderway'] == 1 ? 1 : -1;

	$cid = R('cid');	// 前面已经转过整数了，没安全问题
	$id = R('id');

	// 排除单页模型
	if($run->_var['mid'] == 1) return FALSE;

	// 获取评论列表
	$run->cms_content_comment->table = 'cms_'.$run->_var['table'].'_comment';
	$list_arr = $run->cms_content_comment->find_fetch(array('id' => $id), array('commentid' => $orderway), 0, $firstnum);
	foreach($list_arr as &$v) {
		$run->cms_content_comment->format($v, $dateformat, $humandate);
	}
	$end_arr = end($list_arr);
	$commentid = $end_arr['commentid'];
	$orderway = max(0, $orderway);
	$next_url = $run->_cfg['webdir']."index.php?comment-json-cid-$cid-id-$id-commentid-$commentid-orderway-$orderway-pagenum-$pagenum-ajax-1";
	$isnext = count($list_arr) < $firstnum ? 0 : 1;

	// hook kp_block_comment_after.php

	return array('list_arr' => $list_arr, 'next_url' => $next_url, 'isnext' => $isnext);
}
