# -*- coding: utf-8 -*-
"""@package business.mall.promotion.promotion_repository
促销资源库

"""

#import json
#from bs4 import BeautifulSoup
#import math
from datetime import datetime

from business.mall.realtime_stock import RealtimeStock
from eaglet.decorator import param_required
##from wapi import wapi_utils
#from eaglet.core.cache import utils as cache_util
from db.mall import models as mall_models
from db.mall import promotion_models
#from eaglet.core import watchdog
from business import model as business_model
import settings
from business.mall.promotion.flash_sale import FlashSale
from business.mall.promotion.premium_sale import PremiumSale
from business.mall.promotion.integral_sale import IntegralSale


class PromotionRepository(business_model.Model):
	"""
	促销资源库
	"""
	__slots__ = ()

	@staticmethod
	def __get_promotion_detail_class(promotion_type):
		"""
		获取促销特定数据对应的业务对象的class

		Parameters
			[in] promotion_type: 促销类型

		Returns
			促销特定数据的class（比如FlashSale）
		"""
		DetailClass = None
		if promotion_type == promotion_models.PROMOTION_TYPE_FLASH_SALE:
			DetailClass = promotion_models.FlashSale
		elif promotion_type == promotion_models.PROMOTION_TYPE_PRICE_CUT:
			DetailClass = promotion_models.PriceCut
		elif promotion_type == promotion_models.PROMOTION_TYPE_INTEGRAL_SALE:
			DetailClass = promotion_models.IntegralSale
		elif promotion_type == promotion_models.PROMOTION_TYPE_PREMIUM_SALE:
			DetailClass = promotion_models.PremiumSale
		elif promotion_type == promotion_models.PROMOTION_TYPE_COUPON:
			DetailClass = promotion_models.CouponRule

		return DetailClass

	@staticmethod
	def __fill_integral_sale_rule_details(integral_sales):
		"""
		填充与积分应用相关的`积分应用规则`
		"""
		integral_sale_ids = []
		id2sale = {}
		for integral_sale in integral_sales:
			integral_sale_detail_id = integral_sale.context['detail_id']
			integral_sale.rules = []
			integral_sale_ids.append(integral_sale_detail_id)
			id2sale[integral_sale_detail_id] = integral_sale

		integral_sale_rules = list(promotion_models.IntegralSaleRule.select().dj_where(integral_sale_id__in=integral_sale_ids))
		for integral_sale_rule in integral_sale_rules:
			integral_sale_id = integral_sale_rule.integral_sale_id
			id2sale[integral_sale_id].add_rule(integral_sale_rule)

		for integral_sale in integral_sales:
			integral_sale.calculate_discount()

	@staticmethod
	def __fill_premium_products_details(premium_sales, webapp_owner):
		"""
		填充与限时抢购相关的`促销商品详情`
		"""
		premium_sale_ids = []
		id2sale = {}
		for premium_sale in premium_sales:
			prenium_sale_detail_id = premium_sale.context['detail_id']
			premium_sale.premium_products = []
			premium_sale_ids.append(prenium_sale_detail_id)
			id2sale[prenium_sale_detail_id] = premium_sale

		premium_sale_products = promotion_models.PremiumSaleProduct.select().dj_where(owner_id=webapp_owner.id,premium_sale_id__in=premium_sale_ids)
		product_ids = [premium_sale_product.product_id for premium_sale_product in premium_sale_products]
		
		products = mall_models.Product.select().dj_where(id__in=product_ids)
		
		if webapp_owner.mall_type:
			pool_product_list = [p.product_id for p in  mall_models.ProductPool.select().dj_where(woid=webapp_owner.id, status=mall_models.PP_STATUS_ON)]
		else:
			pool_product_list = []

		id2product = dict([(product.id, product) for product in products])

		for premium_sale_product in premium_sale_products:
			#add by duhao当赠品和主商品不是一个供应商时，需要把赠品的供应商id变为和主商品一样，以便和主商品显示在同一个子订单中
			premium_sale_id = premium_sale_product.premium_sale_id
			promotion = promotion_models.Promotion.get(type=promotion_models.PROMOTION_TYPE_PREMIUM_SALE, detail_id=premium_sale_id)
			product2promotion = promotion_models.ProductHasPromotion.get(promotion=promotion.id)
			main_product = product2promotion.product

			product_id = premium_sale_product.product_id

			realtime_stock = RealtimeStock.from_product_id({
					'product_id': product_id
				})
			realtime_stock_dict = realtime_stock.model2stock.values()[0]

			product = id2product[product_id]

			if pool_product_list and product_id in pool_product_list:
				shelve_type = mall_models.PRODUCT_SHELVE_TYPE_ON
			else:
				shelve_type = product.shelve_type

			data = {
				'id': product.id,
				'name': product.name,
				'thumbnails_url': '%s%s' % (settings.IMAGE_HOST, product.thumbnails_url) if product.thumbnails_url.find('http') == -1 else product.thumbnails_url,
				'original_premium_count': premium_sale_product.count,
				'premium_count': premium_sale_product.count,
				'premium_unit': premium_sale_product.unit,
				'premium_product_id': premium_sale_product.product_id,
				'supplier': main_product.supplier,
				'stock_type': realtime_stock_dict['stock_type'],
				'stocks': realtime_stock_dict['stocks'],
				'shelve_type': shelve_type,
				'is_deleted': product.is_deleted
			}
			id2sale[premium_sale_id].premium_products.append(data)

	@staticmethod
	def __fill_specific_details(promotions, webapp_owner):
		"""
		为促销填充促销特定数据

		Parameters:
			[in, out] promotions: 促销集合

		Note:
			针对不同的促销，会获取不同的促销特定数据的model对象（比如FlashSale），进行填充
		"""
		type2promotions = dict()
		for promotion in promotions:
			type2promotions.setdefault(promotion.type, []).append(promotion)

		for promotion_type, promotions in type2promotions.items():
			#确定detail的Model class
			DetailClass = PromotionRepository.__get_promotion_detail_class(promotion_type)

			#获取specific detail数据
			detail_ids = [promotion.context['detail_id'] for promotion in promotions]
			if DetailClass:
				detail_models = DetailClass.select().dj_where(id__in=detail_ids)
				id2detail = dict([(detail_model.id, detail_model) for detail_model in detail_models])
				for promotion in promotions:
					detail_model = id2detail[promotion.context['detail_id']]
					promotion.fill_specific_detail(detail_model)

				if promotion_type == promotion_models.PROMOTION_TYPE_PREMIUM_SALE:
					PromotionRepository.__fill_premium_products_details(promotions, webapp_owner)
				elif promotion_type == promotion_models.PROMOTION_TYPE_INTEGRAL_SALE:
					PromotionRepository.__fill_integral_sale_rule_details(promotions)
			else:
				raise ValueError('DetailClass(None) is not valid')

	@staticmethod
	@param_required(['products','webapp_owner'])
	def fill_for_products(args):
		webapp_owner = args['webapp_owner']
		webapp_owner_id = webapp_owner.id
		products = args['products']
		today = datetime.today()
		product_ids = []
		id2product = {}
		for product in products:
			product_ids.append(product.id)
			id2product[product.id] = product

		#创建promotions业务对象集合
		#update by bert

		#product_promotion_relations = list(promotion_models.ProductHasPromotion.select().dj_where(product_id__in=product_ids))

		product_promotion_relations = promotion_models.ProductHasPromotion.select().dj_where(product_id__in=product_ids)

		promotion_ids = list()
		promotion2product = dict()
		for relation in product_promotion_relations:
			promotion_ids.append(relation.promotion_id)
			promotion2product[relation.promotion_id] = relation.product_id
		# todo 写法优化
		#promotion_db_models = list(promotion_models.Promotion.select().dj_where(id__in=promotion_ids).where(
		#	promotion_models.Promotion.type != promotion_models.PROMOTION_TYPE_COUPON))
		promotion_db_models = promotion_models.Promotion.select().dj_where(id__in=promotion_ids).where(
			promotion_models.Promotion.type != promotion_models.PROMOTION_TYPE_COUPON)
		promotions = []
		for promotion_db_model in promotion_db_models:
			if (promotion_db_model.status != promotion_models.PROMOTION_STATUS_STARTED) and (promotion_db_model.status != promotion_models.PROMOTION_STATUS_NOT_START):
				#跳过已结束、已删除的促销活动
				continue

			#自营平台商品池商品 参加活动不是当前平台 by bert 
			#TODO bert 优化
			if promotion_db_model.owner_id != webapp_owner_id:
				continue

			if promotion_db_model.type == promotion_models.PROMOTION_TYPE_FLASH_SALE:
				promotion = FlashSale(promotion_db_model)
			if promotion_db_model.type == promotion_models.PROMOTION_TYPE_PREMIUM_SALE:
				promotion = PremiumSale(promotion_db_model)
			if promotion_db_model.type == promotion_models.PROMOTION_TYPE_INTEGRAL_SALE:
				promotion = IntegralSale(promotion_db_model)
			if promotion.is_active():
				promotions.append(promotion)

		PromotionRepository.__fill_specific_details(promotions, webapp_owner)

		#为所有的product设置product.promotion
		for promotion in promotions:
			product_id = promotion2product.get(promotion.id, None)
			if not product_id:
				continue

			product = id2product.get(product_id, None)
			if not product:
				continue

			if promotion.type_name == 'integral_sale':
				product.integral_sale = promotion
			else:
				product.promotion = promotion

	# 目前没人使用～～～～ bert
	# @staticmethod
	# def from_id(promotion_id):
	# 	if promotion_id <= 0:
	# 		return None
			
	# 	promotion_db_model = promotion_models.Promotion.get(id=promotion_id)
	# 	if promotion_db_model.type == promotion_models.PROMOTION_TYPE_FLASH_SALE:
	# 		promotion = FlashSale(promotion_db_model)
	# 	if promotion_db_model.type == promotion_models.PROMOTION_TYPE_PREMIUM_SALE:
	# 		promotion = PremiumSale(promotion_db_model)
	# 	if promotion_db_model.type == promotion_models.PROMOTION_TYPE_INTEGRAL_SALE:
	# 		promotion = IntegralSale(promotion_db_model)
	# 	if not promotion.is_active():
	# 		return None

	# 	PromotionRepository.__fill_specific_details([promotion])

	# 	return promotion

	@staticmethod
	def get_promotion_from_dict_data(data):
		promotion_type = data['type']
		type_name = 'unknown'

		if promotion_type == promotion_models.PROMOTION_TYPE_FLASH_SALE or promotion_type == 'flash_sale':
			DetailClass = FlashSale
		# elif promotion_type == promotion_models.PROMOTION_TYPE_PRICE_CUT:
		# 	DetailClass = promotion_models.PriceCut
		elif promotion_type == promotion_models.PROMOTION_TYPE_INTEGRAL_SALE or promotion_type == 'integral_sale':
		 	DetailClass = IntegralSale
		elif promotion_type == promotion_models.PROMOTION_TYPE_PREMIUM_SALE or promotion_type == 'premium_sale':
		 	DetailClass = PremiumSale
		# elif promotion_type == promotion_models.PROMOTION_TYPE_COUPON:
		# 	DetailClass = promotion_models.CouponRule

		promotion = DetailClass.from_dict(data)

		return promotion
