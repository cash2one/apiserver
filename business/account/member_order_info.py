# -*- coding: utf-8 -*-

"""会员订单信息
"""

import json
from bs4 import BeautifulSoup
import math
from datetime import datetime

from eaglet.decorator import param_required
#from wapi import wapi_utils
from eaglet.core.cache import utils as cache_util
from db.mall import models as mall_models
from db.mall import promotion_models
from db.member import models as member_models
#import resource
from eaglet.core import watchdog
from business import model as business_model
import settings
from business.decorator import cached_context_property

from eaglet.utils.resource_client import Resource

class MemberOrderInfo(business_model.Model):
	"""会员订单信息
	"""
	__slots__ = (
		'history_order_count',
		'not_payed_order_count',
		'not_ship_order_count',
		'shiped_order_count',
		'review_count',
		'finished_count'
	)

	@staticmethod
	@param_required(['webapp_user'])
	def get_for_webapp_user(args):
		"""
		工厂方法，获取与webapp_user关联的会员订单信息

		@param[in] webapp_user

		@return MemberOrderInfo业务对象
		"""
		order_info = MemberOrderInfo(args['webapp_user'])

		return order_info

	def __init__(self, webapp_user):
		business_model.Model.__init__(self)

		self.context['webapp_user'] = webapp_user
		self.__fill_detail()

	def __get_order_has_product_list_ids(self, webapp_user_id):
		'''
		返回order_has_product_list_ids
		'''
		count = 0
		# 得到用户所有已完成订单
		orders = mall_models.Order.select(mall_models.Order.id).dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_SUCCESSED, origin_order_id__lte=0)

		# 得到用户所以已完成订单中的商品order_has_product.id列表
		orderIds = [order.id for order in orders]
		order_has_product_list_ids = []
		for i in mall_models.OrderHasProduct.select().dj_where(order_id__in=orderIds):
			order_has_product_list_ids.append(str(i.id))
		return order_has_product_list_ids

	# def __get_order_stats_from_db(self, cache_key, webapp_user_id):
	# 	"""
	# 	从数据获取订单统计数据
	# 	"""
	# 	def inner_func():
	# 		#try:
	# 		# TODO2: 需要优化：一次SQL，获取全部数据
	# 		stats = {
	# 			"total_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, origin_order_id__lte=0).count(),
	# 			"not_paid": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_NOT, origin_order_id__lte=0).count(),
	# 			"not_ship_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_PAYED_NOT_SHIP, origin_order_id__lte=0).count(),
	# 			"shiped_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_PAYED_SHIPED, origin_order_id__lte=0).count(),
	# 			"finished_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_SUCCESSED,origin_order_id__lte=0).count(),
	# 			"order_has_product_list_ids": self.__get_order_has_product_list_ids(webapp_user_id)
	# 		}
	# 		ret = {
	# 			'keys': [cache_key],
	# 			'value': stats
	# 		}
	# 		return ret
	# 		#except:
	# 		#return None
	# 	return inner_func


	def __get_stats(self,webapp_user_id):

		stats = {
					"total_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, origin_order_id__lte=0).count(),
					"not_paid": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_NOT, origin_order_id__lte=0).count(),
					"not_ship_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_PAYED_NOT_SHIP, origin_order_id__lte=0).count(),
					"shiped_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_PAYED_SHIPED, origin_order_id__lte=0).count(),
					"finished_count": mall_models.Order.select().dj_where(webapp_user_id=webapp_user_id, status=mall_models.ORDER_STATUS_SUCCESSED,origin_order_id__lte=0).count(),
					"order_has_product_list_ids": self.__get_order_has_product_list_ids(webapp_user_id)
				}
		return stats

	def __get_review_count(self, stats):
		order_has_product_list_ids = stats['order_has_product_list_ids']
		reviewed_count = 0
		if order_has_product_list_ids:
			order_has_product_list_ids_str = "_".join(order_has_product_list_ids)
			param_data = {'order_has_product_list_ids':order_has_product_list_ids_str}
			resp = Resource.use('marketapp_apiserver').get({
				'resource': 'evaluate.get_unreviewd_count',
				'data': param_data
			})

			if resp:
				code = resp["code"]
				if code == 200:
					reviewed_count = resp["data"]['reviewed_count']
		review_count = len(order_has_product_list_ids) - int(reviewed_count)
		return review_count

	def __fill_detail(self):
		"""
		获取会员订单信息的详情
		"""
		webapp_user = self.context['webapp_user']
		# key = "webapp_order_stats_{wu:%d}" % (webapp_user.id)
		# stats = cache_util.get_from_cache(key, self.__get_order_stats_from_db(key, webapp_user.id))
		stats = self.__get_stats(webapp_user.id)

		self.history_order_count = stats['total_count']
		self.not_payed_order_count = stats['not_paid']
		self.not_ship_order_count = stats["not_ship_count"]
		self.shiped_order_count = stats["shiped_count"]
		self.review_count = self.__get_review_count(stats)
		self.finished_count = stats['finished_count']



